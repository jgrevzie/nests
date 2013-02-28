



class SessionsController < ApplicationController
	skip_before_filter :authorize

	respond_to :html

	def new
	end

	def create
		nurse = Nurse.where(username: params[:username]).first

		if nurse and nurse.authenticate(params[:password])
			if params[:remember_me]
				cookies.permanent[:nurse_id] = nurse.id
			else
				cookies[:nurse_id] = nurse.id
			end

			if !params[:next_url].empty?
				redirect_to params[:next_url]
			elsif nurse.validator? 
				redirect_to pending_validations_nurse_path(nurse) 
			else 
				redirect_to new_completed_proc_path
			end

		else
			flash[:alert] = "Invalid user/password combination"
			render action: "new"
		end
	end

	def destroy
		cookies[:nurse_id] = nil
		redirect_to login_url, alert: "Logged out"
	end
end
