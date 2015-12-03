#!/bin/bash

#All-Pairs Nearest Neighbors for N Images already stored in SciDB as an Image Volume

#Rank a maxiumum of MAX_RANK images
MAX_RANK=5

#Check Command Line Agruments
if [ $# -eq 0 ]
  then
    echo "Please specify a directory containing input arguments"
    exit 1
fi

#Clear SciDB
python ../image_average/python/clear_scidb.py

echo "Using Dataset: $1"

#Load images from first command-line argument
./image_load.py $1

#Assuming Volume of Images are already in SciDB under the name of image_volume
#Cross-Product of all images in the volume.
echo "DataSet, Cross Join, APNN Computation"
JOIN=$({ /usr/bin/time -f "%e" iquery -nq "SELECT * INTO image_pairs FROM image_volume as iv1 JOIN image_volume as iv2 ON iv1.i0 = iv2.i0 AND iv1.i1 = iv2.i1 AND iv1.i2 = iv2.i2;" > /dev/null; } 2>&1 )

#APNN Query on Image Cross-Product
APNN=$({ /usr/bin/time -f "%e" iquery -naq "store(knn(aggregate(apply(image_pairs, f0_square, pow(f0-f0_2,2)),sum(f0_square),i3,i3_2),$MAX_RANK),image_ranks);" > /dev/null; } 2>&1 )

echo "$1,$JOIN,$APNN"
