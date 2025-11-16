#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: lg_rustlang.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::lang::rustlang() {
  : ${CHDIR:="$HOME/.cache/osci"}
  local baseurl="https://rsproxy.cn"
  if [ X = X$(command -v cargo) ] && [ X = X$(command -v rustup) ]; then
    local init_dlurl="$baseurl/rustup/dist/$(arch)-unknown-linux-gnu/rustup-init"
    set -- $CHDIR/rustup-init && mkdir -p $CHDIR 2>/dev/null
    while true; do
      if [ -x $1 ]; then
        export RUSTUP_DIST_SERVER=$baseurl
        export RUSTUP_UPDATE_ROOT=$baseurl/rustup
        $1 -y --no-modify-path --profile minimal
        break
      fi
      curl --proto '=https' --tlsv1.2 -4fsSLo $1 $init_dlurl && chmod a+x $1
    done
  fi
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  {
    local tpl='
    H4sIAAAAAAAAA+2TQW/bIBTHc+ZTIHLZtBEna9r00kMX7TRph7TrpbUigl8cVAwW4CTdpx+QWF07
    dZvUwzTt/Q425v3/78HDTHhjK1/UE17BFrQvqvEytLqQ1qxVPQq20YPXMo6cTaf5HXn+npyefBhM
    TseT6ez0JDKIM7PZdEDHr678B3Q+CEfpwFkbfqX7Xfwf5dbbzkkYSScCeK5sSRy0WkjgOxU29IIy
    51tn9w/ct8J5YKS3PJ1Pvlr54B6S5zD3bnGzXFzNvxTKVLAvovWoUeB7e0lyMJl69WEtI2V5Dv1U
    8WmpF13k1kAoSa0CX0OQm7whLrWKruA6iIJVp3RVkvgH1BB4pVxKWISmLWScsvwQYMTFv2StRe1j
    /JbxOXtPmW0D1+nOXJywMuYCsy3J4uvV9fLj5fzz9eJy/illm6SFHPKM9udny7Mp78y9sTvDtTLd
    ntemK0kc3kOuLrUwdfIIrYQvaWJIpW0aYSqaJ8GTVZLm1TMis20D8p6RkMaxDWnN+ew6E0f9kHLu
    QINIpzik8YwkLGEvmlZD3lhSx509qvJHet6xfgU6Nv6O5R0femRgV5KtTK1hxhpgab038ysaLO08
    0DcsnkDKkYNvUzfANdECbmV9KrwWOr6PDOluA2ETm5HT03jiW1WBp73edqHtApFW27wv0QXL6Ev2
    LFPfov/oi/lqB96Pos48+p/7/MbuPO3FdCXcD05V5ZtxPj5WzN92/VT+t282giAIgiAIgiAIgiAI
    giAIgiAIgiAIgiAI8j/wHeZpl1UAKAAA'
  } 2>/dev/null
  set -- $HOME/.cargo && if [ -d $1 ]; then
    { echo "$tpl"; } 2>/dev/null | sed -r 's|\s+||' | base64 -d |
      tar -Ozxf - | sed "s|RV_RSCN|$baseurl|" >$1/config.toml
  fi
  ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
