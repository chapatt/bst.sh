#
# Copyright (c) 2017 Chase Patterson
#

# $1: namespace
bst_incrementcount() {
	eval ${1}_count=`eval expr '$'${1}_count + 1`
}

# $1: node
bst_getvalue() {
	echo "$1" | sed -n "s/^\(.*\):.*:.*:.*$/\1/p"
}

# $1: node
bst_getparent() {
	echo "$1" | sed -n "s/^.*:\(.*\):.*:.*$/\1/p"
}

# $1: node
bst_getleft() {
	echo "$1" | sed -n "s/^.*:.*:\(.*\):.*$/\1/p"
}

# $1: node
bst_getright() {
	echo "$1" | sed -n "s/^.*:.*:.*:\(.*\)$/\1/p"
}

# If node has left child: return 0; else: return 1
# $1: node
bst_hasleft() {
	if [ -n "`eval bst_getleft '"'$1'"'`" ]; then
		return 0
	else
		return 1
	fi
}

# If node has right child: return 0; else: return 1
# $1: node
bst_hasright() {
	if [ -n "`eval bst_getright '"'$1'"'`" ]; then
		return 0
	else
		return 1
	fi
}

# $1: namespace
bst_generatenode() {
	if eval [ -z '$'${1}_count ]; then
		echo ${1}0
	else
		eval echo ${1}'$'${1}_count
	fi
}

# $1: value, $2: parent node name, $3: namespace
bst_insertleft() {
        bst_incrementcount "$3"
	eval bst_setleft `bst_generatenode $3` $2
        eval `eval bst_getleft '"$'$2'"'`='${1}':'${2}'::
	# FIXME! should I return name of inserted node? echo `bst_getleft $2`
}

# $1: value, $2: parent node name, $3: namespace
bst_insertright() {
	bst_incrementcount "$3"
	eval bst_setright `bst_generatenode $3` $2
	eval `eval bst_getright '"$'$2'"'`='${1}':'${2}'::
}

# $1: value, $2: current node name, $3: namespace, $4: parent node name
bst_insertnodeiter() {
	# $1 is already in the tree at $2
	if [ "$1" = "`eval bst_getvalue '"$'$2'"'`" ]; then
		return

	# $2 is empty
	elif [ -z "`eval bst_getvalue '"$'$2'"'`" ]; then
		eval $2='${1}':'${4}'::

	# $1 is less than $2
	elif expr "$1" \< "`eval bst_getvalue '"$'$2'"'`" >/dev/null; then

		# $2 has no left child
		if [ -z "`eval bst_getleft '"$'$2'"'`" ]; then
			bst_insertleft "$1" $2 $3
			return
		else
			bst_insertnodeiter "$1" "`eval bst_getleft '"$'$2'"'`" $3 $2
		fi

	# $1 is greater than $2
	elif expr "$1" \> "`eval bst_getvalue '"$'$2'"'`" >/dev/null; then

		# $2 has no right child
		if [ -z "`eval bst_getright '"$'$2'"'`" ]; then
			bst_insertright "$1" $2 $3
			return
		else
			bst_insertnodeiter "$1" "`eval bst_getright '"$'$2'"'`" $3 $2
		fi
	fi
}

# $1: value, $2: namespace
bst_insertnode() {
	bst_insertnodeiter "$1" ${2}0 $2 ''
}

# $1: source node name, $2: destination node name
bst_copynode() {
	eval $2='"$'$1'"'
}

# $1: node name
bst_claimchildren() {
	if eval bst_hasleft '"$'$1'"'; then
		bst_setparent $1 `eval bst_getleft '"$'$1'"'`
	fi
	if eval bst_hasright '"$'$1'"'; then
		bst_setparent $1 `eval bst_getright '"$'$1'"'`
	fi
}

