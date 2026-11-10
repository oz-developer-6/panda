# PANDA (Patient Appointment Network Data Application)

Ruby REST API backend for tracking patient demographics and appointments

Patients can be added, retrieved, updated, and deleted
Patients route also filters by id, and that way we can reach to appointments, and as we provide the id of the patient, we can only access that patient's appointments. This is important so we dont leak data from one patient to another.

I have added a simple clinicians service as well, to add and edit clinicians, no delete as this is only for the MVP, we can get the clinicians from another system, api etc. and thats very common in NHS environment, we can even get that information from two-three different sources, same for patients as well. 

Then we have appointments, which we can add, get and update an appointment, the endpoint on this is very open, as
it just expects an appointment id, and this is ok for MVP, but in real system, this endpoint will most likely require administrator rights, and also patient_id I would say to lock it down to patient, or at least will get the clinicians id from the jwt token or claims etc, to only surface the allowed patients for that clinician. For this reason I have a separate patient/:id/appointments route, which wont require an administration right, but will only display the logged in patient's appointments, again in the real application the :id, will most likely come from the jwt token.

## Tech Stack
[Roda](https://roda.jeremyevans.net/)
[Sequel](https://sequel.jeremyevans.net/) we can swap between SQLite, Postgres, MySQL etc, I went with SQLite
Puma Server
RSpec and rack-test BDD test
i18n gem is used so we can translate with yml files I have added one for English and one for Turkish


## Prerequisites

- Ruby 3.1 ( you can check the version by running `ruby --version`)
- Bundler (if not installed we can install it via `gem install bundler`)



## Running the API Locally

```bash
# 1. Clone from github and navigate to the root folder
cd panda

# 2. Install dependencies
gem install bundler:4.0.23
bundle install

# 3. Run database migrations ( it will create db/panda.sqlite3)
if the below does not work, delete the db/panda.sqlite3, db/panda.sqlite3-shm, db/panda.sqlite3-wal files
bundle exec rake db:migrate

# 4. Start the server (it will start it on port 9292, if required please change it so it does not crash with other things running on the same port)
bundle exec puma config.ru -p 9292
```

It should say the API is now live at `http://localhost:9292`

### Environment Variables

`DATABASE_URL` value is `sqlite://./db/panda.sqlite3`, we can swap to `postgres://...` or `mysql2://...` etc for different database
`RACK_ENV` value is `development` for dev which is also the default value, and `test` for testing, we can set to `production` for prod
`PORT` this should be `9292` but this is not in use, I am hardcoding it with -p 

### Reset the database

This is useful if we want to start fresh

```bash
bundle exec rake db:reset
```

## Running Rspecs Tests

```bash
bundle exec rspec
```

or we can provide the file path if we want to run the specs on that file only

Tests also use a separate `db/panda_test.sqlite3` database, which is cleaned for each test to start fresh, we can use seeding in here as well, for example for clinicians etc that we dont want to reset everytime, but this is ok for MVP


## API Reference and Interaction with the API

All requests and responses use `JSON` and we should add the header `Content-Type: application/json`, otherwise roda will reject the request

All timestamps are in `UTC ISO 8601` format with Z at the end `2026-10-11T14:30:00Z`

We can use Postman `https://www.postman.com/downloads/` to interact with the API once we confirmed that its running on `http://localhost:9292`
Below are the request examples that we can send to our API

I have added a postman collection to interact with the API `panda-collection.postman_collection.json`, please import that to you postman, there is no environment variables on there, I would ususally have the url of the api in an environment variable, but for this MVP I am keeping things simple

### Patients

#### Create a patient
for nhs numbers you can use `https://data-gorilla.uk/en/healthcare/nhs-number/` to generate valid ones for testing
```
POST /patients
```
**Body:**
```json
{
  "nhs_number":     "943 476 5919",
  "first_name":     "John",
  "last_name":      "Smith",
  "date_of_birth":  "1980-01-15",
  "address_line_1": "15 Developer Street",
  "address_line_2": "Congleton",
  "postcode":       "CW12 3LY"
}
```
- `nhs_number` valid  NHS number checked with the rules in here `https://www.datadictionary.nhs.uk/attributes/nhs_number.html
- `postcode` UK format (`CW12 3LY`) it will return 422 if invalid

**Response `201`:**
```json
{
  "id": 1,
  "nhs_number": "9434765919",
  "first_name": "John",
  "last_name": "Simith",
  "date_of_birth": "1980-01-15",
  "address_line_1": "15 Developer Street",
  "address_line_2": "Congleton",
  "postcode": "CW12 3LY",
  "created_at": "2026-11-10T15:10:00Z",
  "updated_at": "2026-11-10T15:10:00Z"
}
```

#### Get a patient
```
GET /patients/:id
```

#### Update a patient
```
PATCH /patients/:id
```
apart from `nhs_number`, other fields, can change

#### Delete a patient
```
DELETE /patients/:id
```
Returns `204 No Content`. Returns `422` if the patient has existing appointments, so we are not allowed to delete it

#### get appointments of a given patient
```
GET /patients/:id/appointments
```


### Appointments

#### Create an appointment
please not this requires a patient with id:1, and clinician with id:2 so it can work
```
POST /appointments
```
**Body:**
```json
{
  "patient_id":   1,
  "clinician_id": 2,
  "scheduled_at": "2026-10-11T09:00:00Z",
  "notes":        "Blood results"
}
```

**Response `201`:**
```json
{
  "id": 1,
  "patient_id": 1,
  "clinician_id": 2,
  "scheduled_at": "2026-10-01T09:00:00Z",
  "status": "scheduled",
  "notes": "blood Results",
  "created_at": "2026-10-01T09:00:00Z",
  "updated_at": "2026-10-01T09:00:00Z"
}
```

#### Get an appointment
```
GET /appointments/:id
```
if `scheduled_at` is a time in the past and the status is still saved as `scheduled`, then the status will be updated to `missed` in the db, this can be automated with a cron job to periodically checked, and also connected to an smtp server to send emails before the expiry etc.

#### Update an appointment
please note if an appointment is missed, it wont be allowed to be modified
```
PATCH /appointments/:id
```

values will be: `scheduled`, `attended`, `cancelled`, `missed`

```json
{
  "status": "attended",
  "notes": "Patient attended to the hospital, we will follow-up in 6 months",
  "clinician_id": 3,
  "scheduled_at": "2026-11-10T10:00:00Z"
}
```


### Clinicians

As I mentioned these can be coming from external system, CSV would have been a good example for MVP as well, or static list that we populate when starting the application, or seed to the databse

#### Create a clinician
```
POST /clinicians
```

```json
{
  "name": "Dr John Smith",
  "department": "Cardihology"
}
```

#### Get a clinician
```
GET /clinicians/:id
```

#### Update a clinician
```
PATCH /clinicians/:id
```

---

### Reporting for Missed Appointments

```
GET /stats/missed
```

Optional query parameters for searching:

`clinician_id`, `department`, date filtering: `from` and `to`

**Response:**
```json
{
  "total_missed": 32,
  "by_clinician": [
    { "clinician_id": 6905, "name": "Dr John Smith", "department": "Cardiology", "missed_count": 5 }
  ],
  "by_department": [
    { "department": "Cardiology", "missed_count": 7 }
  ]
}
```


## Error Responses

All of the errors will return a JSON with `errors` field:

```json
{
  "errors": ["nhs_number NHS number is not correct etc"]
}
```


### What is not implemented and why?
- **Authentication**  out of scope as per this test, it said that this will be an internal api
- **Pagination** on list endpoints we can add with `.paginate` of Sequel, as this is MVP we wont have much data to cause an issue
- **Soft delete for patients** DELETE is hard delete, if we want we can add `deleted_at` column with a migration, we can also add a scope to the list of the objects to not bring deleted ones
- **Background job for missed appointments and maybe notifications**  Sidekiq with a cronejob can be added to trigger emails or update the status of the missed appointments for example a job that runs every night
