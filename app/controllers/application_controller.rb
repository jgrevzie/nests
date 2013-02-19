class ApplicationController < ActionController::Base
	



  protect_from_forgery
	before_filter :authorize
  helper_method :logged_in_nurse, :signed_in_nurse

	def authorize
		unless session[:user_id] && Nurse.where(id: session[:user_id]).exists
			redirect_to login_url, notice: "Welcome - please log in to CathTraq"
		end
	end

  def logged_in_nurse
    session[:nurse]
  end

  def signed_in_nurse
    logged_in_nurse
  end

end
