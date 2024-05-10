-- luasnip.lua
local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('gdscript', {

  s('connect', {
    t 'connect',
    t '(',
    i(1),
    t ',',
    i(2),
    t ')',
  }),
  s('signal', {
    t 'signal ',
    i(1),
    t '(',
    i(2),
    t ')',
  }),
  s('@export', {
    t '@export var ',
    i(1),
    t ' : ',
    i(2),
  }),
  s('@onready', {
    t '@onready var ',
    i(1),
    t ' : ',
    i(2),
    t ' = ',
    i(3),
  }),
  s('process', {
    t 'func _process(delta : float):',
    t { '', '	' },
    i(1),
  }),
  s('physics_process', {
    t 'func _physics_process(delta : float):',
    t { '', '	' },
    i(1),
  }),
  s('ready', {
    t 'func _ready():',
    t { '', '	' },
    i(1),
  }),
  s('func', {
    t 'func ',
    i(1),
    t '(',
    i(2),
    t '):',
    t { '', '	' },
    i(3),
  }),
})
ls.add_snippets('cs', {
  s('export', {
    t '[Export]',
    t { '', 'private ' },
    i(1),
    t ';',
  }),
  s('private', {
    t 'private ',
    i(1),
    t ';',
  }),
  s('public', {
    t 'public ',
    i(1),
    t ';',
  }),
  s('protected', {
    t 'protected',
    i(1),
    t ';',
  }),
  s('function', {
    i(1),
    t '(',
    i(2),
    t ')',
    t { '', '{' },
    t { '', '	' },
    i(3),
    t { '', '}' },
  }),
  s('signal', {
    t '[Signal]',
    t { '', 'public delegate ' },
    i(1),
    t 'EventHandler(',
    i(3),
    t ');',
  }),
  s('print', {
    t 'GD.Print("',
    i(1),
    t '");',
  }),
  s('str', {
    t 'GD.VarToStr(',
    i(1),
    t ')',
  }),
})
ls.add_snippets('txt', {
  s('flaschcard', {
    t '#',
    i(1),
    t { '', '' },
    i(2),
  }),
  s('multiple-choice', {
    t '#',
    i(1),
    t { '', '- ' },
    i(2),
    t { '', '- ' },
    i(3),
    t { '', '- ' },
    i(4),
    t { '', '- ' },
    i(5),
  }),
  s('multi-select', {
    t '#',
    i(1),
    t { '', '[ ] ' },
    i(2),
    t { '', '[ ] ' },
    i(3),
    t { '', '[ ] ' },
    i(4),
    t { '', '[ ] ' },
    i(5),
  }),
})

return {}
