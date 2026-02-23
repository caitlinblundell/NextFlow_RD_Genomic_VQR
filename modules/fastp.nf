/*
 * Runs fastp on the input FASTQ files and produces processed FASTQ files as output.
 */

 process fastp {

    container 'community.wave.seqera.io/library/fastp:1.1.0--08aa7c5662a30d57'

    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the fastp results
    publishDir("${params.outdir}/fastp/${sample_id}", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("fastp_${sample_id}_R*.fastq.gz")

    script:
    """
    echo "Running fastp for sample ${sample_id}"

    fastp -i ${reads[0]} -I ${reads[1]} \
          -o fastp_${sample_id}_R1.fastq.gz \
          -O fastp_${sample_id}_R2.fastq.gz \

    echo "fastp complete for sample ${sample_id}"
    """
}