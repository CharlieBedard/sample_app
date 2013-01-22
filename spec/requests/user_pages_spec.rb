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
end
