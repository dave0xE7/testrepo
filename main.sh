#!/usr/bin/env bash

echo "create new github repo and copy its url:"
echo ""

# read -p "enter url: " url
# echo ""
url='git@github.com:dave0xE7/testrepo.git'

# read -p "repo name: " reponame
# echo ""
reponame='testrepo'

if ! [ -d $reponame.git ]; then
    git init --bare $reponame.git
fi
if ! [ -d $reponame-remote ]; then
    git clone $url $reponame-remote
fi

if ! [ -d $reponame ]; then
    git init $reponame
    cd $reponame
    echo "# testrepo" >> README.md
    git add README.md
    git commit -m 'first commit'
    git branch -M master
    git remote add origin $(pwd)/../$reponame.git
    git push --set-upstream origin master
    git push -u origin master
    cd ..
fi

passphrase="asdf"

function _Push () {
    cd $reponame.git
    git archive --format tar HEAD | gpg --batch --passphrase $passphrase -c > ../$reponame-remote/a
    cd ..
    cd $reponame-remote
    git add a
    git commit -m 'push'
    git push
    cd ..
}


#git init 
#cd $reponame
#git remote add 

#git clone $url $reponame-crypt
#git clone $reponame-crypt $reponame


