




namespace :nest do
  task send_pendings: :environment do
    DailyValidations.send_pendings
  end
end
