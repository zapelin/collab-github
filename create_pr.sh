echo "commit branch -> 
	  commit master -> 
	  push master -> 
	  merge master to branch -> 
	  push branch -> 
	  create PR\n"
echo "checkout master"
git checkout master
echo '${1}' >> ${1}.txt
echo "creating branch ${1}"
git checkout -b ${1}
