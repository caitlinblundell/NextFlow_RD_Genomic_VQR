/*
 * Runs fastp on the input FASTQ files and produces processed FASTQ files as output.
 */

 process fastp {

    // Use biocontainer fastp docker image
    container 'community.wave.seqera.io/library/fastp:1.1.0--08aa7c5662a30d57'

    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the fastp results
    publishDir("${params.outdir}/fastp/${sample_id}", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    // Name outputs using emit so they are output in separate channels and can be referenced easily in the workflow
    output:
    tuple val(sample_id), path("trimmed_${sample_id}_R*.fastq.gz") emit: trimmed_reads
    path "fastp_${sample_id}.html" emit: html
    path "fastp_${sample_id}.json" emit: json

    script:

    // run fastp based on if the sample is paired-end or single-end
    if (reads.size() == 2) {
        """
        fastp \
            -i ${reads[0]} \
            -I ${reads[1]} \
            -o trimmed_${sample_id}_R1.fastq.gz \
            -O trimmed_${sample_id}_R2.fastq.gz \
            --html fastp_${sample_id}.html \
            --json fastp_${sample_id}.json

        echo "fastp complete with paired reads for sample ${sample_id}"
        """
    }

    else {
        """
        fastp \
            -i ${reads[0]} \
            -o trimmed_${sample_id}_R1.fastq.gz \
            --html fastp_${sample_id}.html \
            --json fastp_${sample_id}.json

        echo "fastp complete with single-end reads for sample ${sample_id}"
        """
    }

    echo "fastp complete for sample ${sample_id}"
}