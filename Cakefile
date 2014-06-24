fs = require 'fs'
{spawn} = require 'child_process'

build = (callback)->
  coffee1 = spawn 'coffee', ['-c', '-o', 'build', 'server.coffee']
  coffee2 = spawn 'coffee', ['-c', '-o', 'build/www', 'main.coffee']

task 'build', ->
  build() 
