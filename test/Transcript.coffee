recordSpy = require('../')
should    = require('should')

reverse = (s) ->
  s.split('').reverse().join('')

describe 'Transcript', () ->

  before ()=>
    @spy = recordSpy()


  describe '.pullTranscript(ID, PIN, callback)', () =>
    it 'should return the transcript text on success', (done) =>
      @spy.pullTranscript process.env.GTID, process.env.GTPIN, (err, raw) ->
        should.not.exist(err)
        should.exist(raw)
        raw.should.be.a('string')
        done()



  describe '.getTranscriptClasses(ID, PIN, callback)', () =>
    it 'should return array of classes', (done) =>
      @spy.getTranscriptClasses process.env.GTID, process.env.GTPIN, (err, classArray) ->
        should.exist classArray
        classArray.should.be.an.instanceOf Array
        done()
    it 'should return a map of classes', (done) =>
      @spy.getTranscriptClasses process.env.GTID, process.env.GTPIN, (err, classArray, classMap) ->
        should.exist classMap
        classMap.should.be.an.instanceOf Object
        done()



  describe '.getClassesByTerm(ID, PIN, callback)', () =>
    it 'should return an object', (done) =>
      @spy.getClassesByTerm process.env.GTID, process.env.GTPIN, (err, termClassMap) ->
        should.not.exist err
        should.exist termClassMap
        termClassMap.should.be.an.instanceOf Object
        done()