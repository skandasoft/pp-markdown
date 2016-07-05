{$,SelectListView} = require 'atom-space-pen-views'


class CssListView extends SelectListView

  initialize: (items)->
    super
    @addClass 'overlay from-top'
    @setItems items
    atom.workspace.addModalPanel item:@
    @focusFilterEditor()
    @storeFocusedElement()


  viewForItem: (item)->
      li = $("<li><span class='pp-markdown-css'>#{item}</span></li>")
      radio = $("<span class='pp-default mega-octicon octicon-star'></span>")

      fn = (e)=>
        $(`this `).closest('ol').find('span').removeClass('on')
        $(`this `).addClass('on')
        atom.config.set('pp-markdown.cssURL',item)
        atom.workspace.getActivePaneItem().refresh?()
        e.stopPropagation()
        return false
      radio.on 'mouseover',fn
      li.append radio
      return li

  confirmed: (item)->
    atom.config.set('pp-markdown.cssURL',item)
    atom.workspace.getActivePaneItem().refresh?()
    @cancel()

  cancelled: ->
    @parent().remove()
module.exports = CssListView
