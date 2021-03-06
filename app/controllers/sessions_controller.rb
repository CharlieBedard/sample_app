class SessionsController < ApplicationController
	protect_from_forgery		# What the heck is this?
	
	def new
		#
	end

	def create
		user=User.find_by_email(params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			# User is authenticated...
			sign_in(user)		# Use a library/module method to set the user context
			redirect_back_or(user)	# If we were redirected here, return to original page
		else
			# Invalid user
			flash.now[:error] = "Invalid user email or password"
			render "new"
		end
	end

	def destroy
		sign_out
		redirect_to root_url
	end


end
