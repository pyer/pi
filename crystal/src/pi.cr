
require "http/server"

require "./handlers/error_handler.cr"
require "./handlers/routes_handler.cr"
require "./handlers/static_file_handler.cr"
require "./version.cr"

puts "PI version " + VERSION + " starting..."

# HTTP::Handler(s)
#static = HTTP::StaticFileHandler.new(File.expand_path("."))
static = StaticFileHandler.new(File.expand_path("."))
log    = HTTP::LogHandler.new
error  = ErrorHandler.new
router = RoutesHandler.new

handlers = [ log, error, router, static ]

server = HTTP::Server.new(handlers)
address = server.bind_tcp 8080
puts "Listening on http://#{address}"
puts "Use Ctrl-C to stop"
server.listen

