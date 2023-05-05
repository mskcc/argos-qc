#/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool
baseCommand:
  - python
  - /usr/bin/create_minor_contam_binlist.py

id: create-minor-contam-binlist

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

  minor_contam_file:
    type: File
    inputBinding:
      prefix: --minorcontam

  project_prefix:
    type: string
    inputBinding:
      prefix: --project_prefix

  fp_summary:
    type: File
    inputBinding:
      prefix: --fpsummary

  min_cutoff:
    type: float
    inputBinding:
      prefix: --min_cutoff

outputs:
  minor_contam_freqlist:
    type: File
    outputBinding:
      glob: |
        ${
          return inputs.project_prefix + "_MinorContamFreqList.txt";
        }
