require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  # Validate the contents of the Signin page...
  describe "signin" do
    
    before { visit signin_path }
    
    context "with invalid information" do
    	before { click_button "Sign in" }
    		
    	it { should have_selector('title', text: 'Sign in') }
     	it { should have_selector('div.alert.alert-error', text: "Invalid") }
     	
     	context "after visiting some other page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end			
   
    context "with valid information" do
    	let(:user) { FactoryGirl.create(:user) } 
 #   	puts "Remember token: #{user.remember_token}"
 #			puts user
    	
      before do
        fill_in "Email",	  with: user.email
        fill_in "Password",	with: user.password
        click_button "Sign in"
      end
    		
    	it { should have_selector('title', text: user.name) }
     	it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }
     	it { should_not have_link('Sign in', href: signin_path) }
     	
     	# Now that they are signed in, let's sign them out and check that that worked
     	context "followed by signing out" do
     		before { click_link "Sign out" }
     		it { should have_link "Sign in" }
     	end
    end
  end
end
