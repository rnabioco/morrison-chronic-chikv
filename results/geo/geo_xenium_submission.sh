#! /bin/usr/env bash

dat_dir='../xenium/20241212__000859__Morrison_Run1'
sub='20250616_sheridan_xenium'
sums='metadata/geo_xenium_md5sums.txt'

set -o errexit -o pipefail -o nounset -x

mkdir -p "$sub"

# raw data
tmp=$(mktemp tmp.XXXXX)

dirs="$dat_dir/"*__????????_*

for dir in ${dirs[@]}
do
    dir=$(basename "$dir")

    for file in 'transcripts.parquet' "$dat_dir/$dir/"*.ome.tif
    do
        file=$(basename "$file")
        nm=$(echo "$dir" | cut -d '_' -f 5)
        nm="${nm}_${file}"

        ln -sr "$dat_dir/$dir/$file" "$sub/$nm"

        md5sum "$sub/$nm" \
            >> "$tmp"
    done
done

# processed data
ln -sr 'xenium_metadata.tsv.gz' "$sub"

md5sum 'xenium_metadata.tsv.gz' \
    >> "$tmp"

# format md5sums
cat $tmp \
    | awk -v OFS="  " '{gsub("^.*/", "", $2); print}' \
    > $sums

rm $tmp

