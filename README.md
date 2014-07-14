# ClaudeBot
[![Dependency Status](https://david-dm.org/MrSaints/ClaudeBot.svg)](https://david-dm.org/MrSaints/ClaudeBot)

Totally not trying to poke fun at the word cloud. *\*cough CloudIRC\**
This is a clone of GitHub's Campfire bot, [Hubot](https://hubot.github.com/). He's pretty chill. 
It is also [WalaoBot's](https://github.com/MrSaints/WalaoBot) highly evolved, French cousin. *Oui, oui.*

**What do you call a French bot that has been attacked by a bear?** Claude bot. *\*Ba dum ts\**

This version is designed to protect and serve the great people of [FyreChat IRC #sandbox](http://fyrechat.net/) (using [Hubot IRC adapter](https://github.com/nandub/hubot-irc)); and to be deployed on [Heroku](http://www.heroku.com).

The original, generated Hubot `README` can be found [here](https://github.com/github/hubot/blob/master/src/templates/README.md). 
Additional documentation can be found on [Hubot's GitHub](https://github.com/github/hubot/tree/master/docs).


## Features

As ClaudeBot is *somewhat* biologically identical to Hubot, it derives Hubot's default functionality and script. 
Unlike its twin in its natural form however, ClaudeBot is also exposed to custom scripts from the [hubot-scripts](https://github.com/github/hubot-scripts) package. A full list of enabled scripts may be found in the `hubot-scripts.json` file in this repo.


### Scripting

ClaudeBot is open to evolution. It may be extended to become more alpha, or mutated to become more primitive and/or defunct. 
The [Scripting Guide](https://github.com/github/hubot/blob/master/docs/scripting.md) will provide you with more information on how you can make this brainless slave more exciting or useless and boring. 

You can modify part of its genetic makeup and/or add whatever functionality you want it to have via the `./scripts` folder and the `hubot-scripts.json` file in this repo. 
Browse the [hubot-scripts catalog](http://hubot-script-catalog.herokuapp.com/) for a list of available genes that you can (de)activate on-the-fly.


### Master Ian's Commands

A full list of command may be found by visiting the bot via HTTP `/RobotName/help` or by calling the `help` command.

- **hubot cdnjs search \<query\>:** Returns the CDNJS URL for the first 5 front-end dependencies matching the search \<query\>
- **hubot cdnjs fetch \<dependency\>:** Returns the CDNJS URL for a specific front-end \<dependency\> (e.g. jQuery)
- **hubot so \<query\>:** Returns the first 5 questions on Stack Overflow matching the search \<query\> (stack command shortcut)
- **hubot stack [on] <site> [about] \<query\>:** Returns the first 5 questions on a Stack Exchange \<site\> matching the search \<query\>
- **hubot ttv featured:** Returns the first 5 featured live streams
- **hubot ttv game \<category\>:** Returns the first 5 live streams in a game \<category\> (case-sensitive)
- **hubot ttv search \<query\>:** Returns the first 5 live streams matching the search \<query\>
- **hubot ttv stream \<name\>:** Returns information about stream \<name\>
- **hubot ttv top:** Returns the top 5 games sorted by the number of current viewers on Twitch, most popular first
- **hubot wiki search \<query\>:** Returns the first 5 Wikipedia articles matching the search \<query\>
- **hubot wiki summary \<article\>:** Returns a one-line description about \<article\>
- **hubot face [me]:** Returns a random, but cool ASCII face
- **hubot guess \<number\>:** Returns a feedback indicating how accurate your 4-digit \<number\> guess is
- **hubot guess surrender:** Restarts the game with a new number, duh!
- **hubot guess tutorial:** Tells you how to play this game
- **hubot steam id [me] \<custom URL\>:** Returns the Steam ID for the user under `http://steamcommunity.com/id/<custom URL>`
- **hubot steam status \<Steam ID|custom URL\>:** Returns \<Steam ID\> or \<custom URL\> community status
- **hubot dota history \<Steam ID|custom URL\>:** Returns metadata for the latest 5 game lobbies with \<Steam ID\> or \<custom URL\>
- **hubot dota match \<match ID\> [\<Steam ID|custom URL\>]:** Returns information about a particular \<match ID\>. Optionally, if \<Steam ID\> or \<custom URL\> is included, its match information will also be returned
- **hubot mail \<recipient\> \<message\>:** Sends a \<message\> to \<recipient\> when found available
- **hubot unmail [\<recipient\>]:** Deletes all mail sent by you. Optionally, if \<recipient\> is specified, all mail sent to \<recipient\> by you will be deleted
- **hubot \<search|google\> \<query\>:** Queries Google Search for \<query\> and returns the first 5 results
- **hubot delete \<key\>:** Removes \<key\> and all of its content from the local brain / persistence
- **hubot brain save:** Forces a save to Dweet.io
- **hubot brain status:** Returns the brain status

*Steam Web API which powers all the Steam and Dota 2 commands requires an API key which you may set via `STEAM_API_KEY`.*


### Brain

ClaudeBot (like its counterpart, Hubot) has a short-term and a long-term memory store. Memories in its short-term store will not be persisted should it oh I don't know... die and come back alive? Its local brain will start with a blank slate. Thus, it has an external brain which serves as a more permanent storage medium for long-term memories.

Hubot's default, external brain `redis-brain.coffee` was surgically removed from `hubot-scripts.json` in favour of a custom engineered, cloud, key-value based brain solution powered by [Dweet.io](https://dweet.io/). 

ClaudeBot uses `dweet-brain.coffee` for data storage / persistence. It is however, disabled unless the `DWEET_THING` environment variable is set. What is `DWEET_THING` you may ask? Well [find out](https://dweet.io/) for yourself. It is also set to automatically transfer data from its short-term memory to its long-term memory every 30 minutes. You can tweak it by setting the delay (in seconds) via `DWEET_AUTOSAVE`. You can protect your data by purchasing a [Dweet.io lock](https://dweet.io/locks) and setting its key via `DWEET_KEY`.


## Usage

### Testing (Locally)

You can make ClaudeBot run in your local shell environment by commanding the following:

    % bin/hubot

Then, you can start interacting with ClaudeBot by typing `hubot help` (it has not quite absorbed the fact it is now called Claude, at least not locally). For a list of basic commands, refer to [hubot's documentation](https://github.com/github/hubot/tree/master/docs).


### Adapters

ClaudeBot - as mentioned earlier - was designed to be a slave to the great people of an IRC channel. 
Thus, to make it serve differently it needs to be commanded the following:

    % bin/hubot -a irc

You may replace [hubot-irc](https://github.com/nandub/hubot-irc) with your desired [Hubot adapter](https://github.com/github/hubot/blob/master/docs/adapters.md).


### Configuring

CaludeBot's genetic information may be set for different environments via environment variables (also known as [config vars on Heroku](https://devcenter.heroku.com/articles/config-vars)).  
To operate in an IRC environment however, the following environment variables must be set:

- **HUBOT_IRC_SERVER**
- **HUBOT_IRC_ROOMS**
- **HUBOT_IRC_NICK**

For a list of IRC configuration options, refer to [hubot-irc's documentation](https://github.com/nandub/hubot-irc).

Remember when I stated that ClaudeBot has not quite absorbed the fact it is now called Claude? 
Well, you can force its name by passing `(-n|--name) NAME` when running it. 
You may also set another name (alias) for it via `(-l|--alias) ALIAS`.

Oh, and you should probably tell it who its true masters are by setting `HUBOT_AUTH_ADMIN` (comma-separated like a boss).


### Deployment

Once it is battle ready, send it off for a [tour in Heroku](https://github.com/github/hubot/blob/master/docs/deploying/heroku.md):

    % heroku create --stack cedar
    % git push heroku master
    % heroku ps:scale app=1

Upon deployment, it will take orders / commands from `Procfile`. 
You can change its name here and tell it how it should behave in a [dyno](https://devcenter.heroku.com/articles/procfile).

You may deploy it [elsewhere](https://github.com/github/hubot/tree/master/docs/deploying) too.


### Management
- **Resurrect:** `heroku restart`
- **Battle report:** `heroku logs`