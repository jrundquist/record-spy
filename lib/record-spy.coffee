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

  urlSet:
    'login-get':
      'https://oscar.gatech.edu/pls/bprod/twbkwbis.P_WWWLogin'
    'login-post':
      'https://oscar.gatech.edu/pls/bprod/twbkwbis.P_ValLogin'
    'transcript-get':
      'https://oscar.gatech.edu/pls/bprod/bwskotrn.P_ViewTran'





















  authenticate: (userId, userPass, callback=(()->return)) ->
    @apiCall 'login-get', (err, data) =>
      @apiCall 'login-post',
        method: 'POST'
        sid: userId
        PIN: userPass
        , (err,body='') =>
          @authenticated = not not body.match(/Welcome/ig)
          callback(@authenticated)




















  # Method to pull transcript from the site

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


















  # Methods for pulling classes not sorted by term
  #
  # Each will pull the transcript if nessisary,
  # thus needs to recieve user credentials
  #
  #



  # Get the classes and return a dep->classlist map as well
  # as an array classlist
  #
  getTranscriptClasses: (userId, userPass, callback=(()->return)) ->
    if not @transcriptRaw
      @pullTranscript userId, userPass, (err)=>
        if err
          return callback err
        if not @authenticated
          return callback new Error 'Incorrect authentication credentials'
        [err, classList, classMap] = @_processTranscriptRaw(@transcriptRaw)
        callback(err, classList, classMap)
    else
      [err, classList, classMap] = @_processTranscriptRaw(@transcriptRaw)
      callback(err, classList, classMap)



  # Private method used to form the classList and classMap for
  # a given transcript, or transcript fragment
  #
  # Returns [err, classList, classMap] for passed transcript

  _processTranscriptRaw: (rawTranscript) ->
    err = null
    classList = []
    classMap = {}
    classRegex = '<TR>\\n<TD\\sCLASS="dddefault">([A-Z]+)</TD>\\n<TD\\s(?:COLSPAN="2"\\s)?CLASS="dddefault">([0-9A-Z]+)</TD>'

    classesRaw = rawTranscript.match new RegExp classRegex, 'ig'
    if not classesRaw
      return [err, classList, classMap]
    for classInfo in classesRaw
      info   = (classInfo.match new RegExp classRegex, 'i') || []
      dep    = info[1]||''
      number = info[2]||''
      classList.push number: number, department: dep
      chunk = {number: number}
      if classMap[dep] then classMap[dep].push chunk else classMap[dep] = [chunk]
    [err, classList, classMap]





















  # Methods for pulling classes by term

  #
  # The following are for extracting an object of the form
  # { `term`: { `dep`: [`numbers`] } }
  #


  # Public function callable to return the term -> class map
  #
  # Callback is called with (err, termClassMap)

  getClassesByTerm: (userId, userPass, callback=(()->return)) ->
    if not @transcriptRaw
      @pullTranscript userId, userPass, (err)=>
        if err
          return callback err
        if not @authenticated
          return callback new Error 'Incorrect authentication credentials'
        [err, termClassMap] = @_pullTermsAndClasses(@transcriptRaw)
        callback(err, termClassMap)
    else
      [err, termClassMap] = @_pullTermsAndClasses(@transcriptRaw)
      callback(err, termClassMap)



  # Private method used to actually parse the transcript into term->class map
  #
  # Returns [err, termClassMap] for passed transcript

  _pullTermsAndClasses: (rawTranscript) ->
    termRegex = /<SPAN class="fieldOrangetextbold">([^<]+?):?<\/SPAN>/gi
    termsAndList = rawTranscript.split termRegex
    termsAndList = termsAndList[1..]

    termClassMap = {}

    # Cycle through the terms we found and create their class lists
    for index in [0..(termsAndList.length-1)] by 2
      termName = termsAndList[index].replace(/Term:\s*/, '')
      termHTML = termsAndList[index+1]||''
      [err, classList, classMap] = @_processTranscriptRaw(termHTML)
      termClassMap[termName] = classMap

    [err, termClassMap]





















  # Base API low-level functions



  # Download wrapper
  #
  # Accepts a condenced list of arguments
  # and expands them to something the
  # downloader can use

  apiCall: (method, data={}, callback) ->
    if typeof data is 'function' and not callback
      [callback, data] = [data, callback]
      data = {}
    url = @urlSet[ method.toLowerCase() ]
    method = data['method'] || 'GET'
    delete data['method']
    @download(url, data, method, callback)




  # Internal Downloader method
  #
  # Parses and constructs request
  # arguments and options, which are
  # then passed to the 'request' method
  #
  # callback is passed in raw

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
