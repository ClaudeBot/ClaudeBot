# Description:
#   Dweet.io powered Hubot Brain
#
# Dependencies:
#   "moment": "^2.5.1"
#
# Commands:
#   hubot brain save - Forces a save to Dweet.io
#   hubot brain status - Returns the brain status
#
# Configuration:
#   DWEET_THING
#   DWEET_KEY
#
# Author:
#   MrSaints

moment = require 'moment'

DWEET_THING = process.env.DWEET_THING
DWEET_KEY = process.env.DWEET_KEY

toBase64 = (json) ->
    new Buffer(JSON.stringify(json)).toString 'base64'

fromBase64 = (base64) ->
    JSON.parse new Buffer(base64, 'base64').toString 'ascii'

encodeChildren = (object) ->
    encodedObject = {}
    for key, value of object
        encodedObject[key] = toBase64 value
    encodedObject

decodeChildren = (object) ->
    decodedObject = {}
    for key, value of object
        decodedObject[key] = fromBase64 value
    decodedObject

module.exports = (robot) ->
    if not DWEET_THING?
        return

    status = 
        connected: false
        lastSaved: false

    robot.brain.setAutoSave false
    robot.brain.resetSaveInterval(600)
    #robot.brain.resetSaveInterval(10)

    getData = ->
        dweet_request robot, '/get/latest/dweet', null, (dweet) ->
            if dweet.with is 404
                robot.brain.mergeData {}
                robot.logger.info 'Initializing new data for brain'
                robot.brain.save()
            else if dweet.this is 'failed'
                return robot.logger.error dweet.because

            robot.brain.setAutoSave true
            status.connected = true
            status.lastSaved = dweet.with[0].created

            if dweet.with isnt 404
                content = decodeChildren dweet.with[0].content
                robot.brain.mergeData content
                robot.logger.info 'Data for brain retrieved from Dweet.io'
    getData()

    robot.brain.on 'save', (data = {}) ->
        dweet_request robot, '/dweet', encodeChildren(data), (dweet) ->
            return robot.logger.error dweet.because if dweet.this is 'failed'

            status.lastSaved = dweet.with.created
            robot.logger.info "Successfully Dweeted to #{DWEET_THING}"

    robot.respond /brain save/i, (msg) ->
        msg.reply "Saving..."
        robot.brain.save()

    robot.respond /brain status/i, (msg) ->
        connected = if status.connected then 'Initialized (Autosaving)' else 'Uninitialized (Autosaving Disabled)'
        lastSaved = moment(status.lastSaved).fromNow() or 'N/A'
        msg.reply "Status: #{connected} | Brain last saved: #{lastSaved}"

dweet_request = (robot, endpoint, params = {}, handler) ->
    params['key'] = DWEET_KEY if DWEET_KEY?

    robot.http("https://dweet.io#{endpoint}/for/#{DWEET_THING}")
        .query(params)
        .get() (err, res, body) ->
            parsed = JSON.parse body

            if err
                return robot.logger.error err
            else if parsed.code is 'ResourceNotFound'
                return robot.logger.error parsed.message

            handler parsed