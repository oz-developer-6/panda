# frozen_string_literal: true

module Services
  module Patients
    class Create < Base
      ALLOWED_ATTRIBUTES = %w[
        nhs_number first_name last_name date_of_birth
        address_line_1 address_line_2 postcode
      ].freeze

      def initialize(params)
        @params = (params || {}).slice(*ALLOWED_ATTRIBUTES)
      end

      def call
        patient = Patient.new(@params)
        if patient.valid?
          patient.save
          success(patient, status: 201)
        else
          failure(format_model_errors(patient))
        end
      rescue Sequel::UniqueConstraintViolation
        failure(I18n.t("errors.nhs_number_taken"))
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end
    end
  end
end
