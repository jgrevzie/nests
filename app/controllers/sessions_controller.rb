



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

			params[:next_url].empty? ? redirect_to(initial_page) : redirect_to(params[:next_url])

		else
			flash[:alert] = "Invalid user/password combination"
			render action: "new"
		end
	end

	def destroy
		cookies[:nurse_id] = nil
		redirect_to login_url, alert: "Logged out"
	end

	def home
		redirect_to initial_page
	end
end
