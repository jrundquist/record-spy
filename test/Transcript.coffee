recordSpy = require('../')
should    = require('should')

reverse = (s) ->
  s.split('').reverse().join('')

describe 'Auth', () ->

  before ()=>
    @spy = recordSpy()

  describe '.pullTranscript(ID, PIN, callback)', () =>
    it 'should fail on wrong credentials', (done) =>
      @spy.pullTranscript reverse(process.env.GTID), reverse(process.env.GTPIN), (err, raw)->
        should.exist(err)
        err.should.be.an.instanceOf(Error)
        done()
    it 'should return the transcript text on success', (done) =>
      @spy.pullTranscript process.env.GTID, process.env.GTPIN, (err, raw) ->
        should.not.exist(err)
        should.exist(raw)
        raw.should.be.a('string')
        done()

  describe '.getTranscriptClasses(ID, PIN, callback)', ()=>
    it 'should return array of classes', (done) =>
      @spy.getTranscriptClasses process.env.GTID, process.env.GTPIN, (err, classArray) ->
        should.exist classArray
        classArray.should.be.an.instanceOf Array
        done()