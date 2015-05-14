React = require('react')
window.player = require './player.coffee'

Video = React.createClass
  displayName: 'Video'
  shouldComponentUpdate: (nextProps, nextState) ->
     nextProps.current.url isnt @props.current.url

  componentDidUpdate: (prevProps, prevState) ->
    if !!@props.current.url
      console.log @props.current.url
      if player.exist()
        player.deleteVideo()
      @refs.target.getDOMNode().innerHTML = "<div id='jw_video'></div>"
#play the videoStream with current url
      player.initVideo()
    else
      if player.exist()
        player.deleteVideo()

  render: ->
    <div className = {"video"} ref="target"/>

module.exports = Video