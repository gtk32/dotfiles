-- Floating cheatsheet with the most important keybindings.
-- Open with <leader>? (normal mode), close with q or <Esc>.
-- Content is curated on purpose: only the bindings worth remembering.

local M = {}

local sections = {
  {
    "CUSTOM / PLUGINS  (normal mode)",
    {
      { "<leader>?",      "open/close this cheatsheet" },
      { "<leader>ff",     "find files (mini.pick)" },
      { "<leader>fb",     "switch buffers (mini.pick)" },
      { "<leader>fg",     "grep live in files (mini.pick)" },
      { "<leader>fh",     "search help docs (mini.pick)" },
      { "<leader>cd",     "open Oil file manager" },
      { "<leader>k",      "diagnostics -> location list" },
      { "[d  ]d",         "previous / next diagnostic" },
      { "<C-Tab>",        "next buffer (bufferline)" },
      { "<C-q>",          "close (delete) current buffer" },
      { "<C-PageUp/Down>", "move to split above / below" },
      { "D  C",           "delete / change to EOL, NO yank" },
      { "<C-c>",          "(insert mode) leave insert mode" },
    },
  },
  {
    "MOTIONS",
    {
      { "h j k l",        "left / down / up / right" },
      { "w  W",           "next word / WORD (whitespace-separated)" },
      { "b  B",           "back word / WORD" },
      { "e  E",           "end of word / WORD" },
      { "0  ^  $",        "line start / first non-blank / line end" },
      { "gg  G  {N}gg",   "file top / file bottom / goto line N" },
      { "{  }",           "previous / next paragraph (blank line)" },
      { "%",              "jump to matching bracket ()[]{}" },
      { "f{c}  t{c}",     "jump to / just before next char {c}" },
      { "F{c}  T{c}",     "same, but backwards" },
      { ";  ,",           "repeat last f/t (next / previous)" },
      { "*  #",           "search word under cursor (fwd / back)" },
      { "/  ?",           "search forward / backward; n/N = next/prev" },
      { "gd",             "go to definition (LSP)" },
      { "<C-o>  <C-i>",   "jump back / forward (jumplist)" },
      { "mx  'x",         "set mark x / jump to mark x" },
      { "''",             "jump back to position before last jump" },
    },
  },
  {
    "YANK (copy)  — y + motion; paste with p (after) / P (before)",
    {
      { "yy",             "yank whole line" },
      { "yw",             "yank word incl. trailing space (to next word)" },
      { "yl  yh",         "yank character right / left" },
      { "y0  y$",         "yank to line start / line end" },
      { "yiw",            "yank inner word (word under cursor, no spaces)" },
      { "yaw",            "yank a word (word + one surrounding space)" },
      { "yi(  ya(",       "yank inside / around ( )  — also [ { \" '" },
      { "yit  yat",       "yank inside / around HTML tag" },
      { "yG  ygg",        "yank to file end / file top" },
      { "\"+y",           "yank to system clipboard" },
      { "\"0p",           "paste last yanked text (survives deletes!)" },
    },
  },
  {
    "DELETE / CHANGE  — d = delete, c = change (+ motion)",
    {
      { "dd  dw  d$",     "delete line / word / to line end" },
      { "cc  cw  C  D",   "change line / word / to EOL / delete to EOL" },
      { "diw  daw",       "delete inner word / a word (+ spaces)" },
      { "di(  da(",       "delete inside / around brackets" },
      { "di\"  da\"",     "delete inside / around quotes" },
      { "dap  dip",       "delete a / inner paragraph" },
      { "x  X",           "delete char under / before cursor" },
      { "s  S",           "change char / line (delete + insert)" },
      { "r{c}",           "replace single char with {c}" },
      { "J",              "join next line onto current" },
      { "~",              "toggle case of char, move right" },
      { ">>  <<",         "indent / dedent line (visual: > / <)" },
      { ".",              "repeat last change" },
    },
  },
  {
    "REGISTERS / PASTE",
    {
      { "p  P",           "paste after / before cursor" },
      { "\"ayy",          "yank line into register a" },
      { "\"ap",           "paste from register a" },
      { ":reg",           "show all registers" },
      { "\"+y  \"+p",     "clipboard yank / paste" },
    },
  },
  {
    "SCROLL / MARKS / UNDO",
    {
      { "<C-d>  <C-u>",   "half page down / up" },
      { "<C-f>  <C-b>",   "full page down / up" },
      { "zz  zt  zb",     "center / top / bottom current line" },
      { "u",              "undo" },
      { "<C-r>",          "redo" },
    },
  },
  {
    "SAVE / QUIT",
    {
      { "ZZ",             "write + quit" },
      { "ZQ",             "quit without writing" },
      { ":w  :q  :wq",    "write / quit / write+quit" },
    },
  },
}

-- Build the display lines once.
local lines = {}
for _, section in ipairs(sections) do
  lines[#lines + 1] = " " .. section[1]
  lines[#lines + 1] = " " .. string.rep("-", 70)
  for _, item in ipairs(section[2]) do
    local keys, desc = item[1], item[2]
    lines[#lines + 1] = string.format("  %-16s %s", keys, desc)
  end
  lines[#lines + 1] = ""
end

local win = nil

local function close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

function M.open()
  -- Toggle: pressing <leader>? again closes the cheatsheet.
  if win and vim.api.nvim_win_is_valid(win) then
    close()
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(l))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)
  local row = math.max(0, math.floor((vim.o.lines - height) / 2))
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " keybindings ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
end

return M