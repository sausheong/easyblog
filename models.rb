DataMapper.setup(:default, ENV['POSTGRES_STRING'])

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