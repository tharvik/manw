#!/bin/awk -f

# print a text without the ORS
function echo(text) {
	old = ORS
	ORS = ""

	print text

	ORS = old
}

# print the header
function title_line(title, date) {

	print ".TH \"" title "\" 6 " date " Wikipedia \"Wikipedia, The Free Encyclopedia\""
}

# print a section header
function section_line(title) {

	title = toupper(title)
	print ".SH " title
}

# clean and print a line of all the unparsed syntax
function clean_line(line) {
	
	#! fill it
	echo(line)
}

# bold the given text and print it
function bold(text) {

	echo("\\fB" text "\\fP")
}

# undeline the given text and print it
function link(text) {

	echo("\\fI" text "\\fP")
}

# setup
BEGIN {
	activate = 0		# main code to parse
	title	= ""		# temporary
	section_name_done = 0	# if the name was already printed
}

# get title, which is not in code
/<title>/ {

	title = $4
	for(i = 5; i < NF - 4; i++) {
		title = title " " $i
	}

}

# get date and print header
/wpEdittime/ {

	split($0, array, "\"")
	date = substr(array[2], 0, 6)

	title_line(title, date)
}

# unset activate on end of match
/<\/textarea>/ {
	activate = 0;
}

# main parser
{
	if (activate) {

		# section
		if (substr($1, 0, 2) == "==") {

			# handle spaces and no spaces in section
			match($0, "==.*==")
			matching = substr($0, 3, RLENGTH - 4)
			section_line(matching)

		# first section (which is the name) 
		} else if (!section_name_done) {
			section_line("name")
			section_name_done = 1

		# parse the rest
		} else {

			# main loop, which switch on every keywords
			size = split($0, array, "''|'''|]]|\\[\\[|\\|", seps)	
			bold_switch = 0
			italic_switch = 0
			link_switch = 0
			
			#print array[1] seps[1]

			for(i = 1; i <= size; i++) {

				parsed = 0
				switch(seps[i]) {
				
					case "''":
						if (italic_switch) {
							link(array[i]) #! no separate way to do it?
							parsed = 1
							italic_switch = 0
							break
						}

						italic_switch = 1
						break

					case "'''":
						if (bold_switch) {
							bold(array[i])
							parsed = 1
							bold_switch = 0
							break
						}

						bold_switch = 1
						break

					case "[[":
						link_switch = 1
						break
							
					case "]]":
						if(link_switch) {
							#print ">>>>"
							link(array[i])
							link_switch = 0
							parsed = 1
						}
						break

					case "|":
						if(link_switch) {
							parsed = 1
						}
						break
				}

				if(!parsed) {
					clean_line(array[i])
				}

			}

			# reset line
			print ""

			#clean_line($0)
		}
	}
}

# set activate on match of the block
/text\/x-wiki/ {
	activate = 1
}
