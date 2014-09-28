# Description:
#   Twitch Public API
#
# Dependencies:
#   None
#
# Configuration:
#   TWITCH_API_KEY
#   HUBOT_TWITCH_KEY
#
# Commands:
#   hubot ttv follows - Returns the 10 most recent live streams belonging to your followed channels (list populated from your linked Twitch user)
#   hubot ttv link <user> - Link Twitch <user> to you
#   hubot ttv featured - Returns the first 5 featured live streams
#   hubot ttv game <category> - Returns the first 5 live streams in a game <category> (case-sensitive)
#   hubot ttv search <query> - Returns the first 5 live streams matching the search <query>
#   hubot ttv stream <name> - Returns information about stream <name>
#   hubot ttv top - Returns the top 5 games sorted by the number of current viewers on Twitch, most popular first
#
# Author:
#   MrSaints
#   mbwk

#
# Config
#
TWITCH_API_KEY = process.env.TWITCH_API_KEY
TWITCH_MAX_RESULTS = 5
TWITCH_STORAGE_KEY = process.env.HUBOT_TWITCH_KEY or "_twitch"

module.exports = (robot) ->
    GetTTVData = ->
        robot.brain.data[TWITCH_STORAGE_KEY] or= {}

    robot.respond /ttv follows/i, (msg) ->
        user = msg.message.user.name.toLowerCase()
        if twitchUser = GetTTVData()[user]
            GetTwitchResult msg, "/users/#{twitchUser}/follows/channels", { limit: 10, sortby: "last_broadcast" }, (followsObj) ->
                if followsObj._total is 0 or followsObj.status is 404
                    msg.reply "Your Twitch account is not following anyone or it does not exist."
                    return
                total = 0
                processing = followsObj.follows.length
                for followedChannel, index in followsObj.follows
                    GetTwitchResult msg, "/streams/#{followedChannel.channel.name}", null, (object) ->
                        --processing
                        if object.status isnt 404 and object.stream
                            ++total
                            channel = object.stream.channel
                            msg.send "#{channel.display_name} is streaming #{channel.game} @ #{channel.url}"
                        if processing is 0
                            total = if total is 0 then "None" else total + " or more"
                            return msg.reply "#{total} of your followed channels are currently streaming."
        else
            msg.reply "You have not linked your Twitch account yet."

    robot.respond /ttv link (.+)/i, (msg) ->
        user = msg.message.user.name.toLowerCase()
        twitchUser = msg.match[1]

        GetTwitchResult msg, "/users/#{twitchUser}", null, (object) ->
            if object.status is 404
                msg.reply "The user you have entered (\"#{twitchUser}\") does not exist."
                return

            GetTTVData()[user] = twitchUser
            robot.brain.save()
            msg.reply "Twitch user \"#{twitchUser}\" is now linked to you."

    robot.respond /ttv featured/i, (msg) ->
        GetTwitchResult msg, '/streams/featured', null, (object) ->
            for feature in object.featured
                channel = feature.stream.channel
                msg.send "#{feature.stream.game}: #{channel.display_name} (#{channel.status}) - #{channel.url} [Viewers: #{feature.stream.viewers}]"

    robot.respond /ttv game (.+)/i, (msg) ->
        category = msg.match[1]
        GetTwitchResult msg, '/streams', { game: category }, (object) ->
            if object._total is 0
                msg.reply "No live streams were found in \"#{category}\". Try a different category or try again later."
                return

            for stream in object.streams
                channel = stream.channel
                msg.send "#{channel.display_name} (\"#{channel.status}\"): #{channel.url} [Viewers: #{stream.viewers}]"

            if object._total > TWITCH_MAX_RESULTS
                msg.reply "There are #{object._total - TWITCH_MAX_RESULTS} other \"#{category}\" live streams."

    robot.respond /ttv search (.+)/i, (msg) ->
        query = msg.match[1]
        GetTwitchResult msg, "/search/streams", { q: query }, (object) ->
            if object._total is 0
                msg.reply "No live streams were found using search query: \"#{query}\". Try a different query or try again later."
                return

            for stream in object.streams
                channel = stream.channel
                msg.send "#{channel.display_name} (\"#{channel.status}\"): #{channel.url} [Viewers: #{stream.viewers}]"

            if object._total > TWITCH_MAX_RESULTS
                msg.reply "There are #{object._total - TWITCH_MAX_RESULTS} other live streams matching your search query: \"#{query}\"."

    robot.respond /ttv stream (.+)/i, (msg) ->
        GetTwitchResult msg, "/streams/#{msg.match[1]}", null, (object) ->
            if object.status is 404
                msg.reply "The stream you have entered (\"#{msg.match[1]}\") does not exist."
                return

            if not object.stream
                msg.reply "The stream you have entered (\"#{msg.match[1]}\") is currently offline. Try again later."
                return

            channel = object.stream.channel
            msg.send "#{channel.display_name} is streaming #{channel.game} @ #{channel.url}"
            msg.send "Stream status: \"#{channel.status}\""
            msg.send "Viewers: #{object.stream.viewers}"

    robot.respond /ttv top/i, (msg) ->
        createGameURL = (game) ->
            "https://www.twitch.tv/directory/game/#{encodeURIComponent(game)}"

        GetTwitchResult msg, "/games/top", null, (object) ->
            for gameObj, i in object.top
                msg.send "#{i + 1}. #{gameObj.game.name} | Viewers: #{gameObj.viewers} | Channels: #{gameObj.channels} | #{createGameURL(gameObj.game.name)}"

GetTwitchResult = (msg, api, params = {}, handler) ->
    params.client_id = TWITCH_API_KEY
    params.limit or= TWITCH_MAX_RESULTS
    msg.http("https://api.twitch.tv/kraken#{api}")
        .query(params)
        .get() (err, res, body) ->
            if err
                msg.reply "An error occurred while attempting to process your request."
                return robot.logger.error err

            handler JSON.parse(body)