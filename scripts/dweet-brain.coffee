# Description:
#   Dweet.io and MsgPack powered Hubot Brain
#
# Dependencies:
#   "moment": "^2.6.0"
#   "msgpack": "^0.2.3"
#
# Commands:
#   hubot brain save - Forces a save to Dweet.io
#   hubot brain status - Returns the brain status
#
# Configuration:
#   DWEET_THING
#   DWEET_KEY
#   DWEET_AUTOSAVE
#
# Author:
#   MrSaints

moment = require 'moment'
msgpack = require 'msgpack'

DWEET_THING = process.env.DWEET_THING
DWEET_KEY = process.env.DWEET_KEY
DWEET_AUTOSAVE = process.env.DWEET_AUTOSAVE or 1800

toBase64 = (object) ->
    msgpack.pack(object).toString('base64')

fromBase64 = (encodedObject) ->
    msgpack.unpack new Buffer(encodedObject, 'base64')

encodeChildren = (object, ignoreUsers = false) ->
    encodedObject = {}
    for key, value of object
        continue if ignoreUsers and key is 'users'
        encodedObject[key] = toBase64 value
    encodedObject

decodeChildren = (object) ->
    decodedObject = {}
    for key, value of object
        decodedObject[key] = fromBase64 value
    decodedObject

module.exports = (robot) ->
    if not DWEET_THING?
        return robot.logger.debug 'Missing DWEET_THING in environment. Please set and try again.'

    status = 
        connected: false
        lastSaved: false

    robot.brain.setAutoSave false
    robot.brain.resetSaveInterval DWEET_AUTOSAVE

    getData = ->
        dweetRequest robot, '/get/latest/dweet', null, (dweet) ->
            if dweet.with is 404
                robot.brain.mergeData {}
                robot.logger.info 'Initializing new data for brain.'
                robot.brain.save()
            else if dweet.this is 'failed'
                return robot.logger.error dweet.because
            else
                content = decodeChildren dweet.with[0].content
                robot.brain.mergeData content
                robot.logger.info 'Data for brain retrieved from Dweet.io.'
                status.lastSaved = dweet.with[0].created

            robot.brain.setAutoSave true
            status.connected = true
    getData()

    robot.brain.on 'save', (data = {}) ->
        isIRC = robot.adapterName is 'irc'
        dweetRequest robot, '/dweet', encodeChildren(data, isIRC), (dweet) ->
            return robot.logger.error dweet.because if dweet.this is 'failed'

            status.lastSaved = dweet.with.created
            robot.logger.info "Successfully Dweeted to #{DWEET_THING}."

    robot.respond /brain save/i, (msg) ->
        msg.reply "Saving..."
        robot.brain.save()

    robot.respond /brain status/i, (msg) ->
        connected = if status.connected then 'Initialized (Autosaving)' else 'Uninitialized (Autosaving Disabled)'
        lastSaved = moment(status.lastSaved).fromNow() or 'N/A'
        msg.reply "Status: #{connected} | Brain last saved: #{lastSaved}"

dweetRequest = (robot, endpoint, params = {}, handler) ->
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