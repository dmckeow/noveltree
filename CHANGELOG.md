# Arcadia-Science/noveltree: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* Added apptainer profile with
```
apptainer.enabled      = true
apptainer.autoMounts   = true
```
* Added specific apptainer workflow setting for apptainer e.g.
    * This was done for:
        * all modules in modules/local

```
container "${ workflow.containerEngine == 'apptainer' ? 'arcadiascience/bioservices_1.10.0:1.0.0' : 
    '' }"

    to

container "${ workflow.containerEngine == 'apptainer' ? 'arcadiascience/bioservices_1.10.0:1.0.0' : 
                workflow.containerEngine == 'docker' ? 'arcadiascience/bioservices_1.10.0:1.0.0' :
    '' }"
```
* Commented out a line in modules/local/witch.nf that was intended to fix root permissions problem with docker, which is fixed by simply using apptainer
```
//containerOptions = "--user root"
```

#### Running Noveltree
```
nextflow run . -profile apptainer -params-file https://github.com/Arcadia-Science/test-datasets/raw/main/noveltree/tsar_downsamp_test_parameters.json  --max_cpus 8 --max_memory 30GB
```

## v1.0.1-alpha - 09/28/2023

Release of NovelTree that is associated with the pub ["NovelTree: Highly parallelized phylogenomic inference"](https://doi.org/10.57844/arcadia-z08x-v798). Includes small bug fix caused by including the `xref_tigrfam` return field when querying UniProt. 

## v1.0.0-alpha - 09/27/2023

Initial release of NovelTree. Do not use - this version is deprecated in favor of v1.0.1-alpha.
