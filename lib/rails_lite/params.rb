require 'uri'

class Params

  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params

  attr_accessor :params, :permitted_keys

  def initialize(req, route_params = {})
    @params = {}
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @permitted_keys = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.each { |key| permitted_keys << key }
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
    @params[key]
  end

  def permitted?(key)
    permitted_keys.include?(key)
  end


  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    arr = URI.decode_www_form(www_encoded_form)

    params = {}

    arr.each do |param|
      scope = params
      keys = parse_key(param.first)

      keys.each_with_index do |val, idx|
        if idx == keys.count-1
          scope[val] = param.last
        else
          scope[val] ||= {}
          scope = scope[val]
        end
      end
    end

    params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
