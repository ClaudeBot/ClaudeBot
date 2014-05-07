# Description:
#   ClaudeBot's Utility Belt
#	For everything else that don't belong...
#
# Dependencies:
#   "moment": "^2.5.1"
#
# Configuration:
#   HUBOT_AUTH_ADMIN - A comma separate list of user IDs
#
# Commands:
#   None
#
# Author:
#   MrSaints
#
# Notes:
#	* TODO: Brain save wrapper? / Dirty-checking -> Save
#	* TODO: Clear data command?
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
	if process.env.HUBOT_AUTH_ADMIN?
		admins = process.env.HUBOT_AUTH_ADMIN.split ','

		robot.respond /(.*)/i, (msg) ->
			return unless msg.match[1]

			matches = adminOnly.filter (command) ->
				command.match new RegExp(msg.match[1], 'i')

			if matches.length > 0 and msg.message.user.id.toString() not in admins
				msg.message.done = true
				msg.reply "Sorry, the command you have entered has been restricted to admins only."