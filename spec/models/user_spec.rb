# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

require 'spec_helper'

describe User do
  
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  subject { @user }

# Verify that all of the attributes are defined...
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
# :remember_token is used for user state that persists across browser sessions
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
# Check for the microposts method reference (created by the "has_many" relationship)
	it { should respond_to(:microposts) }
	
# The User model should have "validates" for its attributes so check that it is
#		 working ...
  it { should be_valid }
  
# Our test user should not be the admin...
  it { should_not be_admin }

# Verify that the string attributes are checked for presence...
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

# When the admin attribute is set, this should become an admin...
  describe "with admin attribute set to 'true'" do
    before do
    	@user.save!
    	@user.toggle!(:admin)
    end
    
    it { should be_admin }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

# Verify that a name greater than 50 charatcters is rejected...
  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

# Verify that the email address will be set to lower case before saving to the DB...
  describe "when email address set to lower case" do
    let(:email_set_to_mixed_case) { "AbCdEfG@anyHWERE.CoM" }

    it "should be saved in lower case" do
      @user.email = email_set_to_mixed_case
      @user.save
      @user.reload.email.should == email_set_to_mixed_case.downcase
    end
  end

# Using regex, check that valid and invalid email addresses are processed correctly...
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |bad_addr|
        @user.email = bad_addr
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US_ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |good_addr|
        @user.email = good_addr
        @user.should be_valid
      end
    end
  end

# Verify that duplicate email addresses are found...
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

# Verify passwords...
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password does not match the confirming password" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is accidentally set to nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

# Verify that passwords need to be at least 6 characters long...
  describe "with a password that is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

# Verify the various authentication processes...

  describe "return value of authentication method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end


    describe "without valid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

# Verify that the remember_token is present...
  describe "has non-blank" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

# Tests on microposts...
  describe "micropost associations" do
    
    before { @user.save }
    
    let!(:older_post) do
    	FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    
    let!(:newer_post) do
    	FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    # Check that the array is time ordered newest to oldest...
    it "should have the posts in the correct time order" do
    	@user.microposts.should == [newer_post, older_post]
    end

    # Delete a user and verify that their posts are also gone...
    it "should delete associated microposts" do
    	saved_posts = @user.microposts.dup		# Copy entire array of posts
    	@user.destroy													# Kill the user
    	
    	saved_posts.should_not be_empty
    	
    	saved_posts.each do |post|
    		# Check in DB to verify there are not there...
    		Micropost.find_by_id(post.id).should be_nil
    	end
    end
    
    # Check that we can see our own posts but no one else's posts...
    context "should only see our posts" do
    	let(:not_our_post) do
    		FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
    	end
    	
    	its(:feed) { should include(older_post) }
    	its(:feed) { should include(newer_post) }
    	its(:feed) { should_not include(not_our_post) }
    end
    
  end
end
