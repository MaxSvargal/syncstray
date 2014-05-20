'use strict'

######
#  CoffeeScript Presenter (Publish/Subscribe) pattern realization
#  By MaxSvargal <maxsvargal@gmail.com>
#  http://github.com/maxsvargal
#  License: MIT
######

module.exports = class Observer
  constructor: ->
    @topics = {}
    @subUid = -1
    return

  publish: (topic, args) ->
    return false if not @topics[topic]
    process.nextTick =>
      subscribers = @topics[topic]
      len = if subscribers then subscribers.length else 0
      while len--
        subscribers[len].func(args)

  subscribe: (topic, func) ->
    if not @topics[topic] then @topics[topic] = []
    token = (++@subUid).toString()
    @topics[topic].push
      token: token
      func: func
    return token

  unsubscribe: (token) ->
    for topic, i in @topics
      if topic.token is token
        @topics.splice i, 1
        return token