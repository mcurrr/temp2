React = require('react')
Video = require './video.cjsx'
Outcomes = require './outcomes.cjsx'

Container = React.createClass
  displayName: 'Container'

  render: ->
    <div className='col-sm-8 forVideo' style={'position': 'relative'}>
        <Video
          current={_.cloneDeep @props.current}
        />
        <Outcomes
          current={@props.current}
          events={@props.events}
        />
    </div>

module.exports = Container