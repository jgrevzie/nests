module ApplicationHelper
  SUBMIT_PROC_CONTENT = 'submit a procedure for validation'
  VALIDATION_CONTENT = 'Pending Validations'
  PENDING_VALIDATIONS = VALIDATION_CONTENT
  DB_DIR = ENV['DIR'] || File.join(Rails.root, 'db')
  PROC_FILE = "#{DB_DIR}/procedures.csv"
  NURSE_FILE = "#{DB_DIR}/nurses.csv"
end
