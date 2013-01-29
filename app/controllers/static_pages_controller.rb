class StaticPagesController < ApplicationController
  def home
  		if signed_in?
  			# Create an empty new microppost to be filled in
  			@micropost = current_user.microposts.build
  			
  			# Generate the set of microposts to be displayed
  			@feed_items = current_user.feed.paginate(page: params[:page])
  		end
  end

  def help
  end

  def about
  end

  def contact
  end


end
