require 'rack/logger'
require 'rack/static'
require './ruby/appli'

use Rack::Logger
use Rack::Static, :urls => ["/"], :root => "./www", :cascade => true
run Appli.new
