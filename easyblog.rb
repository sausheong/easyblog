%w(sinatra haml data_mapper rest_client json redcarpet).each do |gem|
  require gem
end
%w(settings helper models routes).each do |file|
  require "./#{file}"
end