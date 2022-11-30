namespace :disbursements do
  desc "Create disbursements for all existing orders"
  task create_all: :environment do
    Disbursements::CreateAllService.new.call
  end

  desc "Create disbursements for previous week"
  task create_for_previous_week: :environment do
    Disbursements::CreateAllService.new(Date.today - 7.days).call
  end
end
