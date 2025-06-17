#! /bin/usr/env bash

data=('210108_A00405_0331_BHNW52DSXY' '220203_A00405_0525_AHH5HYDSX3')
dat_dir='../../data'
ref_dir='../../ref'
res_dir=('../../results/2021-11-05' '../../results/2022-02-03')
sub='20250616_sheridan_scrnaseq'
sums='metadata/geo_scrnaseq_md5sums.txt'

set -o errexit -o pipefail -o nounset -x

mkdir -p "$sub"

# cellranger matrices
tmp=$(mktemp tmp.XXXXX)

nms=(C1
    C2
    C3
    U1
    U2
    U3)

for res in ${res_dir[@]}
do
    for nm in ${nms[@]}
    do
        run=$(basename $res)
        dir="$res/$nm"
        mat_dir="$res/$nm/outs"
    
        if [ ! -d "$dir" ]
        then
            continue
        fi

        for file in 'filtered_feature_bc_matrix.h5'
        do
            mat="$sub/${run}_${nm}_$file"
    
            ln -sr "$mat_dir/$file" "$mat"
    
            md5sum "$mat" \
                >> "$tmp"
        done
    done
done

# Seurat metadata
for file in *_count_matrix.h5 *_metadata.tsv.gz
do
    ln -sr "$file" "$sub"

    md5sum "$file" \
        >> "$tmp"
done

# fastqs
for dat in ${data[@]}
do
    fq=$dat_dir/$dat/*.*q.gz

    ln -sr $fq "$sub"

    cat "$dat_dir/$dat/md5sums.txt" \
        | sort -k2,2 \
        | awk '$2 !~ ".csv$"' \
        >> $tmp
done

# format md5sums
cat $tmp \
    | awk -v OFS="  " '{gsub("^.*/", "", $2); print}' \
    > $sums

rm $tmp

