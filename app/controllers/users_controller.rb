class UsersController < ApplicationController
	before_filter :signed_in_user, 	only: [:index, :edit, :update]
	before_filter :correct_user, 		only: [:edit, :update]
	before_filter :admin_user, 			only: [:destroy]
		
  def new
  #User signup goes here. First thing to do is create a new User instance...
    @user = User.new
  end

  def show
  # Showing a User's profile page for user with ID ":id"...
    @user = User.find(params[:id])
		@microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
  	@users=User.paginate(page: params[:page],	# Get the requested page of users
  											 per_page: 15)		
  end

  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "User deleted"
      redirect_to users_url
  end

  def create
  # Got a POST request with entries set for the new user. Validate and use them if OK.
    @user = User.new(params[:user])
    puts "Inside user controller create. User name is: #{@user.name}"
    if @user.save
   	
      # Before sending the user off to their profile page, also sign them in...
      sign_in(@user)

      # Here on success. Already saved in the DB. Set the "Welcome message"...
      flash[:success] = "Welcome to the Sample App"
      
      # Now, redirect to the Profile page to display the new user...
      redirect_to @user
    else
      # Bad data values. Deliver error and retry...
      render 'new'
    end
  end

  def edit
  # Here to allow a user to edit his/her profile.
  #   The ":signed_in_user" before-filter checks that a user must be signed in before they
  #		can edit a profile. If not signed in, they are redirected to the signin page.
  #		The ":correct_user" before-filter sets the @user instance variable of the user if
  #		correctly signed in. Otherwise, they are redirected to the home(root) page.
  	
  end

  def update
  # Here to capture the changes from a user's profile edits.
  #   The ":signed_in_user" before-filter checks that a user must be signed in before they
  #		can update a profile. If not signed in, they are redirected to the signin page.
  #		The ":correct_user" before-filter sets the @user instance variable of the user if
  #		correctly signed in. Otherwise, they are redirected to the home(root) page.
		
		if @user.update_attributes(params[:user])
    	# Here on successfu update of profile. Acknowledge success...
      flash[:success] = "Profile updated"
      
      # Before sending the user off to their profile page, also sign them in...
      sign_in(@user)

      # Now, redirect to the Profile page to display the updated user...
      redirect_to @user

    else
      # Bad data values. Deliver error and retry...
      render 'edit'
    end
  end
  
  	
	# Private methods go here...
	private

		def correct_user
  		@user=User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end

		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
		
end
