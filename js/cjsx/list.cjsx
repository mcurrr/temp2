React = require('react')

List = React.createClass
  displayName: 'List'

  render: ->
    <div className='col-sm-4'>
      <ul style={{"padding": 0}}>{
        @props.events.map (event, i) =>
          word = ''
          if @props.current.i == i #if active
            style = 'btn btn-block btn-primary'
          else #if not active
            style = 'btn btn-block btn-info'
#chenging style if new or finished (finished priority)
          if !!event.new
            word = 'NEW '
            style = 'btn btn-block btn-success'
          if !!event.finished
            word = 'FIN '
            style = 'btn btn-block btn-danger'

          <li onClick={@props.show.bind null, i} key={i + event.event_name} title="#{event.event_name}">
          <a href="#" onclick="event.preventDefault();" className={style} style={{"overflow": "hidden", "textOverflow": "ellipsis"}}>{
            "#{i+1} #{word} #{event.event_name}"
          }</a>
          </li>
      }
      </ul>
    </div>

module.exports = List