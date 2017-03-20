

#Program: safe_rm_restore
#Type:    bash file
#@author: Brandon Fernandez
#Date:    03/02/2017

#Takes 1 or more params(fileName..)
#Finds the file in the deleted folder
#Restores the file to its original state

#FLOW of PRGRM:

#takes in filename 
#finds file in deleted dir
#seperates basename from inode: cut -d "_" -f1
#finds file by base name in .restore.info
#check if parent directory exists
#if not
#mkdir dir path 'project/td/td2'
#else
#check file doesnt exist already in target dir : if so prompt for overwrite(y/n)
#finally
#mv base(filename) to dir path
#remove restore.info

#FUNCTIONS
#####################################################################

function checkForArgs(){
if [ $# -eq 0 ]
then
	echo -e "safe_rm_restore: missing operand\n\tProgram Terminated...\n"
	exit 0
fi
}

#####################################################################
#MAIN

cat<<eof

                ===========================
                Safe Remove Restore Program
                ===========================

eof

#initial checks
checkForArgs $*

#start of safe_rm_restore for loop
for arg in $@
do
	if [ ! -e ~/deleted/$arg ]
    then
    	echo -e "safe_rm_restore: cannot restore '$arg': No such file or directory\n"
        continue
    fi

bname=$(echo "$arg" | cut -d "_" -f1)

linedel=$(grep -v ".*/$arg" ~/.restore.info)
echo -e "Linedel: $linedel\n"

restorepath=$(grep -w "$arg" ~/.restore.info -m1)
echo "RP: $restorepath"
dirpath=$(echo "$restorepath" | grep -o ".*/")
echo "DP: $dirpath"
mkdir -p $dirpath
if [ -e $dirpath/$bname ]
then
	read -p "Does the user wish to overwrite $bname? (y = yes/n = no)" input
	case $input in
        [Yy]) mv ~/deleted/$arg $dirpath/$bname
				echo "$linedel" > /tmp/tmp
				mv /tmp/tmp ~/.restore.info;;
        [Nn]) continue;;
    esac

else
	mv ~/deleted/$arg $dirpath/$bname
	echo "$linedel" > /tmp/tmp
	mv /tmp/tmp ~/.restore.info
fi
done
