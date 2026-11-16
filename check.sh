

# This variable will track the overall result. 
# 0 means tests passed, 1 means at least one test failed.
status=0

# Loop through the 4 test cases
for num in 1 2 3 4
do
    # Setup folder names
    folder="Testcase$num"
    out_directory="${folder}Diff"
    fail=0 # Tracks if the current test case fails 
    
    # Enter the original test folder. If it doesn't exist, skip.
    cd "$folder" || continue
    
    # Loop through all .1.txt files in this folder
    for file in *.1.txt
    do
        # Skip if the file doesn't exist (handles empty directories)
        [ -e "$file" ] || continue
        
        # Get the matching filename
        file2="${file%.1.txt}.2.txt"
        
        # Only proceed if the file exists
        if [ -f "$file2" ]; then
            # Generate the  diff output into a temporary file
            diff -u "$file" "$file2" > temp_actual.txt
            
            # This is the path where the diff file located
            expected_diff="../${out_directory}/${file%.1.txt}Diff.txt"
            
            # Check if the diff output has content (meaning the files are different)
            if [ -s temp_actual.txt ]; then
                # --- SCENARIO: Files are DIFFERENT ---
                
                # The diff file must exist. If it doesn't, script.sh failed to create it.
                if [ ! -f "$expected_diff" ]; then
                    fail=1
                else
                    # If it exists, verify its content.
                    # We use "tail -n +3" to skip the first 2 lines of the diff output 
                    # (which contain file paths and timestamps that change on every run).
                    tail -n +3 temp_actual.txt > actual_content.txt
                    tail -n +3 "$expected_diff" > expected_content.txt
                    
                    # Compare the  versions to see if the text matches.
                    if ! diff -q actual_content.txt expected_content.txt > /dev/null; then
                        fail=1 # Content mismatch
                    fi
                    
                    # Clean up the temporary comparison files
                    rm -f actual_content.txt expected_content.txt
                fi
            fi
            # Clean up the temp file created by the diff command
            rm temp_actual.txt
        fi
    done
    
    # Go back to the main lab-07 directory
    cd ..
    
    #Remove unused folder if it's empty ---
    # If no failures were detected, but a Diff folder exists, we must verify it's not there by mistake.
    if [ $fail -eq 0 ] && [ -d "$out_directory" ]; then
        has_content=0
        # Loop through all files in the Diff directory
        for f in "$out_directory"/*; do
            [ -e "$f" ] || continue
            # If any file has content, flag it
            if [ -s "$f" ]; then
                has_content=1
            fi
        done
        
        # If the folder only contained empty files, script.sh was supposed to delete it.
        # We delete it here to align with the expected correct output state.
        if [ $has_content -eq 0 ]; then
            rm -r "$out_directory"
        fi
    fi
    
    # Print the final result for this specific test case
    if [ $fail -eq 1 ]; then
        echo "Testcase$num: FAIL"
        status=1 # Mark overall failure
    else
        echo "Testcase$num: PASS"
    fi
done

# Exit with the correct status code. 
# 0 for all pass, 1 if any test failed.
exit $status