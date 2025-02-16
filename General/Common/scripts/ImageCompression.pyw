import sys
import os
import subprocess
import shutil
import time

def compress_image(file_path):
    base_name = os.path.splitext(os.path.basename(file_path))[0]
    extension = os.path.splitext(file_path)[1]
    temp_file_path = os.path.join(os.getenv('TEMP'), f"{base_name}_{int(time.time())}{extension}")

    try:
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        result = subprocess.run(['ffmpeg', '-nostats', '-loglevel', '0', '-i', file_path, temp_file_path], check=True, startupinfo=startupinfo)
        if result.returncode == 0:
            original_size = os.path.getsize(file_path)
            compressed_size = os.path.getsize(temp_file_path)
            if compressed_size < original_size:
                os.remove(file_path)
                shutil.move(temp_file_path, file_path)
            else:
                os.remove(temp_file_path)
                print(f"Compressed file is larger than the original for {file_path}, skipping replacement.")
        else:
            print(f"Error compressing file {file_path}")
    except subprocess.CalledProcessError:
        print(f"Error compressing file {file_path}")

if __name__ == "__main__":
    for file_path in sys.argv[1:]:
        compress_image(file_path)
