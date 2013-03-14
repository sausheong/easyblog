# settings
BOOTSTRAP_THEME = ENV['BOOTSTRAP_THEME'] || '//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.no-icons.min.css'
BLOG_NAME = ENV['BLOG_NAME'] || 'EasyBlog'
WHITELIST = (ENV['WHITELIST'].nil? || ENV['WHITELIST'].empty? ? [] : ENV['WHITELIST'].split(','))

# helper module
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
    true
  end
  
  def must_in_whitelist
    raise "No one in the whitelist yet." if WHITELIST.empty?
    raise "You are not allowed to do this." unless WHITELIST.include?(session[:user]['username'])
    true
  end
end

# models
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Post
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :heading, String, length: 255
  property :content, Text
  
  property :user_name, String
  property :user_link, String  
  property :user_facebook_id, String
  
  has n, :comments, constraint: :destroy
  
  def is_owned_by(user)
    self.user_facebook_id == user['id']
  end
end

class Comment
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :content, Text
  
  property :user_pic_url, URI
  property :user_name, String
  property :user_link, String  
  property :user_facebook_id, String
  
  belongs_to :post
end

#routes
configure do
  enable :sessions
  enable :inline_templates
  set :session_secret, ENV['SESSION_SECRET'] ||= 'sausheong_secret_stuff'
  set :show_exceptions, false
  
  # installation steps  
  DataMapper.auto_upgrade! unless DataMapper.repository(:default).adapter.storage_exists?('post')
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

__END__

