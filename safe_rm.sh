#!/bin/bash

#Program: safe_rm
#Type:    bash file
#@author: Brandon Fernandez
#Date:    03/02/2017

#Takes 1 or more params(fileName..)
#Places file in deleted folder
#Appends old path to restore.info

#SETUP ALL FUNCTIONS
#############################################################

function createDelDir(){
if [ ! -e ~/deleted ]
then
	mkdir ~/deleted
fi
}

function checkForArgs(){
if [ $# -eq 0 ]
then
	echo -e "safe_rm: missing operand\n\tProgram Terminated...\n"
	exit 0
fi
}
	
#Append file PATH to next line of restore.info line
function record_restore_info(){
	inode=$(ls -i $1 | cut -d " " -f1)
	path=$(readlink -m $1)
	fullpath=$path'_'$inode 
	echo "$fullpath" >> ~/.restore.info
}

function safe_remove(){ 
record_restore_info $1
inode=$(ls -i $1 | cut -d " " -f1)
bname=$(basename "$1")
restoreFileName=$bname'_'$inode
mv $1 ~/deleted/$restoreFileName

#check if optv -v is used
if [ $optv -eq 1 ]
then
	echo "removed '$1'"
fi 
}

function safe_remove_handler(){

if [ $opti -eq 1 ]
then
        read -p "Does the user wish to delete this file $1? (y = yes/n = no)" input

    case $input in
        [Yy]) safe_remove $1;;
        [Nn]) continue;;
    esac

        elif [ $optv -eq 1 ]
        then
        echo "removed '$1'"
                safe_remove $1
    else
                safe_remove $1
    fi

}

function dir_safe_remove(){

#for each file in the dir safe_remove

local rdir="$(ls $1)"

for file in $rdir
do
	local lfile=$file
        #recursive if
	if [ -d $1/$lfile ]
    then
		read -p "safe_rm: descend into directory '$1/$lfile'?" ans
	    #TODO: add a statement that will prompt user permission to traverse into the directory"
 	    case $ans in
 	    	[Yy]) dir_safe_remove $1/$lfile;;
	        [Nn]) continue;;    
		esac

    fi
			
  	safe_remove_handler $1/$lfile
done
read -p "Does the user wish to delete this Directory $1? (y = yes/n = no)" ans2

case $ans2 in
	[Yy]) rmdir $1;;
	[Nn]) continue;;
esac

}

#############################################################

#MAIN
createDelDir

cat<<eof

		===================
		Safe Remove Program
		===================

eof

##options
#identify option, remove from command, execute ather 1s
opti=0
optv=0
optr=0

while getopts ivr opt
do
	case $opt in
    i) opti=1;;
    v) optv=1;;
	r) optr=1;;
    *) echo "Invalid [Option]"
		exit 2;;
    esac
done
shift $[$OPTIND-1]


####################################

#Initial checks
checkForArgs $*

#safe_rm for loop Starts HERE
for arg in $@
do

#Safeguard to disable safe_rm from being deleted
if [ $arg = "safe_rm.sh" ]
then
	echo -e "ERROR: Attempting to delete safe_rm\n\t-operation aborted.\n"
continue
fi
#safe_rm a directory if option -r exists 
if [[ -d $arg && $optr -eq 1 ]]
then
	read -p "safe_rm: descend into directory '$arg'?" ans
	case $ans in
		[Yy]) dir_safe_remove $arg;;
		[Nn]) continue;;
    esac

elif [[ -d $arg && $optr -eq 0 ]]
then
	continue
else
	if [ -e $arg ]
	then
		safe_remove_handler $arg
	else
		echo "rm: cannot remove '$arg': No such file or directory"
		continue
	fi
fi
done
