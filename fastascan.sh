
#############################
# MAIN PROGRAM
#############################

green='\033[0;32m'
nc='\033[0m'

#####################################################
# Find fasta files & Check if directory option exists
#####################################################

if [ -n "$1"  ];
then

FASTA_FILES=$(find $1 -not -path '*/._*' -name "*.fasta" -o -not -path '*/._*' -name "*fa" 2>log_error_fastascan.txt ); # -not -path is used to avoid getting hidden files

else

FASTA_FILES=$(find . -not -path '*/._*' -name "*.fasta" -o -not -path '*/._*' -name "*fa" 2>log_error_fastascan.txt ); # -not -path is used to avoid getting hidden files

fi

#######################################################
# Check if the given directory is valid & Ouptut manual
#######################################################

if [ "$?" -eq 1 ]
then
	echo
	echo ERROR: Please use a valid directory!
	echo
	echo -e ${green}'                           #################################'
        echo -e '                                   /FASTASCAN USAGE/        '
        echo -e '                           #################################'${nc}
        echo 
        echo '   The goal of fastascan is to find all fasta files in a given directory or subfolders.'
        echo '   It will print out a report containing: how many files there are, how many sequences'
        echo '   there are per file and total, sequence length per file and total and it will print' 
        echo ' an example header of a file. It also tells apart protein and nucleotide containing files'
        echo '   and it identifies symlinks. If a given fasta file is not in the correct format (does'
        echo '                         not contain a header) it will ingore it.' 

        echo
        echo '~$ fastascan.Nicolas.Byrne.Alvarez.sh [valid directory]' 
        echo
        echo 'If no directory is provided, the current directory will be used as default '
	exit
fi

###########################################
#Start analysis once everything is in order
###########################################

echo
echo
echo -e ${green}'                                     *************************************************************'
echo -e '                                     ####  #####  #####  #####  #####  #####  #####  #####   #   #'
echo -e '                                     #     #   #  #        #    #   #  #      #      #   #   ##  #'
echo -e '                                     ###   #####  #####    #    #####  #####  #      #####   # # #'
echo -e '                                     #     #   #      #    #    #   #      #  #      #   #   #  ##'
echo -e '                                     #     #   #  #####    #    #   #  #####  #####  #   #   #   #'
echo -e '                                     *************************************************************'${nc}
echo
echo

#Print titles of table

echo -e "File_path" '\t' "Number_seqs" '\t' "Content" '\t' "Length" '\t' "Symlink " > foo_table.tbl



# Check if any fasta files were found. If so, run main program

if [ -z "$FASTA_FILES" ]
then
	echo
	echo There are no fasta/fa files to list in this directory.
	echo

else
	echo 
	echo
	echo In the current directory / subfolders there are a total of $(echo $(ls $FASTA_FILES | wc -l))  fasta/fa file'(s)'.
	echo
	echo Processing data...
	echo
	echo -e ${green}'########################'
	echo -e '      /FILE INFO/       '
	echo -e '########################'${nc}
	echo
	TOTAL_LENGTH=0;
	
	
	for i in $FASTA_FILES;
	do
	
		if grep -q ">" $i #Check if it is a .fasta/fa file (contains header ">")	
		
		then
			# Check if a given file is a symlink
			
			if [ -L "$i" ]
			
			then
				SYM=$( echo TRUE )
			       
			else 
				SYM=$( echo FALSE )
		        fi
		        
		        # Count how many sequences there are in each file
		
			SEQUENCES=$(echo $(grep -c ">" $i))  
		        
			# Get the length of each sequence in each file + Calculate total length
			
			FILE_LENGTH=$(awk '!/>/{gsub(/ /, "", $0) gsub(/-/,"", $0)}{print $0}' $i | awk '!/>/{n=n+length}END{print n}')
			
			TOTAL_LENGTH=$(($TOTAL_LENGTH + $FILE_LENGTH))
		        
			# Check type of content (nucleotide or protein)
					
			sed -n '2,2p' $i | if grep -v -q "^[AaTtCcGgNnUu]"  #If we detect something other than possible nucleotides (DNA/RNA) in the second line its a protein
			
			then 
				CONT=$( echo protein )
				
				# Generate output into file
				
				echo -e  $i '\t' $SEQUENCES '\t' $CONT '\t' $FILE_LENGTH '\t' $SYM >> foo_table.tbl
				
			else
				CONT=$( echo nucleotide ) 
				
				# Generate output into file
				
				echo -e  $i '\t' $SEQUENCES '\t' $CONT '\t' $FILE_LENGTH '\t' $SYM >> foo_table.tbl
				
			fi
			
			
			
		else	#If there is no header (or the file is empty for example) we do not consider it a fasta file
		        
		        
			echo -e The file $i does not contain fasta information "\n"
			
		fi
		 	
	done
	
	#Print the table to the STDOUT
	
	column -t -s $'\t' foo_table.tbl
	
	echo
	echo -e ${green}'##########################'
	echo -e '   /GLOBAL INFORMATION/   '
	echo -e '##########################'${nc}
		
	# Count the total number of sequences
	echo
	echo The total number of sequences is $(echo $FASTA_FILES | xargs grep ">" | wc -l)
	echo
	#Give the total sequence length of all the files
	
	echo The total length is $(echo $TOTAL_LENGTH)
	
	#Give the example of a file title
	
	echo
	echo -e Now, an example of a sequence title is shown: $(grep -h -m 1 ">" $FASTA_FILES | head -1)
	echo 	
	
fi

rm foo_table.tbl
rm log_error_fastascan.txt
echo
echo -e ${green}'                                                     ***************************'
echo -e '                                                          /REPORT COMPLETED/    '
echo -e '                                                     ***************************'${nc}
echo
