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

class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  # Create the association with the user that owns this post...
  belongs_to :user
  
  # Verify that a user_id is set
  validates(:user_id, presence: true)

	# Verify that the contents are not blank and is not oversized
  validates(:content, presence: true, length: { maximum: 140 })
 
  # Define the default_scope order based upon creation dates...
  default_scope order: 'microposts.created_at DESC'

end
