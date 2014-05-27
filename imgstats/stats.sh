#! /bin/bash

MOZJPEG_PATH=~/mozjpeg/

if [ ! -d optimgs ]; then
  mkdir optimgs
fi
rm -f optimgs/*

cd imgs

nb=0
totalsize=0
totalrsize=0

echo "Compressing PNGs..."
for i in *.png; do
  ## PNG CRUSH ##
  #pngcrush $i ../optimgs/$i

  ## PNG QUANT ##
  pngquant --skip-if-larger -o ../optimgs/$i $i
  if [ ! -e ../optimgs/$i ]; then
    cp $i ../optimgs/$i
  fi

  ## OPTIPNG ##
  #optipng -fix -dir ../optimgs  -o 5 $i

  s1=`ls -l $i | cut -d ' ' -f 8`
  totalsize=$(($totalsize + $s1))
  s2=`ls -l ../optimgs/$i | cut -d ' ' -f 8`
  totalrsize=$(($totalrsize + $s2))

  nb=$(($nb + 1))
done

echo "----- PNG Stats ------"
echo "Total size before / after:" $(($totalsize / 1000)) "/" $(($totalrsize / 1000))
echo "Size reduction: " $((100 -  ($totalrsize * 100) / $totalsize)) '%'

nb=0
totalsize=0
totalrsize=0
echo "Compressing JPEGs..."
for i in *.jpeg; do
  ## MOZJPEG (quality = 90) ##
  $MOZJPEG_PATH/djpeg -outfile ../optimgs/$i.bmp $i
  $MOZJPEG_PATH/cjpeg -quality 90 -outfile ../optimgs/$i ../optimgs/$i.bmp

  ## MOZJPEG (jpegtran) ##
  $MOZJPEG_PATH/jpegtran -optimize -outfile ../optimgs/$i $i

  ## JPEGOPTIM ##
  #jpegoptim -d ../optimgs/ $i
  #if [ ! -e ../optimgs/$i ]; then
  #  cp $i ../optimgs//$i
  #fi

  s1=`ls -l $i | cut -d ' ' -f 8`
  totalsize=$(($totalsize + $s1))
  s2=`ls -l ../optimgs/$i | cut -d ' ' -f 8`
  totalrsize=$(($totalrsize + $s2))

  nb=$(($nb + 1))
done

echo "----- JPG Stats ------"
echo "Total size before / after:" $(($totalsize / 1000)) "/" $(($totalrsize / 1000))
echo "Size reduction: " $((100 -  ($totalrsize * 100) / $totalsize))

nb=0
totalsize=0
totalrsize=0
echo "Compressing GIFs..."
for i in *.gif; do
  gifsicle -O3 --output ../optimgs/$i $i

  s1=`ls -l $i | cut -d ' ' -f 8`
  totalsize=$(($totalsize + $s1))
  s2=`ls -l ../optimgs/$i | cut -d ' ' -f 8`
  totalrsize=$(($totalrsize + $s2))

  nb=$(($nb + 1))
done

echo "----- GIF Stats ------"
echo "Total size before / after:" $(($totalsize / 1000)) "/" $(($totalrsize / 1000))
echo "Size reduction: " $((100 -  ($totalrsize * 100) / $totalsize))
