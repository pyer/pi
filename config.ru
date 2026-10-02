require 'rack/common_logger'
require 'rack/static'
require './ruby/appli'

use Rack::CommonLogger
use Rack::Static, :urls => ["/"], :root => "./www", :cascade => true

run Appli.new
