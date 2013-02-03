recordSpy = require('../')
should    = require('should')

reverse = (s) ->
  s.split('').reverse().join('')

# describe 'Auth', () ->

#   before ()=>
#     @spy = recordSpy()

#   describe '.authenticate(ID, PIN, callback)', () =>
#     it 'should make fail on wrong credentials', (done) =>
#       @spy.authenticate reverse(process.env.GTID), reverse(process.env.GTPIN), (success)->
#         success.should.be.false
#         done()
#     it 'should return true on success', (done) =>
#       @spy.authenticate process.env.GTID, process.env.GTPIN, (success) ->
#         success.should.be.true
#         done()