#!/usr/bin/env bash

source common.sh

function _Init () {
    if ! [ -d bare ]; then
        git init --bare bare
    fi
    cat hooks/post-receive > bare/hooks/post-receive
    chmod +x bare/hooks/post-receive

    if ! [ -d src ]; then
        git init src
        cd src
        echo "# testrepo" >> README.md
        git add README.md
        git commit -m 'first commit'
        git branch -M master
        git remote add origin ../bare
        git push --set-upstream origin master
        git push -u origin master
        cd ..
    fi
}

if ! [ ${password} ]; then
    if [ -f passphrase ]; then
        export passphrase=$(cat passphrase)
    fi
else
    # read -p "password required: " passphrase
    # export passphrase=$passphrase
    Unlock
fi

function Unlock () {
    echo "Unlocking"
    echo ""
    read -s -p "enter password: " password
    echo ""
    passhash=$(echo $password | _hash)
    if [[ $passhash == $(cat passphrase) ]]; then
        export password=$password
        echo "password correct!"
        echo "unlocked!"
    else
        echo "password incorrect!"
        echo "aborting!"
    fi 
    echo ""
}


function ChangePassword () {
    echo "Changeing Password"
    echo ""
    read -s -p 'enter new password: ' new1
    echo ""
    read -s -p 'enter same password again: ' new2
    echo ""
    if [[ $new1 == $new2 ]]; then
        export password=$new1
        passhash=$(echo $new1 | _hash)
        echo "$passhash" > passphrase
        echo "password changed successfully!"
    else
        echo "passwords do not match!"
        echo "aborting!"
    fi
    echo ""
}


function _Push () {

    _compress src/ | _encrypt > a
    _compress bare/ | _encrypt > b

    git add --all
    git commit -m 'push'
    git push
}

function _Pull () {
    git pull
    # cat a | gpg --batch --passphrase $passphrase -d | tar -xvf -C src
}

function _TestCommit () {
    echo "TestCommit"
    pwd
    echo '#' >> README.md
    git add -A
    git commit -m 'TestCommit'
    git push
}

function _show_help () {
    echo "github-crypt help"
    echo ""
    echo ""
}
function _show_info () {
    echo "github-crypt info"
    echo ""
    echo "[.git]"
    git remote -v
    echo ""
    echo '[src/.git]'
    git -C src remote -v
    # git -C bare remote -v
    echo ""
}


POSITIONAL=()
while (( $# > 0 )); do
    case "${1}" in

        pull)
        echo pull: "${1}"
        _Pull
        shift # shift once since flags have no values
        ;;

        push)
        echo push: "${1}"
        _Push
        shift # shift once since flags have no values
        ;;


        changepass)
        ChangePassword
        shift # shift once since flags have no values
        ;;

        unlock)
        Unlock
        shift # shift once since flags have no values
        ;;

        -f|--flag)
        echo flag: "${1}"
        shift # shift once since flags have no values
        ;;
        -h|--help)
        _show_help
        shift # shift once since flags have no values
        ;;
        -i|--info)
        _show_info
        shift # shift once since flags have no values
        ;;
        -s|--switch)
        numOfArgs=1 # number of switch arguments
        if (( $# < numOfArgs + 1 )); then
            shift $#
        else
            echo "switch: ${1} with value: ${2}"
            shift $((numOfArgs + 1)) # shift 'numOfArgs + 1' to bypass switch and its value
        fi
        ;;
        *) # unknown flag/switch
        POSITIONAL+=("${1}")
        shift
        ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional params
