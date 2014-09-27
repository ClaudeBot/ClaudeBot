# Description:
#   hitbox Public API
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hb stream <name> - Returns information about stream <name>
#
# Author:
#   mbwk

module.exports = (robot) ->

    robot.respond /hb stream (.+)/i, (msg) ->
        hitboxRequest msg, "/media/live/#{msg.match[1]}", null, (object) ->

            if not object.livestream
                msg.reply "Unable to find a currently live stream under that name."
                return

            livestream = object.livestream[0]
            msg.reply "http://hitbox.tv/#{livestream.media_user_name} is currently streaming #{livestream.category_name}"
            msg.send "They have been streaming since #{livestream.media_live_since}"

hitboxRequest = (msg, api, params = {}, handler) ->
    msg.http("http://api.hitbox.tv#{api}")
        .query(params)
        .get() (err, res, body) ->
            if err
                msg.reply "Error encountered while making request to hitbox API."
                return robot.logger.error err

            if body[0] != "{"
                handler {}
                return

            handler JSON.parse(body)
