express = require('express')
connect = require 'connect'
passport = require('passport')
util = require('util')
LocalStrategy = require('passport-local').Strategy
r = require('./ndollar.js');

#Recognition Shit
recognizer = new r.NDollarRecognizer(true);
threshold = .8

verify = (strokes, name) ->
  result = recognizer.Recognize(strokes, true, true)
  return (result.name == name && result.score > threshold)

findById = (id, fn) ->
  idx = id - 1
  if users[idx]
    fn null, users[idx]
  else
    fn new Error("User " + id + " does not exist")
findByUsername = (username, fn) ->
  i = 0
  len = users.length

  while i < len
    user = users[i]
    return fn(null, user)  if user.username is username
    i++
  fn null, null

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  findById id, (err, user) ->
    done err, user

passport.use new LocalStrategy((username, password, done) ->
  process.nextTick ->
    findByUsername username, (err, user) ->
      return done(err)  if err
      unless user
        return done(null, false,
          message: "Unkown user " + username
        )
      unless user.password is password
        return done(null, false,
          message: "Invalid password"
        )
      done null, user
)

#--------------------------------

app = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use connect.static(__dirname + '/public')
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session(secret: "keyboard cat")
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use express.static(__dirname + "/../../public")

app.get "/", (req, res) ->
  res.render "index",
    user: req.user

app.get "/account", ensureAuthenticated, (req, res) ->
  res.render "account",
    user: req.user

app.get "/login", (req, res) ->
  res.render "login",
    user: req.user
    message: req.flash("error")

app.get "/send", (req, res) ->
  console.log(req.data)

app.post "/sendT", (req, res) ->
  recognizer.AddMultistroke(req.body.username, true, req.body.data)
   
app.post "/send", (req, res) ->
  console.log("-----")
  console.log(req.body.data)
  console.log(req.body)
  #console.log(req)
  console.log("---------")
  #console.log(res)
  res.send(verify(req.body.data,req.body.username))

app.get "/register", (req, res) ->
  res.render "hello"

app.post "/register", (req, res) ->
  res.render "hello"

app.post "/login", passport.authenticate("local",
  failureRedirect: "/login"
  failureFlash: true
), (req, res) ->
  res.redirect "/"

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen 3000

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/login"

console.log 'running'
