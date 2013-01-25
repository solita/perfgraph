moment = require "moment"

exports.logger = (m) -> console.log "#{moment().format()} #{m}"