# Only tested on Windows
# Must have ffmpeg in PATH
# Must have Pillow installed: pip install Pillow

import os
import shutil
import subprocess
from PIL import Image

# Compression settings, change to your liking
OGG_QUALITY = -2   # OGG audio quality (-2 = max compression, 10 = low compression)
VIDEO_CRF = 40     # CRF for video compression (0 = low compression, 51 = max compression)
PNG_8BIT = True    # Whether to convert PNGs to 8-bit

compress_images = True
compress_videos = True
compress_sounds = True

input_folder = './assets'
output_folder = './assets-compressed'

def copy_file(file_path, output_dir):
    """Copy file to the output directory."""
    relative_path = os.path.relpath(file_path, input_folder)
    output_path = os.path.join(output_dir, relative_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    shutil.copy(file_path, output_path)
    print(f"Copied file to {output_path}")

def compress_image(file_path, output_dir):
    """Compress PNG"""
    img = Image.open(file_path)
    original_size = os.path.getsize(file_path)

    relative_path = os.path.relpath(file_path, input_folder)
    output_path = os.path.join(output_dir, relative_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    if PNG_8BIT:
        img = img.convert('P')  # Convert to 8-bit

    # Save the image
    img.save(output_path, 'PNG', optimize=True)

    compressed_size = os.path.getsize(output_path)
    print(f"Image {file_path}: {original_size / 1024:.2f} KB -> {compressed_size / 1024:.2f} KB")

    # Revert to the original if compression increased the size
    if compressed_size > original_size:
        shutil.copy(file_path, output_path)
        print(f"Compression increased size, using original")

    return original_size, compressed_size

def compress_audio(file_path, output_dir):
    """Compress OGG files"""
    original_size = os.path.getsize(file_path)

    # Preserve directory structure in the output directory
    relative_path = os.path.relpath(file_path, input_folder)
    output_path = os.path.join(output_dir, relative_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Use libvorbis for OGG files
    codec = "libvorbis"
    options = ['-q:a', str(OGG_QUALITY)]  # Use the defined OGG_QUALITY variable

    # Compress the audio file
    subprocess.run(
        ['ffmpeg', '-y', '-i', file_path, '-codec:a', codec] + options + [output_path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE
    )

    compressed_size = os.path.getsize(output_path)

    # Log the size change
    print(f"Audio {file_path}: {original_size / 1024:.2f} KB -> {compressed_size / 1024:.2f} KB")

    # Revert to the original file if compression increases the size
    if compressed_size > original_size:
        shutil.copy(file_path, output_path)
        print(f"Compression increased size, using original")

    return original_size, compressed_size

def compress_video(file_path, output_dir):
    """Compress video files (MP4, MKV, AVI)."""
    original_size = os.path.getsize(file_path)

    relative_path = os.path.relpath(file_path, input_folder)
    output_path = os.path.join(output_dir, relative_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Use ffmpeg to compress the video
    subprocess.run([
        'ffmpeg', '-y', '-i', file_path, '-vcodec', 'libx264', '-crf', str(VIDEO_CRF), '-preset', 'fast', output_path
    ], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    compressed_size = os.path.getsize(output_path)
    print(f"Video {file_path}: {original_size / 1024:.2f} KB -> {compressed_size / 1024:.2f} KB")

    if compressed_size > original_size:
        shutil.copy(file_path, output_path)
        print(f"Compression increased size, using original")

    return original_size, compressed_size

def compress_files_in_folder(root_dir, output_dir):
    """Walk through the folder and compress media files."""
    total_files = sum([len(files) for _, _, files in os.walk(root_dir)])
    files_processed = 0
    total_original_size = 0
    total_compressed_size = 0

    for root, dirs, files in os.walk(root_dir):
        for file in files:
            file_path = os.path.join(root, file)
            if file.lower().endswith(('png')) and compress_images:
                original_size, compressed_size = compress_image(file_path, output_dir)
            elif file.lower().endswith(('ogg')) and compress_sounds:
                original_size, compressed_size = compress_audio(file_path, output_dir)
            elif file.lower().endswith(('mp4', 'mkv', 'avi')) and compress_videos:
                original_size, compressed_size = compress_video(file_path, output_dir)
            else:
                copy_file(file_path, output_dir)
                original_size = compressed_size = os.path.getsize(file_path)

            total_original_size += original_size
            total_compressed_size += compressed_size

            # Update terminal title with progress
            files_processed += 1
            os.system(f"title {files_processed}/{total_files}")

    size_saved = (total_original_size - total_compressed_size) / (1024 * 1024)
    print(f"\nTotal size saved: {size_saved:.2f} MB")

# Create the output directory
os.makedirs(output_folder, exist_ok=True)

# Compress files
compress_files_in_folder(input_folder, output_folder)

input('Done!')