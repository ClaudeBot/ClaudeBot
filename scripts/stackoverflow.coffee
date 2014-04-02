# Description:
#   Search a Stack Exchange website and return links the first five questions.
#   Based on sosearch.coffee, but improved to utilise Stack Exchange's v2.2 API.
#
# Dependencies:
#   none
#
# Configuration:
#   None
#
# Commands:
#   hubot stack [on] <site> [about] <query> - Search on a Stack Exchange site for questions using the query
#   hubot so <query> - Search on Stack Overflow for questions using the query
#
# Author:
#   MrSaints

zlib = require 'zlib'

module.exports = (robot) ->
    robot.respond /stack (on )?(\w*)( about)? (.*)/i, (msg) ->
        getQuestions msg

    robot.respond /so (.*)/i, (msg) ->
        getQuestions msg, 'stackoverflow'

getQuestions = (msg, site = false) ->
    seSite = site or msg.match[2]
    seQuery = if site then msg.match[1] else msg.match[4]

    json = ""

    msg.http("http://api.stackexchange.com/2.2/search")
        .query
            intitle: seQuery
            site: seSite
        .get((err, req) ->
            req.addListener "response", (res) ->
                output = res

                if res.headers['content-encoding'] is 'gzip'
                    output = zlib.createGunzip()
                    res.pipe output

                output.on 'data', (data) ->
                    json += data.toString 'utf-8'

                output.on 'end', ->
                    parsedData = JSON.parse json

                    if parsedData.error
                        msg.send "An error occurred: #{parsedData.error.message}"
                        return

                    if parsedData.items.length is 0
                        msg.reply "Your query ('#{seQuery}') returned no results on #{seSite}."
                        return

                    for question in parsedData.items[0..4]
                        msg.send "#{question.title} - #{question.link}"
        )()