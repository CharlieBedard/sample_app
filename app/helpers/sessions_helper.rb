module SessionsHelper
	def sign_in(user)
		cookies.permanent[:remember_token] = user.remember_token
		self.current_user = user
	end
	
	def signed_in?
#		if !current_user.nil?
#			puts "Current User token: #{current_user.remember_token}"
#		end
		!current_user.nil?
	end
	
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	# This code looks strange because Ruby allows the symbol "=" to be used in method definitions
	# 	This method is just the accessor method to assign a user object reference to an Session
	# 	instance variable
	def current_user=(user)
		@current_user = user		
	end

	# Define the "getter" for this that always retieves the suer context based upon the cookie
	def current_user
		@current_user ||= User.find_by_remember_token(cookies[:remember_token])		
	end

end
