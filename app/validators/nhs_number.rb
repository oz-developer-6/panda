# frozen_string_literal: true

module Validators
  module NhsNumber

    # if we are to build a UI for this application, I would follow this guide from NHS
    # https://service-manual.nhs.uk/design-system/patterns/ask-for-nhs-numbers

    # NHS number checked with the rules in here `https://www.datadictionary.nhs.uk/attributes/nhs_number.html
    WEIGHTS = [10, 9, 8, 7, 6, 5, 4, 3, 2].freeze

    def self.valid?(number)
      digits = number.to_s.gsub(/\s/, "")
      return false unless digits.match?(/\A\d{10}\z/)

      weighted_sum = digits[0..8].chars.each_with_index.sum do |d, i|
        d.to_i * WEIGHTS[i]
      end

      check_digit = 11 - weighted_sum % 11

      return false if check_digit == 10
      check_digit = 0 if check_digit == 11

      check_digit == digits[9].to_i
    end

    def self.normalize(number)
      number.to_s.gsub(/\s/, "")
    end
  end
end
