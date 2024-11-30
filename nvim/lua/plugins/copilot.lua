return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufEnter",
    config = function()
        require("copilot").setup({
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<M-;>",
                    accept_line = "<M-L>",
                    accept_word = "<M-l>",
                },
            },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                yaml = true,
                help = true,
                ["grug-far"] = false,
            },
        })
    end,
}
