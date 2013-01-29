namespace :db do
	desc "Fill database with sample user data"
	task populate: :environment do
		# Create an admin user as the first person in the DB
		admin = User.create!(name:	 								"Example User",
								 				 email:									"example@railstutorial.org",
								 				 password:							"foobar",
								 				 password_confirmation:	"foobar")
		admin.toggle!(:admin)			# Make this one the admin
		
		# Create another 99 names for the test DB...
		99.times do |n|
			name = Faker::Name.name
			email = "example-#{n+1}@railstutorial.org"
			password = "password"
			User.create!(name:	 								name,
									 email:									email,
									 password:							password,
								 	 password_confirmation:	password)
			
		end
		
		# Create 50 microposts for the first 6 users..
		users_with_posts = User.all(limit: 6)
		50.times do 
			pseudo_text = Faker::Lorem.sentence(5)
			users_with_posts.each { |next_user| next_user.microposts.create!(content: pseudo_text) }
		end
		
	end
end
