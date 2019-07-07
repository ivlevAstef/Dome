var token = $.cookie('token');
const url = "wss://first.com.ru/ws/";
//const url = "wss://first.com.ru:5000";

var socket = null;
$(document).ready(function() {
    function sendMessage(t, m) {
        socket.send(JSON.stringify({'e':t, 'm':m}));
    }
    function sendLogin(l, p) {
        socket.send(JSON.stringify({'e':'login', 'l':l, 'p':p }));
    }
    function getMessage(m) {
        return JSON.parse(m)
    }
    function start(){
        socket = new WebSocket(url);
        socket.onopen = function(){
          sendMessage('token', token) 
          //$('.send').val('Отправить')
        }
        socket.onerror = (e) => {
          console.log(`WebSocket error: ${e}`)
        }
        socket.onclose = function(){
          console.log('обрыв');
          //$('.send').val('обрыв');
          $('.message').append('<div class="message_st"><span class="dt">'+t.d+'</span> '+t.m+'</div>');
          check();
        }
    
        socket.onmessage = (e) => {
            var t = getMessage(e.data)
            switch (t.e) { 
                	case 'm':
                        //ws.send(t.msg)
                        /*
                        var audio = new Audio();
                        audio.src = '/mp3/stairs.mp3';
                        audio.autoplay = true;
                        $('.message').append('<div class="message_st"><span class="dt">'+t.d+'</span> '+t.m+'</div>')
                        */
                        //console.log(t.m)
                		break; 
                    case 'token':
                        //alert(t.m)
                        $.cookie('token', t.m)
                        break;
                	case 'o':
                        $('.online span').html(t.m)
                		break; 
                	case 'login':
                        if (t.go== false){
                                $('.danger').html(t.text);
                            }else{
                                window.location.href = t.href;
                            }
                		break; 
                	case 'test':
                        //console.log(t.m)
                		break; 
                	case 'error':
                        alert(t.m)
                		break; 
            }
            //$('.message').append('<p>'+t+'<p>')
            //console.log(e)
        }
    }
    function check(){
        if(!socket || socket.readyState == 3) start();
    }
    
    start();
    
    setInterval(check, 5000);
  
  
    $(document).on('keypress',function(e) {
        if(e.which == 13) {
            $('.send').click();
        }
    });
    $('.login_btn').click(function(){
        var l = $('.username').val();
        var p = $('.password').val();
        sendLogin(l, p);
        return false;
    });
    $('.send').click(function(){
        var msgs = $('.myTextArea').val();
        if (msgs==''){$('.myTextArea').css('border','1px solid #ff0000');return false;}
        $('.myTextArea').css('border','1px solid #666');
        $('.myTextArea').val('');
        sendMessage('m', msgs);
    });
    $('.test').click(function(){
        sendMessage('test','test');
       // sendMessage('message', msgs);
    });
    
});