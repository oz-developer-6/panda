# frozen_string_literal: true

class Appointment < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  VALID_STATUSES = %w[scheduled attended missed cancelled].freeze
  TERMINAL_STATUSES = %w[cancelled missed].freeze
  ALLOWED_TRANSITIONS = {
    "scheduled" => %w[attended cancelled],
  }.freeze

  many_to_one :patient
  many_to_one :clinician

  def validate
    super
    validates_presence [:patient_id, :clinician_id, :scheduled_at]
    validates_includes VALID_STATUSES, :status, message: "must be one of: #{VALID_STATUSES.join(', ')}"
  end


  # If scheduled time is passed and not attended this is now missed
  def effective_status
    return status if status != "scheduled" # it will return if attended, and will keep that same status

    if scheduled_at && scheduled_at < Time.now.utc
      "missed"
    else
      "scheduled"
    end
  end

  # Persist missed status to DB, this ideally will be on a sidekiq job, that runs daily to mark the missed appointments, but for mvp, I am setting it as soon as we call it
  def sync_missed_status!
    if effective_status == "missed" && status == "scheduled"
      update(status: "missed")
    end
  end

  def before_update
    # dont update cancelled appointments
    if status_changed? && status_was == "cancelled"
      errors.add(:status, I18n.t("errors.cannot_reinstate"))
      cancel_action
    end
    super
  end

  private

  def status_changed?
    changed_columns.include?(:status)
  end

  def status_was
    # actial original value from the DB
    self.class.first(id: id)&.status
  end
end
