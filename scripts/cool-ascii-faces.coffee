# Description:
#   Cool ASCII Faces
#
# Dependencies:
#	"cool-ascii-faces": "^1.3.3"
#
# Configuration:
#   None
#
# Commands:
#   hubot face [me] - Returns a random, but cool ASCII face
#
# Author:
#   MrSaints

cool = require 'cool-ascii-faces'

module.exports = (robot) ->
    robot.respond /face( me)?/i, (msg) ->
    	msg.reply cool()
    	return