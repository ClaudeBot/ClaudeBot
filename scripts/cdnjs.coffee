# Description:
#   CDN JS API - Search front-end dependencies
#
# Dependencies:
#   "underscore": "^1.6.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot cdnjs <query> - Search the cdnJS script repository for the URL to the latest library available using the query (returns first 5 matches)
#   hubot cdnjs strictly <query> - Performs the default search, but with the addition of a strict list search using Underscore.js (returns first match)
#
# Author:
#   MrSaints

_ = require 'underscore'

module.exports = (robot) ->
    robot.respond /cdnjs (.*)/i, (msg) ->
        if msg.match[1].match(/^strictly (.*)$/i)
            getLibraries msg, true
        else
            getLibraries msg

getLibraries = (msg, strict = false) ->
    query = msg.match[1]

    if strict
        query = query.split(' ')[1]

    msg.http("http://api.cdnjs.com/libraries")
        .query
            search: query
        .get() (err, res, body) ->
            data = JSON.parse body

            if data.total is 0
                msg.reply "Your query ('#{query}') returned no results."
                return

            if strict
                match = _.findWhere data.results, name: query

                if match?
                    msg.reply "#{match.name} - #{match.latest}"
                else
                    msg.reply "Your query ('#{query}') returned no results."
            else
                for resource in data.results[0..4]
                    msg.send "#{resource.name} - #{resource.latest}"