class SessionsController < ApplicationController
	skip_before_filter :authorize

	respond_to :html

	def new
	end

	def create
		nurse = Nurse.where(username: params[:username]).first
		if nurse and nurse.authenticate(params[:password])
			session[:user_id] = nurse._id
			if nurse.validator? 
				redirect_to pending_validations_nurse_path(nurse) 
			else 
				redirect_to add_procedure_nurse_path(nurse)
			end
		else
			flash[:alert] = "Invalid user/password combination"
			render action: "new"
		end
	end

	def destroy
		session[:user_id] = nil
		redirect_to login_url, notice: "Logged out"
	end
end

