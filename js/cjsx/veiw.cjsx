React = require('react')
List = require './list.cjsx'
Container = require './container.cjsx'

View = React.createClass
  displayName: 'View'

  render: ->
    <div className='container'>
      <div className='row'>
        <List
          events={@props.events}
          current={@props.current}
          show={@props.show}
        />
        <Container
          current={@props.current}
          events={@props.events}
        />
      </div>
    </div>

module.exports = View