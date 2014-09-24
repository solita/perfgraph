tulosteet     = require "./tulosteet"
services      = require "./services"
tietopalvelut = require "./tietopalvelut"

if process.argv.length == 2
  tulosteet.processTestResults()
  services.processTestResults()
  tietopalvelut.processTestResults()
else if process.argv.length == 5
  tulosteet.processTestResultsOfBuilds([process.argv[2]])
  services.processTestResultsOfBuilds([process.argv[3]])
  tietopalvelut.processTestResultsOfBuilds([process.argv[4]])
else
  console.log 'Usage: pull.coffee \n or pull.coffee tpBuildNumber srvBuildNumber batchBuildNumber'
  tulosteet.db.then( -> tulosteet.db ).then( (db) -> db.close() ).done()
  services.db.then( -> services.db ).then( (db) -> db.close() ).done()
  tietopalvelut.db.then( -> tietopalvelut.db ).then( (db) -> db.close() ).done()