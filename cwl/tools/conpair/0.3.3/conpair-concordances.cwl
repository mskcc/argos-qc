#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool
baseCommand:
  - python
  - /usr/bin/conpair/scripts/verify_concordances.py

id: conpair-concordance
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
  normal_homozygous:
    type: boolean
    default: true
    inputBinding:
      prefix: --normal_homozygous_markers_only

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

  output_prefix:
    type: string
    inputBinding:
      prefix: --outpre

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing

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
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_concordance*.*")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_concordance*.*";
          return null;
        }

  pdf:
    type: File?
    outputBinding:
      glob: |
        ${
          if (inputs.output_directory_name + "/" + inputs.output_prefix + "_concordance*.pdf")
            return inputs.output_directory_name + "/" + inputs.output_prefix + "_concordance*.pdf";
          return null;
        }
