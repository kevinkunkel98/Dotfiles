source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting — disable fastfetch
function fish_greeting
end

# Age of Empires 3 DE - Savegame Ordner
alias aoe3='cd ~/.local/share/Steam/steamapps/compatdata/933110/pfx/drive_c/users/steamuser/Games/Age\ of\ Empires\ 3\ DE/76561199735526387/Savegame'

# opencode
fish_add_path /home/kevin/.opencode/bin
export PATH="$HOME/.local/bin:$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
