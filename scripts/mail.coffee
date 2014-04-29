# Description:
#   Mail System
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot mail <recipient> <message> - Sends a <message> to <recipient> when found available
#
# Author:
#   MrSaints

module.exports = (robot) ->
    getMails = ->
        robot.brain.data.mails or= {}

    deliverMails = (context, recipient) ->
        return unless robot.brain.data.mails?

        recipient = recipient.toLowerCase()

        if mails = getMails()[recipient]
            for mail in mails
                context.send "#{robot.brain.userForName(recipient).name}: [From #{mail[0]}] #{mail[1]}"
            delete getMails()[recipient]

    robot.respond /mail (\S+) (.+)/i, (msg) ->
        [command, recipient, message] = msg.match
        sender = msg.message.user.name

        if recipient is robot.name
            msg.reply "Thanks, but no thanks! I do not need any mail."

        if recipient is sender
            msg.reply "Are you sure you want to send a mail to yourself? Sad."

        recipient = recipient.toLowerCase()

        getMails()[recipient] or= []
        getMails()[recipient].push [sender, message]
        msg.reply "Your mail has been prepared for #{recipient}."

    robot.enter (response) ->
        deliverMails response, response.message.user.name

    robot.hear /./i, (msg) ->
        deliverMails msg, msg.message.user.name