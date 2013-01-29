# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Micropost do
  
  # Begin by creating a new Micropost and checking its attributes
  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.new(content: "Lorem ipsum") }
  
  # All of theses tests are checking the micropost model
  subject { @micropost }
  
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == user }
  
	# The Micropost model should have "validates" for its attributes so check that it is
	#		 working ...
  it { should be_valid }
  
# Verify that the string attributes are checked for presence...
  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end
 
# Check that the user_id attributes is not accessible...
  describe "accessible attributes" do
  	it " should not allow access to user_id" do
  		# Use the Rails' exception machnery to check this...
    	expect do
    		Micropost.new(user_id: user.id)		# Better fail!
    	end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

# Check that the contents of messages are present...
  describe "with no message content" do
  	before { @micropost.content = " " }
  	it { should_not be_valid }
  end
  
# Check that messages > 140 characters fail...
  describe "with too long message content" do
  	before { @micropost.content = 'a' * 141 }
  	it { should_not be_valid }
  end
end
