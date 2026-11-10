# frozen_string_literal: true

module Serializers
  module AppointmentSerializer
    def self.call(appointment)
      {
        id: appointment.id,
        patient_id: appointment.patient_id,
        clinician_id: appointment.clinician_id,
        scheduled_at: appointment.scheduled_at.utc.iso8601,
        status: appointment.effective_status,
        notes: appointment.notes,
        created_at: appointment.created_at.utc.iso8601,
        updated_at: appointment.updated_at.utc.iso8601,
      }
    end
  end
end
