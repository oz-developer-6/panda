# frozen_string_literal: true

require "spec_helper"
require "active_support"
require "active_support/core_ext/integer/time"

RSpec.describe "Stats API" do
  let(:clinician1) { create_clinician(name: "Dr Ozgur", department: "Cardiology") }
  let(:clinician2) { create_clinician(name: "Dr John", department: "GP") }
  let(:patient) { create_patient }

  before do
    # missed appointments
    Appointment.create(patient_id: patient.id, clinician_id: clinician1.id, scheduled_at: 2.hours.ago, status: "missed")
    Appointment.create(patient_id: patient.id, clinician_id: clinician1.id, scheduled_at: 3.hours.ago, status: "missed")
    Appointment.create(patient_id: patient.id, clinician_id: clinician2.id, scheduled_at: 2.hours.ago, status: "missed")
  end

  describe "GET /stats/missed" do
    it "gets the total missed appointments" do
      get "/stats/missed"
      expect(last_response.status).to eq(200)
      expect(json_body[:total_missed]).to eq(3)
    end

    it "filters by department name" do
      get "/stats/missed?department=GP"
      expect(last_response.status).to eq(200)
      expect(json_body[:total_missed]).to eq(1)
    end

    it "applies date filtering" do
      future_time = (1.minute.from_now).iso8601
      get "/stats/missed?to=#{future_time}"
      expect(last_response.status).to eq(200)
      expect(json_body[:total_missed]).to eq(3)
    end

    it "filters the missed appointments by clinician" do
      get "/stats/missed?clinician_id=#{clinician1.id}"
      expect(last_response.status).to eq(200)
      expect(json_body[:total_missed]).to eq(2)
    end
  end
end
