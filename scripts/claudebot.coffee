# Description:
#   ClaudeBot's Utility Belt
#   For everything else that don't belong...
#
# Dependencies:
#   "moment": "^2.8.3"
#
# Configuration:
#   HUBOT_AUTH_ADMIN - A comma separate list of user IDs
#
# Commands:
#   hubot wipe <key> - Removes <key> and all of its content from the local brain / persistence
#
# Author:
#   MrSaints
#
# Notes:
#   * TODO: Brain save wrapper? / Dirty-checking -> Save
#
# URLS:
#   GET /

moment = require 'moment'
adminOnly = [
    'brain save'
    'die'
    'reload all scripts'
    'show storage'
    'show users'
    'fake event'
    'wipe'
    'cc new-channel'
    'cc new-global'
    'cc remove'
]

module.exports = (robot) ->
    start = moment()

    robot.router.get '/', (req, res) ->
        res.send "I am <a href=\"https://github.com/MrSaints/ClaudeBot\">Claude</a>, the bot and I have been sentient since #{start.fromNow()}."

    # Restrict commands
    if process.env.HUBOT_AUTH_ADMIN?
        robot.respond /(.*)/i, (msg) ->
            return unless msg.match[1]

            userCommand = msg.match[1]
            matches = adminOnly.filter (command) ->
                userCommand.match new RegExp(command, 'i')

            if matches.length > 0 and not robot.auth.isAdmin(msg.message.user)
                msg.message.done = true
                msg.reply "Sorry, the command you have entered has been restricted to admins only."

    robot.respond /wipe (.*)/i, (msg) ->
        key = msg.match[1]

        unless robot.brain.data[key]?
            msg.reply "The key you have entered (\"#{key}\") does not exist."
            return

        robot.brain.data[key] = undefined
        msg.reply "\"#{key}\" and all of its contents have been wiped from the brain."