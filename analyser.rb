#!/usr/bin/env ruby

require './lib/macbeth'

macbeth = Macbeth.new
macbeth.analyze
puts macbeth.results
