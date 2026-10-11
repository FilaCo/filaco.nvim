-- [[ Highlight TODO-like keywords and hex colors ]]
--
-- mini.hipatterns comes with mini.nvim (installed by `kickstart.plugins.mini`), so this
-- replaces folke/todo-comments.nvim without downloading anything. todo-comments also
-- needed plenary.nvim, which nothing else in this config uses any more.
--  See `:help mini.hipatterns` and `:help MiniHipatterns-examples`

-- Keywords per highlight group, the same keywords todo-comments highlights by default.
-- The `MiniHipatterns*` groups are styled by the colorscheme (mini.hues) or, without
-- one, by mini.hipatterns itself. `:help MiniHipatterns-hl-groups`
local keywords = {
  MiniHipatternsFixme = { 'FIX', 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
  MiniHipatternsHack = { 'HACK', 'WARN', 'WARNING', 'XXX' },
  MiniHipatternsTodo = { 'TODO', 'PERF', 'OPTIM', 'OPTIMIZE', 'PERFORMANCE' },
  MiniHipatternsNote = { 'NOTE', 'INFO', 'TEST', 'TESTING', 'PASSED', 'FAILED' },
}

-- One highlighter per group. `pattern` is a Lua pattern (`:help lua-pattern`), and may be
-- an array of patterns that all get the same group:
--  - `%f[%w]` is a "frontier": the keyword must start a word, so `MYTODO` does not match
--  - the two empty captures `()` mark the part that gets highlighted: only the keyword,
--    not the colon after it
--  - `%s*:` requires a colon, like todo-comments did (`TODO: text`), so plain words such as
--    `vim.log.levels.INFO` in code stay unhighlighted
local hipatterns = require 'mini.hipatterns'
local highlighters = {}
for group, words in pairs(keywords) do
  local patterns = {}
  for _, word in ipairs(words) do
    table.insert(patterns, '%f[%w]()' .. word .. '()%s*:')
  end
  highlighters[group] = { pattern = patterns, group = group }
end

-- Paint `#rrggbb` colors (not the short `#rgb`) with their own color as background.
--  See `:help MiniHipatterns.gen_highlighter.hex_color()`
highlighters.hex_color = hipatterns.gen_highlighter.hex_color()

-- `setup()` enables highlighting in every normal buffer (`:help 'buftype'`).
hipatterns.setup { highlighters = highlighters }

-- [[ Search the TODOs of the project ]]
--
-- mini.hipatterns only highlights; the project-wide search (todo-comments' `:TodoQuickFix`)
-- is a grep with mini.pick (`kickstart.plugins.pick`). The pattern is a ripgrep regex
-- (`\b` = word boundary), built from the same keywords: `\b(FIX|FIXME|...)\s*:`.
-- In the picker, <C-x> marks results and <M-CR> sends the marked ones to the quickfix list.
-- (`:Pick hipatterns` from mini.extra lists the matches too, but only in loaded buffers.)
local all_words = {}
for _, words in pairs(keywords) do
  vim.list_extend(all_words, words)
end
table.sort(all_words) -- `pairs()` has no fixed order; sorting keeps the regex stable
local todo_regex = '\\b(' .. table.concat(all_words, '|') .. ')\\s*:'

vim.keymap.set('n', '<leader>st', function() MiniPick.builtin.grep { pattern = todo_regex } end, { desc = '[S]earch [T]odos' })

-- vim: ts=2 sts=2 sw=2 et
