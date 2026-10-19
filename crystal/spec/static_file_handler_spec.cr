require "minispec"
require "../src/handlers/static_file_handler.cr"

# TO DO


test "default " do
  assert_equal PI::RoutesHandler::DEFAULT_MIME_TYPE,  "text/html"
end

