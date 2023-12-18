#! /usr/bin/env bash

#BSUB -J cellranger
#BSUB -o logs/cellranger_%J.out
#BSUB -e logs/cellranger_%J.err
#BSUB -R "select[mem>4] rusage[mem=4]"
#BSUB -q rna

set -o nounset -o pipefail -o errexit -x

module load cellranger/6.0.1

mkdir -p logs

run_snakemake() {
    local config_file=$1
    
    drmaa_args='
        -o {log.out}
        -e {log.err}
        -J {params.job_name} 
        -R "{params.memory} span[hosts=1]"
        -R "select[hname!=compute16]"
        -R "select[hname!=compute19]"
        -n {threads} '

    snakemake \
        --snakefile Snakefile \
        --drmaa "$drmaa_args" \
        --jobs 300 \
        --latency-wait 60 \
        --configfile $config_file
}

# joint tissue 2021-11-05
run_snakemake src/configs/2021-11-05.yaml

# joint tissue CHIKV enrichment re-sequencing 2022-02-03 and 2021-12-22
run_snakemake src/configs/2022-02-03.yaml

