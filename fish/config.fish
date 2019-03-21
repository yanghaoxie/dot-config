#+TITLE: Fish Shell Configuration
#+AUTHOR: Meiyo Peng


# ==============================
# Fish Shell Theme
# ==============================

if status is-interactive
    set -g theme_color_scheme dark
    set -g theme_date_format "+%H:%M:%S"
    set -g theme_powerline_fonts no
end

# Disable fish greeting message
function fish_greeting
end


# ==============================
# Environment Variables
# ==============================

# XDG
if status is-login || status is-interactive
    test "$XDG_CONFIG_HOME" = "" && set -gx XDG_CONFIG_HOME $HOME/.config
    test "$XDG_DATA_HOME" = "" && set -gx XDG_DATA_HOME $HOME/.local/share
    test "$XDG_CACHE_HOME" = "" && set -gx XDG_CACHE_HOME $HOME/.cache
end

# Path
if status is-login || status is-interactive
    if not set -q fish_user_paths
        set -U fish_user_paths
    end

    function add_path --description "add directory to PATH variable"
        # trim trailing slash
        set --local dir (string replace -r '(.+)/$' '$1' $argv[1])
        if ! contains $dir $fish_user_paths && test -d $dir
            set fish_user_paths $dir $fish_user_paths
        end
    end

    function remove_path  --description "remove directory from PATH variable"
        set --local dir $argv[1]
        if set --local index (contains -i $dir $PATH); \
            or set --local index (contains -i "$dir/" $PATH)
            set --erase --universal fish_user_paths[$index]
        end
    end

    add_path $HOME/.local/bin
end

# CDPATH
if status is-login || status is-interactive
    set -gx CDPATH . "$HOME/"
end

# Editor
if status is-login || status is-interactive
    if command -sq "emacsclient"
        set -gx EDITOR "emacsclient -t"
        set -gx VISUAL "emacsclient"
    else if command -sq "zile"
        set -gx EDITOR "zile"
        set -gx VISUAL "zile"
    end

    set -gx SUDO_EDITOR $EDITOR
end

# Guile
if status is-login || status is-interactive
    set -gx GUILE_HISTORY "$XDG_DATA_HOME/guile/history"
    set -gx GUILE_WARN_DEPRECATED detailed
end

# Guix
if status is-login || status is-interactive
    set -gx MY_PROFILE "$HOME/.guix-profile"

    # Guix on foreign distros.
    if test -d /var/guix && ! test -L /run/current-system
        # Environment
        set -gx ROOT_PROFILE "/var/guix/profiles/per-user/root/guix-profile"
        set -gx GUIX_LOCPATH "$ROOT_PROFILE/lib/locale"
        set -gx SSL_CERT_DIR "$ROOT_PROFILE/etc/ssl/certs"
        set -gx SSL_CERT_FILE "$ROOT_PROFILE/etc/ssl/certs/ca-certificates.crt"

        # XDG
        test "$XDG_CONFIG_DIRS" = "" && set -gx XDG_CONFIG_DIRS "/etc/xdg"
        test "$XDG_DATA_DIRS" = "" && set -gx XDG_DATA_DIRS "/usr/local/share:/usr/share"
        set -gx XDG_CONFIG_DIRS "$MY_PROFILE/etc/xdg:$XDG_CONFIG_DIRS"
        set -gx XDG_DATA_DIRS "$MY_PROFILE/share:$XDG_DATA_DIRS"

        # Source my etc/profile
        set -gx GUIX_PROFILE $MY_PROFILE
        fenv source $MY_PROFILE/etc/profile
        set -e GUIX_PROFILE

        # $PATH
        add_path $MY_PROFILE/sbin
        add_path $MY_PROFILE/bin
        add_path $XDG_CONFIG_HOME/guix/current/bin
    end
end


# ==============================
# Aliases
# ==============================

# Editor
if status is-interactive
    alias e=$EDITOR
    alias ec=emacsclient
    alias emacsq="emacs -q"
    alias se="sudo -e"
end

if status is-interactive
    alias df "command df -h"
    alias du "command du -h"
    alias open "command xdg-open"
    alias py "command ptipython"
    alias rsync 'command rsync -hrtP --filter ". $XDG_CONFIG_HOME/rsync/filter"'

    # One-line utilities
    alias gpg-update-tty "gpg-connect-agent updatestartuptty /bye"
    alias ssh-socks "ssh -o ProxyCommand='ncat --proxy-type socks5 --proxy localhost:1080 %h %p'"
end


# ==============================
# Applications
# ==============================

if status is-login
    # SSH
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh

    # Python
    set -gx PYTHONSTARTUP $XDG_CONFIG_HOME/python/startup.py

    # Go language
    set -gx GOPATH $HOME/Projects/go
    add_path $GOPATH/bin

    # Jupyter
    set -gx JUPYTER_CONFIG_DIR $XDG_CONFIG_HOME/jupyter

    # disable less history
    set -gx LESSHISTFILE "-"
end

# Input method
if status is-login
    set -gx GTK_IM_MODULE "ibus"
    set -gx QT_IM_MODULE "ibus"
    set -gx XMODIFIERS "@im=ibus"

    # Guix
    if test -L /run/current-system
        set -gx GUIX_GTK2_IM_MODULE_FILE /run/current-system/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache
        set -gx GUIX_GTK3_IM_MODULE_FILE /run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache
    end
end


# ==============================
# Local Configurations
# ==============================

if test -f "$XDG_CONFIG_HOME/fish/local.fish"
    source "$XDG_CONFIG_HOME/fish/local.fish" >/dev/null 2>&1
end
