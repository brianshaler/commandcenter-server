fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

_ = require 'lodash'
Promise = require 'when'
mkdirp = require 'mkdirp'

cacheDir = path.resolve __dirname, '../cache'
mkdirp cacheDir
dataFile = path.resolve cacheDir, 'data.json'

module.exports = Configurations =
  get: ->
    defaultData =
      configurations: []
    Promise.promise (resolve, reject) ->
      fs.exists dataFile, (exists) ->
        return resolve defaultData if !exists
        fs.readFile dataFile, (err, contents) ->
          return reject err if err
          obj = {}
          try
            obj = JSON.parse contents
          catch ex
            'nothing'

          data = _.merge {}, defaultData, obj

          resolve data

  set: (configuration) ->
    if !configuration.id
      hash = crypto.createHash 'md5'
      hash.update String Date.now()
      id = hash
        .digest 'hex'
        .substring 0, 16
      configuration.id = id
      configuration.createdAt = Date.now()
    displays = _.map configuration.displays, (display) ->
      props =
        x: 0
        y: 0
        width: 1
        height: 1
      for prop in Object.keys(props)
        val = parseFloat display[prop]
        val = props[prop] if !val? or isNaN val
        display[prop] = val
      display
    configuration.displays = displays

    Configurations.get()
    .then (data) ->
      {configurations} = data
      # add or update
      newConfigs = _.filter configurations, (c) ->
        # console.log 'compare ids', c, configuration.id
        c.id != configuration.id
      # console.log 'configs', newConfigs
      # newConfigs.push configuration
      _.extend {}, data,
        configurations: _.sortBy newConfigs.concat(configuration), 'createdAt'
    .then Configurations.save
    .then -> configuration

  delete: (id) ->
    Configurations.get()
    .then (data) ->
      {configurations} = data
      newConfigs = _.filter configurations, (c) ->
        c.id != id
      _.extend {}, data,
        configurations: newConfigs
    .then Configurations.save

  save: (data) ->
    Promise.promise (resolve, reject) ->
      contents = JSON.stringify data, null, 2
      fs.writeFile dataFile, contents, (err) ->
        return reject err if err
        resolve data
