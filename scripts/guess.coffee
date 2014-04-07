# Description:
#   4-digit guessing game
#   Based on AB, The Game by Muan (http://ab.muan.co/)
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot guess <number> - Returns a feedback indicating how accurate your 4-digit <number> guess is
#   hubot guess surrender - Restarts the game with a new number, duh!
#   hubot guess tutorial - Tells you how to play this game
#
# Author:
#   MrSaints

players = []
failure = [
    "I have not failed. I've just found 10,000 ways that won't work. -Thomas Edison"
    "Success is stumbling from failure to failure with no loss of enthusiasm. -Winston Churchill"
    "It is hard to fail, but it is worse never to have tried to succeed. -Theodore Roosevelt"
    "Only those who dare to fail greatly can ever achieve greatly. -Robert F. Kennedy"
    "Failures are finger posts on the road to achievement. -C.S. Lewis"
    "My great concern is not whether you have failed, but whether you are content with your failure. -Abraham Lincoln"
    "When I was young, I observed that nine out of ten things I did were failures. So I did ten times more work. -George Bernard Shaw"
]

checkNumber = (answer, attempt) ->
    attemptArray = attempt.split ""
    answerArray = answer.toString().split ""

    a = 0
    b = 0

    for index, number of answerArray
        if number is attemptArray[index]
            answerArray[index] = 'x'
            attemptArray[index] = 'o'
            ++a

    for index, number of answerArray
        if attemptArray.indexOf(number) >= 0
            attemptArray[attemptArray.indexOf(number)] = ''
            ++b

    [a, b]

newNumber = ->
    (Math.random()).toString()[2..5]

suffix = (number) ->
    remainder = number % 10
    suffixes = ["th", "st", "nd", "rd"]

    if number > 3 and number < 21
        number += suffixes[0]
    else if remainder <= 3
        number += suffixes[remainder]
    else
        number += suffixes[0]

    number

win = (msg) ->
    msg.reply "#{msg.match[1]} is the right answer! You got it at the #{suffix(players[msg.message.user.name].attempts)} attempt."
    restart msg.message.user.name
    console.log players

restart = (user) ->
    players[user] = null

module.exports = (robot) ->
    robot.respond /guess (\d{4})/i, (msg) ->
        if not players[msg.message.user.name]?
            # Initialize
            players[msg.message.user.name] = 
                answer: newNumber()
                attempts: 0

        ++players[msg.message.user.name].attempts

        if players[msg.message.user.name].answer is msg.match[1]
            win msg

        feedback = checkNumber players[msg.message.user.name].answer, msg.match[1]

        msg.reply "#{feedback[0]}A #{feedback[1]}B"

    robot.respond /guess surrender/i, (msg) ->
        if players[msg.message.user.name]
            restart msg.message.user.name
            msg.reply "New game session created! #{msg.random(failure)}"

    robot.respond /guess tutorial/i, (msg) ->
        msg.reply "The goal of this game is to guess a 4-digit number within the least number of attempts possible."
        msg.send "With every guess, you will get a feedback indicating how many A and B you got with the guess."
        msg.send "An A means: one of the digits is correct, and is also at the right place."
        msg.send "A B means: one of the digits is a right number, but not at the right place."