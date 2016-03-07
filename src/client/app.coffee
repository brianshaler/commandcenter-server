_ = require 'lodash'
React = require 'react'
ReactDOM = require 'react-dom'
request = require 'request'

Configuration = React.createFactory require './configuration'

{DOM} = React

module.exports = React.createClass
  getInitialState: ->
    configurations: []
    newDisplays: []

  componentDidMount: ->
    @refresh()

  save: (configuration) ->
    url = "#{window.location.origin}/configuration/#{configuration.id ? 'new'}.json"
    request.post url,
      form:
        configuration: configuration
      json: true
    , (err, httpWhatever, body) =>
      console.log err if err
      console.log 'got back', body
      @refresh()

  refresh: ->
    return unless @isMounted()
    url = "#{window.location.origin}/configurations.json"
    request url, (err, responseWhatever, body) =>
      if err
        console.log 'error', err
        return
      return unless body
      try
        obj = JSON.parse body
      catch ex
        console.log 'error', ex, body
        return
      @setState obj

  onChangeDisplay: (configIndex, displayIndex, prop) ->
    (e) =>
      e.preventDefault()
      if configIndex?
        configurations = @state.configurations
        configurations[configIndex].displays[displayIndex][prop] = e.target.value
        @setState
          configurations: configurations
      else
        displays = @state.newDisplays
        displays[displayIndex][prop] = e.target.value
        @setState
          newDisplays: displays

  addDisplay: (e) ->
    e.preventDefault()
    @setState
      newDisplays: @state.newDisplays.concat
        x: 1
        y: 1

  appendDisplay: (configIndex) ->
    (e) =>
      e.preventDefault()
      configurations = @state.configurations
      configurations[configIndex].displays.push {}
      @setState
        configurations: configurations

  render: ->
    DOM.div null,
      DOM.h1 null, 'Sup.'
      DOM.h3 null, 'edit'
      _.map @state.configurations, (config, configIndex) =>
        Configuration
          key: configIndex
          id: config.id
          name: config.name
          displays: config.displays

      DOM.h3 null, 'new config'
      Configuration
        key: @state.configurations.length
        id: 'new'
        displays: []
        onSave: (e, id) =>
          @refresh()
