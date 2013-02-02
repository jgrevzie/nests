class ApplicationController < ActionController::Base
	protect_from_forgery




	before_filter :authorize

	def authorize
		unless session[:user_id] && Nurse.where(id: session[:user_id]).exists
			redirect_to login_url, notice: "Welcome - please log in to CathTraq"
		end
	end
end
