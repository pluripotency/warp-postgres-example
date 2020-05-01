import m from 'mithril'

delay_fadeout = (response)->
  todo.response = response
  todo.get_all()
  setTimeout ()->
    todo.response = ''
  , 2000

todo =
  newTodoName: ''
  setNewTodoName: (value)->
    todo.newTodoName = value
  post_new_todo: (e)->
    e.preventDefault()
    m.request
      method: 'post'
      url: '/todo'
      body: name: todo.newTodoName
    .then delay_fadeout

  data: []
  get_all: ()->
    m.request
      method: 'get'
      url: '/todo'
    .then (data)->
      todo.data = data
  delete: (id)->
    m.request
      method: 'delete'
      url: "/todo/#{id}"
    .then delay_fadeout
  toggle_checked: (item)->
    m.request
      method: 'put'
      url: "/todo/#{item.id}"
      body:
        name: item.name
        checked: !item.checked
    .then delay_fadeout

Home =
  view: ()->
    todo.get_all()
    m '.container', [
      m '.card', [
        m '.card-header', [
          m 'a',
            href: 'https://blog.logrocket.com/create-an-async-crud-web-service-in-rust-with-warp/'
          , 'warp-postgres-example'
        ]
        m '.card-body', [
          m '.row', [
            m '.col', [
              m 'form.form-inline', [
                m '.form-group', [
                  m 'label.mr-2', 'New Todo '
                  m 'input.form-control[type=text]',
                    oninput: (e)-> todo.setNewTodoName(e.target.value)
                    value: todo.newTodoName
                ]
                m 'button.btn.btn-light',
                  type: 'submit'
                  onclick: todo.post_new_todo
                , 'Submit'
              ]
            ]
            m '.col', [
              m 'label.btn.btn-light',
                onclick: todo.get_all
              , 'Reload'
            ]
          ]
          m 'table.table.table-condensed', [
            m 'thead', [
              m 'tr', [ 'id', 'name', 'checked'].map (h)-> m 'th', h
            ]
            m 'tbody', todo.data.map (item)->
              m 'tr', [
                m 'td', [
                  item.id
                  m 'span.badge.badge-warning.ml-2',
                    onclick: ()->
                      todo.delete(item.id)
                  , "Delete"
                ]
                m 'td', item.name
                m 'td', [
                  m 'span.badge',
                    class: if item.checked then 'badge-secondary' else 'badge-primary'
                    onclick: ()->
                      todo.toggle_checked(item)
                  , if item.checked then 'done' else 'Do'
                ]
              ]
          ]
          if todo.response
            m 'label.form-control', JSON.stringify todo.response
        ]
      ]
    ]

m.mount document.getElementById('contents'), Home
