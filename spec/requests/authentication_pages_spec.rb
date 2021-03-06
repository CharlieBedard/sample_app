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
      before { sign_in(user) }
    		
    	it { should have_selector('title', text: user.name) }
    	
     	it { should have_link('Users', 		href: users_path) }
     	it { should have_link('Profile', 	href: user_path(user)) }
     	it { should have_link('Settings', href: edit_user_path(user)) }
     	it { should have_link('Sign out', href: signout_path) }
     	
     	it { should_not have_link('Sign in', href: signin_path) }

          	
     	# Now that they are signed in, let's sign them out and check that that worked
     	context "followed by signing out" do
     		before { click_link "Sign out" }
     		it { should have_link "Sign in" }
     	end
    end
  end
  
  describe "Authorization" do
  	context "for non-signed-in users" do
  		let(:user) { FactoryGirl.create(:user) }
  		
  		context "in the Users controller" do
  			
  			context "visiting the edit page" do
  				# If user is not signed in and tries to edit a profile, they
  				#		should be redirected to the "sign-in" page...
  				before { visit edit_user_path(user) }
  				it { should have_selector('title', text: 'Sign in') }
  			end
  			
  			context "submitting to the update action" do
  				before { put user_path(user) }
  				specify { response.should redirect_to(signin_path) }
  			end
  			
  			context "visiting the user index" do
  				# If user is not signed in and tries to list all users, they
  				#		should be redirected to the "sign-in" page...
  				before { visit users_path }
  				it { should have_selector('title', text: 'Sign in') }
  			end
  		end
  	 				
  		context "when attempting to visit a protected page" do	
  			before do
  				visit edit_user_path(user)	# Should cause a redirect to the sigin page
  				fill_in "Email",		with: user.email
  				fill_in "Password",	with:user.password
  				click_button "Sign in"  		# Sign us in...		
  			end
  			
  			# Should have been redirected and signed in. Verify that we are back
  			#		to the edit page after sigining in...
  			context "after signing in" do

  				it "should render the desired protected page" do
  					page.should have_selector('title', text: 'Edit user')
  				end
  			end
   		end
   		
   		# Here to test microposts authorization. You should only be able to
  		#		create/destroy your own posts. To check that, you must be signed in
  		context "in the Microposts controller" do
  			context "submitting to the create action" do
  				before { post microposts_path }
 					specify { response.should redirect_to(signin_path) }
  			end

  			context "submitting to the destroy action" do
  				before do
  					new_post = FactoryGirl.create(:micropost)
  					delete micropost_path(new_post)
  				end
 					specify { response.should redirect_to(signin_path) }
  			end
  		end
  	end
  	
  	context "as wrong user" do
  		let(:user) { FactoryGirl.create(:user) }
  		let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in(user) }
      
      context "visiting Users#edit page" do
      	before { visit edit_user_path(wrong_user) }
  			it { should_not have_selector('title', text: full_title("Edit user")) }
      end
      
      context "submitting an HTTP PUT request to the Users#update action" do
  			before { put user_path(wrong_user) }
 				specify { response.should redirect_to(root_path) }
      end
  	end

  	# This test checks that an intruder trying to force a 'delete user' request
  	#		directly to the site will fail
  	context "as non-admin user" do
  		let(:user) { FactoryGirl.create(:user) }
  		let(:non_admin) { FactoryGirl.create(:user) }
  		
      before { sign_in(non_admin) }
      
      context "submitting an HTTP DELETE request to the Users#destroy action" do
      	before { delete user_path(user) }
      	specify { response.should redirect_to(root_path) }
      end
  	end  	
  	
  end
  
end
