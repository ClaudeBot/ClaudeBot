# Description:
#   Mail System
#
# Dependencies:
#   "moment": "^2.8.3"
#
# Configuration:
#   None
#
# Commands:
#   hubot mail <recipient> <message> - Sends a <message> to <recipient> when found available
#   hubot unmail [<recipient>] - Deletes all mail sent by you. Optionally, if <recipient> is specified, only mail sent to <recipient> by you will be deleted
#
# Author:
#   MrSaints

moment = require 'moment'

#
# Config
#
MAIL_STORAGE_KEY = process.env.HUBOT_MAIL_KEY or "_mail"

module.exports = (robot) ->
    # Returns mail from the brain or an empty object if none is found
    GetMail = ->
        robot.brain.data[MAIL_STORAGE_KEY] or= {}

    # Delivers all mail belonging to a recipient in `ctx` via reply()
    # Returns nothing
    DeliverMail = (ctx) ->
        recipient = ctx.message.user.name.toLowerCase()
        if mails = GetMail()[recipient]
            for mail in mails
                ctx.reply "[From #{mail[0]}, #{moment.unix(mail[1]).fromNow()}] #{mail[2]}"
            delete GetMail()[recipient]
            ctx.robot.brain.save()

    #
    # Hubot commands
    #
    robot.respond /unmail\s?(.*)/i, (msg) ->
        deleted = 0

        # TODO: Detect and delete empty nodes
        DeleteByRecipient = (recipient) ->
            if mails = GetMail()[recipient.toLowerCase()]
                for mail, index in mails by -1
                    if mail[0] is msg.message.user.name.toLowerCase()
                        mails.splice index, 1
                        ++deleted

        # Delete using a specified recipient
        if recipient = msg.match[1]
            DeleteByRecipient recipient
            if deleted is 0
                msg.reply "There are no outbound mail sent by you towards #{recipient}."
            else
                msg.reply "#{deleted} of your mail(s) towards #{recipient} has been deleted."
                robot.brain.save()

        # Delete all from sender / command executor
        else
            for recipient, mails of GetMail()
                DeleteByRecipient recipient

            if deleted is 0
                msg.reply "There are no outbound mail sent by you."
            else
                msg.reply "#{deleted} of your mail(s) has been deleted."
                robot.brain.save()

    robot.respond /mail (\S+) (.+)/i, (msg) ->
        [_command, recipient, message] = msg.match
        sender = msg.message.user.name.toLowerCase()
        recipient = recipient.toLowerCase()

        if sender is recipient
            msg.reply "Are you sure you want to send a mail to yourself? Sad."
        else if recipient is robot.name.toLowerCase()
            msg.reply "Thanks, but no thanks! I do not need any mail."
        else
            try
                GetMail()[recipient] or= []
                GetMail()[recipient].push [sender, moment().unix(), message]
                robot.brain.save()
                msg.reply "Your mail has been prepared for #{recipient}."
            catch error
                robot.logger.error error

    #
    # Hubot events
    #
    robot.enter (msg) ->
        DeliverMail msg

    robot.hear /./i, (msg) ->
        DeliverMail msg