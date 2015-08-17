{View} = require 'space-pen'

module.exports =
  class ContextResultView extends View

    load: (response) ->
      @message.text(response.message)
      if response.status != "ok"
        @table.remove()
        return

      @typeHeader.attr("colspan", response.contexts.length)

      for key of response.contexts[0]
        tr = document.createElement('tr')
        @table.append(tr)

        th = document.createElement('th')
        th.appendChild(@code(key))
        tr.appendChild(th)

        last_type = null
        for context in response.contexts
          if last_type != context[key]
            td = document.createElement('td')
            td.setAttribute("colspan", 1)
            last_type = context[key]
            td.appendChild(@code(last_type))
            tr.appendChild(td)
          else
            td.setAttribute("colspan", parseInt(td.getAttribute("colspan"))+1)

    code: (text) ->
      res = document.createElement('code')
      res.textContent = text
      res

    @content: ->
      @div =>
        @span outlet: "message"
        @table outlet: "table", class: "crystal-tools-context-table", =>
          @tr class: "crystal-tools-context-table-header", =>
            @th "Expr"
            @th outlet: "typeHeader", "Types"
