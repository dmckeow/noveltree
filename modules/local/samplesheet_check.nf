process SAMPLESHEET_CHECK {
    tag "$complete_samplesheet"

    conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"
    
    // TODO: FOR SOME REASON THIS MODULE OUTPUTS TO "PIPELINE_INFO" BUT THE MCL_SAMPLESHEET_CHECK OUTPUTS TO ITS OWN DIRECTORY. 
    // SPECIFYNG PUBLISHDIR BELOW DOESN'T SEEM TO FIX IT?
    //publishDir(
    //    path: "${params.outdir}/complete_dataset",
    //    mode: 'copy',
    //    saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    //)

    input:
    path s3_dir // Path to the directory on S3 containing all proteomes
    path complete_samplesheet // Samplesheet formatted as described in the README

    output:
    path '*.csv'                 , emit: csv     // Checked samplesheet
    path '*.fasta'               , emit: fasta   // Per-species proteomes
    path '*orthofinder_prep.txt' , emit: of_prep // Path to directory containing data formatted for Orthofinder
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This python script is bundled with the pipeline, in phylorthology/bin/

    """
    check_samplesheet.py \\
        $complete_samplesheet \\
        complete_samplesheet.valid.csv
        
    # Copy the S3 files to the publishdir, adding this as a column to the 
    # samplesheet
    # NOTE: If the full S3 paths are provided (rather than the filename, 
    # and S3 directory given separately as done here), nextflow will not 
    # recognize the files as being from S3.
    samps=\$(tail -n+2 complete_samplesheet.valid.csv | cut -f2 -d",")
    
    echo "fpath" > fpaths.txt # Instantiate with a header
    
    # Loop through, combining the S3 directory with the fasta filename and 
    # adding this column to the file
    for samp in \$(echo \$samps)
    do
        cp $s3_dir/\$samp .
        echo \$(pwd)/\$samp >> fpaths.txt
    done
    paste -d"," complete_samplesheet.valid.csv fpaths.txt > tmp
    mv tmp complete_samplesheet.valid.csv
    
    # And write out the base filepath where data is stored to file so we can 
    # use this when preparing for orthofinder 
    pwd > complete_orthofinder_prep.txt
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
