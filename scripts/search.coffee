# Description:
#   Google Web Search API (Deprecated)
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot <search|google> <query> - Queries Google Search for <query> and returns the first 5 results
#
# Author:
#   MrSaints

module.exports = (robot) ->
    robot.respond /(search|google) (.*)/i, (msg) ->
        params = 
            v: '1.0'
            rsz: 5
            q: msg.match[2]

        msg.http("https://ajax.googleapis.com/ajax/services/search/web")
            .query(params)
            .get() (err, res, body) ->
                if err
                    msg.reply "An error occurred while attempting to process your request: #{err}"
                    return robot.logger.error err

                data = JSON.parse(body).responseData

                if data.results.length is 0
                    msg.reply "No results were found using search query: \"#{msg.match[2]}\". Try a different query."
                    return

                for result in data.results
                    msg.send "#{result.titleNoFormatting}: #{result.url}"

                msg.reply "There are about #{data.cursor.resultCount} results (#{data.cursor.searchResultTime})."

