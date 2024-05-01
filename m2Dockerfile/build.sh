#!/bin/bash
tagname=$1
pathd=$(pwd)

gitClone () {
 echo "Git Cloning"
 cd magento2 && git checkout 2.4-develop && git reset
 git pull
 git fetch --all --tags --prune
 git checkout tags/$tagname
if [ $? -ne 0 ]
	then
	echo "error on cloning the branch"
	exit 34;
fi
 cd ..
 if [ -d ./magento ]
 then rm -fr magento && mkdir magento
 fi
 rsync -raz --exclude=.git magento2/* $pathd/magento/.
 if [ $? -ne 0 ]
        then
                echo "error cloning the repo"
                exit 127
 fi
	docker build -t amila/vanilla-m2:$tagname $pathd
 if [ $? -eq 0 ]
        then
                docker push amila/vanilla-m2:$tagname
                echo "or you can run it!"
		exit 0;
 fi
 }

echo "Cloning $1 with $#"
if [ $# -lt 1 ]
	then echo "version not provided"
		echo $?
		exit 1;
fi

if [ -d ./magento2 ]
	then
	echo "FE"
	gitClone
	if [ $? -ne 0 ]
		then echo "removing temp magento folder" && rm -fr ./magento2
	fi
fi
if [ ! -d ./magento2 ]
	then
		mkdir magento2
		gitCone
fi
