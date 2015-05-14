React = require 'react'
View = require './veiw.cjsx'
player = require './player.coffee'
socket = require './socket.coffee'
$ = require 'jquery'
_ = require 'lodash'


App = React.createClass
  displayName: 'App'

  getInitialState: ->
    {
      events: []
      current: {
        url: ''
        i: null
      }
    }

  propTypes:
    events: React.PropTypes.array.isRequired
    current: React.PropTypes.object
    url: React.PropTypes.string

  componentWillMount: ->
    player.init()
#get the list of all live events
    $.ajax
      url: 'https://www.favbet.com/live/markets/'
      cache: false
      dataType: 'json'
      error: (xhr, ajaxOptions, thrownError) ->
        console.log 'error on first request'
        console.log xhr.status
        console.log thrownError
      success: (data) =>
        window.events = []
        window.live = 0
        window.channel = 0
        window.broadcast = 0
        window.statistic = 0
        sportCollection = data.markets
        console.log sportCollection
        _.map sportCollection, (sport) ->
          _.map sport.tournaments, (tournament) ->
            tournament.events.map (event, i) ->
#in case invalid event
              if event.event_name
                live++
#TODO: figure out how to separate actual event from it's own statistic (use event_dt, event_name, head_market)
                if event.event_tv_channel?
                  #do we have the same event in the array already (statistic)?
                  res = _.result _.find events, (old) ->
                    old.event_name == event.event_name
                  if res
                    #it's a statistic
                    console.log "statistic!", event.event_name
                  else
                    #it's not a statistic
                    channel++
                    events.push event
                    console.log "unique event: ", event.event_name

        console.log "#{live} live events + #{statistic} channel statistics"
        console.log "#{channel} live events with video stream"
        sortedEvents = _.sortBy events, 'event_name'
        @setState(
          events: sortedEvents
        )

  handlerShowingVideo: (i) ->
    console.log "i: #{i}"
    if @_hasFinished()
      @_deleteFinished(i)
#@_deleteFinished include @_deleteNewWord() and @_getIdTv()
    else
      if i != @state.current.i
        events = @state.events
        current = @state.current
        events.map (event) ->
          if event.active?
            delete event.active
        events[i].active = true
        current.i = i
        @setState(
          events: events
          current: current
        )
        @_deleteNewWord()
        @_getIdTv()
    console.log "current.i: #{@state.current.i}"

  _getIdTv: () ->
    $.ajax
      url: "https://www.favbet.com/live/markets/event/#{@state.events[@state.current.i].event_id}/"
      cache: false
      dataType: 'json'
      error: (xhr, ajaxOptions, thrownError) ->
        console.log xhr.status
        console.log thrownError
      success: (data) =>
        current = @state.current
        current.id_tv = data.event_tv_channel
        @setState(
          current: current
        )
        @_getVideoStreamPath()


  _deleteNewWord: () ->
    events = @state.events
#using "@state.current.i" instead of just "i" because "i" might change during deleting finished events
    if @state.current.i?
      if !!events[@state.current.i].new
        events[@state.current.i].new = false
        @setState(
          events: events
        )

  _hasFinished: ->
    events = @state.events
    hasIt = _.find events, (event) ->
      !!event.finished
#    console.log "hasFinished? - #{!!hasIt}"
    !!hasIt

  _deleteFinished: (i) ->
    events = @state.events
    current = @state.current
#if click was on finished event then just delete all finished events and make non-active those who left
#INFO: with this click player will disapear
    if !!events[i].finished
      current.i = null
      current.url = ''
      _.remove events, (event) ->
        !!event.finished
      events.map (event) ->
        if event.active?
          delete event.active
      @setState(
        events: events
        current: current
      )
      console.log "#1: click was on finished event"
      console.log "current.i: ", current.i
      console.log "events: ", events
    else
#if click was on non-finished but active event then delete finished and reculculate current active event
      if i == current.i
        _.remove events, (event) ->
          !!event.finished
        actElem = _.find events, (event) ->
          !!event.active
        current.i = _.indexOf events, actElem
        @setState(
          events: events
          current: current
        )
        console.log "#2: click was on non-finished but active event"
        console.log "current.i: ", current.i
        console.log "events: ", events
#if click was on non-finished and non-active event then make it active then delete finished and then reculculate current active event
      else
        events.map (event) ->
          if event.active?
            delete event.active
        events[i].active = true
        _.remove events, (event) ->
          !!event.finished
        actElem = _.find events, (event) ->
          !!event.active
        current.i = _.indexOf events, actElem
        @setState(
          events: events
          current: current
        )
        @_getIdTv()
        console.log "#3: click was on non-finished and non-active event"
        console.log "current.i: ", current.i
        console.log "events: ", events
    @_deleteNewWord()

  _getVideoStreamPath: () ->
#get current id_tv
    $.ajax
      url: "https://www.favbet.com/live/tv/#{@state.current.id_tv}/"
      cache: false
      dataType: 'xml'
      error: (xhr, ajaxOptions, thrownError) ->
        console.log xhr.status
        console.log thrownError
        current.url = ''
        @setState(
          current: current
        )
        if xhr.status == 403
          console.log "YOU NEED TO LOG IN"
      success: (data) =>
#get URL from XML of stream
        url = $(data).find('stream').attr('request_stream')
        if !url
          error = $(data).find('streams').attr('error')
          url = ''
          current = @state.current
          current.url = url
          @setState(
            current: current 
          )
          console.log "error in XML: #{error}"
          console.log @state.current.url
        else
  #decoding url with regexp
          url = url.replace /%3A/g, ':'
          url = url.replace /%2F/g, '/'
          url = url.replace /%3F/g, '?'
          url = url.replace /%3D/g, '='
          url = url.replace /%26/g, '&'
          if url.match /^http/
            $.ajax
              url: url
              cache: false
              dataType: 'xml'
              error: (xhr, ajaxOptions, thrownError) ->
                console.log xhr.status
                console.log thrownError
              success: (data) =>
                console.log data
  #get URL from XML of stream, assembling url parts
                urlUrl = $(data).find('token').attr('url')
                urlStream = $(data).find('token').attr('stream')
                urlAuth = $(data).find('token').attr('auth')
  #final url
                url = "rtmp://#{urlUrl}:#{urlStream}"
                console.log "URL with authenticatiion:", url
                console.log "authenticatiion:", urlAuth
                current = @state.current
                current.url = url
                @setState(
                  current: current 
                )
                console.log "stream with autentication, NOT able to show in video.js"
          else
            current = @state.current
            current.url = url
            @setState(
              current: current
            )

  render: ->
    <View
      show={@handlerShowingVideo}
      events={@state.events}
      current={@state.current}
    />

window.App = React.render(<App/>, document.getElementById('main'))