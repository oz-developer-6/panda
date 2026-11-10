# frozen_string_literal: true

module Serializers
  module ClinicianSerializer
    def self.call(clinician)
      {
        id: clinician.id,
        name: clinician.name,
        department: clinician.department,
        created_at: clinician.created_at.utc.iso8601,
        updated_at: clinician.updated_at.utc.iso8601,
      }
    end
  end
end
