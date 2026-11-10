# frozen_string_literal: true

class Clinician < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  one_to_many :appointments

  def validate
    super
    validates_presence [:name, :department]
  end

  def before_save
    self.name = name.to_s.unicode_normalize(:nfc) if name
    super
  end
end
