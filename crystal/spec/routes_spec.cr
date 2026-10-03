require "minispec"
require "../src/routes"
require "../src/version"
require "./spec_helper"

include Routes

test "number of routes" do
  routes
  assert_equal Mock.count, 8
end

