# Description:
#   CDN JS Public API
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cdnjs search <query> - Returns the CDNJS URL for the first 5 front-end dependencies matching the search <query>
#   hubot cdnjs fetch <dependency> - Returns the CDNJS URL for a specific front-end <dependency> (e.g. jQuery)
#
# Author:
#   MrSaints

module.exports = (robot) ->
    robot.respond /cdnjs fetch (.*)/i, (msg) ->
        cdnjs_request msg, (data) ->
            for resource in data.results
                if resource.name is msg.match[1]
                    msg.reply "#{resource.name}: #{resource.latest}"
                    return

            msg.reply "The front-end dependency you have entered (\"#{msg.match[1]}\") does not exist. Try a different dependency."

    robot.respond /cdnjs search (.*)/i, (msg) ->
        cdnjs_request msg, (data) ->
            for resource in data.results[0..4]
                msg.send "#{resource.name}: #{resource.latest}"

            if data.total > 5
                msg.reply "There are #{data.total - 5} other front-end dependencies matching your search query: \"#{msg.match[1]}\"."

cdnjs_request = (msg, handler) ->
    msg.http("http://api.cdnjs.com/libraries")
        .query
            search: msg.match[1]
        .get() (err, res, body) ->
            if err
                msg.reply "An error occurred while attempting to process your request."
                return robot.logger.error err

            data = JSON.parse body

            if data.total is 0
                msg.reply "No front-end dependencies were found using search query: \"#{msg.match[1]}\". Try a different query."
                return

            handler data