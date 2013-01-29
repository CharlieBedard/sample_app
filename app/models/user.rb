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

class User < ActiveRecord::Base
  attr_accessible(:email, :name, :password, :password_confirmation)
  
# Rails has a complex method that uses "password_digest" in the DB table to hold and
#   authenticate a user's password using BCrypt. This method checks both the password
#   and password_confirmation fields of the object to see that they match and adds the
#   authentication to compare the password to the value in the database.
  has_secure_password

# Create the association with the many microposts that are owned by this user
  has_many :microposts, dependent: :destroy

# Before committing to DB, normalize all email address to lowercase...
  before_save { self.email.downcase! }
# ... and create its persistent remember_token
  before_save :create_remember_token

# Verify that the name is not blank and is not oversized
  validates(:name, presence: true, length: { maximum: 50 })

# Check that the provided email address is a valid format...
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false })

# Verify that a password has been supplied and meets minimum length of 6 characters
#  validates(:password, presence: true, length: { minimum: 6 })
  validates(:password, length: { minimum: 6 })

# Verify that a password_confirnmation has been supplied...
  validates(:password_confirmation, presence: true)

# Define public methods used by this model

def feed
# This method returns an array of microposts for the named user using the
#		"where" method which sends SQL strings to DB
	Micropost.where("user_id = ?", id)
end


# Define private methods used only by this model
private
	def create_remember_token
		# Create a unique string as the persistent token using built-in library
		self.remember_token = SecureRandom.urlsafe_base64
#		puts "Created a new TOKEN #{self.name}"
	end

end
