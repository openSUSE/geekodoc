#!/bin/bash -i
#
# Run test cases
#
# The test cases are separated into "good" and "bad":
#
# * good are tests which MUST SUCCEED, otherwise it is an error
# * bad are tests which MUST FAIL, otherwise it is an error
#
# Author: Thomas Schraitle
# Date:   2016-2018

VALIDATOR="xmllint"
PROG=${0##*/}
PROGDIR=${0%/*}
# Needed to be able to run it from different directories
SCHEMA=${PROGDIR}/../rng/geekodoc5-flat.rng
SCHEMA=$(readlink -f ${SCHEMA})
ERRORS=0
ERRORFILE=${PROGDIR}/last-test-run-errors

SUCCESS=0
FAILURE=1

MAKE=1

TEST_CATEGORY=all

export LANG=C

function logerror() {
    local fatal=0
    if [[ $1 == '--fatal' ]]; then
        fatal=1
        shift
    fi
    echo -e "\e[1;31mERROR: $1\e[0m"
    [[ $fatal -ne 0 ]] && exit 1
}

function loginfo() {
    local extraoptions=
    if [[ $1 == '-n' ]]; then
        extraoptions='-n'
        shift
    fi
    echo -e $extraoptions "\e[1;39mINFO: $1\e[0m"
}

function logwarn() {
    echo -e "\e[1;95mWARN: $1\e[0m"
}

function validator() {
    case "$VALIDATOR" in
     "xmllint")
        # sed '$ d' removes the last line in which xmllint just prints the
        # validation status (which we don't want cluttering our output).
        xmllint --noout --relaxng "$1" "$2" 2>&1 | sed '$ d'
        ;;
     "jing")
        jing "$1" "$2"
        ;;
     *)
        echo "Unrecognized validator: $VALIDATOR" 1>&2
        ;;
    esac
    return 1
}

function print_help {
    cat <<EOF_helptext
Run all the test cases using ${SCHEMA}

Usage:
   ${PROG} [-h|--help] [OPTIONS]

Options:
   -h, --help  Shows this help message
   -V VALIDATOR, --validator VALIDATOR
               Choose to validate either with "jing" or "xmllint"
   -t, --test  Choose the test category:
               * 'bad' check only tests which are expected to fail
               * 'good' check only tests which are expected to succeed
               * 'all' chooses both (default)
   -n, --noremake Do not run make on the geekodoc/rng/ directory
               (useful for running this in the RPM %check section)
EOF_helptext
}


function test_check()
{
    local TEST=$1
    local RESULT=$2
    local RESULTSTR=

    RESULTSTR="\e[1;32mPASSED\e[0m"
    case "$1" in
        good)
            if [[ ! "$RESULT" == '' ]]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
                ERRORS=$(($ERRORS + 1))
            fi
            ;;
        bad)
            if [[ "$RESULT" == '' ]]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
                ERRORS=$(($ERRORS + 1))
            fi
            ;;
        *)
            ;;
    esac
    echo -e $RESULTSTR
}

function test_files() {
    local DIR=$1
    local CHECK=$2
    local GOOD_OR_BAD=${DIR##*/}
    local result
    local resultstr
    local re='^[0-9]+$'

    for xmlfile in $DIR/*.xml; do
       loginfo -n "Validating '$xmlfile'... "
       wellformedness=$(xmllint --noout --noent $xmlfile 2>&1)
       if [[ ! $wellformedness == '' ]]; then
           # In this case, we always want to say "FAILED", so this usage is correct.
           # (But we are abusing the existing test_check() function somewhat.)
           test_check good 'not good'
           echo -e "$wellformedness"
           logerror --fatal "Test case is not well-formed: '$xmlfile'. Quitting."
       fi
       result=$(validator $SCHEMA $xmlfile)
       test_check $GOOD_OR_BAD "$result"
       if [[ ! "$result" == '' ]]; then
           [[ $GOOD_OR_BAD == 'good' ]] && echo -e "$result"
           echo "###### Errors in '$xmlfile' ######" >> $ERRORFILE
           echo -e "\n$result\n\n" >> $ERRORFILE
       fi
    done
}

# -----
#
ARGS=$(getopt -o h,V:,t:,n -l help,validator:,test:,nomake -n "$PROG" -- "$@")
eval set -- "$ARGS"
while true ; do
    case "$1" in
        -h|--help)
            print_help
            exit
            shift
            ;;
        -V|--validator)
            case "$2" in
                'xmllint' | 'jing')
                 VALIDATOR="$2"
                 ;;
               *)
                 print_help
                 echo "ERROR: Unrecognized validator '$2'" 2>/dev/stderr
                 exit 10
                 ;;
            esac
            shift 2
            ;;
        -t|--test)
            case "$2" in
              all)
                # don't do anything, this is the default
                ;;
              bad|good)
                TEST_CATEGORY=$2
                shift 2
                ;;
              -*)
                # another option, don't use it
                shift 1
                ;;
              *)
                logerror "Expected 'all', 'bad', or 'good' for option $1"
                exit 1
                ;;
            esac
            ;;
        -n|--nomake)
            MAKE=0
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ $MAKE -eq 1 ]]; then
  loginfo "Making flat GeekoDoc..."
  make -C "$PROGDIR/../rng" > /dev/null
  [[ ! $? -eq 0 ]] && logerror --fatal "Make error. Quitting."
else
  loginfo "Not making flat GeekoDoc"
fi

loginfo "Using validator '$VALIDATOR'"
loginfo "Selected category: '$TEST_CATEGORY'"

rm -r "$ERRORFILE" 2> /dev/null

case "$TEST_CATEGORY" in
  all)
    test_files $PROGDIR/good test_check_good
    echo "----------------------------------"
    test_files $PROGDIR/bad test_check_bad
    ;;
  good)
    test_files $PROGDIR/good test_check_good
    ;;
  bad)
    test_files $PROGDIR/bad test_check_bad
    ;;
esac


echo
loginfo "Find all validation errors in $ERRORFILE"
if [ 0 -eq "$ERRORS" ]; then
    loginfo "Found\e[1;32m $ERRORS errors\e[0m. Congratulations! :-)"
    exit 0
else
    loginfo "Found\e[1;31m $ERRORS error(s)\e[0m. :-("
    exit 1
fi
