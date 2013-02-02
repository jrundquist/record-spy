recordSpy = require('../')
should    = require('should')

describe 'Auth', () ->

    describe '.auth(url)', ()->
      it 'should make requests?', (done) ->
        spy = recordSpy();
        spy.authenticate process.env.GTID, process.env.GTPIN, (success)->
          success.should.be.true
          done()