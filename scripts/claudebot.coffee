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

moment = require 'moment'

module.exports = (robot) ->
	start = moment()

	robot.router.get '/', (req, res) ->
		res.send "I am <a href=\"https://github.com/MrSaints/ClaudeBot\">Claude</a>, the bot and I have been sentient since #{start.fromNow()}."