#!/bin/bash
# Invokes awww with a random file from /home/tokosan/media/images/wallpapers/

ls /home/tokosan/media/images/wallpapers/ |sort -R |tail -1 |while read file; do
    # Something involving $file, or you can leave
    # off the while to just get the filenames
    echo $file
    awww img /home/tokosan/media/images/wallpapers/$file --transition-type=center --transition-fps=165
done
