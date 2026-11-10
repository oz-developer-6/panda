# frozen_string_literal: true

module Services
  module Appointments
    class Create < Base
      def initialize(params)
        @params = params || {}
      end

      def call
        scheduled_at = parse_scheduled_at(@params["scheduled_at"])
        return failure(I18n.t("errors.invalid_date", field: "scheduled_at")) if scheduled_at.nil?

        appt = Appointment.new(
          patient_id: @params["patient_id"].to_i,
          clinician_id: @params["clinician_id"].to_i,
          scheduled_at: scheduled_at,
          status: "scheduled", # I am hardcoding this because we want this to be default
          notes: @params["notes"]
        )

        if appt.valid?
          appt.save
          success(appt, status: 201)
        else
          failure(format_model_errors(appt))
        end
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end

      private

      def parse_scheduled_at(val)
        return nil if val.nil? || val.to_s.strip.empty? # it can be null or empty string or whitespace
        Time.parse(val.to_s).utc
      rescue ArgumentError, TypeError
        nil
      end
    end
  end
end
