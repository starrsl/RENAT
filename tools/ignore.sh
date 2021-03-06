#!/bin/bash
# -*- coding: utf-8 -*-

. gettext.sh
TEXTDOMAIN=ignore_ja_JP
TEXTDOMAINDIR=$(dirname $0)/locale
export TEXTDOMAIN
export TEXTDOMAINDIR

PROG=$(basename $0)
usage () {
  echo "$(eval_gettext "Mark an item with ignore flag that would be ignored by run.sh.")"
  echo 
  echo "$(eval_gettext "  \$PROG -l base:                 show the ignore list of the base folder")"
  echo "$(eval_gettext "  \$PROG -d [-r dep] item:        remove ignore flag of an item")"
  echo "$(eval_gettext "  \$PROG [-r dep] item comment:   mark an item as ignore with comment")"
  echo "$(eval_gettext "Option -r without parameter will mark all the item and its sub items.")"
  echo "$(eval_gettext "Without option -r (aka -r 0), the command only mark the item without its sub items.")"
  echo 
}

if [ $# -lt 1 ];  then
  usage
  exit 1
fi

MAXDEP="-maxdepth 0"

# parameters
OPT=$1
while [ ! -z "$OPT" ]; do
  case "$OPT" in
    '-h'|'--help' )
      usage
      exit 1
      ;;
    '-l'|'--list' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$(eval_gettext "\$PROG: option -l requires an argument")" 1>&2
        exit 1
      fi
      LIST=1
      ITEM=$2
      shift 2
      ;; 
    '-d'|'--delete' )
      DEL=1
      shift 1
      ;;
    '-r'|'--recursive' )
      if [[ "$2" =~ ^[0-9]+$ ]]; then
        MAXDEP="-maxdepth $2"
        shift 2
      else
        MAXDEP=""
        shift 1
      fi
      ;;
    * )
      if [ -z $ITEM ]; then
        ITEM=$1
        shift 1
        COMMENT="$@"
      else
        COMMENT="$@"
      fi 
      break
      ;;
  esac
  OPT=$1
done

# DEBUG=1
if [ ! -z $DEBUG ]; then
  echo "LIST=$LIST"
  echo "DEL=$DEL"
  echo "MAXDEP=$MAXDEP"
  echo "ITEM=$ITEM"
  echo "COMMENT=$COMMENT"
  exit 1
fi
 
# listing 
if [ ! -z $LIST ]; then
  echo "ignored list:"
  echo
  for TARGET in $(find $ITEM -depth -type f -name ".ignore" | sort); do
    ITEM=$(echo $TARGET | sed "s/^$PROG\///g" | sed "s/\/\.ignore//g")
    COMMENT=$(cat $TARGET)
    printf "%-64s %s\n" "$ITEM" "$COMMENT"
  done
  echo 
  exit 0
fi

# remove marking
if [ ! -z $DEL ]; then
  for TARGET in $(find $ITEM $MAXDEP -type d); do
    if [ -f $TARGET/.ignore ]; then
      rm -f $TARGET/.ignore
      echo "$(eval_gettext "removed .ignore in '\$TARGET'")"
    fi
  done
  exit 0
fi

# add marking
for TARGET in $(find $ITEM $MAXDEP -type d); do
  if [ -f $TARGET/main.robot ]; then
    if [ -f $TARGET/.ignore ];  then
        OLD_COMMENT=$(cat $TARGET/.ignore)
    fi
    echo "$COMMENT" > $TARGET/.ignore
    echo "$(eval_gettext "ignored item '\$TARGET'")"
  fi
done

