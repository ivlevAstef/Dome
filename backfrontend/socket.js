const geoip = require('geoip-lite');
var dateFormat = require('dateformat');
const uuidv1 = require('uuid/v1'); //npm install uuid
const WebSocket = require('ws');
//var Cookies = require('cookie');
//var cookieParser = require('cookie-parser');
var atob = require('atob');
var btoa = require('btoa');
var xss = require("xss");
const utf8 = require('utf8');
var passwordHash = require('password-hash');
var NodeSession = require('node-session')
const admin = false;

const mysql = require("mysql2");
const connmysql = mysql.createConnection({
  host: "localhost",
  user: "first",
  database: "first",
  password: "}uR2TZD?z*d?c7p",
  //charset : 'utf8mb4'
  charset : 'utf8',
  //character_set_database : 'Latin1'

});

connmysql.connect(function(err){
    if (err) {
      return console.error("Ошибка: " + err.message);
    }
    else{
      console.log("Подключение к серверу MySQL успешно установлено");
    }
 });
 
var sql1 = "DROP TABLE IF EXISTS users_admin ";
connmysql.query(sql1, function(err, results) {
    if (err) throw err;
console.log("Table users_admin dropped");
});

var hashedPassword = passwordHash.generate('admin');
var sql2 = "CREATE TABLE users_admin " +
                " (id INT not null AUTO_INCREMENT, " +
                " sesID VARCHAR(255), " +
                " ip VARCHAR(255), " +
                " passwordHash VARCHAR(255), " +
                " login VARCHAR(255), " +
                " datetime timestamp, " +
                " PRIMARY KEY (Id) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;";                
connmysql.query(sql2, function(err, results) {
    if(err) console.log(err);
    else console.log("Данные добавлены");
});

const sql = "INSERT INTO users_admin (sesID, passwordHash, ip, login, datetime) VALUES('',"+connmysql.escape(hashedPassword)+" ,'','admin', NOW())";
connmysql.query(sql, function(err, results) {
    if(err) console.log(err);
    else console.log("Данные добавлены");
});

/*
var sql1 = "DROP TABLE IF EXISTS users ";
connmysql.query(sql1, function(err, results) {
    if (err) throw err;
console.log("Table users dropped");
});
var sql2 = "CREATE TABLE users " +
                " (id INT not null AUTO_INCREMENT, " +
                " imei VARCHAR(255), " +
                " system VARCHAR(255), " +
                " genkeycode VARCHAR(255), " +
                " fullname VARCHAR(255), " +
                " position VARCHAR(255), " +
                " gps VARCHAR(50), " +
                " status VARCHAR(1), " +
                " datetime timestamp, " +
                " PRIMARY KEY (Id) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;";  

connmysql.query(sql2, function(err, results) {
    if(err) console.log(err);
    else console.log("Данные добавлены");
});*/
            
//connmysql.query("SET NAMES 'utf8mb4'");
//connmysql.query("SET CHARACTER SET utf8mb4");
/*
var mysql = require('mysql');
var connmysql = mysql.createConnection({
  database: 'first',
  host: "localhost",
  user: "first",
  password: "}uR2TZD?z*d?c7p"
});
 
connmysql.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

/*
            var sql1 = "DROP TABLE IF EXISTS messages ";
            connmysql.query(sql1, function(err, results) {
                if (err) throw err;
                console.log("Table messages dropped");
            });

            // Create messages Table.
            var sql2 = "CREATE TABLE messages " +
                " (id INT not null AUTO_INCREMENT, " +
                " user_from VARCHAR(40), " +
                " user_to VARCHAR(40), " +
                " message TEXT, " +
                " datetime timestamp, " +
                " PRIMARY KEY (Id) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;";
         
            connmysql.query(sql2, function(err, results) {
                if (err) throw err;
                console.log("Table messages created");
            });
  */          
//var connect = require('connect');
//const querystring = require('querystring');
//const clientSessions = require("client-sessions");
/*

var nodeSession = new NodeSession({secret: 'F3UBzdH96Efi3CTKai5MTPyChpuXLs9D',
                           'driver': 'file',
                           'files': process.cwd() + '/sessions',
                           'cookie': 'node_session',
                           'lifetime': 300000000, // 5000 minutes
                           'expireOnClose': false,
                           'domain': null,
                           'encrypt': false,
                           'secure': false});
*/                        
//Synchronously//Asynchronously geoip
geoip.reloadDataSync(); 
geoip.reloadData(function(){console.log("Geoip Done")});
// создаём новый websocket-серверconst 
wss = new WebSocket.Server({port:5000});

