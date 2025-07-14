# Make sure the atuin config directory exists
mkdir ~/.config/atuin

# Set up Atuin, including the default Ctrl+R keybinding.
# This generates the init script into ~/.config/atuin/init.nu
atuin init nu | save --force ~/.config/atuin/init.nu

# Source the newly generated script
source ~/.config/atuin/init.nu
