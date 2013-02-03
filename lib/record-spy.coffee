fs          = require 'fs'
https       = require 'https'
urlUtil     = require 'url'
request     = require 'request'
querystring = require 'querystring'
constants   = require 'constants'

userAgentString = 'CourseShark Record-Crawler/nodejs 0.0.1'

# Export the main object
exports = module.exports = () ->

  # We return this unnnamed object (class)
  cookieJar: request.jar()

  transcriptRaw: (if fs.existsSync('./tempTranscript.html') then ""+(fs.readFileSync './tempTranscript.html') else false)

  urlSet:
    'login-get':
      'https://oscar.gatech.edu/pls/bprod/twbkwbis.P_WWWLogin'
    'login-post':
      'https://oscar.gatech.edu/pls/bprod/twbkwbis.P_ValLogin'
    'transcript-get':
      'https://oscar.gatech.edu/pls/bprod/bwskotrn.P_ViewTran'

  authenticate: (userId, userPass, callback=(()->return)) ->
    if process.env.NODE_ENV is 'test!'
      @authenticated = (userPass.toString() is process.env.GTPIN.toString())
      return callback(@authenticated)
    @apiCall 'login-get', (err, data) =>
      @apiCall 'login-post',
        method: 'POST'
        sid: userId
        PIN: userPass
        , (err,body='') =>
          @authenticated = not not body.match(/Welcome/ig)
          callback(@authenticated)

  pullTranscript: (userId, userPass, callback=(()->return)) ->
    makeCall = ()=>
      @apiCall 'transcript-get',
        method: 'POST'
        levl: ''
        tprt: 'ADVW'
        , (err,body='') =>
          @transcriptRaw = body
          callback(err, body)

    # Return if we have it TODO REMOVE THIS
    if @transcriptRaw
      return callback(null, @transcriptRaw)

    # Login if need be
    if not @authenticated
      @authenticate userId, userPass, (authSuccess)=>
        if not authSuccess
          return callback new Error 'Incorrect authentication credentials'
        makeCall()
    else
      makeCall()




  getTranscriptClasses: (userId, userPass, callback=(()->return)) ->
    if not @transcriptRaw
      @pullTranscript userId, userPass, (err)=>
        if err
          return callback err
        if not @authenticated
          return callback new Error 'Incorrect authentication credentials'
        @processTranscriptRaw(callback)
    else
      @processTranscriptRaw(callback)




  processTranscriptRaw: (callback) ->
    fs.writeFile './tempTranscript.html', @transcriptRaw, (err) =>
      if err then return callback(err)
      err = null
      classList = []
      classMap = {}
      classRegex = '<TR>\\n<TD\\sCLASS="dddefault">([A-Z]+)</TD>\\n<TD\\s(?:COLSPAN="2"\\s)?CLASS="dddefault">([0-9X]+)</TD>'

      classesRaw = @transcriptRaw.match new RegExp classRegex, 'ig'
      for classInfo in classesRaw
        info   = (classInfo.match new RegExp classRegex, 'i') || []
        dep    = info[1]||''
        number = info[2]||''
        classList.push number: number, department: dep
        if classMap[dep] then classMap[dep].push number else classMap[dep] = [number]
      callback(err, classList, classMap)




  apiCall: (method, data={}, callback) ->
    if typeof data is 'function' and not callback
      [callback, data] = [data, callback]
      data = {}
    url = @urlSet[ method.toLowerCase() ]
    method = data['method'] || 'GET'
    delete data['method']
    @download(url, data, method, callback)


  # Internal Downloader method
  download: (url, data, method, callback) ->
    # Options:
    #   url: String url to hit
    #   data: GET parameters
    #   callback: function accepts err and result
    urlParsed = urlUtil.parse url

    dlOptions =
      agent: new https.Agent
        secureProtocol: 'SSLv3_method'
        secureOptions: constants.SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS
      jar: @cookieJar
      hostname: urlParsed.hostname
      host: urlParsed.host
      path: [urlParsed.path, querystring.stringify data].join('?')
      method: method
      port: if urlParsed.protocol is 'https:' then 443 else 80
      data: querystring.stringify data
      headers:
        'User-Agent':  userAgentString
        'user-agent': userAgentString
      uri: 'https://'+urlParsed.host+[urlParsed.path, querystring.stringify data].join('?')

    #Send request
    request dlOptions, (err, res, body)->
      callback err, body
