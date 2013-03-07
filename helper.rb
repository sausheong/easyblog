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
    p WHITELIST
    raise "No one in the whitelist yet." if WHITELIST.empty?
    raise "You are not allowed to do this." unless WHITELIST.include?(session[:user]['username'])
    true
  end
end