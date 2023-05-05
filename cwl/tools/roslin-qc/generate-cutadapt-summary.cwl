#/usr/bin/env cwl-runner
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 8000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-roslin-qc:0.6.4

class: CommandLineTool
baseCommand:
  - python
  - /usr/bin/merge_cut_adapt_stats.py

id: generate-cutadapt-summary.cwl
inputs:

  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

    inputBinding:
      prefix: --clstats1

  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File
    inputBinding:
      prefix: --clstats2

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing_file


  output_filename:
    type: string
    inputBinding:
      prefix: --output

outputs:
  output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.output_filename;
        }
