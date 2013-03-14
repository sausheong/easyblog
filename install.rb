require 'rest_client'
require 'json'
require 'highline/import'

puts
puts "EasyBlog installation script"
puts "============================"
puts "This script will install EasyBlog into Heroku. You will be asked for:"
puts "1. A Heroku API key, which you can get from https://dashboard.heroku.com/account once you sign up for an account"
puts "2. A Facebook application ID and application secret, which you can from https://developers.facebook.com/apps once you create a Facebook application"
puts
heroku_api = ask("Please enter your Heroku API key:  ") { |q| q.echo = "x" }
facebook_app_id = ask("Enter your Facebook App ID:  ") { |q| q.echo = "x" }
facebook_app_secret = ask("Enter your Facebook App Secret:  ") { |q| q.echo = "x" }

# installation script executes from here
heroku_url = "https://:#{heroku_api}@api.heroku.com/apps"

# Create app
response = RestClient.post heroku_url, "app[stack]=cedar", "Accept"=>"application/json"
app = JSON.parse response
puts "Creating app #{app['name']} is #{app['create_status']}"

# Add the Heroku Postgres:Dev addon
response = RestClient.post "#{heroku_url}/#{app['name']}/addons/heroku-postgresql:dev", "Accept"=>"application/json"
addon = JSON.parse response
puts "Postgres DB is #{addon['status']}"

# Set the configurations
config = {'FACEBOOK_APP_ID' => facebook_app_id, 'FACEBOOK_APP_SECRET' => facebook_app_secret}
response = RestClient.put "#{heroku_url}/#{app['name']}/config_vars", config.to_json, "Accept"=>"application/json"
puts "Facebook configurations set."

# Push the code up to Heroku
system "git remote add heroku #{app['git_url']}"
system "git push heroku master"

# Show the final url
puts "== COMPLETE =="
puts "Your new blog is now installed at the URL below:"
puts
puts app['web_url']
puts
puts "Please remember to set your Facebook app to integrate with your blog through 'Website with Facebook Login', with the Site URL set to http://#{app['name']}.herokuapp.com:80/"
puts