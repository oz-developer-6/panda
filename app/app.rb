# frozen_string_literal: true

class App < Roda
  # below I am adding plugins to the application, this way we can keep it lightweight and only have the ones we need
  # this will save us memory, and application will be fast, I also want to mention why I am using roda, rather than ruby on rails
  # roda is a good choise for API backend, as its fast and uses less memory, and its good for MVP. and along with Sequel
  plugin :json
  plugin :json_parser, content_type: 'application/json'
  plugin :halt
  plugin :all_verbs
  plugin :symbol_status

  route do |r|
    r.on "patients" do
      r.is do
        # POST /patients
        r.post do
          result = Services::Patients::Create.call(r.params)
          respond_with(r, result, success_status: 201, serializer: Serializers::PatientSerializer)
        end
      end

      r.on :id do |id|
        patient = Patient.first!(id: id.to_i)

        # GET /patients/:id/appointments
        r.on "appointments" do
          r.is do
            r.get do
              result = Services::Appointments::ListForPatient.call(patient)
              respond_with(r, result, serializer: Serializers::AppointmentSerializer)
            end
          end
        end

        r.is do
          # GET /patients/:id
          r.get do
            Serializers::PatientSerializer.call(patient)
          end

          # PATCH /patients/:id
          r.patch do
            result = Services::Patients::Update.call(patient, r.params)
            respond_with(r, result, serializer: Serializers::PatientSerializer)
          end

          # DELETE /patients/:id
          r.delete do
            result = Services::Patients::Delete.call(patient)
            respond_with(r, result, success_status: 204)
          end
        end
      end
    end

    r.on "clinicians" do
      r.is do
        # POST /clinicians
        r.post do
          result = Services::Clinicians::Create.call(r.params)
          respond_with(r, result, success_status: 201, serializer: Serializers::ClinicianSerializer)
        end
      end

      r.on :id do |id|
        clinician = Clinician.first!(id: id.to_i)

        r.is do
          # GET /clinicians/:id
          r.get do
            Serializers::ClinicianSerializer.call(clinician)
          end

          # PATCH /clinicians/:id
          r.patch do
            result = Services::Clinicians::Update.call(clinician, r.params)
            respond_with(r, result, serializer: Serializers::ClinicianSerializer)
          end
        end
      end
    end

    r.on "appointments" do
      r.is do
        # POST /appointments
        r.post do
          result = Services::Appointments::Create.call(r.params)
          respond_with(r, result, success_status: 201, serializer: Serializers::AppointmentSerializer)
        end
      end

      r.on :id do |id|
        appt = Appointment.first!(id: id.to_i)
        appt.sync_missed_status!

        r.is do
          # GET /appointments/:id
          r.get do
            Serializers::AppointmentSerializer.call(appt)
          end

          # PATCH /appointments/:id
          r.patch do
            result = Services::Appointments::Update.call(appt, r.params)
            respond_with(r, result, serializer: Serializers::AppointmentSerializer)
          end
        end
      end
    end

    r.on "stats" do
      r.on "missed" do
        r.is do
          # GET /stats/missed
          r.get do
            result = Services::Stats::MissedReport.call(r.params)
            respond_with(r, result)
          end
        end
      end
    end
  end

  private

   # This is error handling, I can have sanitize of error messages in here, or in the format_errors
  plugin :error_handler do |e|
    response.status = case e
                      when Sequel::NoMatchingRow then 404
                      when Sequel::ValidationFailed then 422
                      else 500
                      end
    { errors: format_errors(e) }
  end

  def format_errors(e)
    case e
    when Sequel::ValidationFailed
      e.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten
      # in here, we can have an allowed list of fields, or forbidden list of fields, that we want to obfuscate
    when Sequel::NoMatchingRow
      [I18n.t("errors.not_found", resource: "Resource")]
    else
      [e.message] # in here we can sanitize the error message, to not give out any sensitive information, like patient name, id
    end
  end

  def respond_with(r, result, success_status: 200, serializer: nil)
    if result.success?
      response.status = result.status || success_status
      if serializer && result.data
        if result.data.is_a?(Array)
          result.data.map { |item| serializer.call(item) }
        else
          serializer.call(result.data)
        end
      else
        result.data || ""
      end
    else
      r.halt(result.status, { errors: result.errors }.to_json)
    end
  end

end
