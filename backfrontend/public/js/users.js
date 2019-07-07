var token = $.cookie('token');
const url = "wss://first.com.ru/ws/";

var socket = null;
$(document).ready(function() {
    function sendMessage(t, m) {
        socket.send(JSON.stringify({'e':t, 'm':m}));
    }
    function getMessage(m) {
        return JSON.parse(m)
    }
    function start(){
        socket = new WebSocket(url);
        socket.onopen = function(){
            socket.send(JSON.stringify({e:'tocken', m:token}));
            socket.send(JSON.stringify({e:'users'}));
        }
        socket.onerror = (e) => {
          console.log(`WebSocket error: ${e}`)
        }
        socket.onclose = function(){
          console.log('обрыв');
          check();
        }
    
        socket.onmessage = (e) => {
            var t = getMessage(e.data)
            switch (t.e) { 
                	case 'alarm':
                      var audio = new Audio();
                      audio.src = '/mp3/alarm.mp3';
                      audio.autoplay = true;
                      $('.message').append('<div class="message_st"><span class="dt">'+t.d+'</span> '+t.m+'</div>')
              		  //break; 
                    case 'token':
                        $.cookie('token', t.m)
                        break;
                	case 'users':
                        if(t.fullname==null) t.fullname = '<input type="hidden" class="fullname" id="'+t.id+'" placeholder="Введите ФИО"><button type="submit" refid="'+t.id+'" class="btn btn-warning fullnamechange">Изменить</button>'; //btn btn-primary
                        if (t.status==0){var classs='green';}else{classs='red'}
                        $('table.users tbody').html('<tr class="trid'+t.id+' '+classs+'"><th scope="row">'+t.id+'</th><td>'+t.fullname+'</td><td>'+t.imei+'</td><td>'+t.system+'</td><td>'+t.date+'</td></tr>');
                		break; 
                	case 'test':
                        console.log(t.m)
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
   
    $('.fullnamechange').click(function(){
        $(this).html('Сохранить');
        $(this).removeClass('btn-warning');
        $(this).addClass('btn-primary');
        /*
        var msgs = $('.myTextArea').val();
        if (msgs==''){$('.myTextArea').css('border','1px solid #ff0000');return false;}
        $('.myTextArea').css('border','1px solid #666');
        $('.myTextArea').val('');
        sendMessage('m', msgs);*/
        return false;
    });/*
    $('.test').click(function(){
        sendMessage('test','test');
    });*/
    
});