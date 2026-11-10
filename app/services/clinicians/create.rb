# frozen_string_literal: true

module Services
  module Clinicians
    class Create < Base
      ALLOWED_ATTRIBUTES = %w[name department].freeze

      def initialize(params)
        @params = (params || {}).slice(*ALLOWED_ATTRIBUTES)
      end

      def call
        clinician = Clinician.new(@params)
        if clinician.valid?
          clinician.save
          success(clinician, status: 201)
        else
          failure(format_model_errors(clinician))
        end
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end
    end
  end
end
