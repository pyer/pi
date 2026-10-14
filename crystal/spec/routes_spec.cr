require "minispec"
require "./routes_helper"
require "../src/handlers/routes_handler"

pending "number of routes" do
  router = RoutesHandler.new
  assert_equal router.@routes.size, 10
end

before do
  Log.setup(:error)
end


test "home" do
  router = RoutesHandler.new
  request  = HTTP::Request.new("GET", "/")
  response = HTTP::Server::Response.new(IO::Memory.new(0))
  context  = HTTP::Server::Context.new(request, response)
  router.call(context)
  assert_equal context.response.status, HTTP::Status::OK
  assert_equal context.response.body, "<html></html>\n"
end

test "version" do
  router = RoutesHandler.new
  request  = HTTP::Request.new("GET", "/version")
  response = HTTP::Server::Response.new(IO::Memory.new(0))
  context  = HTTP::Server::Context.new(request, response)
  router.call(context)
  assert_equal context.response.status, HTTP::Status::OK
  assert_equal context.response.body, "Version 1.1.0"
end

test "error404" do
  router = RoutesHandler.new
  request  = HTTP::Request.new("GET", "/xxx")
  response = HTTP::Server::Response.new(IO::Memory.new(0))
  context  = HTTP::Server::Context.new(request, response)
  router.call(context)
  assert_equal context.response.status, HTTP::Status::NOT_FOUND
end

