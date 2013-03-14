# EasyBlog

EasyBlog is an attempt to create a minimalist and extensible blog for Rubyists. You'd come to realise that it's probably not what you want. It's actually exactly what **I** want. A simple blog that I can totally control. If you don't like it, well you can fork it from Github here: http://github.com/sausheong/easyblog and then make it suit what you need. 

The entire web app is in a single 400 lines of code file `easyblog.rb`, including the view templates. I've also included a very easy to use installation script that deploys EasyBlog to Heroku. in 3 steps:

1. Sign up for a Heroku account
2. Register a Facebook app
3. Run the installation script and follow the instructions

Made with Ruby using Sinatra, HAML and DataMapper. Dressed with Twitter Bootcamp and a dash of Font Awesome. Finally with a sprinkle of Bootswatch themes. Served while hot at http://easyblog.herokuapp.com

Enjoy.

# Installation and setting up your own blog

You need these few things.

## Facebook app

EasyBlog integrates with Facebook for authentication. Create a Facebook app through http://developers.facebook.com. Then look out for the *App ID* and *App Secret*. If you are using the installation script, you will be asked for these two pieces of information. Please remember to set your Facebook app to integrate with your blog through 'Website with Facebook Login', with the Site URL set to http://[your app name].herokuapp.com:80/

If you have entered the wrong ID and secret, you can set them again. Use the values to set the environment variables *FACEBOOK_APP_ID* and *FACEBOOK_APP_SECRET* accordingly.

Don't like Facebook? Deal with it, or modify it to integrate with what you like or write your own authentication mechanism. Simply change the `/auth/login` route and there you go.

## Relational database

I used Postgres, specifically, Heroku Postgres from http://postgres.heroku.com for persistent storage, along with DataMapper. This is installed as part of the installation script. If you wish to use something else, just change the `DATABASE_URL` environment variable.
  
## Whitelist of bloggers

Not everyone can post into your blog. You'd probably only want yourself in it, but you might want some friends to post too. Set the environment variable `WHITELIST` to a comma-delimited list of Facebook usernames (no spaces before or after the comma please). If you want to be the only one who can post, just put in your Facebook username. For eg. my Facebook username is 'sausheong' so that's the `WHITELIST` setting for me.

If you use the installation script, you will be asked for such a whitelist. 


## Other settings

Only the Facebook and relational DB are needed, everything else is optional (except maybe). Here are some other environment variables you might want to set:

* `BOOTSTRAP_THEME` - A URL to the Bootstrap CSS stylesheet you want to use instead of the default. I used the *Journal* theme from Bootswatch. The default is the default Bootstrap stylesheet
* `BLOG_NAME` - A string to name your blog. The default is 'EasyBlog'

## To set environment variables in Heroku

Add the configuration settings using `heroku config:add <env variable>=<value>`. For a fuller explanation please refer to https://devcenter.heroku.com/articles/config-vars
  
## Installing on Heroku

The fastest way to install is to run the installation script and follow the instructions.
    
    > ruby ./install.rb
    
Then enter the Heroku API key, Facebook App ID and App Secret when asked. At the end of the script you will be provided with your new blog!
  