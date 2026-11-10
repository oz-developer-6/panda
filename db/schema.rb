# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:clinicians) do
      primary_key :id
      String :name, size: 255, null: false
      String :department, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    
    create_table(:patients, ignore_index_errors: true) do
      primary_key :id
      String :nhs_number, size: 10, null: false
      String :first_name, size: 255, null: false
      String :last_name, size: 255, null: false
      Date :date_of_birth, null: false
      String :address_line_1, size: 255, null: false
      String :address_line_2, size: 255
      String :postcode, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      
      index [:nhs_number], name: :sqlite_autoindex_patients_1, unique: true
    end
    
    create_table(:schema_info) do
      Integer :version, default: 0, null: false
    end
    
    create_table(:appointments, ignore_index_errors: true) do
      primary_key :id
      foreign_key :patient_id, :patients, null: false, on_delete: :cascade
      foreign_key :clinician_id, :clinicians, null: false
      DateTime :scheduled_at, null: false
      String :status, default: "scheduled", size: 255, null: false
      String :notes, size: 255
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      
      index [:clinician_id]
      index [:patient_id]
      index [:status]
    end
  end
end
