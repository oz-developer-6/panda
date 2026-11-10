# frozen_string_literal: true

require "spec_helper"

RSpec.describe Services do
  let(:valid_patient_params) do
    {
      "nhs_number" => "9434 765 919",
      "first_name" => "Jenny",
      "last_name" => "Energizer",
      "date_of_birth" => "1980-01-15",
      "address_line_1" => "2 River Street",
      "postcode" => "CW12 3LY"
    }
  end

  describe Services::Patients::Create do
    it "creates a patient" do
      result = described_class.call(valid_patient_params)
      expect(result.success?).to be true
      expect(result.data).to be_a(Patient)
      expect(result.data.nhs_number).to eq("9434765919")
    end

    it "does not create a patient if NHS number not valid" do
      result = described_class.call(valid_patient_params.merge("nhs_number" => "1234567890"))
      expect(result.failure?).to be true
      expect(result.errors).not_to be_empty
    end

    it "gives an error when duplicate NHS number" do
      create_patient(nhs_number: "9434765919")
      result = described_class.call(valid_patient_params)
      expect(result.failure?).to be true
      expect(result.errors.first).to eq(I18n.t("errors.nhs_number_taken"))
    end
  end

  describe Services::Patients::Update do
    it "updates patient" do
      patient = create_patient
      result = described_class.call(patient, { "first_name" => "edited name" })
      expect(result.success?).to be true
      expect(patient.first_name).to eq("edited name")
    end
  end

  describe Services::Patients::Delete do
    it "deletes patient when there is no appointments" do
      patient = create_patient
      result = described_class.call(patient)
      expect(result.success?).to be true
      expect(result.status).to eq(204)
      expect(Patient[patient.id]).to be_nil
    end

    it "does not delete patient with appointments" do
      patient = create_patient
      clinician = create_clinician
      create_appointment(patient: patient, clinician: clinician)

      result = described_class.call(patient)
      expect(result.failure?).to be true
      expect(result.errors).not_to be_empty
      expect(Patient[patient.id]).not_to be_nil
    end
  end

  describe Services::Appointments::Create do
    let(:patient) { create_patient }
    let(:clinician) { create_clinician }

    it "creates an appointment" do
      result = described_class.call({
        "patient_id" => patient.id,
        "clinician_id" => clinician.id,
        "scheduled_at" => (Time.now.utc + 3600).iso8601,
        "notes" => "new appointment"
      })
      expect(result.success?).to be true
      expect(result.data.status).to eq("scheduled")
    end

    it "does not create when no date provided" do
      result = described_class.call({
        "patient_id" => patient.id,
        "clinician_id" => clinician.id,
        "scheduled_at" => "invalid-date"
      })
      expect(result.failure?).to be true
      expect(result.errors.first).to include("scheduled_at")
    end
  end

  describe Services::Appointments::Update do
    let(:patient) { create_patient }
    let(:clinician) { create_clinician }

    it "updates the appointment from scheduled to attended" do
      appt = create_appointment(patient: patient, clinician: clinician)
      result = described_class.call(appt, { "status" => "attended" })
      expect(result.success?).to be true
      expect(appt.status).to eq("attended")
    end

    it "does not create a cancelled appointment" do
      appt = create_appointment(patient: patient, clinician: clinician, attrs: { status: "cancelled" })
      result = described_class.call(appt, { "status" => "scheduled" })
      expect(result.failure?).to be true
      expect(result.errors.first).to eq(I18n.t("errors.cannot_reinstate"))
    end

    it "does not modify when appoitnment is missed" do
      past = Time.now.utc - 3600
      appt = create_appointment(patient: patient, clinician: clinician, attrs: { scheduled_at: past })
      appt.sync_missed_status!

      result = described_class.call(appt, { "notes" => "update" })
      expect(result.failure?).to be true
      expect(result.errors.first).to eq(I18n.t("errors.cannot_modify_terminal", status: "missed"))
    end
  end
end
