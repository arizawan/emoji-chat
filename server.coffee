http = require 'http'
express = require 'express'
app = express() 
server = http.createServer app
io = require 'socket.io'
  .listen(server)    

users = []

app.use '/', express.static "#{__dirname}/www" 

server.listen 8888

io.on 'connection', (socket) ->
  socket.on 'login', (name) ->
    console.log "User: #{name} login!"
    if (users.indexOf name) > -1
      socket.emit 'nickExisted'
    else
      socket.userIndex = users.length;
      socket.nickname = name;
      users.push name
      socket.emit 'loginSuccess'
      io.sockets.emit 'system', name, users.length,'login'

  socket.on 'disconnect', ->
    users.splice socket.userIndex, 1
    socket.broadcast.emit 'system', socket.nickname, users.length, 'logout'
  
  socket.on 'postMsg', (msg, color)->
    socket.broadcast.emit 'newMsg', socket.nickname, msg, color
