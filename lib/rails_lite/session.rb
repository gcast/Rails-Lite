require 'json'
require 'webrick'

class Session

  attr_accessor :cookie

  def initialize(req)
    cookie = req.cookies.find{ |cookie| cookie.name == '_rails_lite_app' }
    if cookie
      @cookie = JSON.parse(cookie.value)
    else
      @cookie = {}
    end
  end

  def [](key)
    self.cookie[key]
  end

  def []=(key, val)
    self.cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
  end
end
