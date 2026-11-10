# frozen_string_literal: true

module Services
  module Patients
    class Delete < Base
      def initialize(patient)
        @patient = patient
      end

      def call
        if @patient.appointments_dataset.count > 0
          return failure(I18n.t("errors.patient_has_appointments"))
        end

        # we can choose to do a soft delete here instead, which would be a patient.set(deleted_at: Time.now.utc)
        @patient.destroy
        success(nil, status: 204)
      rescue Sequel::HookFailed, Sequel::ValidationFailed
        failure(I18n.t("errors.patient_has_appointments"))
      end
    end
  end
end
