# frozen_string_literal: true

require "spec_helper"

RSpec.describe Validators::NhsNumber do
  describe ".valid?" do
    it "validates the correct NHS numbers" do # generated on `https://data-gorilla.uk/en/healthcare/nhs-number/`
      %w[2123875902 9305028969 2805586123].each do |num|
        expect(described_class.valid?(num)).to be true
      end
    end

    it "does not passfor invalid NHS numbers" do
      expect(described_class.valid?("2805586124")).to be false
      expect(described_class.valid?("9305048969")).to be false
      expect(described_class.valid?("4123875902")).to be false
    end

    it "finds the letters" do
      expect(described_class.valid?("ABCDEFGHIJ")).to be false
    end

    it "fails the missing digits, when number is short" do
      expect(described_class.valid?("123456789")).to be false
    end

    it "fails the extra digits, when number is long" do
      expect(described_class.valid?("12345678901")).to be false
    end

    it "validates numbers with spaces" do
      expect(described_class.valid?("325 310 8015")).to be true
    end

    it "removes spaces before validating" do
      expect(described_class.normalize("025 332 2049")).to eq("0253322049")
    end
  end
end

