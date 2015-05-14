React = require('react')

Outcomes = React.createClass
  displayName: 'Outcomes'

  render: ->
    <div className='outcomes' style={"position": "absolute", "color": "blue"}>
      <ul>{
        if @props.current.i? && @props.events[@props.current.i].head_market? && @props.events[@props.current.i].head_market.outcomes?
          if @props.events[@props.current.i].head_market.market_suspend == 'no'
            style = 'coefShow'
          else
            style = 'coefNoShow'
          @props.events[@props.current.i].head_market.outcomes.map (outcome, i) =>

            <li className='outcome' key={i}>
              <span>{
                "#{outcome.outcome_name} : "
              }</span>
              <span className={style}>{
                "#{outcome.outcome_coef}"
              }</span>
            </li>
      }
      </ul>
    </div>

module.exports = Outcomes
