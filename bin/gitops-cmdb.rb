#!/usr/bin/env ruby

# add lib/ folder to the path
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'gitops_cmdb'
require 'gitops_cmdb/cli'

puts GitopsCmdb::CLI.new.run
