




namespace :nest do
  task send_pendings: :environment do
    Nurse.send_all_pending_validation_mails
  end
end
