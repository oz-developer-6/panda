# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:patients) do
      primary_key :id
      String :nhs_number, null: false, unique: true, size: 10
      String :first_name, null: false
      String :last_name, null: false
      Date :date_of_birth, null: false
      String :address_line_1, null: false
      String :address_line_2
      String :postcode, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
