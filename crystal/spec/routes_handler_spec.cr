require "minispec"
require "http/server"
require "../src/handlers/routes_handler"

test "default mime type" do
  assert_equal RoutesHandler::DEFAULT_MIME_TYPE,  "text/html"
end

test "stream mime type" do
  assert_equal RoutesHandler::STREAM_MIME_TYPE, "application/octet-stream"
end

test "find default mime type" do
  router = RoutesHandler.new
  mime = router._find_mime("/url/path")
  assert_equal mime, "text/html"
end

test "find text mime type" do
  router = RoutesHandler.new
  mime = router._find_mime("/url/index.html")
  assert_equal mime, "text/html"
end

