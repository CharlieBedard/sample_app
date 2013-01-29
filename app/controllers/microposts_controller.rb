class MicropostsController < ApplicationController
	before_filter :signed_in_user, only: [:create, :destroy]
	before_filter :correct_user, 	 only: :destroy
				
  # This method creates a new Micropost and associates it with the currently
  #		signed in user. The "before" flter ensures that there is a currently
  #		signed in user.
  def create
  	@micropost = current_user.microposts.build(params[:micropost])

    if @micropost.save
   	
      # Here on success. Already saved in the DB. 
      flash[:success] = "New post accepted"
      
      # Now, redirect back to the root page to allow more new posts...
      redirect_to root_url
    else
      # Bad data values. Back to home page with null feeds list
      @feed_items = []
      render 'static_pages/home'
    end
  end

  #
  def destroy
    @post_to_go.destroy
    redirect_to root_url		
  end


private
	# Define a method to return whether the current user is the micropost's user
	def correct_user
		@post_to_go = current_user.microposts.find_by_id(params[:id])
		redirect_to root_url if @post_to_go.nil?
	end

end
