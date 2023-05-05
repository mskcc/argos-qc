#/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool
baseCommand:
  - python
  - /usr/bin/create_cdna_contam.py
id: create-cdna-contam

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-roslin-qc:0.6.4

doc: |
  None

inputs:

  input_mafs:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --input_mafs

  project_prefix:
    type: string
    inputBinding:
      prefix: --project_prefix

outputs:
  cdna_contam_output:
    type: File
    outputBinding:
      glob: |
        ${
          return inputs.project_prefix + "_cdna_contamination.txt";
        }
