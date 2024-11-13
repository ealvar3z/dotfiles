-- load standard vis module, providing parts of the Lua API
require('vis')

function FilterRange(file, range, pos, filter)
    -- Based on: http://martanne.github.io/vis/doc/#Vis:operator_new
    local status, out, err = vis:pipe(file, range, filter)
    if not status then
        vis:info(err)
    else
        file:delete(range)
        file:insert(range.start, out)
    end
    return range.start -- new cursor location
end

function Plug(src, dtype, req_file)
    local domain, username, reponame = src:match("([^/]+)/([^/]+)/([^/]+)$")
    local prefix = (
        os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config'
    ) .. '/vis'
    -- Dots ('.') in domain (or any other segment) will cause require() to fail
    local dest = string.format(
        '%s/%s/%s/%s', prefix, dtype, username, reponame
    )
    local exists = io.open(dest, 'r')

    if not (exists ~= nil and io.close(exists)) then
        vis:message(string.format('Cloning: %s', src))
        os.execute(
            string.format(
                'command git clone --depth 1 %s %s > /dev/null 2>&1',
                src, dest
            )
        )
    end

    if dtype == 'themes' then
        local sym_src = string.format(
            "%s/%s/%s/%s/%s.lua", prefix, dtype, username, reponame, req_file
        )
        local sym_dest = string.format("%s/%s/%s.lua", prefix, dtype, req_file)
        local exists = io.open(sym_dest, 'r')

        if not (exists ~= nil and io.close(exists)) then
            vis:message(string.format('Symlinking: %s', req_file))
            os.execute(string.format(
                'ln -nfs "%s" "%s" > /dev/null 2>&1', sym_src, sym_dest
            ))
        end

        vis.events.subscribe(vis.events.WIN_OPEN, function(win)
            vis:command('set theme ' .. req_file)
        end)
    end

    return require(
        string.format(
            '%s/%s/%s/%s', dtype, username, reponame, req_file
        )
    )
end

my_fzf_args = string.gsub([[
    --bind=$my_fzf_key_bindings \
    --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108 \
    --color info:108,prompt:109,spinner:108,pointer:168,marker:168 \
    --delimiter / --nth -1 \
    --height=70% \
    --inline-info \
    --no-mouse \
    --preview-window=up:70% \
    --preview="(
        bat --style=changes,grid,numbers --color=always {} ||
        highlight -O ansi -l {} ||
        coderay {} ||
        rougify {} ||
        cat {}
    ) 2> /dev/null | head -1000"
]], '%$([%w_]+)', {
    my_fzf_key_bindings=table.concat({
        "alt-j:preview-down",
        "alt-k:preview-up",
        "ctrl-f:preview-page-down",
        "ctrl-b:preview-page-up",
        "?:toggle-preview",
        "alt-w:toggle-preview-wrap",
        "ctrl-z:clear-screen"
    }, ",")
})

plugin_vis_open = Plug(
    'https://github.com/jeebak/vis-fzf-open',
    'plugins',
    'fzf-open'
)
-- Path to the fzf executable (default: "fzf")
plugin_vis_open.fzf_path = (
    "FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g \"\"' fzf"
)
-- Arguments passed to fzf (default: "")
plugin_vis_open.fzf_args = my_fzf_args

plugin_vis_mru = Plug(
    'https://github.com/jeebak/vis-fzf-mru',
    'plugins',
    'fzf-mru'
)
-- Path to the fzf executable (default: "fzf")
plugin_vis_mru.fzfmru_path = "fzf"
-- Arguments passed to fzf (default: "")
plugin_vis_mru.fzfmru_args = my_fzf_args
-- File path to file history (default: "$HOME/.mru")
plugin_vis_mru.fzfmru_filepath = os.getenv("HOME") .. "/.config/vis/mru.txt"
-- The number of most recently used files kept in history (default: 20)
plugin_vis_mru.fzfmru_history = 100
-- Start w/ last file if "vis" was started w/out a file name arg
plugin_vis_mru.fzfmru_start_with_last_file = true

plugin_vis_cursors = Plug(
    'https://github.com/erf/vis-cursors',
    'plugins',
    'cursors'
)
-- File path to cursor positions (default: "$HOME/.cursors")
plugin_vis_cursors.path = os.getenv("HOME") .. "/.config/vis/cursors.txt"

