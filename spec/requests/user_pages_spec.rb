require 'spec_helper'

describe "User pages" do

  subject { page }

  # Validate the contents of the User Profile page...
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) } 
    before { visit user_path(user) }
    
    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

  # Verify the edit operations on the user's profile page...
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) } 
    before do
    	sign_in user
    	visit edit_user_path(user)
    end
    
    context "page" do
    	it { should have_selector('h1', text: "Update your profile") }
    	it { should have_selector('title', text: "Edit user") }
    	it { should have_link('change', href: 'http://gravatar.com/emails') }
    end
    
    context "with invalid information" do
    	before { click_button "Save changes" }
    	
    	it { should have_content('error') }
    end
    
    context "with valid information" do
    	let(:new_name) 	{ "New Name" }
    	let(:new_email) { "new@example.com" }
    	before do
    		fill_in "Name",							with: new_name
    		fill_in "Email",						with: new_email
    		fill_in "Password",					with: user.password
    		fill_in "Confirm Password",	with: user.password
    		click_button "Save changes"
    	end
      
      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  # Series of tests to validate operation of the User Signup page...
  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    # Blank info should be invalid
    context "with invalid information" do
      # Empty entries should fail...
      it "should not create a new user" do
        expect { click_button submit }.not_to change(User, :count)  # No new records
      end
    
      # Check out that our error messages are working...
      context "after clicking 'Sign up'" do
        before { click_button submit }

        # Page should have proper title...
        it { should have_selector('title', text: 'Sign up') }

        # Look for various error messages...
        it { should have_content("Password can't be blank") }
        it { should have_content("Name can't be blank") }
        it { should have_content("Email is invalid") }
        it { should have_content("Password is too short (minimum is 6 characters)") }
        it { should have_content("Password confirmation can't be blank") }
      end
    end

    # See if it works with some valid sample data...
    context "with valid information" do
      before do
        fill_in "Name",		with: "Example User"
        fill_in "Email",	with: "user@example.com"
        fill_in "Password",	with: "foobar"
        fill_in "Confirmation",	with: "foobar"
      end

      context "after clicking 'Sign up'" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        
        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: "Welcome") }
        it { should have_link('Sign out') }
      end
    
      it "should allow a new user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
  end
  
  # These tests check that the list of all users is working. We use the Factory
  #		to create 30 users, signin as the first user and then check that
  #		there is a list item (<li>) with the user names as the tags.
  describe "index" do
  	
  	# Create a new user object and sign them in...
  	let(:user) { FactoryGirl.create(:user) }
  		
  	before(:each) do
  		sign_in(user)
  		visit users_path
   	end
   	
   	# Should be at the "index" page. Check title and header...
    it { should have_selector('title', text: 'All users') }
   	it { should have_selector('h1',		 text: "All users") }

   	# And it should list all 30 users...
   	describe "pagination" do
   		#Create 30 users for each test in this section...
   		before(:all)	{	30.times { FactoryGirl.create(:user) } }
   		after(:all) 	{ User.delete_all }
   		
   		it { should have_selector('div.pagination') }
   		
   		it "should list every user" do
   			User.paginate(page: 1).each do |user|
   				page.should have_selector('li',	text: user.name)   			
   			end
   		end
  	end
  	
  	# Check for the presence and absence of the "delete" link
  	#		depending upon the state of the :admin property
  	describe "delete links" do
  		
  		# Since the test user is not an admin, the "delete" link should not be there...
    	it { should_not have_link('delete') }

			# Now, create a test admin user, sign them in and then make sure that
			#		the "delete" links now appear on the "Users" page
			context "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before(:each) do
					sign_in(admin)
					visit users_path
				end
			
	    	it { should have_link('delete', href: user_path(User.first)) }
	    	it "should be able to delete another user" do
	    		expect { click_link('delete') }.to change(User, :count).by(-1)
	    	end
    	
    		# Finally, check that we cannot delete our own admin entry...
     		it { should_not have_link('delete', href: user_path(admin)) } 
     	end  		
		end
  end
end
