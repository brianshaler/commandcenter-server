_ = require 'lodash'
React = require 'react'

{DOM} = React

displayArray =
  cols: 6
  rows: 2

directions = [
  ['top', 'up']
  ['top', 'down']
  ['bottom', 'up']
  ['bottom', 'down']
  ['left', 'left']
  ['left', 'right']
  ['right', 'left']
  ['right', 'right']
]

checkDirection = (display, [side, dir]) ->
  switch side
    when 'top'
      if dir == 'up'
        return false if display.y <= 0
      else
        return false if display.height <= 1
    when 'bottom'
      if dir == 'up'
        return false if display.height <= 1
      else
        return false if display.y + display.height >= displayArray.rows
    when 'left'
      if dir == 'left'
        return false if display.x <= 0
      else
        return false if display.width <= 1
    when 'right'
      if dir == 'left'
        return false if display.width <= 1
      else
        return false if display.x + display.width >= displayArray.cols
  true


module.exports = React.createClass
  getInitialState: ->
    _.extend
      expanded: false
      selectedDisplay: -1
    , @props

  componentWillReceiveProps: (newProps) ->
    newState = _.extend {}, @state, newProps
    @setState newState

  appendDisplay: (e) ->
    e.preventDefault()
    newX = -1
    newY = -1
    for row in [0..displayArray.rows-1]
      for col in [0..displayArray.cols-1]
        continue if newX >= 0
        found = _.find @state.displays, (d) ->
          return false if d.x > col or d.y > row
          return false if d.x + d.width <= col
          return false if d.y + d.height <= row
          true
        if !found
          newX = col
          newY = row
    unless newX >= 0 and newY >= 0
      return
    displays = @state.displays
    displays.push
      x: newX
      y: newY
      width: 1
      height: 1
    @setState
      displays: displays
      selectedDisplay: displays.length - 1

  onChangeDisplay: (displayIndex, prop) ->
    (e) =>
      e.preventDefault()
      displays = @state.displays
      displays[displayIndex][prop] = e.target.value
      @setState
        displays: displays

  selectDisplay: (displayIndex) ->
    (e) =>
      @setState
        selectedDisplay: if @state.selectedDisplay == displayIndex
          -1
        else
          displayIndex

  nudge: (display, direction, displayIndex) ->
    (e) =>
      e.preventDefault()
      switch direction[0]
        when 'top'
          if direction[1] == 'up'
            display.y -= 1
            display.height += 1
          else
            display.y += 1
            display.height -= 1
        when 'bottom'
          if direction[1] == 'up'
            display.height -= 1
          else
            display.height += 1
        when 'left'
          if direction[1] == 'left'
            display.x -= 1
            display.width += 1
          else
            display.x += 1
            display.width -= 1
        when 'right'
          if direction[1] == 'left'
            display.width -= 1
          else
            display.width += 1
      # console.log direction, display
      displays = @state.displays
      displays[displayIndex] = display
      @setState
        displays: displays

  render: ->
    {displays} = @state

    displayWidth = 30
    displayHeight = 6

    drawArrow = (display, direction, displayIndex) =>
      switch direction[0]
        when 'top'
          x = display.x + display.width / 2
          y = display.y
        when 'bottom'
          x = display.x + display.width / 2
          y = display.y + display.height
        when 'left'
          x = display.x
          y = display.y + display.height / 2
        when 'right'
          x = display.x + display.width
          y = display.y + display.height / 2
      rotation = switch direction[1]
        when 'up'
          180
        when 'down'
          0
        when 'left'
          90
        when 'right'
          -90

      DOM.div
        key: direction.join '-'
        style:
          position: 'absolute'
          top: 0
          left: 0
          transformOrigin: '0 0'
          transform: "translate3d(#{x / displayArray.cols * displayWidth}em, #{y / displayArray.rows * displayHeight}em, 0) rotate(#{rotation}deg)"
      ,
        DOM.div
          style:
            position: 'absolute'
            top: '5px'
            left: '-9px'
            width: '18px'
            height: '21px'
        ,
          DOM.a
            href: '#'
            style:
              border: 'none'
            onClick: @nudge display, direction, displayIndex
          ,
            DOM.img
              src: '/images/arrow.png'

    DOM.form
      action: "/configuration/#{@state.id ? 'new'}"
      method: 'post'
    ,
      DOM.input
        name: "configuration[id]"
        type: 'hidden'
        value: @state.id
      DOM.input
        name: "configuration[name]"
        type: 'hidden'
        value: @state.name
      _.flatten _.map displays, (display, displayIndex) ->
        _.map display, (propVal, propKey) ->
          DOM.input
            key: "#{displayIndex}-#{propKey}"
            type: 'hidden'
            name: "configuration[displays][#{displayIndex}][#{propKey}]"
            value: propVal
      DOM.div null,
        DOM.input
          value: @state.name
          placeholder: 'name'
          onChange: (e) =>
            @setState
              name: e.target.value
      DOM.div
        style:
          margin: '1em 0'
          border: 'solid 1px #999'
          backgroundColor: if @state.selectedDisplay >= 0
            'rgba(0, 0, 0, 0.3)'
          else
            'rgba(0, 0, 0, 0.4)'
          borderRadius: '0.7em'
          width: "#{displayWidth}em"
          height: "#{displayHeight}em"
      ,
        DOM.div
          style:
            position: 'absolute'
        ,
          _.map displays, (display, displayIndex) =>
            DOM.div
              key: displayIndex
              style:
                position: 'absolute'
                left: "#{0.1 + display.x / displayArray.cols * displayWidth}em"
                top: "#{0.1 + display.y / displayArray.rows * displayHeight}em"
                width: "#{-0.2 + display.width / displayArray.cols * displayWidth}em"
                height: "#{-0.2 + display.height / displayArray.rows * displayHeight}em"
                # border: 'solid 1px #bbb'
                borderRadius: '0.5em'
                backgroundColor: if @state.selectedDisplay >= 0
                  if @state.selectedDisplay == displayIndex
                    'rgba(155, 200, 255, 0.7)'
                  else
                    'rgba(255, 255, 255, 0.3)'
                else
                  'rgba(100, 255, 100, 0.4)'
              onClick: @selectDisplay displayIndex
            , ' '
          if @state.selectedDisplay >= 0
            display = displays[@state.selectedDisplay]
            _ directions
            .filter (direction) ->
              checkDirection display, direction
            .map (direction) =>
              # console.log 'direction', direction
              drawArrow display, direction, @state.selectedDisplay
            .value()
          else
            null

      if @state.selectedDisplay >= 0
        DOM.p null,
          DOM.input
            style:
              width: "#{displayWidth}em"
            key: "url-#{@state.selectedDisplay}"
            placeholder: 'url'
            value: @state.displays[@state.selectedDisplay].url
            onChange: @onChangeDisplay @state.selectedDisplay, 'url'
      else
        null

      DOM.p null,
        DOM.input
          type: 'button'
          value: 'add display'
          onClick: @appendDisplay

      if @state.expanded
        DOM.div null,
          DOM.h4 null, @state.id
          _.map displays, (display, displayIndex) =>
            DOM.div
              key: displayIndex
            ,
              DOM.p null, 'display ' + displayIndex
              DOM.p null,
                DOM.span null, 'x: '
                DOM.input
                  value: display.x
                  onChange: @onChangeDisplay displayIndex, 'x'
                  placeholder: 'x'
              DOM.p null,
                DOM.span null, 'y: '
                DOM.input
                  value: display.y
                  onChange: @onChangeDisplay displayIndex, 'y'
                  placeholder: 'y'
              DOM.p null,
                DOM.span null, 'w: '
                DOM.input
                  value: display.width
                  onChange: @onChangeDisplay displayIndex, 'width'
                  placeholder: 'width'
              DOM.p null,
                DOM.span null, 'h: '
                DOM.input
                  value: display.height
                  onChange: @onChangeDisplay displayIndex, 'height'
                  placeholder: 'height'
              DOM.p null,
                DOM.span null, 'u: '
                DOM.input
                  value: display.url
                  onChange: @onChangeDisplay displayIndex, 'url'
                  placeholder: 'url'
          DOM.p null,
            DOM.input
              type: 'button'
              onClick: @appendDisplay
              value: 'add display'
      else
        DOM.a
          style:
            display: 'none'
          href: '#'
          onClick: (e) =>
            e.preventDefault()
            @setState
              expanded: true
        , 'expand'
      DOM.p null,
        DOM.input
          type: 'submit'
          value: 'save'
