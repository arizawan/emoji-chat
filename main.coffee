window.onload = ->
  chat = new Chat()
  chat.init()

class Chat
  init: ->
    that = this
    this.socket = io.connect()
    this.socket.on 'connect', ->
      document.getElementById 'info'
        .textContent = 'a nick name :)'
      document.getElementById 'nickWrapper'
        .style.display = 'block'
      document.getElementById 'nicknameInput'
        .focus() 

    this.socket.on 'nickExisted', ->
      document.getElementById 'info'
        .textContent = 'nickName is taken, choose another please'
   
    this.socket.on 'loginSuccess', ->
      document.title = 'node-chat' + document.getElementById 'nicknameInput'
      document.getElementById 'loginWrapper'
        .style.display = 'none'
      document.getElementById 'messageInput'  
        .focus()

    this.socket.on 'system', (nickName, userCount, type)->
      msg = nickName + if type is 'login' then ' joined' else ' left'
      that.displayMsg 'system', msg, 'red'
      document.getElementById 'status'
        .textContent = "#{userCount} users online"

    this.socket.on 'newMsg', (user, msg, color) ->
      that.displayMsg user, msg, color

    document.getElementById 'loginBtn'
      .addEventListener 'click', ->
        nickName = document.getElementById 'nicknameInput' 
          .value
        if nickName isnt ""
          that.socket.emit 'login', nickName
        else
          document.getElementById 'nicknameInput'
            .focus()
      ,false

    document.getElementById 'sendBtn'
      .addEventListener 'click', ->
        msg = document.getElementById 'messageInput'
          .value
        color = document.getElementById 'colorStyle'
          .value
        document.getElementById 'messageInput'
          .value = ''
        document.getElementById 'messageInput'
          .focus()
        if msg.trim().length != 0
          that.socket.emit 'postMsg', msg, color
          that.displayMsg 'me', msg, color
      ,false    

    this.initEmoji()
    document.getElementById 'emojiButton'
      .addEventListener 'click', (e) ->
        emojiwrapper = document.getElementById 'emojiWrapper'
        emojiwrapper.style.display = 'block'
        e.stopPropagation();
      ,false

    document.body.addEventListener 'click', (e)->
      emojiwrapper = document.getElementById 'emojiWrapper' 
      emojiwrapper.style.display = 'none' if e.target isnt emojiwrapper

    document.getElementById 'emojiWrapper'
      .addEventListener 'click', (e)->
        target = e.target
        if target.nodeName.toLowerCase() is 'span'
          messageInput = document.getElementById 'messageInput'
          messageInput.focus()
          messageInput.value = "#{messageInput.value}[emoji:#{target.title}]"
      ,false

    document.getElementById 'nicknameInput'
      .addEventListener 'keyup', (e)->
        if e.keyCode == 13
          nickName = document.getElementById 'nicknameInput'
            .value
          that.socket.emit 'login', nickName if nickName isnt "" 
      ,false

    document.getElementById 'messageInput'
      .addEventListener 'keyup', (e)->
        if e.keyCode == 13 and msg isnt "" 
          messageInput = document.getElementById 'messageInput'
          msg = messageInput.value
          color = document.getElementById 'colorStyle' .value
          messageInput.value = ""
          that.socket.emit 'postMsg', msg, color
          that.displayMsg 'me', msg, color
      ,false

    document.getElementById 'clearBtn'
     .addEventListener 'click', (e)->
       document.getElementById 'historyMsg'
         .innerHTML = ""
     ,false
     
  displayMsg: (user, msg, color)->
    container = document.getElementById 'historyMsg'
    msgToDisplay = document.createElement 'p'
    date = new Date().toTimeString().substr 0, 8 
    msg = this.showEmoji msg
    msgToDisplay.style.color = color || '#000'
    msgToDisplay.innerHTML = "#{user}<span class=\"timespan\">(#{date}):</span>#{msg}";
    container.appendChild msgToDisplay
    container.scrollTop = container.scrollHeight

  initEmoji: ->
    container = document.getElementById('emojiWrapper')
    frag = document.createDocumentFragment()
    count = 0
    console.log jEmoji.EMOJI_MAP.length
    for key, value of jEmoji.EMOJI_MAP 
      console.log key
      s = document.createElement 'span'
      s.innerHTML = jEmoji.unifiedToHTML(key)
      frag.appendChild s
      ++count
      if count > 225 then break
    container.appendChild frag

  showEmoji: (msg)->
    result = msg
    reg = /\[emoji:[\w ]+\]/g

    while match = reg.exec msg
      emojiName = match[0].slice 7,-1
      result = result.replace match[0], jEmoji.unifiedToHTML key for key,value of jEmoji.EMOJI_MAP when jEmoji.EMOJI_MAP[key][1] is emojiName
    result

