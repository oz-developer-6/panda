# frozen_string_literal: true

require "spec_helper"
require "active_support"
require "active_support/core_ext/integer/time"

RSpec.describe Appointment do
  let(:patient) { create_patient }
  let(:clinician) { create_clinician }

  describe "#effective_status" do
    it "sets status to scheduled for not missed appointments" do
      appt = Appointment.new(
        patient_id: patient.id,
        clinician_id: clinician.id,
        scheduled_at: 1.hour.from_now,
        status: "scheduled"
      )
      expect(appt.effective_status).to eq("scheduled")
    end

    it "assigns missed for past appointments" do
      appt = Appointment.new(
        patient_id: patient.id,
        clinician_id: clinician.id,
        scheduled_at: 1.hour.ago,
        status: "scheduled"
      )
      expect(appt.effective_status).to eq("missed")
    end

    it "attended for attended appointments" do
      appt = Appointment.new(
        patient_id: patient.id,
        clinician_id: clinician.id,
        scheduled_at: 5.hours.ago,
        status: "attended"
      )
      expect(appt.effective_status).to eq("attended")
    end

    it "is cancelled for cancelled appointments" do
      appt = Appointment.new(
        patient_id: patient.id,
        clinician_id: clinician.id,
        scheduled_at: 2.hours.from_now,
        status: "cancelled"
      )
      expect(appt.effective_status).to eq("cancelled")
    end
  end
end
