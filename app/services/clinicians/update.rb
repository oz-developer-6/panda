# frozen_string_literal: true

module Services
  module Clinicians
    class Update < Base
      UPDATABLE_ATTRIBUTES = %w[name department].freeze

      def initialize(clinician, params)
        @clinician = clinician
        @params = (params || {}).slice(*UPDATABLE_ATTRIBUTES)
      end

      def call
        @clinician.set(@params)
        if @clinician.valid?
          @clinician.save
          success(@clinician)
        else
          failure(format_model_errors(@clinician))
        end
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end
    end
  end
end
