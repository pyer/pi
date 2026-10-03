require "minispec"
require "../src/version"

test "version from shard.yml" do
  shard_version = {{`shards version`.chomp.stringify}}
  assert_equal VERSION, shard_version
end

