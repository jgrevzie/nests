



class ApplicationController < ActionController::Base
  protect_from_forgery
	before_filter :authorize
  helper_method :logged_in_nurse, :signed_in_nurse

	def authorize
		unless logged_in_nurse
			redirect_to login_path(next_url: request.url),
                             notice: "Welcome - please log in to CathTraq"
		end
	end

  def logged_in_nurse
    Nurse.where(id: cookies[:nurse_id]).first if cookies[:nurse_id]
  end

  def signed_in_nurse
    logged_in_nurse
  end
  
end
