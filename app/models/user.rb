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

class User < ActiveRecord::Base
  attr_accessible(:email, :name, :password, :password_confirmation)

# Rails has a complex method that uses "password_digest" in the DB table to hold and
#   authenticate a user's password using BCrypt. This method checks both the password
#   and password_confirmation fields of the object to see that they match and adds the
#   authentication to compare the password to the value in the database.
  has_secure_password

# Before committing to DB, normalize all email address to lowercase...
  before_save { |user| user.email = email.downcase }

# Verify that the name is not blank and is not oversized
  validates(:name, presence: true, length: { maximum: 50 })

# Check that the provided email address is a valid format...
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false })

# Verify that a password has been supplied and meets minimum length of 6 characters
  validates(:password, presence: true, length: { minimum: 6 })

# Verify that a password_confirnmation has been supplied...
  validates(:password_confirmation, presence: true)

end
