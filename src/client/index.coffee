_ = require 'lodash'
React = require 'react'
ReactDOM = require 'react-dom'

App = React.createFactory require './app'

{DOM} = React

element = document.getElementById 'main'

app = new App
  stuff: 'things'

ReactDOM.render app, element
