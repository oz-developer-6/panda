# frozen_string_literal: true

module Services
  module Stats
    class MissedReport < Base
      def initialize(params)
        @params = params || {}
      end

      def call
        from_time = Time.parse(@params["from"]).utc if @params["from"]
        to_time = Time.parse(@params["to"]).utc if @params["to"]

        query = Appointment.where(Sequel[:appointments][:status] => "missed")
        query = query.where(Sequel[:appointments][:clinician_id] => @params["clinician_id"].to_i) if @params["clinician_id"]
        query = query.join(:clinicians, id: :clinician_id).where(Sequel[:clinicians][:department] => @params["department"]) if @params["department"]
        query = query.where(Sequel[:appointments][:scheduled_at] >= from_time) if from_time
        query = query.where(Sequel[:appointments][:scheduled_at] <= to_time) if to_time

        total = query.count

        by_clinician = DB[:appointments]
          .join(:clinicians, id: :clinician_id)
          .where(Sequel[:appointments][:status] => "missed")
          .then { |q| @params["department"] ? q.where(Sequel[:clinicians][:department] => @params["department"]) : q }
          .then { |q| from_time ? q.where(Sequel[:appointments][:scheduled_at] >= from_time) : q }
          .then { |q| to_time ? q.where(Sequel[:appointments][:scheduled_at] <= to_time) : q }
          .select(
            Sequel[:clinicians][:id].as(:clinician_id),
            Sequel[:clinicians][:name],
            Sequel[:clinicians][:department],
            Sequel.function(:count, Sequel[:appointments][:id]).as(:missed_count)
          )
          .group(Sequel[:clinicians][:id])
          .all

        by_department = DB[:appointments]
          .join(:clinicians, id: :clinician_id)
          .where(Sequel[:appointments][:status] => "missed")
          .then { |q| from_time ? q.where(Sequel[:appointments][:scheduled_at] >= from_time) : q }
          .then { |q| to_time ? q.where(Sequel[:appointments][:scheduled_at] <= to_time) : q }
          .select(
            Sequel[:clinicians][:department],
            Sequel.function(:count, Sequel[:appointments][:id]).as(:missed_count)
          )
          .group(Sequel[:clinicians][:department])
          .all

        report = {
          total_missed: total,
          by_clinician: by_clinician.map do |row|
            {
              clinician_id: row[:clinician_id],
              name: row[:name],
              department: row[:department],
              missed_count: row[:missed_count]
            }
          end,
          by_department: by_department.map do |row|
            {
              department: row[:department],
              missed_count: row[:missed_count]
            }
          end
        }

        success(report)
      end
    end
  end
end
