# README

## Versions
- Ruby: 3.1.2
- Rails: ~> 7.0.3

## DB
- SQLite

### DB creation
To create database you can run command:

`rails db:drop db:create db:migrate`

### Data load
To load all data (`merchants`, `shoppers`, `orders`, `disbursements`) you can run command:

`rails db:seed`

Also, to (re)create `disbursements` separately you can run:

`rails disbursements:create_all`

## Scheduling

For scheduling of weekly disbursement creation I use `whenever` gem that is working on 
top of `crontab` in linux or MacOS. Rules for scheduling you can check in 

`config/schedule.rb`

To check the `crontab` commands that will be created in real life tou can run command in the root 
of the project:

`whenever -f`

For now there is only one rule that runs disbursement creation for previous week on `00:01` of each 
Monday:
```ruby
every :monday, at: "00:01" do
  rake "disbursements:create_for_previous_week"
end
```

## To run the app:
To run application:

`rails s`

It will be run on `http://localhost:3000`

## API
API of the application has only one endpoint:

`GET /api/v1/dibursements` 

with possible parameters:
- `year` - year of the disbursement week (integer, required)
- `week` - week number inside year of the disbursement week (integer, required)
- `merchant_id` - ID of a merchant (integer, optional). Without this parameter response will include 
disbursements for all merchants

### Example of request:
`http://localhost:3000/api/v1/disbursements/?year=2018&week=14&merchant_id=13`

### Example of response:
```json
[
    {
        "id": 193,
        "merchant_id": 13,
        "amount_cents": 657,
        "year": 2018,
        "week": 14,
        "created_at": "2022-11-30T20:52:29.366Z",
        "updated_at": "2022-11-30T20:52:29.366Z"
    }
]
```

## To run tests:
`rspec spec`

## App architecture
All business logic wrapped in services that are inside `app/services` folder.
- `Disbursements::CreateService` - service for creation disbursement for specific merchant in 
specific week
- `Disbursements::CreateAllService` - service for creation disbursements for all merchants in all weeks of some 
specific week
- `Disbursements::ListService` - service for getting list of disbursements in specific week for 
specific merchant of fos all merchants 
