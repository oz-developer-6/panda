# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:appointments) do
      primary_key :id
      foreign_key :patient_id, :patients, null: false, on_delete: :cascade
      foreign_key :clinician_id, :clinicians, null: false
      DateTime :scheduled_at, null: false
      String :status, null: false, default: "scheduled"
      String :notes
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :patient_id
      index :clinician_id
      index :status
    end
  end
end
