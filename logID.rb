
Here is a sample Rack module for logging the request ID.

module Rack::LogRequestID
  def initialize(app); @app = app; end

  def call(env)
    puts "request_id=#{env['HTTP_X_REQUEST_ID']}"
    @app.call(env)
  end
end
If you are using Rack without Rails, for a more comprehensive Rack middleware, we recommend the Heroku Request ID gem. Do not use this gem if you are using Rails, this gem will break Rails request logging functionality. Using the gem with Rack will provide timing information if you have Rack::Runtime enabled:

use Rack::Runtime
