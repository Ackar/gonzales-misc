#! /bin/bash

GIF=$1

ffmpeg -i $GIF -r 24 -crf 18 -an -pix_fmt yuv420p ${GIF%.*}.webm
