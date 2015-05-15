Player =
  BUFF_TIME: 7

  _getPausedStatus: () ->
    Player.wasPaused

  _getBuffTime: () ->
    Player.BUFF_TIME

  init: ->
    Player.wasPaused = false
    window.isPlayerExist = false

  exist: ->
    window.isPlayerExist

  initVideo: ->
    setTimeout (->
      window.isPlayerExist = true
      window.innerPlayer = jwplayer("jw_video").setup({
        file: window.App.state.current.url
        image: "https://www.favbet.com/static/themes/1/img/logo.png?v=1"
        rtmp:
          bufferlength: Player._getBuffTime()
        width: "100%"
        aspectratio: "4:3"
      })
      innerPlayer.play()
#if volume was previously changed then set it for new player
#TODO: rewrite volume methods fo jwplayer
      innerPlayer.onBuffer ->
        console.log innerPlayer.getRenderingMode()
        console.log "BUFFERING..."
        start = new Date()
        window.start = start.getTime()

      innerPlayer.onBufferChange ->
        console.log "BUFFER changed>>>>>>>>>>>"

      innerPlayer.onPlay ->
        if !!Player.wasPaused
          innerPlayer.stop()
          console.log 'stopped'
          innerPlayer.play()
          Player.wasPaused = false
        else
      #for the very first time
          console.log "PLAY"
          end = new Date()
          window.end = end.getTime()
          console.log "should be", Player._getBuffTime(), 'seconds'
          console.log "real seconds", ((end - start)/1000)

      innerPlayer.onPause ->
        console.log 'paused'
        Player.wasPaused = true

    ), 100

  deleteVideo: ->
    window.isPlayerExist = false
    innerPlayer.remove()

#KOSTIL'?
  unPauseVideo: ->
#forcing to update player by triggering react with changing url in state
    current = window.App.state.current
    oldCurrent = current.url
    current.url = ''
    window.App.setState(
      current: current
    )
#    console.log "empty url: ", window.App.state.current.url
    current.url = oldCurrent
    window.App.setState(
      current: current
    )
#    console.log "old url: ", window.App.state.current.url

module.exports = Player
