# Description:
#   Wikipedia Public API
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot wiki search <query> - Returns the first 5 Wikipedia articles matching the search <query>
#   hubot wiki summary <article> - Returns a one-line description about <article>
#
# Author:
#   MrSaints

module.exports = (robot) ->
    robot.respond /wiki search (.*)/i, (msg) ->
        params =
            action: 'opensearch'
            format: 'json'
            limit: 5
            search: msg.match[1]

        wiki_request msg, params, (object) ->
            if object[1].length is 0
                msg.reply "No articles were found using search query: \"#{msg.match[1]}\". Try a different query."
                return

            for article in object[1]
                msg.send "#{article}: #{createURL(article)}"

    robot.respond /wiki summary (.*)/i, (msg) ->
        params =
            action: 'query'
            exintro: true
            explaintext: true
            format: 'json'
            prop: 'extracts'
            titles: msg.match[1]

        wiki_request msg, params, (object) ->
            for id, article of object.query.pages
                if id is -1
                    msg.reply "The article you have entered (\"#{msg.match[1]}\") does not exist. Try a different article."
                    return

                summary = article.extract.split(". ")[0..1].join ". "
                msg.send "#{article.title}: #{summary}."
                msg.reply "Original article: #{createURL(article.title)}"
                return

createURL = (title) ->
    "https://en.wikipedia.org/wiki/#{encodeURIComponent(title)}"

wiki_request = (msg, params = {}, handler) ->
    msg.http("http://en.wikipedia.org/w/api.php")
        .query(params)
        .get() (err, res, body) ->
            if err
                msg.reply "An error occurred while attempting to process your request: #{err}"
                return robot.logger.error err

            handler JSON.parse(body)