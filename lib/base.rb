
require './lib/error.rb'
require './lib/mime_type.rb'
require './lib/response.rb'
require './lib/tree.rb'
require './lib/version.rb'

class Base
    class << self
      @@routes = Hash.new { |hash, key| hash[key] = [] }

      ['DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT'].each do |verb|
        define_method(verb.downcase) do |path, &block|
          @@routes[verb] << { path: path, block: block }
        end
      end
    end

    def inspect_req
      p self.class.name
    end

    def call(env)
      req = Rack::Request.new(env)
      route = find_route(req)
      if route.nil?
        fname = '.' + req.path_info
        return Error::error404 unless File.exist?(fname)
        mime = find_mime(req)
        body = File.read(fname)
        return Response::ok(body,mime)
      end
      mime = find_mime(req)
      return Response::ok(instance_eval(&route[:block]),mime)
    end

    private
    def find_route(req)
      @@routes[req.request_method].find do |r|
        r[:path] == req.path_info
      end
    end

    def find_mime(req)
      dot = req.path_info.rindex('.')
      return DEFAULT_MIME_TYPE if dot.nil?
      len = req.path_info.length
      ext = req.path_info[dot, len]
      mime = MIME_TYPE[ext]
      return DEFAULT_MIME_TYPE if mime.nil?
      return mime
    end

end
