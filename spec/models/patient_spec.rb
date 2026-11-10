# frozen_string_literal: true

require "spec_helper"

RSpec.describe Patient do
  describe "validations" do
    it "is validated" do
      patient = Patient.new(
        nhs_number: "2805586123",
        first_name: "Ozgur",
        last_name: "Tezel",
        date_of_birth: Date.new(1980, 1, 15),
        address_line_1: "13 Royal Street",
        postcode: "CW12 3LY"
      )
      expect(patient.valid?).to be true
    end

    it "requires nhs_number" do
      patient = Patient.new(first_name: "Ozgur", last_name: "Tezel",
                            date_of_birth: Date.today, address_line_1: "13 royal street", postcode: "CW12 3LY")
      expect(patient.valid?).to be false
    end

    it "requires valid NHS number" do
      patient = Patient.new(nhs_number: "1234567890", first_name: "Ozgur",
                            last_name: "Tezel", date_of_birth: Date.today,
                            address_line_1: "123 St", postcode: "CW12 3LY")
      expect(patient.valid?).to be false
      expect(patient.errors[:nhs_number]).not_to be_empty
    end

    it "dont accept invalid postcode" do
      patient = Patient.new(nhs_number: "2805586123", first_name: "Ozgur",
                            last_name: "Tezel", date_of_birth: Date.today,
                            address_line_1: "123 St", postcode: "not_a_postcode")
      expect(patient.valid?).to be false
      expect(patient.errors[:postcode]).not_to be_empty
    end
  end

  describe "normalization" do
    it "remove spaces from NHS number" do
      patient = create_patient(nhs_number: "943 476 5919")
      expect(patient.nhs_number).to eq("9434765919")
    end

    it "makes postcode to uppercase and adds a space" do
      patient = create_patient(postcode: "cw123ly")
      expect(patient.postcode).to eq("CW12 3LY")
    end


  end
end
