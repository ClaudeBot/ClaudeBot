# Description:
#   Wikipedia API - Search for Wikipedia articles
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot wiki <query> - Search Wikipedia for articles using the query (returns the first 5 matches)
#
# Author:
#   MrSaints

module.exports = (robot) ->
    robot.respond /wiki (.*)/i, (msg) ->
        getArticles msg

createURL = (title) ->
    "https://en.wikipedia.org/wiki/#{encodeURIComponent(title)}"

getArticles = (msg) ->
    query = msg.match[1]

    msg.http("http://en.wikipedia.org/w/api.php")
        .query
            action: 'opensearch'
            format: 'json'
            limit: 5
            search: query
        .get() (err, res, body) ->
            data = JSON.parse body

            if data[1].length is 0
                msg.reply "Your query ('#{query}') returned no articles."
                return

            for article in data[1][0..4]
                msg.send "#{article} - #{createURL(article)}"