# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/scripts:$HOME/.local/bin:" ]]; then
    PATH="$HOME/.local/scripts:$HOME/.local/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
#
# What about /etc/bashrc.d
# What about /etc/profile.d


_scan_dir ()
{
  #local prefix=~/.local/bashrc.d
  local prefix=$1
  local ext=${2:-.sh}
  local rc=
  local def_prio=99

  if [ -d ${prefix} ]; then
      for rc in ${prefix}/*${ext} ; do
          if [ -f "$rc" ]; then
              local path=$prefix
              local name=${rc##*/}

              local short=${name:0:3}
              local prio=${short//[^0-9]/}
              local prio=${prio:-$def_prio}

              # echo "$prefix $name"
              echo "$prio $name;$prefix"
          fi
      done
  fi
}

_add_file ()
{
  >&2 echo "yoo => $1"
  local path=${1%/}
  local name=${path##*/}
  local dir=${path%/*}
  local prio=${2:-80}

  if [ -f ${path} ]; then
    echo "$prio $name;$dir"
  #>&2 echo "yoo => $prio;$name;$dir"
    #  echo . /etc/bashrc
  fi
}

_load_source ()
{
  local prio=${1%% *}

  local path=${1##*;}
  local name=${1%%;*}
  local name=${name:3}
  local src="$path/$name"

  echo "Source: $prio - $src"
}


# Load order
files=$(
{
_add_file /etc/profile
_scan_dir /etc/profile.d .sh
_scan_dir /etc/bashrc.d .sh

_scan_dir ~/.local/bashrc.d .sh;
_scan_dir ~/.local/shell/bash_init .sh;

_scan_dir ~/.local/shell/bash_ps1 .sh
_scan_dir ~/.local/shell/bash_comp .sh


_scan_dir /home/jez/volumes/data/prj/mrjk/idmgr_beta/shellhook/bash_init .sh
} |  sort -u
)


echo "Load files: "
#echo "$files" | sort
_OLD_IFS=$IFS
IFS=$'\n'
for file in $files; do
  _load_source $file
done
IFS=$_OLD_IFS

