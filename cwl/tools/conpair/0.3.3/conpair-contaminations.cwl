#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool
baseCommand:
  - python
  - /usr/bin/conpair/scripts/estimate_tumor_normal_contaminations.py

id: conpair-contamination
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 16000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-conpair:0.3.3

doc: |
  None

inputs:
  tpileup:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --tumor_pileup

  npileup:
    type:
      type: array
      items: File
    inputBinding:
      prefix: --normal_pileup

  markers:
    type:
    - [File, string]
    inputBinding:
      prefix: --markers

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing

  output_prefix:
    type: string
    inputBinding:
      prefix: --outpre

  output_directory_name:
    type: string
    default: "."
    inputBinding:
      prefix: --outdir

outputs:
  outfiles:
    type: File[]?
    outputBinding:
      glob: |
        ${
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.*")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.*";
          return null;
        }

  pdf:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.pdf")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_contamination*.pdf";
          return null;
        }
