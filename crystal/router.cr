require "http/server"
require "./config"

class Router
  include HTTP::Handler
  @routes = Hash(String, Proc(String)).new

  def initialize
    routes
  end

  # @routes is a hash where key=method:path
  # the value is the content of the response sent to the client
  def get(path : String, &block : -> String)
    # just a message while parsing the configuration
    puts "  get " + path
    # filling the hash
    @routes["GET "+path] = block
  end

  def call(context : HTTP::Server::Context)
    begin
      key = context.request.method+" "+context.request.path
      text = @routes[key].call
      context.response.reset
      context.response.content_type = _find_mime(key)
      context.response.puts(text)
    rescue KeyError
      call_next(context)
    end
  end

  def _find_mime(req : String)
    dot = req.rindex('.')
    return DEFAULT_MIME_TYPE if dot.nil?
    len = req.size
    ext = req[dot+1, len]
    mime = MIME_TYPE[ext]
    mime = STREAM_MIME_TYPE if mime.nil?
    return mime
  end

end

