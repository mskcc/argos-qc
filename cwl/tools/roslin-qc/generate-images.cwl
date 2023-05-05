#/usr/bin/env cwl-runner
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
  - Rscript
  - /usr/bin/qc_summary.R
id: generate-images

inputs:

  bin:
    type: string
    default: "/usr/bin/"
    inputBinding:
      prefix: --bin

  data_dir:
    type: Directory

  output_dir:
    type: string
    default: "images/"
    inputBinding:
      prefix: --output_dir

  input_dir:
    type: [ 'null', string ]
    default: "."
    inputBinding:
      prefix: --path

  file_prefix:
    type: string
    inputBinding:
      prefix: --pre

  log:
    type: string
    default: "qcPDF.log"
    inputBinding:
      prefix: --logfile

  minor_contam_threshold:
    type: [ 'null', float ]
    default: 0.02
    inputBinding:
      prefix: --minor_contam_threshold

  major_contam_threshold:
    type: [ 'null', float ]
    default: 0.55
    inputBinding:
      prefix: --major_contam_threshold

  duplication_threshold:
    type: ['null', int ]
    default: 80
    inputBinding:
      prefix: --dup_rate_threshold

  cov_warn_threshold:
    type: [ 'null', int ]
    default: 200
    inputBinding:
      prefix: --cov_warn_threshold

  cov_fail_threshold:
    type: [ 'null', int ]
    default: 50
    inputBinding:
      prefix: --cov_fail_threshold

outputs:
  output:
    type: Directory
    outputBinding:
      glob: "."

  images_directory:
    type: Directory
    outputBinding:
      glob: "images"

  project_summary:
    type: File
    outputBinding:
      glob: "*_ProjectSummary.txt"

  sample_summary:
    type: File
    outputBinding:
      glob: "*_SampleSummary.txt"
