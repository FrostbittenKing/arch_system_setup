# Path to your oh-my-zsh configuration.
ZSH=/usr/share/oh-my-zsh
ZSH_CUSTOM=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="itachi"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias xz='xz -T0'
alias nautilus='nautilus --no-desktop'
alias arduino='_JAVA_AWT_WM_NONREPARENTING= arduino'
# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

#RSENSE
RSENSE_HOME=/opt/rsense-0.3

#lessfiler
LESSOPEN="|~/.lessfilter %s"

# Customize to your needs...
PATH=$HOME/.rvm/bin:$PATH # Add RVM to PATH for scripting

export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/android-ndk:/opt/android-sdk/tools:/opt/cuda-toolkit/bin:/opt/java6/bin:/opt/java6/db/bin:/opt/java6/jre/bin:/usr/bin/core_perl:/home/itachi/bin:/opt/java6/bin:/home/itachi/.gem/ruby/2.3.0/bin" LESSOPEN
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
TERMINFO=~/.terminfo
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
eval $(dircolors -b)

alias grep="/usr/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS
