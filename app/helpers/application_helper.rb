module ApplicationHelper
  SUBMIT_PROC_CONTENT = 'submit a procedure for validation'
  VALIDATION_CONTENT = 'Pending Validations'
  PENDING_VALIDATIONS = VALIDATION_CONTENT




  def protect_against_forgery?
      false
  end

end
