# Description:
#   ClaudeBot's Utility Belt
#	For everything else that don't belong...
#
# Dependencies:
#   "moment": "^2.5.1"
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   MrSaints
#
# Notes:
#	* TODO: Brain save wrapper? / Dirty-checking -> Save
#
# URLS:
#	GET /

moment = require 'moment'
adminOnly = [
	'brain save'
	'die'
	'reload all scripts'
	'show storage'
	'show users'
	'fake event'
]

module.exports = (robot) ->
	start = moment()

	robot.router.get '/', (req, res) ->
		res.send "I am <a href=\"https://github.com/MrSaints/ClaudeBot\">Claude</a>, the bot and I have been sentient since #{start.fromNow()}."

	# Restrict commands
	robot.respond /(.*)/i, (msg) ->
		return if not msg.match[1]

		matches = adminOnly.filter (command) ->
			command.match new RegExp(msg.match[1], 'i')
		if matches.length > 0 and not robot.auth.hasRole msg.envelope.user, 'admin'
			msg.message.done = true
			msg.reply "Sorry, the command you have entered has been restricted to admins only."