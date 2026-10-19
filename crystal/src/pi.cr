
require "http/server"

require "./handlers/error_handler.cr"
require "./handlers/routes_handler.cr"
require "./handlers/static_file_handler.cr"
require "./version.cr"

puts "PI version " + PI::VERSION + " starting..."

# HTTP::Handler(s)
log    = HTTP::LogHandler.new
error  = PI::ErrorHandler.new
router = PI::RoutesHandler.new
static = PI::StaticFileHandler.new(File.expand_path("www"))

handlers = [ log, error, router, static ]

server = HTTP::Server.new(handlers)
address = server.bind_tcp 8080
puts "Listening on http://#{address}"
puts "Use Ctrl-C to stop"
server.listen

