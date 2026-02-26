/*
 * Runs FreeBayes on the aligned BAM files to perform variant calling and produces VCF files as output.
 */

process freeBayes {

    // Use bioconda FreeBayes docker image
    container 'community.wave.seqera.io/library/freebayes:1.3.10--a4e01a89d7090203'

    // Specify the output directory for the FreeBayes results
    publishDir("${params.outdir}/freeBayes/", mode: "copy")

    input:
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path referenceFasta

    output:
    tuple val(sample_id), file("${sample_id}.vcf")

    script:
    """
 
    """

}