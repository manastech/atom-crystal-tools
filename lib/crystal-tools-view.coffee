module.exports =
class CrystalToolsView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('crystal-tools')

    # Create message element
    @message = document.createElement('div')
    @message.textContent = "The CrystalTools package is Alive! It's ALIVE!"
    @message.classList.add('message')
    @element.appendChild(@message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  showError: (text) ->
    @p(text)

  showContext: (response) ->
    @p(response.message)
    if response.contexts && response.contexts.length > 0
      table = document.createElement('table')
      table.classList.add('crystal-tools-context-table')
      @element.appendChild(table)

      tr = document.createElement('tr')
      tr.classList.add('crystal-tools-context-table-header')
      table.appendChild(tr)

      th = document.createElement('th')
      th.textContent = 'Expr'
      tr.appendChild(th)

      th = document.createElement('th')
      th.textContent = 'Type'
      th.setAttribute("colspan", response.contexts.length)
      tr.appendChild(th)

      for key of response.contexts[0]
        tr = document.createElement('tr')
        table.appendChild(tr)

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
            td.setAttribute("colspan", parseInt(td.getAttribute("colspan")+1))

  p: (text) ->
    message = document.createElement('p')
    message.textContent = text
    @element.appendChild(message)

  code: (text) ->
    res = document.createElement('code')
    res.textContent = text
    res
