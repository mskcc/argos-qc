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
  - /usr/bin/merge_mean_quality_histograms.py

id: generate-qual-files
inputs:
  files:
    type:
      type: array
      items:
        type: array
        items: File
    inputBinding:
      prefix: --files
  rqual_output_filename:
    type: string
    inputBinding:
      prefix: --rqual_outfile
  oqual_output_filename:
    type: string
    inputBinding:
      prefix: --oqual_outfile

outputs:
  rqual_output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.rqual_output_filename;
        }

  oqual_output:
    type: File
    outputBinding:
      glob: |
        ${
            return inputs.oqual_output_filename;
        }
