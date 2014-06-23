window.onload = function() {
  var chat = new Chat();
  chat.init();
}

function Chat() {}

Chat.prototype = {
  init: function() {
    var that = this;
    this.socket = io.connect();

    this.socket.on('connect', function(){
      document.getElementById('info').textContent = 'a nick name :)';
      document.getElementById('nickWrapper').style.display = 'block';
      document.getElementById('nicknameInput').focus();
    });

    this.socket.on('nickExisted', function() {
      document.getElementById('info').textContent = 'nickName is taken, choose another please';
    });

    this.socket.on('loginSuccess', function() {
      document.title = 'node-chat | ' + document.getElementById('nicknameInput').value;
      document.getElementById('loginWrapper').style.display = 'none';
      document.getElementById('messageInput').focus();
    });

    this.socket.on('system', function(nickName, userCount, type) {
      var msg = nickName + (type == 'login'? ' joined' : ' left');
      that.displayMsg('system', msg, 'red');
      document.getElementById('status').textContent = userCount + ' users online';
    });

    this.socket.on('newMsg', function(user, msg, color) {
      that.displayMsg(user, msg, color);
    });

    document.getElementById('loginBtn').addEventListener('click', function() {
      var nickName = document.getElementById('nicknameInput').value;

      if (nickName != "") {
        that.socket.emit('login', nickName);
      } else {
        document.getElementById('nicknameInput').focus();
      }
    }, false);

    document.getElementById('sendBtn').addEventListener('click', function(){
      var msg = document.getElementById('messageInput').value;
      var color = document.getElementById('colorStyle').value;
      document.getElementById('messageInput').value = '';
      document.getElementById('messageInput').focus();
      if (msg.trim().length != 0) {
        that.socket.emit('postMsg', msg, color);
        that.displayMsg('me', msg, color);
      }
    });

    this.initEmoji();
    document.getElementById('emojiButton').addEventListener('click', function(e) {
      var emojiwrapper = document.getElementById('emojiWrapper');
      emojiwrapper.style.display = 'block';
      e.stopPropagation();
    }, false);

    document.body.addEventListener('click', function(e) {
      var emojiwrapper = document.getElementById('emojiWrapper');
      if (e.target != emojiwrapper) {
        emojiwrapper.style.display = 'none';
      }
    });

    document.getElementById('emojiWrapper').addEventListener('click', function(e) {
      var target = e.target;
      if (target.nodeName.toLowerCase() == 'span') {
        var messageInput = document.getElementById('messageInput');
        messageInput.focus();
        messageInput.value = messageInput.value + '[emoji:' + target.title + ']';
      };
    }, false);

    document.getElementById('nicknameInput').addEventListener('keyup', function(e) {
      // enter press
      if (e.keycode == 13) {
        var nickName = document.getElementById('nicknameInput').value;
        if (nickName != "") {
          that.socket.emit('login', nickName);
        };
      }
    }, false);

    document.getElementById('messageInput').addEventListener('keyup', function(e) {
      var messageInput = document.getElementById('messageInput');
      var msg = messageInput.value;
      color = document.getElementById('colorStyle').value;
      if (e.keyCode == 13 && msg != "") {
        messageInput.value = "";
        that.socket.emit('postMsg', msg, color);
        that.displayMsg('me', msg, color);
      }
    }, false);

    document.getElementById('clearBtn').addEventListener('click', function(e) {
      document.getElementById('historyMsg').innerHTML = "";
    }, false);
  },

  displayMsg: function(user, msg, color) {
    var container = document.getElementById('historyMsg'),
        msgToDisplay = document.createElement('p'),
        date = new Date().toTimeString().substr(0, 8),
        msg = this.showEmoji(msg);
    msgToDisplay.style.color = color || '#000';
    msgToDisplay.innerHTML = user + '<span class="timespan">(' + date + "):</span>" + msg;
    container.appendChild(msgToDisplay); 
    container.scrollTop = container.scrollHeight;
  },

  initEmoji: function() {
    var container = document.getElementById('emojiWrapper'),
        frag = document.createDocumentFragment();
    
    var count = 0;
    for (var key in jEmoji.EMOJI_MAP) {
      var s = document.createElement('span');
      console.log(jEmoji.EMOJI_MAP[key]);
      s.innerHTML = (jEmoji.unifiedToHTML(key));
      frag.appendChild(s);
      ++count;
      if (count > 225)
        break;
    }
    container.appendChild(frag);
  },

  showEmoji: function(msg) {
    var match, result = msg,
        reg = /\[emoji:[\w ]+\]/g,
        emojiName;
    while (match = reg.exec(msg)) {
      emojiName = match[0].slice(7, -1);
      for (var key in jEmoji.EMOJI_MAP) {
        if (jEmoji.EMOJI_MAP[key][1] == emojiName) {
          result = result.replace(match[0], jEmoji.unifiedToHTML(key));
          break;
        }
      }
    }
    return result;
  }
};
