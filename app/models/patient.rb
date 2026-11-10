# frozen_string_literal: true

class Patient < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  one_to_many :appointments

  VALID_STATUSES = %w[scheduled attended missed cancelled].freeze

  def validate
    super
    validates_presence [:first_name, :last_name, :date_of_birth, :nhs_number, :address_line_1, :postcode]

    if nhs_number
      normalized = Validators::NhsNumber.normalize(nhs_number)
      unless Validators::NhsNumber.valid?(normalized)
        errors.add(:nhs_number, I18n.t("errors.invalid_nhs_number"))
      end
    end

    if postcode
      normalized = Validators::Postcode.normalize(postcode)
      if normalized.nil?
        errors.add(:postcode, I18n.t("errors.invalid_postcode"))
      end
    end
  end

  def before_save
    # Normalize fields, this is where we keep our database clean so we dont add bad data to it
    self.nhs_number = Validators::NhsNumber.normalize(nhs_number) if nhs_number
    self.postcode = Validators::Postcode.normalize(postcode) if postcode
    # Unicode NFC normalization for GDPR name
    self.first_name = first_name.to_s.unicode_normalize(:nfc) if first_name
    self.last_name = last_name.to_s.unicode_normalize(:nfc) if last_name
    super
  end

  def before_destroy
    # this is where I check if patient has appointments, we can do this in active-record with dependent restrict_with_error
    if appointments_dataset.count > 0
      errors.add(:base, I18n.t("errors.patient_has_appointments"))
      cancel_action
    end
    super
  end
end
