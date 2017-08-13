fs = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'

class Birds

  config: require('./birds-settings').config

  activate: ->
    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    if /light/.test atom.config.get('core.themes').toString()
      atom.config.setDefaults "#{@packageName}", style: 'Light'
    @disposables.add atom.config.observe "#{@packageName}.scheme", => @enableConfigTheme()
    @disposables.add atom.config.observe "#{@packageName}.style", => @enableConfigTheme()
    @disposables.add atom.commands.add 'atom-workspace', "#{@packageName}:select-theme", @createSelectListView

  deactivate: ->
    @disposables.dispose()

  enableConfigTheme: ->
    scheme = atom.config.get "#{@packageName}.scheme"
    style = atom.config.get "#{@packageName}.style"
    @enableTheme scheme, style

  enableTheme: (scheme, style) ->
    # No need to enable the theme if it is already active.
    return if @isActiveTheme scheme, style unless @isPreviewConfirmed
    try
      # Write the requested theme to the `syntax-variables` file.
      fs.writeFileSync @getSyntaxVariablesPath(), @getSyntaxVariablesContent(scheme, style)
      activePackages = atom.packages.getActivePackages()
      if activePackages.length is 0 or @isPreview
        # Reload own stylesheets to apply the requested theme.
        atom.packages.getLoadedPackage("#{@packageName}").reloadStylesheets()
      else
        # Reload the stylesheets of all packages to apply the requested theme.
        activePackage.reloadStylesheets() for activePackage in activePackages
      @activeScheme = scheme
      @activeStyle = style
    catch
      # If unsuccessfull enable the default theme.
      @enableDefaultTheme()

  isActiveTheme: (scheme, style) ->
    scheme is @activeScheme and style is @activeStyle

  getSyntaxVariablesPath: ->
    path.join __dirname, "..", "styles", "syntax-variables.less"

  getSyntaxVariablesContent: (scheme, style) ->
    """
    @birds-scheme: '#{@getNormalizedName scheme}';
    @birds-style: '#{@getNormalizedName style}';

    @import 'schemes/@{birds-scheme}';
    @import 'syntax-variables-@{birds-style}';

    """

  getNormalizedName: (name) ->
    "#{name}"
      .replace ' ', '-'
      .toLowerCase()

  enableDefaultTheme: ->
    scheme = atom.config.getDefault "#{@packageName}.scheme"
    style = atom.config.getDefault "#{@packageName}.style"
    @setThemeConfig scheme, style

  setThemeConfig: (scheme, style) ->
    atom.config.set "#{@packageName}.scheme", scheme
    atom.config.set "#{@packageName}.style", style

  createSelectListView: =>
    BirdsSelectListView = require './birds-select-list-view'
    birdsSelectListView = new BirdsSelectListView @
    birdsSelectListView.attach()

  isConfigTheme: (scheme, style) ->
    configScheme = atom.config.get "#{@packageName}.scheme"
    configStyle = atom.config.get "#{@packageName}.style"
    scheme is configScheme and style is configStyle

module.exports = new Birds
