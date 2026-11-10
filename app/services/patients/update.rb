# frozen_string_literal: true

module Services
  module Patients
    class Update < Base
      UPDATABLE_ATTRIBUTES = %w[
        first_name last_name date_of_birth
        address_line_1 address_line_2 postcode
      ].freeze

      def initialize(patient, params)
        @patient = patient
        @params = (params || {}).slice(*UPDATABLE_ATTRIBUTES)
      end

      def call
        @patient.set(@params)
        if @patient.valid?
          @patient.save
          success(@patient)
        else
          failure(format_model_errors(@patient))
        end
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end
    end
  end
end
