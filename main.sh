#!/bin/bash


# manw
#  translate a wikipedia page in a man page


## Arguments
#   $@	the page name to search


## Return code
#   0   Everything went all right
#   1	Something bad happened


# print the syntax and exit
syntax ()
{
	echo 'manw: translate a wikipedia page in a man page'
	echo 'Usage:'
	echo -e "\t$0 language page-name"
	echo 'Example:'
	echo -e "\t$0 en man page"
	echo -e "\t$0 fr man_page"
	echo -e "\t$0 de Man page"
	exit 1
}

# check for arguments and exit if needed
#  $@	all arguments
check_args ()
{
	[[ $# -ge 1 ]] || syntax
}

# download the given page name
#  $1	the language
#  $2	the page name
download ()
{
	rm '/tmp/manw'
	local URL="https://$1.wikipedia.org/w/index.php?title=$2&action=edit"
	wget -c "$URL" -nv -O '/tmp/manw'
}

# entry point
#  $@	all arguments
main ()
{
	check_args $@
	language=''
	title=''
	if [ $# -ge 2 ] ; then 
		language=$1
		shift
		title="$*"
	else 
		language="en"
		title="$*"
	fi
	echo "Language : $language"
	echo "Title : $title"

	download "$language" "$title"
	./parse.awk '/tmp/manw' > /tmp/man_page
	man '/tmp/man_page'
}


main $@
