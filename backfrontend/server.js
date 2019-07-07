//const uuidv1 = require('uuid/v1')
//const geoip = require('geoip-lite')
//var NodeSession = require('node-session');
/*
session = new NodeSession({secret: 'F3UBzdH96Efi3CTKai5MTPyChpuXLs9D',
                           'driver': 'file',
                           'files': process.cwd() + '/sessions',
                           'cookie': 'node_session',
                           'lifetime': 300000000, // 5000 minutes
                           'expireOnClose': false,
                           'domain': null,
                           'encrypt': false,
                           'secure': false});
*/
//var http = require('http')
var fs = require('fs')
const path = require('path')
const express = require('express')
const app = express()
const port = 3000

//app.get('/', (req, res) => (e,s) = {res.send('Hello World!'))
app.use('/', express.static(__dirname + '/public'));
app.listen(port, () => console.log(`Example app listening on port ${port}!`))

//    Cookies = require('cookies')
//var Cookie = require('cookie');
//const uuidv1 = require('uuid/v1');
    // NEVER use a Sync function except at start-up!
    //index = fs.readFileSync(__dirname + '/index.html');
/*var filename = '/home/first.com.ru/nodejs/index.html';
var app = http.createServer(function(req, res) {
    var keys = ['keyboard cat']
    res.writeHead(200, {'Content-Type': 'text/html'});
    fs.readFile(filename, "utf8", function(err, data) {
        if (err) throw err;
        res.write(data);
        res.end();
    });
    
});
app.listen(3000);
/*

const http = require('http');
const geoip = require('geoip-lite');
//Synchronously
geoip.reloadDataSync(); 
//Asynchronously
geoip.reloadData(function(){
    console.log("Geoip Done");
});

module.exports.x = "Vasya";
module.exports.f1 = function() {
     return 100;
};

const hostname = '127.0.0.1';
const port = 3000;
//var ip = req.info.remoteAddress
//req.header('x-forwarded-for') || req.connection.remoteAddress;
//req.info.remoteAddress

const server = http.createServer((request, response) => {
    response.statusCode = 200;
    response.setHeader('Content-Type', 'text/plain');
    response.end('Hello, World\n');
    
    var ip = request.headers['x-forwarded-for'] || request.connection.remoteAddress;
    var geo = geoip.lookup(ip);
    console.log('User IP:'+ip);
    console.log(geo);
    
});

server.listen(port, hostname, () => {
  console.log('Server running at http://${hostname}:${port}/');
});*/