Plug(
    'https://github.com/lutobler/vis-modelines',
    'plugins',
    'vis-modelines'
)

Plug(
    'https://github.com/lutobler/vis-commentary',
    'plugins',
    'vis-commentary'
)

Plug(
    'https://github.com/samlwood/vis-gruvbox',
    'themes',
    'gruvbox'
)

vis:command_register("PlugUpdate", function()
    local prefix = (
        os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config'
    ) .. '/vis'
    local command = [[bash -c '
        while read -r line; do
            command git -C "$line" pull
        done < <(
            find %s/plugins %s/themes -type d -name .git | sed "s/\.git$//"
        ) > /dev/null 2>&1'
    ]]
    vis:info('Updating plugins and themes')
    os.execute(string.format(command, prefix, prefix))
    vis:feedkeys("<vis-redraw>")
end, "Update plugins and themes")

vis:command_register("W", function()
    -- Based on: https://gist.github.com/abaez/191397143c72ab7622e1812f6d887336
    local file = vis.win.file
    vis:command((", > sudo tee %s"):format(file.name))

    vis.events.emit(vis.events.FILE_SAVE_PRE, function(...)
        return true
    end)
    vis.events.emit(vis.events.FILE_SAVE_POST, function(...)
        file.modified = false
    end)
end, "Write file with sudo tee")

vis:operator_new("<Space>s", function(file, range, pos)
    return FilterRange(file, range, pos, "sort")
end, "Formating operator, filter range through sort(1)")

vis.events.subscribe(vis.events.INIT, function()
    -- vis:map(vis.modes.NORMAL, ';', ':')
    vis:map(vis.modes.INSERT, 'jk', '<Escape>h')
    vis:command('set escdelay 200')
    -- Your global configuration options
    vis:command('map! normal ; :')
    vis:command('map! normal <C-p>    :fzf<Enter>')
    vis:command('map! normal <Space>h :fzfmru<Enter>')
    vis:command('map! normal <Tab>    :fzfmru-last-used<Enter>')

    vis:command('map! normal j gj')
    vis:command('map! normal k gk')

    vis:command('map! normal <Space>q :q<Enter>')
    vis:command('map! normal <Space>w :w<Enter>')
    vis:command('map! normal <Space>s :split<Enter>')
    vis:command('map! normal <Space>v :vsplit<Enter>')

    -- m Save currently active selections to register
    -- M Restore selections from register
    vis:command('map! normal <Space>M <vis-selections-restore>')
    vis:command('map! normal M        <vis-motion-window-line-middle>')

    vis:command('map! visual <Space>y "+y')
    vis:command('map! visual <Space>d "+d')
    vis:command('map! visual <Space>p "+p')
    vis:command('map! visual <Space>P "+P')
    vis:command('map! normal <Space>p "+p')
    vis:command('map! normal <Space>P "+P')

    vis:command('map! normal ;ws :x/[\\ \\t]+$/\\ c//<Enter>')

    -- TODO: Figure out how to toggle instead of [s]how and [h]ide
    vis:command(
        string.format(
            'map! normal ;ls %s%s%s%s',
            ':set\\ show-eof\\ on<Enter>',
            ':set\\ show-newlines\\ on<Enter>',
            ':set\\ show-spaces\\ on<Enter>',
            ':set\\ show-tabs\\ on<Enter>'
        )
    )
    vis:command(
        string.format(
            'map! normal ;lh %s%s%s%s',
            ':set\\ show-eof\\ off<Enter>',
            ':set\\ show-newlines\\ off<Enter>',
            ':set\\ show-spaces\\ off<Enter>',
            ':set\\ show-tabs\\ off<Enter>'
        )
    )
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    -- Your per window configuration options e.g.
    vis:command('set autoindent on')
    vis:command('set colorcolumn 80')
    vis:command('set cursorline')
    vis:command('set expandtab on')
    vis:command('set number')
    vis:command('set relativenumbers')
    vis:command('set show-spaces off')
    vis:command('set show-tabs on')
    vis:command('set tabwidth 4')
end)

