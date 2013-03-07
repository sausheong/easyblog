configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'sausheong_secret_stuff'
  set :show_exceptions, false
end

helpers EasyHelper

error RuntimeError do
  @error = request.env['sinatra.error'].message
  haml :error
end

get "/" do
  page = params[:page] || 1
  page_size = params[:page_size] || 5
  @posts = Post.all(order: :created_at.desc).page(page: page, per_page: page_size)
  @posts_by_month = Post.all.group_by do |post|
    post.created_at.strftime("%B, %Y")
  end
  haml :index
end

get "/post/view/:id" do
  @post = Post.get params[:id]
  haml :'post/view'
end

get "/post/new" do
  must_login and must_in_whitelist
  @post = Post.new
  haml :'post/new'
end

get "/post/edit/:id" do
  must_login and must_in_whitelist
  @post = Post.get params[:id]
  raise 'Cannot find this post' unless @post
  haml :'post/edit'
end

delete "/post" do
  must_login and must_in_whitelist
  post = Post.get params[:id]
  raise "You didn't write this post so you can't remove it." unless post.user_facebook_id == session[:user]['id']
  post.destroy
  redirect "/"
end

delete "/comment" do
  must_login
  comment = Comment.get params[:id]
  raise "You didn't write this comment so you can't remove it." unless comment.user_facebook_id == session[:user]['id']
  comment.destroy
  redirect "/"
end


post "/post" do
  must_login and must_in_whitelist
  unless post = Post.get(params[:id])
    post = Post.new
    post.user_facebook_id, post.user_name, post.user_link = session[:user]['id'], session[:user]['name'], session[:user]['link']    
  end
  post.heading, post.content = params['heading'], params['content']
  post.save
  redirect "/"
end

post "/comment" do
  must_login
  post = Post.get params[:post_id]
  raise "Cannot find a post for you to comment on" unless post  
  unless comment = Comment.get(params[:id])
    comment = post.comments.new
    comment.user_name, comment.user_link = session[:user]['name'], session[:user]['link']    
    comment.user_pic_url, comment.user_facebook_id = session[:user]['picture']['data']['url'], session[:user]['id']     
  end
    comment.content = params['content']
    comment.save
    redirect "/post/view/#{post.id}"
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
    session[:access_token] = resp.split("&")[0].split("=")[1]
    user = RestClient.get("https://graph.facebook.com/me?access_token=#{session[:access_token]}&fields=picture,name,username,link,timezone")
    session[:user] = JSON.parse user
    redirect "/"
  end
end

get "/logout" do
  session.clear
  redirect "/"
end


