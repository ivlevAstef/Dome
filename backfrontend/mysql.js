var express = require('express')
  , Koa = require('koa')
  , nodeMyAdmin = require('node-mysql-admin');
  
const app = new Koa();
const expressApp = express();
expressApp.use(nodeMyAdmin(expressApp));
 
app.use(function*(next) {
    // do routing by simple matching, koa-route may also work
    if (this.path.startsWith('/myadmin')) {
        // direct to express
        if (this.status === 404 || this.status === '404') {
            delete this.res.statusCode
        }
        // stop koa future processing (NOTE not sure it is un-doc feature or not?)
        this.respond = false
        // pass req and res to express
        expressApp(this.req, this.res)
    } else {
        // go to next middleware
        yield next
    }
});
app.listen(3003);