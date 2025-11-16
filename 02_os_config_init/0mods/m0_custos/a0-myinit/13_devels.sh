#---
[ X != X$(command -v clang-format) ] && alias ffc='clang-format -i --style=file'
#---
# [ X != X$(command -v tsize.sh) ] && tsize.sh &>/dev/null
#---
[ X != X$(command -v shfmt) ] && alias ffs='shfmt -s -ln bash -i 2 -w'
#---
[ X != X$(command -v bat) ] && alias cat='bat -pp'
#---
# if [ X != X$(command -v pnpm) ]; then
alias pn='pnpm'
alias pni='pnpm install -D'
alias pnb='pnpm build'
alias pnr='pnpm remove'
# fi
#---
# if [ X != X$(command -v yarn) ]; then
alias yadd='yarn add -D'
alias ydel='yarn remove'
alias ygadd='yarn global add'
alias ygdel='yarn global remove'
# fi
#---
# if [ X != X$(command -v cargo) ]; then
alias cgb='cargo build'
alias cgc='cargo check'
alias cgn='cargo new'
alias cgr='cargo run'
# fi
