process ORTHOFINDER_PREP {
    tag "Prepping data for OrthoFinder"
    label 'process_low'

    container "${ workflow.containerEngine == 'docker' ? 'arcadiascience/orthofinder_2.5.4:1.0.0' :
        workflow.containerEngine == 'apptainer' ? 'arcadiascience/orthofinder_2.5.4:1.0.0' :
        '' }"

    publishDir(
        path: "${params.outdir}/orthofinder",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

    input:
    path(fastas, stageAs: 'input/')
    val output_directory

    output:
    path "**.dmnd"           , emit: diamonds
    path "**.fa"             , emit: fastas
    path "**SequenceIDs.txt" , emit: seqIDs
    path "**SpeciesIDs.txt"  , emit: sppIDs
    path "versions.yml"      , emit: versions

    script:
    """
    # The fasta directory depends on whether we're running the mcl testing or not.
    orthofinder \\
        -f input/ \\
        -t ${task.cpus} \\
        -op > tmp

    mkdir ${output_directory} && mv input/OrthoFinder/ ${output_directory}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        orthofinder: \$(orthofinder --versions | head -n2 | tail -n1 | sed "s/OrthoFinder version //g" | sed "s/ Copyright (C) 2014 David Emms//g")
    END_VERSIONS
    """
}
