process SAMPLESHEET_CHECK {
    tag "$complete_samplesheet"

    container "${ workflow.containerEngine == 'docker' ? 'quay.io/biocontainers/python:3.9--1': 
        workflow.containerEngine == 'apptainer' ? 'quay.io/biocontainers/python:3.9--1':
    '' }"

    input:
    path complete_samplesheet // Samplesheet formatted as described in the README

    output:
    path '*.csv'        , emit: csv
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This python script is bundled with the pipeline, in bin/
    """
    check_samplesheet.py \\
        $complete_samplesheet \\
        complete_samplesheet.valid.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
