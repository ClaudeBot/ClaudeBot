# ClaudeBot

Totally not trying to poke fun at the word cloud. *\*cough CloudIRC\**
This is a clone of GitHub's Campfire bot, [Hubot](https://hubot.github.com/). He's pretty chill. 
It is also [WalaoBot's](https://github.com/MrSaints/WalaoBot) highly evolved, French cousin. *Oui, oui.*

**What do you call a French bot that has been attacked by a bear?** Claude bot. *\*Ba dum ts\**

This version is designed to protect and serve the great people of [FyreChat IRC #sandbox](http://fyrechat.net/) (using [Hubot IRC adapter](https://github.com/nandub/hubot-irc)); and to be deployed on [Heroku](http://www.heroku.com).

The original, generated Hubot `README` can be found [here](https://github.com/github/hubot/blob/master/src/templates/README.md). 
Additional documentation can be found [hubot's GitHub](https://github.com/github/hubot/tree/master/docs).


## Features

As ClaudeBot is *somewhat* biologically identical to Hubot, it derives Hubot's default functionality and script. 
Unlike its twin in its natural form however, ClaudeBot is also exposed to custom scripts from the [hubot-scripts](https://github.com/github/hubot-scripts) package. A full list of enabled scripts may be found in the `hubot-scripts.json` file in this repo.


### Scripting

ClaudeBot is open to evolution. It may be extended to become more alpha, or mutated to become more primitive and/or defunct. 
The [Scripting Guide](https://github.com/github/hubot/blob/master/docs/scripting.md) will provide you with more information on how you can make this brainless slave more exciting or useless and boring. 

You can modify part of its genetic makeup and/or add whatever functionality you want it to have via the `./scripts` folder and the `hubot-scripts.json` file in this repo. 
Browse the [hubot-scripts catalog](http://hubot-script-catalog.herokuapp.com/) for a list of available genes that you can activate.


### Master Ian's Commands

- **wiki \<query\>:** Search Wikipedia for articles using the query (returns the first 5 matches)
- **hubot ttv \<category\>:** Perform a case-sensitive search on Twitch.tv for live streams in a game category (returns the first 5)
- **hubot ttv featured:** Return the first 5 featured live streams on Twitch.tv
- **stack [on] \<site\> [about] <query>:** Search on a Stack Exchange site for questions using the query (returns the first 5 matches)
- **so \<query\>:** Search on Stack Overflow for questions using the query (shortcut for stack command)
- **cdnjs \<query\>:** Search the cdnJS script repository for the URL to the latest library available using the query (returns the first 5 matches)
- **cdnjs strictly \<query\>:** Performs the default search, but with the addition of a strict list search using Underscore.js (returns the first match)


### Brain

It does not have a brain yet and thus there is no persistence. 
`redis-brain.coffee` was removed earlier on from `hubot-scripts.json` ... 
It has no memory of you.


## Usage

### Testing (Locally)

You can make ClaudeBot run in your local shell environment by commanding the following:

    % bin/hubot

Then, you can start interacting with ClaudeBot by typing `hubot help` (it has not quite absorbed the fact it is now called Claude, at least not locally). For a list of basic commands, refer to [hubot's documentation](https://github.com/github/hubot/tree/master/docs).

### Adapters

ClaudeBot - as mentioned earlier - was designed to be a slave to the great people of an IRC channel. 
Thus, to make it serve differently it needs to be commanded the following:

    % bin/hubot -a irc

You may replace irc with your desired [Hubot adapter](https://github.com/github/hubot/blob/master/docs/adapters.md).


### Deployment

Once it is battle ready, send it off for a [tour in Heroku](https://github.com/github/hubot/blob/master/docs/deploying/heroku.md):

    % heroku create --stack cedar
    % git push heroku master
    % heroku ps:scale app=1

Upon deployment, it will take orders / commands from `Procfile`. 
You can change its name here and tell it how it should behave in a [dyno](https://devcenter.heroku.com/articles/procfile).


### Management
- **Resurrect:** `heroku restart`
- **Battle report:** `heroku logs`