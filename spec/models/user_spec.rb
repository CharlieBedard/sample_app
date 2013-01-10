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
  it { should respond_to(:authenticate) }

# The User model should have "validates" for its attributes so check that it is working ...
  it { should be_valid }

# Verify that the string attributes are checked for presence...
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
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
end
