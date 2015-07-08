fs   = require "fs"
# atom = require "atom"
_    = require "lodash"

trace = (x) ->
  console.log x
  return x

selector             = '.source.elm'
inclusionPriority    = 1
excludeLowerPriority = false

activePath = ->
  trace atom.workspace
  textEditor = atom.workspace.getActiveTextEditor()
  if !textEditor or !textEditor.getPath()
    ### default to building the first one if no editor is active ###
    if 0 == atom.project.getPaths().length
      return false
    atom.project.getPaths()[0]
  else
    # otherwise, build the one in the root of the active editor ###
    _.find atom.project.getPaths(), (path) ->
      realpath = fs.realpathSync(path)
      textEditor.getPath().substr(0, realpath.length) == realpath

getSuggestions = ({editor, bufferPosition}) ->
  prefix = getPrefix {editor, bufferPosition}

  trace activePath()

  if _.startsWith prefix, "import " and (_.endsWith prefix, "(" or _.endsWith prefix, ",")
    new Promise (resolve) ->
      resolve([
        text: 'elmpackage'
        description: 'its just some text'
        rightLabel: ": Text"
      ])
  else new Promise (resolve) -> resolve []

getPrefix = ({editor, bufferPosition}) ->
  # Whatever your prefix regex might be
  regex = /[\w0-9_-]+$/
  # Get the text for the line up to the triggered buffer position
  line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
  # Match the regex to the line, and return the match
  line.match(regex)?[0] or ''

module.exports = AutocompleteElm =
  activate    : (state) -> console.log "wowzers!"
  getProvider : ->
    { selector
    , inclusionPriority
    , excludeLowerPriority
    , getSuggestions }
