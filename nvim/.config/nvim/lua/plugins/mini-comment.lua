return {
  'nvim-mini/mini.comment',
  version = false,
  config = function()
    local minicomment = require("mini.comment")
    minicomment.setup({
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = 'gc',

        -- Toggle comment on current line
        comment_line = '<C-/>',

        -- Toggle comment on visual selection
        comment_visual = '<C-/>',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        -- Works also in Visual mode if mapping differs from `comment_visual`
        textobject = 'gc',
      },
    })
  end,
}
