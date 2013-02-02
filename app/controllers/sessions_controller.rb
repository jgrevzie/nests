class SessionsController < ApplicationController
	skip_before_filter :authorize

	def new
	end

	def create
		nurse = Nurse.where(username: params[:username]).first
		if nurse and nurse.authenticate(params[:password])
			session[:user_id] = nurse._id
			if nurse.admin? then redirect_to admin_url else redirect_to add_procedure_nurse_url(nurse) end
		else
			redirect_to login_url, alert: "Invalid user/password combination"
		end
	end

	def destroy
		session[:user_id] = nil
		redirect_to login_url, notice: "Logged out"
	end
end

