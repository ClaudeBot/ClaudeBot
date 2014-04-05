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
#   hubot steam status <Steam ID> - Returns <Steam ID> community status
#   hubot dota history <Steam ID> - Returns metadata for the latest 5 game lobbies with <Steam ID>
#   hubot dota match <match ID> [<Steam ID>] - Returns information about a particular <match ID>. Optionally, if <Steam ID> is included, its match information will also be returned
#
# Author:
#   MrSaints

moment = require 'moment'

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
    robot.respond /steam id( me)? (.*)/i, (msg) ->
        getSteamID msg, msg.match[2], (id) ->
            if id
                msg.match[2] += if msg.match[2].slice(-1) is "s" then "'" else "'s"
                msg.reply "#{msg.match[2]} Steam ID is: #{id}"

    robot.respond /steam status (\d+)/i, (msg) ->
        steam_request msg, "/ISteamUser/GetPlayerSummaries", steamids: msg.match[1], (object) ->
            player = object.response.players[0]
            status = if player.communityvisibilitystate is 1 then 'Unavailable (Private)' else personaStates[player.personastate]
            lastOnline = moment.unix(player.lastlogoff).fromNow()
            msg.reply "#{msg.match[1]} belongs to #{player.personaname} who is currently #{status} and was last online #{lastOnline}."
        , 2

    robot.respond /dota history (\d+)/i, (msg) ->
        steam_request msg, "/IDOTA2Match_570/GetMatchHistory", { account_id: msg.match[1], matches_requested: 5 }, (object) ->
            if object.result.status is 15
                msg.reply "The Steam ID you have entered (\"#{msg.match[1]}\") does not exist or it does not have match history enabled."
                return
            else if object.result.num_results is 0
                msg.reply "No game matches were found for the Steam ID: #{msg.match[1]}."
                return

            communityID = getCommunityID(msg.match[1])

            for match in object.result.matches
                hero = "N/A"
                start = moment.unix(match.start_time).fromNow()

                for player in match.players
                    if player.account_id is communityID
                        hero = getHero(player.hero_id).localized_name
                        break;

                msg.send "Match ID: #{match.match_id} | Lobby: #{lobbies[match.lobby_type]} | Hero: #{hero} | #{start}"

    robot.respond /dota match (\d+)( \d*)?/i, (msg) ->
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

            if communityID
                for player in match.players
                    if player.account_id is communityID
                        msg.reply "#{getHero(player.hero_id).localized_name} (Lvl #{player.level}) | KDA: #{player.kills}/#{player.deaths}/#{player.assists} | LH: #{player.last_hits} | GPM: #{player.gold_per_min} | XPM: #{player.xp_per_min}"
                        return
                msg.reply "The Steam ID you have entered (\"#{msg.match[1]}\") was not found in Match ID #{match.match_id}."

getSteamID = (msg, customURL, handler) ->
    steam_request msg, "/ISteamUser/ResolveVanityURL", vanityurl: customURL, (object) ->
        if object.response.success is 42
            msg.reply "The custom URL you have entered (\"#{msg.match[2]}\") does not exist."
            return

        handler object.response.steamid

getCommunityID = (steamID) ->
    # 64 -> 32
    (steamID - 76561197960265728)

getHero = (heroID) ->
    return hero for hero in heroes when hero.id is heroID

getTowers = (dec) ->
    for status, tower in "00000000000#{(+dec).toString(2)}".slice(-11).split('')
        if parseInt(status) then towers[tower] else continue

steam_request = (msg, endpoint, params = {}, handler, version = 1) ->
    params.key = process.env.STEAM_API_KEY

    msg.http("http://api.steampowered.com#{endpoint}/v#{version}/")
        .query(params)
        .get() (err, res, body) ->
            if err or res.statusCode isnt 200
                err = "Bad request (invalid Steam web API key)" if res.statusCode is 400
                msg.reply "An error occurred while attempting to process your request: #{err}"
                return

            handler JSON.parse(body)
