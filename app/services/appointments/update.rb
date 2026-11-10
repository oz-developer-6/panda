# frozen_string_literal: true

module Services
  module Appointments
    class Update < Base
      def initialize(appointment, params)
        @appointment = appointment
        @params = params || {}
      end

      def call
        current = @appointment.effective_status

        # Missed appointments cannot be changed
        if current == "missed"
          return failure(I18n.t("errors.cannot_modify_terminal", status: "missed"))
        end

        # Cancelled appointments can not be changed
        if @appointment.status == "cancelled"
          if @params.key?("status")
            return failure(I18n.t("errors.cannot_reinstate"))
          else
            return failure(I18n.t("errors.cannot_modify_terminal", status: "cancelled"))
          end
        end

        # validation
        if @params.key?("status")
          new_status = @params["status"]
          allowed = Appointment::ALLOWED_TRANSITIONS[current] || []
          unless allowed.include?(new_status)
            return failure(I18n.t("errors.invalid_status_transition", from: current, to: new_status))
          end
        end

        # Date validation
        update_attributes = {}
        if @params.key?("scheduled_at")
          scheduled_at = parse_scheduled_at(@params["scheduled_at"])
          return failure(I18n.t("errors.invalid_date", field: "scheduled_at")) if scheduled_at.nil?
          update_attributes[:scheduled_at] = scheduled_at
        end

        update_attributes[:status] = @params["status"] if @params.key?("status")
        update_attributes[:notes] = @params["notes"] if @params.key?("notes")
        update_attributes[:clinician_id] = @params["clinician_id"].to_i if @params.key?("clinician_id")

        @appointment.update(update_attributes)
        @appointment.refresh
        success(@appointment)
      rescue Sequel::ValidationFailed => e
        failure(e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten)
      end

      private

      def parse_scheduled_at(val)
        return nil if val.nil? || val.to_s.strip.empty?
        Time.parse(val.to_s).utc
      rescue ArgumentError, TypeError
        nil
      end
    end
  end
end
