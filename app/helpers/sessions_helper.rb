module SessionsHelper
	def sign_in(user)
		cookies.permanent[:remember_token] = user.remember_token
		self.current_user = user
	end
	
	def signed_in?
		if !current_user.nil?
		end
		!current_user.nil?
	end
	
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)														                  
	end

	# This code looks strange because Ruby allows the symbol "=" to be used in method
	#		definitions. This method is just the accessor method to assign a user object
	#		reference to an Session instance variable
	def current_user=(user)
		@current_user = user		
	end

	# Define the "getter" for this that always retrieves the user context based upon the cookie
	def current_user
		@current_user ||= User.find_by_remember_token(cookies[:remember_token])		
	end
	
	# Define a method to determine if the user object passed in matches the current cookie
	#		defining the currently active "session"
	def current_user?(user)
		user == current_user
	end

	def signed_in_user
		unless signed_in?
			# This method redirects to the "Sign in" page of the user is not already
			#		signed in. Let's remember where we are now so we can send him back
			#		to this page after signing in...
			store_location
		
			# Redirect to "signin" age...
		
			# The more obvious code to redirect is:
			#		flash[:notice] = "Please sign in"
			# 	redirect_to signin_utl
			# However, there is a shortcut for setting flash used in the code below:
			redirect_to signin_url, notice: "Please sign in"
		end
	end

	# Define a method to remember the last page we were on so can implement "friendly"
	#		redirection which sends a user back to their initial requested page after
	#		correcting an issue such as signing in first.
	def store_location
		session[:return_to] = request.url
	end

	# Define the matching method to redirect back to the remembered page. The
	#		"default" argument is where to go if you cannot get back to the saved page.
	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)									# Forget the "remembered" page
	end
end
