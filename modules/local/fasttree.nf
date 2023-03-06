process FASTTREE {
    tag "$alignment"
    label 'process_fasttree'

    // container "${ workflow.containerEngine == 'docker' ? 'arcadiascience/magus_0.1.0:0.0.1':
    //     '' }"
    container "${ workflow.containerEngine == 'docker' ? 'austinhpatton123/magus_0.1.0:0.0.1':
        '' }"

    input:
    path(alignment)
    val model // not used

    output:
    path("*.treefile")  , emit: phylogeny
    path(alignment)     , emit: msa
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    """
    og=\$(echo $alignment | cut -f1 -d "_")
    
    # Efficiently infer a gene family tree using FastTree!
    /MAGUS/magus_tools/fasttree/FastTreeMP \\
        $args \\
        $alignment > \${og}_ft.treefile
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        FastTree: \$(/MAGUS/magus_tools/fasttree/FastTreeMP | head -n1 | cut -d" " -f5)
    END_VERSIONS
    """
}
