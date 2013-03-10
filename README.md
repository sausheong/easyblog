# EasyBlog

EasyBlog is an attempt to create a minimalist and extensible blog for Rubyists. You'd come to realise that it's probably not what you want. It's actually exactly what **I** want. A simple blog that I can totally control. If you don't like it, well you can fork it from Github here: http://github.com/sausheong/easyblog and then make it suit what you need. 

The entire server app is in a single file `easyblog.rb`. All other files are in the views folder, which (of course), has all the view templates.

Made with Ruby using Sinatra, HAML and DataMapper. Dressed with Twitter Bootcamp and a dash of Font Awesome. Finally with a sprinkle of Bootswatch themes. Served while hot at http://easyblog.herokuapp.com

Enjoy.

# Installation and setting up your own blog

You need these few things.

## Facebook app

EasyBlog integrates with Facebook for authentication. Create a Facebook app through http://developers.facebook.com. Then look out for the *App ID* and *App Secret*. Use the values to set the environment variables *FACEBOOK_APP_ID* and *FACEBOOK_APP_SECRET* accordingly.

Don't like Facebook? Deal with it, or modify it to integrate with what you like or write your own authentication mechanism. Simply change the `/auth` route and there you go.

## Relational database

I used Postgres, specifically, Heroku Postgres from http://postgres.heroku.com for persistent storage, along with DataMapper. They have a free dev database, if you don't feel like paying for one. Create the database string. It should be in the form `postgres://<username>:<password>@<hostname>:<port>/<database>`. The set the environment variable `POSTGRES_STRING`
  
## Whitelist of bloggers

Not everyone can post into your blog. You'd probably only want yourself in it, but you might want some friends to post too. Set the environment variable `WHITELIST` to a comma-delimited list of Facebook usernames (no spaces before or after the comma please). If you want to be the only one who can post, just put in your Facebook username. For eg. my Facebook username is 'sausheong' so that's the `WHITELIST` setting for me.


## Other settings

Only the Facebook and relational DB are needed, everything else is optional (except maybe). Here are some other environment variables you might want to set:

* `BOOTSTRAP_THEME` - A URL to the Bootstrap CSS stylesheet you want to use instead of the default. I used the *Journal* theme from Bootswatch. The default is the default Bootstrap stylesheet
* `BLOG_NAME` - A string to name your blog. The default is 'EasyBlog'

## Set up on Heroku

This is probably the easiest. It's definitely the only one I tried so far. Just push the code up, then on the Terminal, using the Heroku toolbelt, add the configuration settings using `heroku config:add <env variable>=<value>`.
  