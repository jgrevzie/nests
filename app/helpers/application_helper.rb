module ApplicationHelper
  SUBMIT_PROC_CONTENT = 'submit a procedure for validation'
  VALIDATION_CONTENT = 'Pending Validations'

  def logged_in_nurse
    session[:nurse]
  end
end
