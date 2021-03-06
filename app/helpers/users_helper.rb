module UsersHelper

# This utility helper uses the "Gravatar" Web service to create a global Avatar for the named
# user using the MD5 hash of their email address.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
#    image_tag("TinyPhoto.png", alt: user.name, class: "gravatar")
  end
end
