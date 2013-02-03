# record-spy

record-spy is a developmental module used for pulling transcript records from a banner school.

Currently is hard-coded with Georgia Tech urls, but could be customized in the future to accept banner-urls for login and transcripts as parameters

## Install
```
npm install git+ssh://git@github.com:courseshark/record-spy.git
```

## Usage

The record-spy module exports a function that returns the spy object. This setup will be used later to pass configuration options to the spy object upon initalization.
```coffeescript
recordSpy = require 'record-spy'
spy = recordSpy()
```

### Authentication
In order to make record requests, the spy must authenticate with the student's Banner credentials. This is an optional step as record request methods must be passed credentials as well and will authenticate the spy if it has not been authenticated already.

```coffee
spy.authenticate sid, pin, (success) ->
  if success then console.log 'successfuly authenticated!'
```
The callback accepts only one parameter, a Boolean representing if the authentication was successful or not.

### Class Listings
Class Lists can be pulled using the method `.getTranscriptClasses`. This method will call the callback with `(err, classList, classMap)`.
```coffee
spy.getTranscriptClasses sid, pin, (err, classArray, classMap) ->
  console.log "Class Array\n", classArray
  console.log "Class Map\n", classMap
```
Will output something simmilar to:

```javascript
Class Array
----
 [ { number: '1501', department: 'MATH' },
  { number: '1301', department: 'CS' },
  { number: '2XXX', department: 'MATH' },
  { number: '1331', department: 'CS' },
  { number: '1522', department: 'MATH' },
  { number: '24X3', department: 'MATH' },
  { number: '2XXX', department: 'MATH' },
  { number: '2211', department: 'PHYS' },
  { number: '1100P', department: 'REC' },
  { number: '1050', department: 'CS' },
  { number: '1100', department: 'CS' },
  { number: '2212', department: 'PHYS' },
  { number: '1332', department: 'CS' },
  { number: '2110', department: 'CS' },
  { number: '2340', department: 'CS' },
  { number: '4802', department: 'PHYS' },
  { number: '3750', department: 'CS' },
  { number: '4001', department: 'CS' },
  { number: '4460', department: 'CS' },
  { number: '3101', department: 'CS' },
  { number: '3510', department: 'CS' },
  { number: '4495', department: 'CS' },
  { number: '1040', department: 'HPS' },
  { number: '1040', department: 'HPS' },
  { number: '4641', department: 'CS' } ]

Class Map
----
{ MATH: 
   [ { number: '1501' },
     { number: '2XXX' },
     { number: '1522' },
     { number: '2401' },
     { number: '3012' },
     { number: '3215' } ],
  CS: 
   [ { number: '1301' },
     { number: '1331' },
     { number: '1050' },
     { number: '3750' },
     { number: '4001' },
     { number: '4911' },
     { number: '3451' },
     { number: '4510' },
     { number: '4641' } ],
  PHYS: 
   [ { number: '2211' },
     { number: '2212' },
     { number: '4802' } ],
  REC: [ { number: '1100P' } ],
  HPS: [ { number: '1040' }, { number: '1040' } ],
```

### Term Listings
In order to see clearly when a student took a set of classes, a `.getClassesByTerm(ID, PIN, callback)` method is available. This method's callback is passed the arguments `(err, termClassMap)`.

The `termClassMap` response is of the form:
```javascript
{ '200808': 
   { MATH: 
     [ { number: '1501' },
       { number: '2XXX' } ] },
  'Spring 2012': 
   { CS: 
     [ { number: '1301' },
       { number: '1331' },
       { number: '1050' }, ],
     ENGL: [ { number: '1101' } ],
     HPS: [ { number: '1040' } ] },
  'Fall 2012': { INTA: [ { number: '1200' } ] }
  'Spring 2013': { CS: [ ... ], LCC: [ { number: '4813' } ] }
}
```

## Response Notes
* Note that duplicate classes are not removed.
  * That is, if a student takes a class more than once, it will appear both times in the results
* Course titles are not parse and returned. This is due to presentation variations in Banner.


## Running Tests
To run the test suite first installing the dependencies:
```
npm install
```
Then it's just a matter of running:
```
make test
```