@@ layout
!!! 1.1
%html{:xmlns => "http://www.w3.org/1999/xhtml"}
  %head
    %title=BLOG_NAME
    %meta{name: 'viewport', content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0'}
    %link{rel: 'stylesheet', href: BOOTSTRAP_THEME, type: 'text/css'}
    %link{rel: 'stylesheet', href: "//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-responsive.min.css", type: 'text/css'}
    %link{rel: 'stylesheet', href: '//netdna.bootstrapcdn.com/font-awesome/3.0.2/css/font-awesome.css', type:  'text/css'}
    %link{rel: 'stylesheet', href: '//twitter.github.com/bootstrap/assets/js/google-code-prettify/prettify.css', type:  'text/css'}
    %link{rel: 'stylesheet', href: '//twitter.github.com/bootstrap/assets/css/docs.css', type:  'text/css'}
    %script{type: 'text/javascript', src: "//code.jquery.com/jquery-1.9.1.min.js"}    
    %script{type: 'text/javascript', src: "//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"}

  %body
    #fb-root   
    =toolbar
    =yield
    
    %br
    %footer
      %p.mute.footer 
        %small 
          &copy; 
          %a{href:'http://about.me/sausheong'} Chang Sau Sheong 
          2013

:css
  body { font-size: 20px; line-height: 26px; }

@@ error
%section
  .container.content.center      
    %h1.text-error.text-center
      %i.icon-warning-sign
      Oops, there's been an error. 
    %br
    %p.lead.text-center
      =@error

@@ toolbar
.navbar.navbar-fixed-top
  .navbar-inner
    .container

      %button.btn.btn-navbar.collapsed{'data-toggle' => 'collapse', 'data-target' => '.nav-collapse'}
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar

      %ul.nav
        %a.brand{href:"/"}
          =BLOG_NAME

      .nav-collapse        
        %ul.nav
          - if session[:user] and WHITELIST.include?(session[:user]['username'])
            %li
              %a{href: '/post/new'} 
                %i.icon-plus-sign-alt
                New Post            

        %ul.nav.pull-right
          - if session[:user]
            %li.dropdown
              %a.dropdown-toggle{:href => "#", 'data-toggle' => 'dropdown' }
                %i.icon-user
                =session[:user]['name']
                %span.caret
              %ul.dropdown-menu
                %li
                  %a{:href => '/logout'} Sign out
          - else
            %li
              %a{:href => '/auth'} 
                %i.icon-facebook-sign
                Sign in

@@ index
%section
  .container.content
    - if @posts.empty?
      %h2 There are no posts yet.
    - else
      .row
        .span9
          - @posts.each do |post|
            %h3.text-info
              %a{href: "/post/view/#{post.id}"}
                %i.icon-bookmark-empty
                =post.heading
              &nbsp;
              - if session[:user] and post.is_owned_by(session[:user])
                %small
                  %a{href:"/post/edit/#{post.id}"}
                    %i.icon-pencil
                    edit

            %small.muted
              by
              %a{href: post.user_link}=post.user_name
              on
              =post.created_at.strftime "%e %b %Y, %l:%M %P"
              &nbsp; &middot; &nbsp;
              #{post.comments.size} comments
      
            %p
              =markdown post.content            
          
            - unless post.id == @posts.last.id
              %hr
          
          .pagination
            =@posts.pager.to_html("/")    
        .span3.hidden-tablet.hidden-phone
          =snippet(:'sidebar/_posts_by_month', locals: {posts: @posts_by_month})
    
@@ post/_fields
%fieldset
  %label
    %strong Heading
  %input.span8{type: 'text', name: 'heading', placeholder: 'Type your post heading here', value: @post.heading}
  
  %label
    %strong Content
  %textarea.span8{name: 'content', placeholder: 'Type your post here', rows: 10}
    =@post.content

@@ post/edit
%section
  .container.content
    %h1 
      %i.icon-plus-sign-alt
      Edit Post
    
    .row
      .span12
        %form{method: 'post', action: '/post'}
          %p.text-info.lead
            Modify your post below.
          =snippet :'post/_fields'
          %input{type: 'hidden', name: 'id', value: @post.id}
          .form-actions
            %input.btn.btn-primary{type: 'submit', value: 'Modify'}
            %a.btn{href:'/'} Cancel

@@ post/new
%section
  .container.content
    %h1 
      %i.icon-plus-sign-alt
      Add New Post
    
    .row
      .span12
        %form{method: 'post', action: '/post'}
          %p.text-info.lead
            Type a new post into the fields and click on add to create it.
          =snippet :'post/_fields'
          
          .form-actions
            %input.btn.btn-primary{type: 'submit', value: 'Add'}
            %a.btn{href:'/'} Cancel

@@ post/view
%section
  .container.content
    %h1 
      %i.icon-bookmark
      =@post.heading
      - if session[:user] and @post.is_owned_by(session[:user])
        %span
          %small.muted
            %form#delete{method: 'post', action: '/post'}
              %input{type: 'hidden', name: 'id', value: @post.id}
              %input{type: 'hidden', name: '_method', value: 'delete'}
              %a{href:"/post/edit/#{@post.id}"}
                %i.icon-pencil
                edit
              &middot;
              %a{href:"#", onclick: "$('#delete').submit();"}
                %i.icon-remove
                delete
     
    .row
      .span12
        %br
        =markdown @post.content
        %br
    .row
      .span12
        %h3
          %i.icon-comment-alt
          Comments
          (#{@post.comments.size})
      - @post.comments.each do |comment|
        .span1
          %img.img-polaroid{src: comment.user_pic_url}
        .span11
          =markdown comment.content
          %small.muted
            by
            %a{href: comment.user_link}=comment.user_name
            on
            =comment.created_at.strftime "%e %b %Y, %l:%M %P"            
          
        .span12
          %hr
    - if session[:user]      
      .row
        .span12
          %h4
            %i.icon-comment
            Add new comment
        .span1
          %img.img-polaroid{src: session[:user]['picture']['data']['url']}
        .span11
          %form{method: 'post', action: '/comment'}
            %input{type: 'hidden', name: 'post_id', value: @post.id}
            %textarea.span6{name: 'content', placeholder: 'Type your comment here', rows: 5}
            %br
            %input.btn.btn-primary{type: 'submit', value: 'Add comment'}
    - else
      .row
        .span12.muted
          Please sign in to comment.
          
@@ sidebar/_posts_by_month
%h3 Posts by month
%ul
- posts.each do |month, posts|
  %li
    %a{href:'/'}
      #{month} (#{posts.count})