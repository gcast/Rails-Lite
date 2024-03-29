require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res
  attr_accessor :already_built_response

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_built_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    if already_built_response == true
      raise "already_built_response"
    else
      @res.body = content
      @res['content-type'] = type
      @already_built_response = true
    end
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    if already_built_response? == true
      raise "already_built_response"
    else
      @res.status = 302
      @res['location'] = url
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller = self.class.name.underscore
    file = File.read("views/#{controller}/#{template_name}.html.erb")
    render_content(ERB.new(file).result(binding), 'html/text')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless @already_built_response
  end
end
