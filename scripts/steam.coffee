# Description:
#   Steam Web API (Dota 2)
#
# Dependencies:
#   "moment": "^2.5.1"
#   "ref": "^0.1.3"
#
# Configuration:
#   STEAM_API_KEY
#
# Commands:
#   hubot steam id [me] <custom URL> - Returns the Steam ID for the user under http://steamcommunity.com/id/<custom URL>
#   hubot steam status <Steam ID|custom URL> - Returns <Steam ID> or <custom URL> community status
#   hubot dota history <Steam ID|custom URL> - Returns metadata for the latest 5 game lobbies with <Steam ID> or <custom URL>
#   hubot dota match <match ID> [<Steam ID|custom URL>] - Returns information about a particular <match ID>. Optionally, if <Steam ID> or <custom URL> is included, its match information will also be returned
#
# Author:
#   MrSaints

moment = require 'moment'
require 'ref'

STEAM_API_KEY = process.env.STEAM_API_KEY

personaStates = [
    "Offline"
    "Online"
    "Busy"
    "Away"
    "Snooze"
    "Looking to trade"
    "Looking to play"
]

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
    7: "Ranked match"
towers = [
    "Ancient top"
    "Ancient bottom"
    "Bottom tier 3"
    "Bottom tier 2"
    "Bottom tier 1"
    "Middle tier 3"
    "Middle tier 2"
    "Middle tier 1"
    "Top tier 3"
    "Top tier 2"
    "Top tier 1"
]

module.exports = (robot) ->
    if not STEAM_API_KEY?
        return robot.logger.debug 'Missing STEAM_API_KEY in environment. Please set and try again.'

    robot.respond /steam id( me)? (.*)/i, (msg) ->
        getSteamID msg, msg.match[2], (id) ->
            msg.match[2] += if msg.match[2].slice(-1) is "s" then "'" else "'s"
            msg.reply "#{msg.match[2]} Steam ID is: #{id}"

    robot.respond /steam status (.*)/i, (msg) ->
        summary = (steamID) ->
            steam_request msg, "/ISteamUser/GetPlayerSummaries", steamids: steamID, (object) ->
                player = object.response.players[0]
                status = if player.communityvisibilitystate is 1 then 'Unavailable (Private)' else personaStates[player.personastate]
                lastOnline = moment.unix(player.lastlogoff).fromNow()
                msg.reply "#{msg.match[1]} belongs to #{player.personaname} who is currently #{status} and was last online #{lastOnline}."
            , 2

        if msg.match[1].match /\d{17}/
            summary msg.match[1]
        else
            getSteamID msg, msg.match[1], (steamID) ->
                summary steamID

    robot.respond /dota history (.*)/i, (msg) ->
        [command, value] = msg.match

        params =
            original: value
            account_id: value
            matches_requested: 5

        history = (params, type = 'Steam ID') ->
            steam_request msg, "/IDOTA2Match_570/GetMatchHistory", params, (object) ->
                if object.result.status is 15
                    msg.reply "The #{type} you have entered (\"#{params.original}\") does not exist or it does not have match history enabled."
                    return
                else if object.result.num_results is 0
                    msg.reply "No game matches were found for the #{type}: #{params.original}."
                    return

                communityID = getCommunityID params.account_id

                for match in object.result.matches
                    hero = "N/A"
                    start = moment.unix(match.start_time).fromNow()

                    for player in match.players
                        if player.account_id is communityID
                            hero = getHero(player.hero_id).localized_name
                            break;

                    msg.send "Match ID: #{match.match_id} | Lobby: #{lobbies[match.lobby_type]} | Hero: #{hero} | #{start}"

        if value.match /\d{17}/
            history params
        else
            getSteamID msg, value, (id) ->
                params.account_id = id
                history params, 'profile URL'

    robot.respond /dota match (\d+)\s*(.*)?/i, (msg) ->
        steam_request msg, "/IDOTA2Match_570/GetMatchDetails", match_id: msg.match[1], (object) ->
            match = object.result
            start = moment.unix(match.start_time).fromNow()
            duration = moment.duration(match.duration, 'seconds').minutes()
            firstBlood = moment.duration(match.first_blood_time, 'seconds').humanize()
            victor = if match.radiant_win then "Radiant" else "Dire"

            radiantTowers = getTowers(match.tower_status_radiant).join(', ') or 'None'
            direTowers = getTowers(match.tower_status_dire).join(', ') or 'None'

            msg.send "Match ID #{match.match_id} is a #{lobbies[match.lobby_type].toLowerCase()} game that took place #{start}. The #{victor} won the game in #{duration} minutes. First blood was drawn #{firstBlood} into the game."
            msg.send "Radiant towers remaining: #{radiantTowers} | Dire towers remaining: #{direTowers}"

            communityID = if msg.match[2]? then getCommunityID(msg.match[2]) else false

            playerInfo = (communityID) ->
                for player in match.players
                    if player.account_id is communityID
                        faction = if player.player_slot > 4 then 'Dire' else 'Radiant'
                        msg.reply "#{getHero(player.hero_id).localized_name} (Lvl #{player.level}), #{faction} | KDA: #{player.kills}/#{player.deaths}/#{player.assists} | LH: #{player.last_hits} | GPM: #{player.gold_per_min} | XPM: #{player.xp_per_min}"
                        return
                msg.reply "The Steam ID you have entered (\"#{msg.match[1]}\") was not found in Match ID #{match.match_id}."

            if msg.match[2]?
                if msg.match[2].match /\d{17}/
                    playerInfo getCommunityID(msg.match[2])
                else
                    getSteamID msg, msg.match[2], (steamID) ->
                        playerInfo getCommunityID(steamID)

getSteamID = (msg, customURL, handler) ->
    steam_request msg, "/ISteamUser/ResolveVanityURL", vanityurl: customURL, (object) ->
        if object.response.success is 42
            msg.reply "The custom URL you have entered (\"#{customURL}\") does not exist."
            return

        handler object.response.steamid

getCommunityID = (steamID) ->
    # 64 -> 32
    buffer = new Buffer 8
    buffer.writeUInt64LE steamID, 0
    buffer.readUInt32LE 0

getHero = (heroID) ->
    return hero for hero in heroes when hero.id is heroID

getTowers = (dec) ->
    for status, tower in "00000000000#{(+dec).toString(2)}".slice(-11).split('')
        if parseInt(status) then towers[tower] else continue

steam_request = (msg, endpoint, params = {}, handler, version = 1) ->
    params.key = STEAM_API_KEY

    msg.http("http://api.steampowered.com#{endpoint}/v#{version}/")
        .query(params)
        .get() (err, res, body) ->
            if err or res.statusCode isnt 200
                err = "Bad request (invalid Steam web API key)" if res.statusCode is 400
                msg.reply "An error occurred while attempting to process your request."
                return robot.logger.error err

            handler JSON.parse(body)
