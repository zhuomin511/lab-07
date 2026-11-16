

# Loop through all 4 test case folders one by one.
for folder in Testcase1 Testcase2 Testcase3 Testcase4
do
    # Define the name of the output folder.
    out_directory="${folder}Diff"
    
    # Remove the old output folder if it exists. This ensures that running the script 
    # multiple times always gives the same result.
    rm -rf "$out_directory"
    
    # Change directory into the current test folder. 
    # If it doesn't exist, skip the rest of this loop iteration.
    cd "$folder" || continue
    
    # Loop through every file ending in ".1.txt" in the current directory.
    for file in *.1.txt
    do
        # If no ".1.txt" files exist, the loop will treat "*.1.txt" as a literal string.
        # This checks if the file actually exists. If not, skip to the next iteration.
        [ -e "$file" ] || continue
        
        # Create the matching ".2.txt" filename using string manipulation.
        # It removes the ".1.txt" suffix from the variable $file, and adds ".2.txt".
        file2="${file%.1.txt}.2.txt"
        
        # Check if the corresponding ".2.txt" file actually exists.
        # "-f" means "is a regular file".
        if [ -f "$file2" ]; then
            # Run the unified diff command and save the output to a temporary file.
            # "diff -u" shows the differences. If the files are identical, the output is empty.
            diff -u "$file" "$file2" > temp_diff.txt
            
            # Check if the temporary diff file has content.
            # "-s" means "file exists and has a size greater than zero" (i.e., is not empty).
            # If it's not empty, it means the two files ARE different.
            if [ -s temp_diff.txt ]; then
                
                # If differences exist, create the output directory (only if it hasn't been created yet).
                # "-d" checks if it is a directory.
                if [ ! -d "../$out_directory" ]; then
                    mkdir "../$out_directory"
                fi
                
                # Move the temporary diff file into the output directory.
                # We rename it to match the required format, e.g., "Version1Diff.txt".
                # ${file%.1.txt} strips the ".1.txt" part, leaving just the base name.
                mv temp_diff.txt "../${out_directory}/${file%.1.txt}Diff.txt"
            else
                # If the temporary file is empty (no differences found), 
                # delete the temp file so it doesn't clutter the workspace.
                rm temp_diff.txt
            fi
        fi
    done
    
    # Move back up to the main lab-07 directory to process the next Testcase folder.
    cd ..
done