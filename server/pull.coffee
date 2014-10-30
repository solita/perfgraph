tulosteet     = require "./tulosteet"
tietopalvelut = require "./tietopalvelut"
services      = require "./services"

if process.argv.length == 2
  tulosteet.processTestResults()
  tietopalvelut.processTestResults()
  services.processTestResults()
else if process.argv.length == 5
  tulosteet.processTestResultsOfBuilds([process.argv[2]])
  tietopalvelut.processTestResultsOfBuilds([process.argv[3]])
  services.processTestResultsOfBuilds([process.argv[4]])
else
  console.log 'Usage: pull.coffee \n or pull.coffee tulosteet eraajot services \n example: pull.coffee 123 0 932'
  tulosteet.db.then( -> tulosteet.db ).then( (db) -> db.close() ).done()
  tietopalvelut.db.then( -> tietopalvelut.db ).then( (db) -> db.close() ).done()
  services.db.then( -> services.db ).then( (db) -> db.close() ).done()
