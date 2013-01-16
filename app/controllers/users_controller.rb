class UsersController < ApplicationController

  def new
  #User signup goes here. First thing to do is create a new User instance...
    @user = User.new
  end

  def show
  # Showing a User's profile page for user with ID ":id"...
    @user = User.find(params[:id])

  end

  def index
  end

  def destroy
  end

  def create
  # Got a POST request with entries set for the new user. Validate and use them if OK.
    @user = User.new(params[:user])
    if @user.save
      # Here on successful. Already saved in the DB. Set the "Welcome message"...
      flash[:success] = "Welcome to the Sample App"

      # Now, redirect to the Profile page to display the new user...
      redirect_to @user
    else
      # Bad data values. Deliver error and retry...
      render 'new'
    end
  end

  def edit
  end

  def update
  end
end
