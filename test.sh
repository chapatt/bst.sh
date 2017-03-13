. ./bst.sh

test_bst_incrementcount() {
	unset t_count
	if bst_incrementcount t \
	   && [ -z "`bst_incrementcount t`" ] \
	   && [ $t_count = 1 ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_getvalue() {
	if bst_getvalue "a:b:c:d">/dev/null \
	   && [ "`bst_getvalue \"a:b:c:d\"`" = "a" ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_getparent() {
	if bst_getparent "a:b:c:d">/dev/null \
	   && [ "`bst_getparent \"a:b:c:d\"`" = "b" ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_getleft() {
	if bst_getleft "a:b:c:d">/dev/null \
	   && [ "`bst_getleft \"a:b:c:d\"`" = "c" ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_getright() {
	if bst_getright "a:b:c:d">/dev/null \
	   && [ "`bst_getright \"a:b:c:d\"`" = "d" ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_hasleft() {
	if bst_hasleft "::a:" \
	   && !(bst_hasleft ":::") \
	   && [ -z "`bst_hasleft \":::\"`" ];
	then
		return 0
	else
		return 1
	fi
}

test_bst_hasright() {
	if bst_hasright ":::a" \
	   && !(bst_hasright ":::") \
	   && [ -z "`bst_hasright \":::\"`" ];
	then
		return 0
	else
		return 1
	fi
}

tests="bst_incrementcount
       bst_getvalue
       bst_getparent
       bst_getleft
       bst_getright
       bst_hasleft
       bst_hasright"

cols=`stty size | cut -d " " -f 2`

fail_count=0

for i in $tests; do
	printf "Testing %s%n" $i n
	result="`test_$i && echo PASSED || echo FAILED`"
	leader="`head -c \`expr $cols - $n - 6\` < /dev/zero | tr '\0' '.'`"
	printf "%s%s\n" $leader $result
	if [ $result = "FAILED" ]; then
		fail_count=`expr $fail_count + 1`
	fi
done

exit $fail_count