# $1: node name, $2: namespace
bst_deletenode() {
	# has no children
	if ! eval bst_hasleft '"$'$1'"' && ! eval bst_hasright '"$'$1'"'; then
		bst_temp=`eval bst_getparent '"$'$1'"'`
		if [ "$1" = "`eval bst_getleft '"$'$bst_temp'"'`" ]; then
			bst_setleft '' $bst_temp
		elif [ "$1" = "`eval bst_getright '"$'$bst_temp'"'`" ]; then
			bst_setright '' $bst_temp
		fi
		unset bst_temp
		unset $1
	elif ! eval bst_hasleft '"$'$1'"'; then
		eval bst_temp='"$'$1'"'	# save current contents
		bst_copynode `eval bst_getright '"$'$1'"'` $1 # cp right to current
		bst_setparent `bst_getparent "$bst_temp"` $1
		unset `bst_getright "$bst_temp"`	# free right
		unset bst_temp

		bst_claimchildren $1
	elif ! eval bst_hasright '"$'$1'"'; then
		eval bst_temp='"$'$1'"'	# save current contents
		bst_copynode `eval bst_getleft '"$'$1'"'` $1 # cp right to current
		bst_setparent `bst_getparent "$bst_temp"` $1
		unset `bst_getleft "$bst_temp"`		# free left
		unset bst_temp

		bst_claimchildren $1
	else
		bst_temp=`bst_getinordersuccessor $1 $2`
		echo $bst_temp
		bst_setvalue `eval bst_getvalue '"$'$bst_temp'"'` $1
		bst_deletenode $bst_temp
		unset bst_temp
	fi
}

# If found: print 0, return 0; if not found: print parent, return 1;
# 	if tree doesn't exist: return 2
# $1: value, $2: namespace
bst_findnode() {
	echo
}

# If node doesn't exist: return 1; else: print node name of min
# $1: root node name
bst_findmin() {
	if [ -z $1 ]; then
		return 1
	fi

	if ! eval bst_hasleft '"$'$1'"'; then
		echo $1
	else
		eval bst_findmin `eval bst_getleft '"$'$1'"'`
	fi
}

# If node doesn't exist: return 1; else: print node name of max
# $1: root node name
bst_findmax() {
	if [ -z $1 ]; then
		return 1
	fi

	if ! eval bst_hasright '"$'$1'"'; then
		echo $1
	else
		eval bst_findmax `eval bst_getright '"$'$1'"'`
	fi
}

# If successor exists: print node name, return 0; if max: return 1
# $1: node name, $2: namespace
bst_getinordersuccessor() {
	if eval bst_hasright '"$'$1'"'; then
		eval bst_findmin `eval bst_getright '"$'$1'"'`
		return
	fi

	if [ `bst_findmax ${2}0` = $1 ]; then
		return 1
	fi

	bst_temp=`eval bst_getparent '"$'$1'"'`
	while [ "`eval bst_getright '"$'$bst_temp'"'`" = $1 ]; do
		bst_temp=`eval bst_getparent '"$'$bst_temp'"'`
	done
	echo $bst_temp
	unset bst_temp
}

# Print names of nodes in order; if tree doesn't exist: return 1
# $1: namespace
bst_traverseinorder() {
	bst_temp1=`bst_findmin ${1}0`
	echo $bst_temp1
	while bst_getinordersuccessor $bst_temp1 $1; do
		bst_temp1=`bst_getinordersuccessor $bst_temp1 $1`
	done
}

# $1: value, $2: node name
bst_setvalue() {
	eval $2='"'$1:`eval bst_getparent '"$'$2'"'`:`eval bst_getleft '"$'$2'"'`:`eval bst_getright '"$'$2'"'`'"'
}

# $1: parent name, $2: node name
bst_setparent() {
	eval $2='"'`eval bst_getvalue '"$'$2'"'`:$1:`eval bst_getleft '"$'$2'"'`:`eval bst_getright '"$'$2'"'`'"'
}

# $1: left name, $2: node name
bst_setleft() {
	eval $2='"'`eval bst_getvalue '"$'$2'"'`:`eval bst_getparent '"$'$2'"'`:$1:`eval bst_getright '"$'$2'"'`'"'
}

# $1: right name, $2: node name
bst_setright() {
	eval $2='"'`eval bst_getvalue '"$'$2'"'`:`eval bst_getparent '"$'$2'"'`:`eval bst_getleft '"$'$2'"'`:$1'"'
}
