DataMapper.setup(:default, 'postgres://fgsayuybcutpkn:ziUz0_jrFLLPmfY47YosYPYgBx@ec2-23-21-161-153.compute-1.amazonaws.com:5432/d90hei5ctjbumd')

class Post
  include DataMapper::Resource
  property :id, Serial
  property :timestamp, DateTime, default: Time.now
  property :heading, String, length: 255
  property :content, Text
  
  property :username, String
  property :userlink, String  
end
