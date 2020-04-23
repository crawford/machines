{ config, lib, ... }:

let cfg = config.programs.zsh;
in
{
  options.programs.zsh.promptColor = lib.mkOption {
    default = "cyan";
    description = ''
      The color used to draw the non-root user prompt. The supported values are detailed in http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting.
    '';
  };

  config.programs.zsh = {
    enable   = true;
    histSize = 10000;

    interactiveShellInit = ''
      bindkey -e

      #Git Integration
      typeset -ga preexec_functions
      typeset -ga precmd_functions
      typeset -ga chpwd_functions

      typeset -g __CURRENT_GIT_BRANCH=
      typeset -gi __CURRENT_GIT_BRANCH_DIRTY=1

      parse_git_branch() {
        git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/:\1/'
      }

      preexec_functions+='zsh_preexec_update_git_vars'
      zsh_preexec_update_git_vars() {
        case "$(history $HISTCMD)" in
          *git*)
          typeset -gi __CURRENT_GIT_BRANCH_DIRTY=1 ;;
        esac
      }

      chpwd_functions+='zsh_chpwd_update_git_vars'
      zsh_chpwd_update_git_vars() {
        typeset -gi __CURRENT_GIT_BRANCH_DIRTY=1
      }

      precmd_functions+='zsh_precmd_undirty_branch'
      zsh_precmd_undirty_branch() {
        if [[ $__CURRENT_GIT_BRANCH_DIRTY -ne 0 ]]
        then
          typeset -gi __CURRENT_GIT_BRANCH_DIRTY=0
          typeset -g __CURRENT_GIT_BRANCH="$(parse_git_branch)"
        fi
      }

      get_git_prompt_info() {
        echo $__CURRENT_GIT_BRANCH
      }
      #End Git Integration

      TMOUT=5
      TRAPALRM () {
        zle reset-prompt
      }

      set -o vi
    '';

    promptInit = ''
      if [ $UID -eq 0 ]
      then
        PROMPT="%K{red}(%T %n@%m%(?.. ✘))%k "
      else
        PROMPT='%F{${cfg.promptColor}}(%F{black}%B%T%b %F{${cfg.promptColor}}%n@%m%F{cyan}$(get_git_prompt_info)%(?.. %F{red}✘)%F{${cfg.promptColor}})%f '
      fi
      RPROMPT="%F{${cfg.promptColor}}%~%f"
    '';

    setOptions = [
      "HIST_IGNORE_DUPS"
      "APPEND_HISTORY"
      "AUTO_CD"
      "EXTENDED_GLOB"
      "NOMATCH"
      "NOTIFY"
      "PROMPT_SUBST"
    ];
  };
}
