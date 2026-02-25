/*
 * Runs bowtie2 on the input FASTQ files and produces aligned BAM files as output.
 * Converts bowtie2 output SAM files to BAM format using samtools.
 * TODO: currently assumes paired-end reads, need to add handling for single-end as well
 */

process convertSAM {

    // Use bioconda samtools docker image
    container 'community.wave.seqera.io/library/samtools:1.23--12d9384dd0649f36'

    // Specify the output directory for the samtools results
    publishDir("${params.outdir}/bowtie2/", mode: "copy")

    input:
    tuple val(sample_id), path(alignedSAM)

    output:
    tuple val(sample_id), path("${sample_id}_aligned.bam"), emit: aligned_bam

    script:
    """
    echo "Converting SAM to BAM for ${alignedSAM}"
    samtools view -b ${alignedSAM} -o ${sample_id}_aligned.bam
    """

}


process bowtie2 {
    
    //Use bioconda bowtie2 docker image
    container 'community.wave.seqera.io/library/bowtie2:2.5.5--e6c87d4462b58ff7'

    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the bowtie2 results
    publishDir("${params.outdir}/bowtie2/", mode: "copy")

    input:
    tuple val(sample_id), path(reads)
    tuple val(bowtie2IndexBasename), path(bt2_files)

    output: 
    tuple val(sample_id), path("${sample_id}_aligned.sam"), emit: aligned_sam


    script:
    """
    echo "Running bowtie2 for sample ${sample_id}"

    bowtie2 \
        -x ${bowtie2IndexBasename} \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        -S ${sample_id}_aligned.sam
    """
}

workflow alignReadsBowtie2 {

    take:
    reads_for_alignment_ch
    bowtie2_index_ch

    main:
    bowtie2(reads_for_alignment_ch, bowtie2_index_ch)
    aligned_sam = bowtie2.out.aligned_sam
    bam_out = convertSAM(aligned_sam)

    emit:
    bam_out
}