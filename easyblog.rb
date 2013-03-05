%w(sinatra haml data_mapper rest_client json redcarpet).each do |gem|
  require gem
end
require './models'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'sausheong_secret_stuff'
  set :show_exceptions, false
end

module EasyHelper
  def markdown(content)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true).render(content)
  end
  
  def snippet(page, options={})
    haml page, options.merge!(layout: false)
  end
    
  def toolbar
    haml :toolbar, layout: false
  end
  
  def must_login
    raise "You have not signed in yet. Please sign in first!" unless session[:user]
  end
end

helpers EasyHelper

error RuntimeError do
  @error = request.env['sinatra.error'].message
  haml :error
end

get "/" do
  page = params[:page] || 1
  page_size = params[:page_size] || 5
  @posts = Post.all(order: :timestamp.desc).page(page: page, per_page: page_size)
  haml :index
end

get "/post/new" do
  must_login
  @post = Post.new
  haml :'post/new'
end

post "/post" do
  post = Post.new
  post.heading, post.content, post.username, post.userlink = params['heading'], params['content'], session[:user]['name'], session[:user]['link']
  post.save
  redirect "/"
end

get '/auth' do  
  RestClient.get "https://www.facebook.com/dialog/oauth",
                    params: {client_id: ENV['FACEBOOK_APP_ID'], 
                             redirect_uri: "#{request.scheme}://#{request.host}:#{request.port}/auth/callback"}
end

get '/auth/callback' do
  if params['code']
    resp = RestClient.get("https://graph.facebook.com/oauth/access_token",
                      params: {client_id: ENV['FACEBOOK_APP_ID'],
                               client_secret: ENV['FACEBOOK_APP_SECRET'],
                               redirect_uri: "#{request.scheme}://#{request.host}:#{request.port}/auth/callback",
                               code: params['code']})                                           
    access_token = resp.split("=")[1]
    user = RestClient.get("https://graph.facebook.com/me?access_token=#{access_token}")
    session[:user] = JSON.parse user
    redirect "/"
  end
end

get "/logout" do
  session.clear
  redirect "/"
end


