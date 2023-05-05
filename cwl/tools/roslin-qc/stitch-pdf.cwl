#!/usr/bin/env cwl-runner
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: $(inputs.data_dir.listing)
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-roslin-qc:0.6.4

class: CommandLineTool
baseCommand:
  - java
  - -jar
  - /usr/bin/QCPDF.jar
id: stitch-pdf

inputs:

  data_dir:
    type: Directory

  request_file:
    type: File
    inputBinding:
      prefix: -rf

  version:
    type: float
    default: 1.0
    inputBinding:
      prefix: -v

  images_dir:
    type: [ 'null', string ]
    default: "."
    inputBinding:
      prefix: -d

  output_directory:
    type: [ 'null', string ]
    default: "."
    inputBinding:
      prefix: -o

  cov_warn_threshold:
    type: [ 'null', int ]
    default: 200
    inputBinding:
      prefix: -cw

  cov_fail_threshold:
    type: [ 'null', int ]
    default: 50
    inputBinding:
      prefix: -cf

  pl:
    type: string
    default: "Variants"
    inputBinding:
      prefix: -pl

outputs:
  compiled_pdf:
    type: File
    outputBinding:
      glob: "*.pdf"

