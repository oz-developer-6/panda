# frozen_string_literal: true

require "spec_helper"

require "active_support"
require "active_support/core_ext/integer/time"

RSpec.describe "Appointment" do
  let(:patient) { create_patient }
  let(:clinician) { create_clinician }

  let(:valid_params) do
    {
      patient_id: patient.id,
      clinician_id: clinician.id,
      scheduled_at: (1.day.from_now).iso8601,
      notes: "First meeting and consultation"
    }
  end

  describe "POST /appointments" do
    it "creates the appointment" do
      post "/appointments", valid_params.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(201)
      body = json_body
      expect(body[:status]).to eq("scheduled")
      expect(body[:scheduled_at]).to match(1.day.from_now.iso8601[0..9])
    end

    it "validates scheduled at" do
      post "/appointments", valid_params.merge(scheduled_at: "invalid").to_json,
           { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
    end
  end

  describe "GET /appointments/:id" do
    it "get the appointment" do
      appt = create_appointment(patient: patient, clinician: clinician)
      get "/appointments/#{appt.id}"
      expect(last_response.status).to eq(200)
      expect(json_body[:id]).to eq(appt.id)
    end

    it "does not get the appointment when id is wrong" do
      get "/appointments/12390048"
      expect(last_response.status).to eq(404)
    end
  end

  describe "PATCH /appointments/:id - status transitions" do
    it "updates the scheduled appointment" do
      appt = create_appointment(patient: patient, clinician: clinician)
      patch "/appointments/#{appt.id}", { status: "attended" }.to_json,
            { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      expect(json_body[:status]).to eq("attended")
    end

    it "cannot activate the canncelled appointment" do
      appt = create_appointment(patient: patient, clinician: clinician,
                                attrs: { status: "cancelled" })
      patch "/appointments/#{appt.id}", { status: "scheduled" }.to_json,
            { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
      expect(json_body[:errors].first).to include("cancelled")
    end

    it "marks passed appointment as missed" do
      Timecop.freeze(Time.now.utc - 2.hours.ago.utc) do
        appt = create_appointment(patient: patient, clinician: clinician,
                                  attrs: { scheduled_at: 1.hour.ago.utc })
        get "/appointments/#{appt.id}"
        expect(last_response.status).to eq(200)
        expect(json_body[:status]).to eq("missed")
      end
    end

    it "does not update a missed appointment" do
      Timecop.freeze(Time.now.utc - 2.hours.ago.utc) do
        past = 1.hour.ago.utc
        appt = create_appointment(patient: patient, clinician: clinician,
                                  attrs: { scheduled_at: past })
        # Force sync
        appt.sync_missed_status!
        patch "/appointments/#{appt.id}", { notes: "updated" }.to_json,
              { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eq(422)
      end
    end
  end

end
