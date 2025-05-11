# ohmyksh needs to know where it lives, so we tell it via this env var:
OHMYKSH_DIR=${HOME}/src/ohmyksh

# Now we can load everything up!
. ${OHMYKSH_DIR}/ohmy.ksh

# All the paths we use (in order!)
set -A my_paths -- \
        ~/bin \
        ~/go/bin

paths "${my_paths[@]}"

# Load our various extensions
load_extension k
load_extension nocolor
load_extension openbsd

# Load handy completions for various things
load_completion ssh
pgrep -q cmd && load_completion vmd
load_completion rc
load_completion git


alias c='clear'
alias x='exit'
alias la='ls -a'
alias pi='pkg_info -aQ'
alias ps='doas pkg_add'


# the q prompt auto-loads the git-prompt extension
set_prompt 9
