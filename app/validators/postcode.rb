# frozen_string_literal: true

module Validators
  module Postcode
   # I am using the regex from here `https://github.com/stemount/gov-uk-official-postcode-regex-helper`
   # Alternatively, I can use a gem called `uk_postcode` however this would have introduced another dependency
   # and that dependecy can have CVEs or other security propblems, which will require me to maintain, so a regex
   # is a simpler solution in here. I know the regex is ugly to look at, thats why i provided the above link
   # to where I got it from, so we can look at there to understand what its doing. but again this is MVP, so I am
   # avoiding to introduce a gem and this is a well known tested regex for uk postcodes

   # Also alternatviely, I could use the CSVs from here `https://ideal-postcodes.co.uk/guides/uk-postcode-format` and check
   # against it, but again regex is working here so these are all alternatives that can be discussed, as for example
   # new build houses that get new postcodes, wont appear in the CSV, unless we keep updating it, these are all points to discuss
    POSTCODE_REGEX = /\A(?:([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z])))) [0-9][A-Za-z]{2}))\z/i.freeze

    def self.valid?(postcode)
      return false if postcode.nil?

      !!(postcode.to_s.strip =~ POSTCODE_REGEX)
    end

    def self.normalize(postcode)
      return nil if postcode.nil?

      # again in here, we could either use the uk_postcode gem, or go with more of a regex to do the clean up
      # or go with adding other chars like forward slash, #, dot, etc to the clean up, but as this is MVP
      # I am keeping it light 
      spaces_removed = postcode.to_s.delete(" ")
      hypens_removed = spaces_removed.delete("-")

      cleaned_postcode = hypens_removed.upcase
      # check if after the spaces are removed, the postcode has valid UK postcode length
      return nil if cleaned_postcode.length < 5 || cleaned_postcode.length > 7


      # I am formatting the postcode, because the requriement is the UI might not do this. And also we can save a clean
      # format to the database, which will help in regards with searching later on, like we can search the first part etc.
      formatted = "#{cleaned_postcode[0...-3]} #{cleaned_postcode[-3..]}"
      formatted if valid?(formatted)
    end
  end
end
