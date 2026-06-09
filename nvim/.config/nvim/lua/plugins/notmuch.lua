return {
    'yousefakbar/notmuch.nvim',
    config = function()
        -- Configuration goes here
        local opts = {
          notmuch_db_path = "/home/geert/Sync/Mail",
          maildir_sync_cmd = "mbsync -a",
          sync = {
            sync_mode = "background"
          },
          render_html_body = true,  -- requires w3m
        }
        require('notmuch').setup(opts)

        -- Open inbox directly
        vim.keymap.set("n", "<leader>mi", "<CMD>NmSearch tag:inbox<CR>", { desc = "Mail: Inbox" })
        -- Open search prompt
        vim.keymap.set("n", "<leader>ms", function()
            local query = vim.fn.input("Mail search: ")
            if query ~= "" then
                vim.cmd("NmSearch " .. query)
            end
        end, { desc = "Mail: Search" })
    end,
}
