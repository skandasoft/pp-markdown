{CompositeDisposable} = require 'atom'
marked = require 'marked'
cssListView = require './cssListView'
fs = require 'fs'

module.exports =
  subscriptions: null
  config:
    requires:
      title: 'NPM/Require'
      type: 'array'
      default:[]

    types:
      title: 'Markdown File Types'
      type: 'array'
      default: []

    filepaths:
      title: 'Require filepath for markdown themes'
      type: 'string'
      default: './sample-md-filepath.coffee'

    cssURL:
      title: 'Choose CSS URL'
      type: 'string'
      enums:['markdown.css']
      default: 'markdown.css'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @cssList = []
    @subscriptions.add atom.commands.add 'atom-workspace', 'pp-markdown:css': => @selectCSS()
    @filePaths = require requires if requires = atom.config.get('pp-markdown.filepaths')
    for key,val of @filePaths
      atom.config.getSchema('pp-markdown').properties.cssURL.enums.push key
      @cssList.push key

  toggle: ->

  selectCSS: ->
    new cssListView(@cssList)
    # refresh
    if atom.workspace.getActivePaneItem().constructor.name is "HTMLEditor"
      atom.workspace.getActivePaneItem().refresh?()

  compile: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
    marked.setOptions options
      # renderer: new marked.Renderer(),
      # gfm: true,
      # tables: true,
      # breaks: false,
      # pedantic: false,
      # sanitize: true,
      # smartLists: true,
      # smartypants: false
    markedSrc = ''
    if quickPreview or hyperLive or fileName.startsWith('browserplus~')
      markedSrc = src
    else
      markedSrc = fs.readFileSync(fileName,'utf-8').toString()

    text : marked markedSrc

  consumeAddPreview: (@preview)->
    requires =
      pkgName: 'markdown'
      fileTypes: do ->
        types = atom.config.get('pp.markdown-types') or []
        types.concat ['md','markdown'] #filetypes against which this compileTo Option will show

      # names: do ->
      #   names = atom.config.get('pp.markdown-names') or []
      #   names.concat ['CoffeeScript (Literate)'] #filetypes against which this compileTo Option will show
      #
      # scopeNames: do ->
      #   scopes = atom.config.get('pp.coffee-scope') or []
      #   scopes.concat ['source.litcoffee'] #filetypes against which this compileTo Option will show
      html:
        ext: 'html'
        hyperLive: true
        quickPreview: true
        exe: @compile

      browser:
        hyperLive: true
        quickPreview: true
        noPreview: true
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)=>
          unless cssURL = @filePaths[atom.config.get('pp-markdown.cssURL')]
            cssURL = "file:///#{atom.packages.getActivePackage('pp-markdown').path}/resources/markdown.css"
          result = @compile(src,options,data,fileName,quickPreview,hyperLive,editor,view)
          html: atom.packages.getActivePackage('pp')?.mainModule.makeHTML
            html: result.text
            css: [cssURL]

    @ids = @preview requires

  deactivate: ->
    preview deactivate: @ids

  serialize: ->
