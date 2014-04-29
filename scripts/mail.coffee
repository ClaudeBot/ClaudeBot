# Description:
#   Mail System
#
# Dependencies:
#   "moment": "^2.5.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot mail <recipient> <message> - Sends a <message> to <recipient> when found available
#   hubot unmail [<recipient>] - Deletes all mail sent by you. Optionally, if <recipient> is specified, all mail sent to <recipient> by you will be deleted
#
# Author:
#   MrSaints

moment = require 'moment'

module.exports = (robot) ->
    getMails = ->
        robot.brain.data.mails or= {}

    deliverMails = (context, recipient) ->
        return unless robot.brain.data.mails?

        recipient = recipient.toLowerCase()

        if mails = getMails()[recipient]
            for mail in mails
                context.send "#{robot.brain.userForName(recipient).name}: [From #{mail[0]}, #{moment.unix(mail[1]).fromNow()}] #{mail[2]}"
            delete getMails()[recipient]

    robot.respond /unmail(\s?.*)/i, (msg) ->
        # TODO

    robot.respond /mail (\S+) (.+)/i, (msg) ->
        [command, recipient, message] = msg.match
        sender = msg.message.user.name

        if recipient is robot.name
            msg.reply "Thanks, but no thanks! I do not need any mail."
            return

        if recipient is sender
            msg.reply "Are you sure you want to send a mail to yourself? Sad."
            return

        recipient = recipient.toLowerCase()

        getMails()[recipient] or= []
        getMails()[recipient].push [sender, moment().unix(), message]
        msg.reply "Your mail has been prepared for #{recipient}."

    robot.enter (response) ->
        deliverMails response, response.message.user.name

    robot.hear /./i, (msg) ->
        deliverMails msg, msg.message.user.name