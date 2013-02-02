https   = require 'https'
urlUtil = require 'url'
request = require 'request'
querystring = require 'querystring'
constants = require('constants')

userAgentString = 'CourseShark Record-Crawler/nodejs 0.0.1'

# Export the main object
exports = module.exports = () ->

  # We return this unnnamed object (class)
  cookieJar: request.jar()

  urlSet:
    "login-get":
      "https://oscar.gatech.edu/pls/bprod/twbkwbis.P_WWWLogin"
    "login-post":
      "https://oscar.gatech.edu/pls/bprod/twbkwbis.P_ValLogin"

  authenticate: (userId, userPass, callback=(()->return)) ->
    @apiCall 'login-get', (err, data) =>
      @apiCall 'login-post',
        method: 'POST'
        sid: userId
        PIN: userPass
        , (err,body='')->
          callback(!!body.match(/Welcome/i))

  apiCall: (method, data={}, callback) ->
    if typeof data is 'function' and not callback
      [callback, data] = [data, callback]
      data = {}
    url = @urlSet[ method.toLowerCase() ]
    method = data["method"] || "GET"
    delete data["method"]
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
