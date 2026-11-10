# frozen_string_literal: true

module Serializers
  module PatientSerializer
    def self.call(patient)
      {
        id: patient.id,
        nhs_number: patient.nhs_number,
        first_name: patient.first_name,
        last_name: patient.last_name,
        date_of_birth: patient.date_of_birth.to_s,
        address_line_1: patient.address_line_1,
        address_line_2: patient.address_line_2,
        postcode: patient.postcode,
        created_at: patient.created_at.utc.iso8601,
        updated_at: patient.updated_at.utc.iso8601,
      }
    end
  end
end
