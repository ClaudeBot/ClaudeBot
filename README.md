# ClaudeBot

[![Build Status](https://travis-ci.org/ClaudeBot/ClaudeBot.svg)](https://travis-ci.org/ClaudeBot/ClaudeBot)
[![Dependency Status](https://david-dm.org/ClaudeBot/ClaudeBot.svg)](https://david-dm.org/ClaudeBot/ClaudeBot)

A general-purpose IRC bot powered by Github's Hubot.

**We are in the midst of revising our documentation for ClaudeBot to reflect changes in Hubot, community scripts, and our personal scripts. Suggestions and contributions are welcomed.**


## About

[Hubot](https://hubot.github.com/) is Github's extendable and scriptable chat bot.

ClaudeBot is a personalised instance of Hubot, and it currently reside in the [FyreChat](http://www.fyrechat.net/) IRC network. It is configured to be deployed on [Heroku](http://www.heroku.com/), but efforts are being made to migrate it to a self-managed platform.

It leverages on Hubot's [core scripts](scripts/), and tries to maintain consistency with its standards / conventions. In practice, this philosophy may be omitted if an alternative or a need for immediate action is required. Simply put, we may deviate from Hubot's codebase, and community if we have to.

It is designed to bring the power of [numerous web APIs](https://github.com/ClaudeBot) onto a single chat interface.


## Running

If you are just getting started with node.js, npm and Hubot, please check out Hubot's [documentation](https://hubot.github.com/docs/). This documentation assumes you have reasonable experience with the aforementioned technologies.

### Locally (Shell)

Fork and/or download this repository. Now, execute in the project directory:

```
% bin/hubot
```

### Deployment

Refer to Hubot's [`bin/hubot`](https://github.com/github/hubot/blob/master/bin/hubot#L11) file for a list of available flags. Change [`Procfile`](https://devcenter.heroku.com/articles/procfile) accordingly if you are deploying it on Heroku. Hubot's [official documentation](https://hubot.github.com/docs/deploying/) provides more thorough information on deployment.

If you would like to change the bot's name (currently set to ClaudeBot), modify ClaudeBot's [`bin/hubot`](https://github.com/ClaudeBot/ClaudeBot/blob/master/bin/hubot) (the bot's alias is defined in this file as well). This is not the same as Hubot's `bin/hubot` (which is a dependency of ClaudeBot).


## Persistence

ClaudeBot's [brain data](https://hubot.github.com/docs/scripting/#persistence) (in-memory key-value store) is frequently synchronised to and from a Redis store ([RedisLabs](https://redislabs.com/)). Scripts may use `robot.brain` to store and retrieve long-term data (e.g. user information).

It previously relied on [Dweet.io](http://dweet.io/) for persistence, but it has since been [deprecated](scripts/dweet-brain.disabled) as it is not practical in the long-run.


## Environment Variables

The following environment variables (the bot's configuration) are required for certain aspects of the bot to work:

### IRC Adapter

- `HUBOT_IRC_SERVER`
- `HUBOT_IRC_ROOMS` *(comma-separated)*
- `HUBOT_IRC_NICK`

View [`hubot-irc`](https://github.com/nandub/hubot-irc) documentation for more information. You may also decide to change the bot's adapter. Alter the `-a` or `--adapter` flag (see [`Procfile`](Procfile) for an example on how it is used).

### Services

- `REDIS_URL`
- `GOOGLE_API_KEY`
- `PASTEBIN_API_KEY`
- `STEAM_API_KEY`
- `TWITCH_API_KEY`

Ensure they are set to avoid any unexpected behaviour or errors. Alternatively,  you may disable the scripts that require them (e.g. `hubot-steam-webapi` uses the `STEAM_API_KEY`).


## Scripts

ClaudeBot neither relies on nor supports the old [`hubot-scripts`](https://github.com/github/hubot-scripts) repository. Scripts may be added via npm and `external-scripts.json`, or through the `scripts/` directory ([search npm](https://www.npmjs.com/search?q=hubot-) or visit the [organisation](https://github.com/hubot-scripts) for a list of available scripts). We strongly discourage the use of `hubot-scripts`.


## Commands

Refer to the [installed / external scripts'](https://github.com/ClaudeBot/ClaudeBot/blob/master/external-scripts.json) documentation (i.e. their `README`) or visit the [online help page](http://bot.fyianlai.com/ClaudeBot/help) for ClaudeBot.

Assuming your copy of the bot is online, its own help page is located at `localhost:8080/BotName/help` by default. _The default web port is `5000` if it is executed using [foreman](http://ddollar.github.io/foreman/), i.e. [`Procfile`](Procfile)_. Also, typing `! help` (on your bot's adapter interface, e.g. Shell, IRC, Slack, etc) will return a list of available commands. `!` is an alias for `ClaudeBot`, and may be used interchangeably.


## Community

We love developing scripts, and improvements for Hubot. It is also a good learning experience and we welcome you to join us!

We are available to help you at [FyreChat's](http://www.fyrechat.net/) __#sandbox__ channel. Feel free to open up issues or pull requests. Comments, feature requests, bug reports, questions, etc will be entertained.
