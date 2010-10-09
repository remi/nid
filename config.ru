$KCODE = "UTF8"

require 'rubygems'
use Rack::ShowExceptions

require 'nid'
run Nid.new
