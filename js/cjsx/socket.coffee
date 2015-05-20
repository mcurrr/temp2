window.jQuery = window.$ = require 'jquery'
require './bullet.js'

window.socket = $.bullet 'wss://www.favbet.com/bullet'

window.socket.onopen = ->
  console.log "window.socket opened"
  window.socket.send(JSON.stringify {user_ssid: "9275171377C27C12F3C6A47EDF"})
  window.socket.send(JSON.stringify {
            dataop: {
              "live.event": ["all"]
            }
          })
  
window.socket.ondisconnect = ->
  console.log "socket disconnect"
  
window.socket.onclose = ->
  console.log "socket closed"
  
window.socket.onmessage = (e) ->
  eData = JSON.parse(e.data)
  sortMessage(eData)
  window.socket.send(JSON.stringify {
            dataop: {
              "live.event": ["all"]
            }
          })

sortMessage = (e) ->
  e.map (inCome, k) ->
    switch (inCome.type)

#=================OUTCOMES

      when 'outcome.update_list'
        events = window.App.state.events
        inCome.data.outcomes.map (obj) -> 
          events.map (event) ->
            if obj.market_id == event.head_market.market_id
              event.head_market.outcomes.map (coef) ->
                if obj.outcome_id == coef.outcome_id
                  coef.outcome_coef = obj.outcome_coef
                  console.log "coef of #{event.event_name} had changed"
                  ###
                  SET STATE HERE                  
                  ###
                  window.App.setState(
                    events: events
                    )

      when 'outcome.update_result'
        console.log "<-=-=-=-=-=-=-=-=-=-=WHAT?-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        console.log "#{inCome.type}"
        console.log inCome.data
      
#===================EVENTS

      when 'event.unsuspend'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            console.log "UNSUSPENDED EVENT #{event.event_name}!"
            event.suspended = false
            event.head_market.market_suspend = 'no'
            ###
            SET STATE HERE                  
            ###
            window.App.setState(
              events: events
              )
            false
      
      when 'event.suspend'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            console.log "SUSPENDED EVENT #{event.event_name}!"
            event.suspended = true
            event.head_market.market_suspend = 'yes'
            false
      
      when 'event.update_result'
        false
      
      when 'event.update'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            console.log "UPDATE CHANNEL #{event.event_name}?"
            if event.event_tv_channel != inCome.data.event_tv_channel
              event.event_tv_channel = inCome.data.event_tv_channel
              console.log "REPLACED CHANNEL IN #{event.event_name}!"
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
              )
              if !!event.active
                current = window.App.state.current
                current.id_tv = event.event_tv_channel
                window.App.setState(
                  current: current
                )
                window.App._getVideoStreamPath() #WILL IT WORK???
                console.log "WOPS! TV CHANNEL WAS CHANGED RIGHT NOW+++++++++++++++++++++++++++"
                false
            else
              console.log "seems to be not inportant..."

      when 'event.set_finished'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            console.log "FINISHED EVENT #{event.event_name}! RESULT: #{inCome.data.event_result_name}"
            event.finished = true
            ###
            SET STATE HERE
            ###
            window.App.setState(
              events: events
              )
            false

      when 'event.delete'
        window.output = "#{inCome.type}"
        console.log "EVENT DELETE"
        console.log inCome.type, inCome.data, "<------------------"
        events = window.App.state.events
        del = _.remove events, (event) ->
          event.event_id == inCome.data.event_id
        console.log "length of deleted", del.length
        if del.length
          console.log "WAS", events.length + del.length
          ###
          SET STATE HERE
          ###
          window.App.setState(
            events: events
            )
          console.log "IS", events.length
          console.log "ACTION-=-=-=-=-#{del[0].event_name} DELETED!"
#if deleted event was active then stop streaming it
          if !!del[0].active
            current = window.App.state.current
            current.i = null
            current.url = ''
            ###
            SET STATE HERE
            ###
            window.App.setState(
              current: current
              )
            console.log "IT WAS ACTIVE. CHOOSE ANOTHER ONE"
          else
            current = window.App.state.current
            events = window.App.state.events
            actElem = _.find events, (event) ->
              !!event.active
            current.i = _.indexOf events, actElem
            console.log "now current.i = #{current.i} because of deleting"
            ###
            SET STATE HERE
            ###
            window.App.setState(
              current: current
              )

      when 'event.insert'
        events = window.App.state.events
#checking if it is watchable
        if inCome.data.event_tv_channel?
          inCome.data.new = true
          console.log "WAS", events.length
          events.push inCome.data
#sorting new array by the event name
          console.log "active event before sorting -", _.pluck events, 'active'
          console.log events
          sortedEvents = _.sortBy events, 'event_name'
          console.log "active event after sorting -", _.pluck sortedEvents, 'active'
          console.log sortedEvents
#recounting current.i
          current = window.App.state.current
          console.log "current.i was = #{current.i}"
          actElem = _.find sortedEvents, (event) ->
            !!event.active
          current.i = _.indexOf sortedEvents, actElem
          console.log "now current.i = #{current.i} because of new incoming"
          ###
          SET STATE HERE
          ###
          window.App.setState(
            events: sortedEvents
            current: current
            )
          console.log "IS", window.App.state.events.length
          console.log "ACTION-=-=-=-=-#{inCome.data.event_name} INSERT CHANNEL!"


#================MARKETS

      when 'market.insert_list'
        events = window.App.state.events
        inCome.data.map (inComeChild) ->
          events.map (event) ->
            if event.event_id == inComeChild.event_id
              event.head_market = inComeChild
              console.log "market.insert_list #{event.event_name}"
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      when 'market.unsuspend'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            if event.head_market.market_id = inCome.data.market_id
              event.head_market.market_suspend = 'no'
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      when 'market.suspend'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            if event.head_market.market_id = inCome.data.market_id
              event.head_market.market_suspend = 'yes'
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      when 'market.delete'
        events = window.App.state.events
        console.log "MARKET DELETE"
        console.log inCome.type, inCome.data, "<------------------"
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            if event.head_market.market_id = inCome.data.market_id
              event.head_market = {}
              console.log "market.delete #{event.event_name}"
              console.log inCome.data
              console.log event
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      when 'market.unsuspend_list'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            if event.head_market.market_id = inCome.data.market_id
              event.head_market.market_suspend = 'no'
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      when 'market.suspend_list'
        events = window.App.state.events
        events.map (event) ->
          if event.event_id == inCome.data.event_id
            if event.head_market.market_id = inCome.data.market_id
              event.head_market.market_suspend = 'yes'
              console.log "market.suspend_list #{event.event_name}"
              console.log inCome.data
              console.log event
              ###
              SET STATE HERE
              ###
              window.App.setState(
                events: events
                )
              false

      else window.output = "SMTH NEW!!! #{inCome.type}======!!!!!!!!!!======"


module.exports = window.socket