//wss.set('log level', 1);
//  отправляем клиентам, когда функция clientValidator возвращает true. this — это wss.
/*wss.broadcast = function(data) {
    for(var i in this.clients) {
        console.log(this.clients[i]);
        this.clients[i].send(data);
    }
};

/*
wss.broadcast = function(data) {
  for(var i in wss.clients) {
    console.log(wss.clients[i]);
    wss.clients[i].send(data);
  }
};*/

wss.broadcast = function(data) {
  this.clients.forEach(function each(client) {
            client.send(data)
        })
}
// подключенные клиенты
var clientsOnLine = [];
var keys = ['keyboard cat']
function count(array)
{
    var cnt=0;
    for (var i in array)
        {
        if (i)
            {
            cnt++
            }
        }
    return cnt
}

SocketAmdins = [];
SocketClients = [];

wss.on("connection",  (ws, req) => {
    id = 'token';
    var socket_id = '';
    var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
    //console.log("add guest ip: " + ip)
    ws.on('message', data => {
        var data1 = JSON.parse(data);
        console.log(data1);
        
        if(data1.e == 'users'){
            var sql1 = "SELECT * FROM users ORDER BY status, id DESC";
            connmysql.query(sql1, function (err, results, fields) {
                if (err) throw err;
                //console.log(results)
                results.forEach(function(row) {
                    Data = new Date();
                    Data.setTime(row.datetime);
                    Year = Data.getFullYear();
                    Month = Data.getMonth();
                    Day = Data.getDate();
                    Hour = Data.getHours();
                    Minutes = Data.getMinutes();
                    Seconds = Data.getSeconds();
                    var dat = Year+"-"+Month+"-"+Day+" "+Hour+":"+Minutes+":"+Seconds;
                    ws.send(JSON.stringify({'e':'users', 'id':row.id, 'imei':row.imei, 'system':row.system, 'fullname':row.fullname, 'status':row.status,'date':dat}));
                });
            });
        }
        if(data1.e == 'token'){
            if (data1.m == undefined){
                id = uuidv1();
                //id = Math.floor(Math.random()*10)+id+Math.floor(Math.random()*10)
                ws.send(JSON.stringify({'e':'token', 'm':id}))
            }else{
                id = data1.m
                ws.send(JSON.stringify({'e':'test', 'm':id}))
            }
            
            
            const symbolKey = Reflect.ownKeys(ws._sender._socket).find(key => key.toString() === 'Symbol(asyncId)')
            socket_id = ws._sender._socket[symbolKey]
            if (!clientsOnLine.indexOf(id)) 
                clientsOnLine.push(id)
                //if (!clientsOnLine[id][ws]) 
                //console.log(ws._sender._socket[symbolKey])//['Symbol(asyncId)'])//.server.Symbol(asyncId)
                clientsOnLine[id] = []
                clientsOnLine[id][socket_id]=[ws]
            
            var tc = count(clientsOnLine)
            console.log("online:"+tc)
            wss.broadcast(JSON.stringify({'e':'o', 'm':tc}))
            /*
            connmysql.query("SELECT * FROM messages", function (err, result, fields) {
                if (err) throw err;
                result.forEach(function(row) {
                    //console.log(row.message);
                    //var dateTime = new Date();
                    Data = new Date();
                    Data.setTime(row.datetime);
                    Hour = Data.getHours();
                    Minutes = Data.getMinutes();
                    Seconds = Data.getSeconds();
                    //dateFormat(now, "dddd, mmmm dS, yyyy, h:MM:ss TT");
                    var tt = Hour+":"+Minutes+":"+Seconds;
                    //var tt =  Date.UTC(dateTime.getFullYear(), dateTime.getMonth(), dateTime.getDate(), dateTime.getHours(), dateTime.getMinutes());

                    ws.send(JSON.stringify({'e':'m','d':(tt) ,'m':xss(row.message)}));
                });
             
            });
            
            //wss.broadcast(atob('connect new user'), client => client !== ws)
            /*
            connmysql.connect(function(err) {
                if (err) {
                    throw err;
                }
                console.log("Connected!");
            });
            //console.log(ws._sender._socket)
            //console.log('==============================================================')//.server.Symbol(asyncId)
            */
            /*connmysql.query("SELECT * FROM messages",
            function(err, results, fields) {
                console.log(err);
                console.log(results); 
                console.log(fields);  
            });*/
        }else
        if(data1.e == 'test'){
            ws.send(JSON.stringify({'e':'test', 'm':id}))
        }else
        if(data1.e == 'mobile'){
            admin = false;
            //['e':'mobile','imei':'213131sd32...do256str.','system':'ios','genkeycode':'random121s1s do 256']
            //['e':'mobile','imei':'213131sd32...do256str.','system':'android','genkeycode':'random121s1s do 256']
            var sql = "SELECT * FROM users WHERE imei = "+connmysql.escape(data1.imei)+
                        " AND system = "+connmysql.escape(data1.system)+
                        " AND genkeycode = "+connmysql.escape(data1.genkeycode)+" LIMIT 1";

            connmysql.query(sql, function (err, result, fields){
                if (err) throw err;
                loginin = false;
                if(result.length==0){
                    const sql = "INSERT INTO users (imei, system, genkeycode, datetime) VALUES("+connmysql.escape(data1.imei)+", "+connmysql.escape(data1.system)+", "+connmysql.escape(data1.genkeycode)+", NOW());";
                    //const arr = [connmysql.escape(data1.imei), connmysql.escape(data1.system), connmysql.escape(data1.genkeycode)]
                    //const sql = "INSERT INTO users (imei, system, genkeycode, datetime) VALUES(?,?,?,NOW());";

                    connmysql.query(sql, function(err, result) {
                        if(err) console.log(err);
                        console.log('Добавился пользователь: '+result.insertId);
                        var iduser = result.insertId;
                        SocketClients.push(iduser);
                        SocketClients[iduser] = ws;
                        ws.send(JSON.stringify({'e':'mobile','id':iduser}));
                    });
                }else{
                        result.forEach(function(row) {
                            var iduser = row.id;
                            SocketClients.push(iduser);
                            SocketClients[iduser] = ws;
                            var sql = "UPDATE users SET status=1, datetime = NOW() WHERE id = "+row.id;
                            console.log('Подключился пользователь: '+row.id);
                            ws.send(JSON.stringify({'e':'mobile','id':iduser}));
                    });
                }
            });
        }
        if(data1.e == 'login'){
            var admin = true;
            var loginin = false;
            //console.log(data1.e+ ' '+data1.l+ ' '+data1.p)
            //var hashedPassword = passwordHash.generate(data1.p);
            var sql = "SELECT * FROM users_admin WHERE login = "+connmysql.escape(data1.l)+" LIMIT 1";
            //console.log(sql);
            connmysql.query(sql, function (err, result, fields) {
                if (err) throw err;
                loginin = false;
                //console.log(result);
                result.forEach(function(row) {
                    Data = new Date();
                    Data.setTime(row.datetime);
                    Hour = Data.getHours();
                    Minutes = Data.getMinutes();
                    Seconds = Data.getSeconds();
                    if (passwordHash.verify(data1.p, row.passwordHash)){
                        loginin = true;
                        SocketAmdins.push(row.id);
                        SocketAmdins[row.id]=ws;
                        var sql = "UPDATE users_admin SET sesID="+connmysql.escape(id)+", ip = "+connmysql.escape(ip)+", datetime = NOW() WHERE id = "+row.id+"";
                        connmysql.query(sql, function (error, results, fields) {
                            if (error) throw error;
                        });
                        ws.send(JSON.stringify({'e':'login','href':'https://first.com.ru/users.html'}));
                    }
                    //var tt = Hour+":"+Minutes+":"+Seconds;
                    //var tt =  Date.UTC(dateTime.getFullYear(), dateTime.getMonth(), dateTime.getDate(), dateTime.getHours(), dateTime.getMinutes());

                    //ws.send(JSON.stringify({'e':'m','d':(tt) ,'m':xss(row.message)}));
                });
                if (loginin==false) ws.send(JSON.stringify({'e':'login','go':false, 'text':'Пароль указан не верно!'}));
             
            });
            
            //console.log(hashedPassword);
            
            //if(passwordHash.verify(data1.p, "sha1$a8b0017c$1$fd3b9c81fd92c66017be8435b40fedb3ebf60a9e"));
            //console.log(passwordHash.isHashed(hashedPassword));
            /*exports.cryptPassword = function(password, callback) { bcrypt.genSalt(10, function(err, salt) { if (err) return callback(err); bcrypt.hash(password, salt, function(err, hash) { return callback(err, hash); }); });
            };
            exports.comparePassword = function(plainPass, hashword, callback) { bcrypt.compare(plainPass, hashword, function(err, isPasswordMatch) { return err == null ? callback(null, isPasswordMatch) : callback(err); });
            };*/
        }else
        if(data1.e == 'm'){
            Data = new Date();
            Hour = Data.getHours();
            Minutes = Data.getMinutes();
            Seconds = Data.getSeconds();
            //ws.send(JSON.stringify({'e':(data1.e), 'm':(data1.m)}))
            //wss.broadcast(JSON.stringify({'e':(data.e), 'm':(data.m)}));
            //mes = data1.m.replace(/[\u0800-\uFFFF]/g, '');
            //mes = utf8.decode(data1.m);
             //var mes = iconv.decode(data1.m, "CP866");
             mes = data1.m;
             /*
            const message = [0,0,connmysql.escape(data1.m)];
            const sql = "INSERT INTO messages (user_from, user_to, message, datetime) VALUES(?, ?, ?, NOW())";
            connmysql.query(sql, message, function(err, results) {
                if(err) console.log(err);
                else console.log("Данные добавлены");
            });
            const sql = "INSERT INTO messages (user_from, user_to, message, datetime) VALUES(0, 0, "+connmysql.escape(data1.m)+", NOW())";
            connmysql.query(sql, function(err, results) {
                if(err) console.log(err);
                else console.log("Данные добавлены");
            });*/
            
            
            wss.broadcast(JSON.stringify({'e':'m','d':(Hour+':'+Minutes+':'+Seconds) ,'m':xss(data1.m)}))
        }else{
            
        }
        //data = JSON.Parse(data)
        //var textsend = JSON.stringify({'e':'ответ получен'})
        //ws.send(data) себе
        /*for (var key in clients) {
            clients[key].send(message);
        }*/ 
          /*              
        switch (data) { 
        	case 'client':
                ws.send(data)
        		break; 
        	case 'message':
                ws.send(data)
        		break; 
        	case 'alert':
                wss.broadcast(data, client => client !== ws);  
                //ws.send(data.msg)
        		break;
            default:
        		break;
        }*/
        
        
    })
    ws.on('close', function() {
        console.log('соединение закрыто ' + id);
        if (admin == false) delete SocketClients[id];
        else  delete SocketAmdins[id];
        
        delete clientsOnLine[id][socket_id];
        
        if (count(clientsOnLine[id])==0)
            delete clientsOnLine[id];
        //clientsOnLine.splice(id, 1);
        var tc = count(clientsOnLine)
        console.log("online:"+tc)
        wss.broadcast(JSON.stringify({'e':'o', 'm':tc })) 
    })
    
   // })
    
})
/*
constWebSocket = require('ws')
const wss = newWebSocket.Server({ port: 5000 })
wss.on('connection', ws => {
  ws.on('message', message => {
    console.log(`Received message => ${message}`)
  })
  ws.send('ho!')
})
/*

var io = require('socket.io').listen(5000);
//var io = require('socket.io');
//var express = require('express');

//var app = express.createServer()
//var io = io.listen(app);

//app.listen(5000);

io.sockets.on('connection', function (socket) {
    
    var socketCount = 0;
  
    socketCount++;

    console.log('new user connected');

    // Let all sockets know how many are connected
    socket.emit('users connected', socketCount);

    socket.on('disconnect', function(){
    // Decrease the socket count on a disconnect, emit
    socketCount--;
    socket.emit('users connected', socketCount);
    });

  socket.on('chat message', function(msg){
    // New message added, broadcast it to all sockets
    io.emit('chat message', msg);
  });
});
// гарантированное закрытие  базы данных
 connection.end(function(err) {
  if (err) {
    return console.log("Ошибка: " + err.message);
  }
  console.log("Подключение закрыто");
});
*/
