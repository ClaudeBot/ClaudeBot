# Description:
#   Steam Web API (Dota 2)
#
# Dependencies:
#   "moment": "^2.5.1"
#
# Configuration:
#   STEAM_API_KEY
#
# Commands:
#   hubot steam id [me] <custom URL> - Returns the Steam ID for the user under http://steamcommunity.com/id/<custom URL>
#   hubot dota history <Steam ID> - Returns metadata for the latest 5 game lobbies with <Steam ID>
#   hubot dota match <match ID> - Returns information about a particular <match ID>
#
# Author:
#   MrSaints

version = '0001'

moment = require 'moment'

heroes = require '../data/heroes'
lobbies =
    "-1": "Invalid"
    0: "Public matchmaking"
    1: "Practice"
    2: "Tournament"
    3: "Tutorial"
    4: "Co-op with bots"
    5: "Team match"
    6: "Solo queue"

module.exports = (robot) ->
    robot.respond /steam id( me)? (.*)/i, (msg) ->
        steam_request msg, "/ISteamUser/ResolveVanityURL", vanityurl: msg.match[2], (object) ->
            if object.response.success is 1
                msg.match[2] += if msg.match[2].slice(-1) is "s" then "'" else "'s"
                msg.reply "#{msg.match[2]} Steam ID is: #{object.response.steamid}"
                return

            msg.reply "The custom URL you have entered (\"#{msg.match[2]}\") does not exist."

    robot.respond /dota history (.*)/i, (msg) ->
        communityID = getCommunityID(msg.match[1])
        steam_request msg, "/IDOTA2Match_570/GetMatchHistory", { account_id: communityID, matches_requested: 5 }, (object) ->
            if object.result.status is 15
                msg.reply "The Steam ID you have entered (\"#{msg.match[1]}\") does not have match history enabled."
                return
            else if object.result.num_results is 0
                msg.reply "No game matches were found for the Steam ID: #{msg.match[1]}."
                return

            for match in object.result.matches
                hero = "N/A"
                start = moment.unix(match.start_time).fromNow()

                for player in match.players
                    if player.account_id is communityID
                        hero = getHero player.hero_id
                        break;

                msg.send "Match ID: #{match.match_id} | Lobby: #{lobbies[match.lobby_type]} | Hero: #{hero.localized_name} | #{start}"

getCommunityID = (steamID) ->
    (steamID - 76561197960265728)

getHero = (heroID) ->
    return hero for hero in heroes when hero.id is heroID

steam_request = (msg, endpoint, params = {}, handler) ->
    params.key = process.env.STEAM_API_KEY

    msg.http("http://api.steampowered.com#{endpoint}/v#{version}/")
        .query(params)
        .get() (err, res, body) ->
            if err or res.statusCode isnt 200
                err = "Bad request (invalid Steam web API key)" if res.statusCode is 400
                msg.reply "An error occurred while attempting to process your request: #{err}"
                return

            handler JSON.parse(body)

