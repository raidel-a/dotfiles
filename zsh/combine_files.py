import os

# Define the output file name
output_file = 'combined_content.txt'

# Open the output file in write mode
with open(output_file, 'w') as outfile:
    # Walk through the current directory and its subdirectories
    for root, dirs, files in os.walk('.'):
        for file in files:
            # Get the full file path
            file_path = os.path.join(root, file)
            # Write the comment with the file path
            outfile.write(f'# File: {file_path}\n')
            # Try to read and write the contents of the file
            try:
                with open(file_path, 'r') as infile:
                    content = infile.read()
                    outfile.write(content + '\n\n')  # Add contents to output file
            except Exception as e:
                outfile.write(f'# Error reading file: {file_path} - {e}\n\n')

print(f"Combined contents of all files have been written to {output_file}")
