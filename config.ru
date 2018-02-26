#\ -w -p 8080 -s webrick

require './app'
require 'webrick/log'
log = WEBrick::Log.new
log.info("PI #{VERSION}")
run App.entry
