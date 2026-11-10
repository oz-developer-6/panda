# frozen_string_literal: true

module Services
  module Appointments
    class ListForPatient < Base
      def initialize(patient)
        @patient = patient
      end

      def call
        appointments = @patient.appointments_dataset.all
        appointments.each(&:sync_missed_status!) # this would usually not be done here, it would be a cron job to check every day for missing appointments
        success(appointments)
      end
    end
  end
end
