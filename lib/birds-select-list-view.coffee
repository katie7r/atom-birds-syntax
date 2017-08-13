{SelectListView} = require 'atom-space-pen-views'

class BirdsSelectListView extends SelectListView

  initialize: (@birds) ->
    super
    @list.addClass 'mark-active'
    @setItems @getThemes()

  viewForItem: (theme) ->
    element = document.createElement 'li'
    if @birds.isConfigTheme theme.scheme, theme.style
      element.classList.add 'active'
    element.textContent = theme.name
    element

  getFilterKey: ->
    'name'

  selectItemView: (view) ->
    super
    theme = @getSelectedItem()
    @birds.isPreview = true
    @birds.enableTheme theme.scheme, theme.style if @attached

  confirmed: (theme) ->
    @confirming = true
    @birds.isPreview = false
    @birds.isPreviewConfirmed = true
    @birds.setThemeConfig theme.scheme, theme.style
    @cancel()
    @confirming = false

  cancel: ->
    super
    @birds.enableConfigTheme() unless @confirming
    @birds.isPreview = false
    @birds.isPreviewConfirmed = false

  cancelled: ->
    @panel?.destroy()

  attach: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @selectItemView @list.find 'li:last'
    @selectItemView @list.find '.active'
    @focusFilterEditor()
    @attached = true

  getThemes: ->
    schemes = atom.config.getSchema("#{@birds.packageName}.scheme").enum
    if atom.config.get "#{@birds.packageName}.matchUserInterfaceTheme"
      styles = [atom.config.defaultSettings["#{@birds.packageName}"].style]
    else
      styles = atom.config.getSchema("#{@birds.packageName}.style").enum
    themes = []
    schemes.forEach (scheme) -> styles.forEach (style) ->
      themes.push scheme: scheme, style: style, name: "#{scheme} (#{style})"
    themes

module.exports = BirdsSelectListView
