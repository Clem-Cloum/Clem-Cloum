#!/usr/bin/env bash
# Découpe les rushes (HEVC iPhone) en clips H.264 utilisés par index.html.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p assets/cut
E="-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 -movflags +faststart"

# Gauche (pull vert) : réplique 1, image figée pendant la réponse, réplique finale
ffmpeg -v error -y -i assets/video1.MOV -t 6.6 $E -c:a aac -b:a 192k assets/cut/gauche-1.mp4
ffmpeg -v error -y -ss 6.55 -i assets/video1.MOV -frames:v 1 -q:v 2 assets/cut/gauche-1-fin.jpg
ffmpeg -v error -y -i assets/video4.MOV -t 20.6 $E -c:a aac -b:a 192k assets/cut/gauche-4.mp4

# Droite (haut rayé) : écoute en aller-retour bouclé, puis réponse
ffmpeg -v error -y -i assets/video2.MOV -filter_complex "[0:v]split[a][b];[b]reverse[r];[a][r]concat=n=2:v=1:a=0[v]" -map "[v]" $E -an assets/cut/pp.mp4
ffmpeg -v error -y -stream_loop 4 -i assets/cut/pp.mp4 -t 36 $E -an assets/cut/droite-ecoute.mp4
rm assets/cut/pp.mp4
ffmpeg -v error -y -ss 0.4 -i assets/video3.mov -t 3.1 $E -c:a aac -b:a 192k assets/cut/droite-3.mp4
