# Description:
#   Twitch API - Find live streams
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot ttv <category> - Perform a case-sensitive search on Twitch.tv for live streams in a game category (returns the first 5)
#   hubot ttv featured - Return the first 5 featured live streams on Twitch.tv
#   hubot ttv stream <name> - Returns information about stream <name>
#
# Author:
#   MrSaints

module.exports = (robot) ->
    robot.respond /ttv (.*)/i, (msg) ->
        tempv = msg.match[1].indexOf "stream",0
        if msg.match[1] is "featured"
            getStreams msg, true
        else if tempv is 0
            getStreams msg, false, true
        else
            getStreams msg


getStreams = (msg, featured, channel) ->
    category = msg.match[1]

    API = "/streams"
    type = "streams"

    if featured
        API = "/streams/featured"
        type = "featured"

    if channel
        streamsplit = msg.match[1].split " "
        API = "/streams/#{streamsplit[1]}"
        type = "stream"
        

    msg.http("https://api.twitch.tv/kraken#{API}")
        .query
            game: category
            limit: 5
        .get() (err, res, body) ->
            data = JSON.parse body

            if channel
                if not data[type]
                    msg.reply "The stream is either offline, or does not exist."
                    return

                if data[type]
                    stream = data[type]
                    msg.send "#{stream.channel.display_name} is streaming #{stream.channel.game} @ #{stream.channel.url}"
                    msg.send "Stream status: \"#{stream.channel.status}\""
                    msg.send "Viewers: #{stream.viewers}"
                    return

            if data._total is 0
                msg.reply "No live streams were found in '#{category}'. Try a different category or try again later."
                return

            for stream in data[type][0..4]
                stream = stream.stream if featured
                msg.send "#{stream.channel.display_name} (#{stream.channel.status}) - #{stream.channel.url} [Viewers: #{stream.viewers}]"

            if !featured and data._total > 5
                msg.reply "There are #{data._total - 5} other '#{category}' live streams."

