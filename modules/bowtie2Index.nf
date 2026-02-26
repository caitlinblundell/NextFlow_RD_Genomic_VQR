/*
 * Builds a bowtie index from a reference genome FASTA file, which is then used by the bowtie2 process for alignment.
 * Warning: this process currently builds a small bowtie2 index, assuming ref genome is below 4bn bases.
 */

process bowtie2Index {

    //Use bioconda bowtie2 docker image
    container 'community.wave.seqera.io/library/bowtie2:2.5.5--e6c87d4462b58ff7'

    // Add a tag to identify the process
    tag "$referenceFasta"

    // Specify the output directory for the bowtie2 results
    publishDir("${params.outdir}/bowtie2Index/", mode: "copy")

    input:
    path(referenceFasta)

    output:
    // Emit all files with .bt2/.bt21 extension in one channel along with basename for bowtie2 alignment
    tuple val(indexBasename), path("*.bt2*"), emit: bowtie2_index

    script:

    //Compute index basename
    indexBasename = referenceFasta.baseName

    """
    echo "Building bowtie2 index for reference genome ${referenceFasta}"
    echo "Index basename: ${indexBasename}"

    bowtie2-build ${referenceFasta} ${indexBasename} -p 8
    """
}