# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Patients API" do
  describe "POST /patients" do
    let(:valid_params) do
      {
        nhs_number: "212 387 5902",
        first_name: "John",
        last_name: "Doe",
        date_of_birth: "1980-01-15",
        address_line_1: "123 Test St",
        postcode: "CW1 23LY"
      }
    end

    it "creates a patient" do
      post "/patients", valid_params.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(201)
      body = json_body
      expect(body[:nhs_number]).to eq("2123875902")
      expect(body[:postcode]).to eq("CW12 3LY")
    end

    it "does not create when NHS number not valid" do
      post "/patients", valid_params.merge(nhs_number: "1234567890").to_json,
           { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
      expect(json_body[:errors]).not_to be_empty
    end

    it "does not create when postcode is not valid" do
      post "/patients", valid_params.merge(postcode: "wrongPostCode").to_json,
           { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
    end

    it "does not process the duplicate NHS number" do
      create_patient
      post "/patients", valid_params.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
    end

    it "validates required fields" do
      post "/patients", { nhs_number: "9434765919" }.to_json,
           { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(422)
    end
  end

  describe "GET /patients/:id" do
    it "gets the patient" do
      patient = create_patient
      get "/patients/#{patient.id}"
      expect(last_response.status).to eq(200)
      expect(json_body[:id]).to eq(patient.id)
      expect(json_body[:nhs_number]).to eq(patient.nhs_number)
    end

    it "does not find the patientt" do
      get "/patients/8902302"
      expect(last_response.status).to eq(404)
    end
  end

  describe "PATCH /patients/:id" do
    it "updates the patient" do
      patient = create_patient
      patch "/patients/#{patient.id}", { first_name: "New name" }.to_json,
            { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      expect(json_body[:first_name]).to eq("New name")
    end

    it "formats the postcode" do
      patient = create_patient
      patch "/patients/#{patient.id}", { postcode: "ec1a1bb" }.to_json,
            { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      expect(json_body[:postcode]).to eq("EC1A 1BB")
    end
  end

  describe "DELETE /patients/:id" do
    it "deletes a patient with no appointments" do
      patient = create_patient
      delete "/patients/#{patient.id}"
      expect(last_response.status).to eq(204)
    end

    it "does not delete a patient with appointments" do
      patient = create_patient
      clinician = create_clinician
      create_appointment(patient: patient, clinician: clinician)
      delete "/patients/#{patient.id}"
      expect(last_response.status).to eq(422)
    end
  end

  describe "GET /patients/:id/appointments" do
    it "returns patient appointments" do
      patient = create_patient
      clinician = create_clinician
      create_appointment(patient: patient, clinician: clinician)
      get "/patients/#{patient.id}/appointments"
      expect(last_response.status).to eq(200)
      expect(json_body).to be_an(Array)
      expect(json_body.length).to eq(1)
    end
  end
end
