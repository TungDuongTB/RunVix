
import os
import re

def remove_comments_from_line(line):
    in_string = None # Can be ' or " or ''' or """
    i = 0
    while i < len(line):
        char = line[i]
        
        # Handle escape characters
        if char == '\\' and in_string:
            i += 2
            continue
            
        # Handle string start/end
        if char in ["'", '"']:
            # Check for triple quotes
            if i + 2 < len(line) and line[i:i+3] == char * 3:
                quote_type = char * 3
                if in_string == quote_type:
                    in_string = None
                    i += 3
                    continue
                elif not in_string:
                    in_string = quote_type
                    i += 3
                    continue
            
            if not in_string:
                in_string = char
            elif in_string == char:
                in_string = None
                
        # Check for //
        if not in_string and char == '/' and i + 1 < len(line) and line[i+1] == '/':
            # Check if it's a URL
            if i >= 5 and line[i-5:i] == "http:":
                i += 2
                continue
            if i >= 6 and line[i-6:i] == "https:":
                i += 2
                continue
            
            # It's a comment!
            return line[:i].rstrip()
            
        i += 1
    return line

def process_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except UnicodeDecodeError:
        try:
            with open(file_path, 'r', encoding='latin-1') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return
    
    new_lines = []
    for line in lines:
        original_line = line.rstrip('\n\r')
        processed_line = remove_comments_from_line(original_line)
        
        if processed_line.strip() == "" and original_line.strip() != "":
            # The line was only a comment, skip it
            continue
            
        new_lines.append(processed_line + '\n')
    
    # Remove excessive blank lines (more than 2 consecutive)
    final_lines = []
    blank_count = 0
    for line in new_lines:
        if line.strip() == "":
            blank_count += 1
        else:
            blank_count = 0
        
        if blank_count <= 2:
            final_lines.append(line)
            
    # Remove trailing empty lines
    while final_lines and final_lines[-1].strip() == "":
        final_lines.pop()
        
    if final_lines:
        # Ensure it ends with a newline if it's not empty
        if not final_lines[-1].endswith('\n'):
            final_lines[-1] += '\n'

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(final_lines)

def find_files(root_dir):
    target_extensions = ('.dart', '.java', '.kt', '.gradle', '.kts', '.cpp', '.h', '.swift', '.cc')
    files_to_process = []
    for root, dirs, files in os.walk(root_dir):
        # Skip some directories
        if '.git' in dirs:
            dirs.remove('.git')
        if '.dart_tool' in dirs:
            dirs.remove('.dart_tool')
        if 'build' in dirs:
            dirs.remove('build')
        if '.agents' in dirs:
            dirs.remove('.agents')
            
        for file in files:
            if file.endswith(target_extensions):
                files_to_process.append(os.path.join(root, file))
    return files_to_process

if __name__ == "__main__":
    root_directory = r"D:\DoAn\Project\RunVix"
    all_files = find_files(root_directory)
    print(f"Found {len(all_files)} files to process.")
    for f in all_files:
        print(f"Processing {f}...")
        process_file(f)
