# frozen_string_literal: true

require "spec_helper"

RSpec.describe Validators::Postcode do
  describe ".normalize" do
    it "accepts already formatted postcodes" do
      expect(described_class.normalize("CW12 3LY")).to eq("CW12 3LY")
    end

    it "removes hyphens in postcodes" do
      expect(described_class.normalize("CW12-3LY")).to eq("CW12 3LY")
      expect(described_class.normalize("CW12 - 3LY")).to eq("CW12 3LY")
      expect(described_class.normalize("cw12-3ly")).to eq("CW12 3LY")
    end

    # this is a known case for UK postcodes
    it "handles Girobank postcode GIR 0AA" do
      expect(described_class.normalize("GIR0AA")).to eq("GIR 0AA")
      expect(described_class.normalize("GIR 0AA")).to eq("GIR 0AA")
    end

    it "turns lowercase postcodes as uppercase" do
      expect(described_class.normalize("cw12 3ly")).to eq("CW12 3LY")
      expect(described_class.normalize("cw123ly")).to eq("CW12 3LY")
    end

    it "trims whitespaces in a postcode" do
      expect(described_class.normalize("  CW12  3LY  ")).to eq("CW12 3LY")
    end

    it "adds a space to a postcode, when there isn't one" do
      expect(described_class.normalize("CW123LY")).to eq("CW12 3LY")
    end


    it "returns nil for invalid postcode" do
      expect(described_class.normalize("INVALIDPOSTCODE")).to be_nil
    end
  end

  describe ".valid?" do
    it "returns true for valid formatted postcodes" do
      expect(described_class.valid?("CW12 3LY")).to be true
      expect(described_class.valid?("GIR 0AA")).to be true
      expect(described_class.valid?("M23 3ZJ")).to be true
    end

    it "returns false for invalid postcodes" do
      expect(described_class.valid?("TownCentre")).to be false
      expect(described_class.valid?("12345")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end
end
