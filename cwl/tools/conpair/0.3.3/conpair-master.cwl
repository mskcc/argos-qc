#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: Workflow
id: conpair-master

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:

  ref:
    type:
    - [File, string]
    secondaryFiles:
      - ^.dict
      - ^.fasta.fai
  tumor_bams:
    type:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
  normal_bams:
    type:
        type: array
        items: File
    secondaryFiles:
      - ^.bai
  normal_sample_name: string[]
  tumor_sample_name: string[]
  markers:
      type:
      - [File, string]
  gatk_jar_path:
      type:
      - [File, string]
  markers_bed:
      type:
      - [File, string]
  pairing_file:
      type:
      - [File, string]
  file_prefix: string
  runparams:
    type:
      type: record
      fields:
        gatk_jar_path: string
        tmp_dir: string


outputs:

  conpair_output_dir:
      type: Directory
      outputSource: put-conpair-files-into-directory/directory

  contamination_pdf:
      type: File
      outputSource: run-contamination/pdf

  concordance_pdf:
      type: File
      outputSource: run-concordance/pdf

steps:
   run-pileups-contamination:
     in:
        tumor_bam: tumor_bams
        normal_bam: normal_bams
        tumor_sample_name: tumor_sample_name
        normal_sample_name: normal_sample_name
        ref: ref
        markers: markers
        markers_bed: markers_bed
        runparams: runparams
        gatk_jar_path: gatk_jar_path
        java_temp:
          valueFrom: ${ return inputs.runparams.tmp_dir; }
     out: [ tpileout, npileout ]
     scatter: [ tumor_bam, normal_bam, tumor_sample_name, normal_sample_name ]
     scatterMethod: dotproduct
     run:
        class: Workflow
        inputs:
           tumor_bam: File
           normal_bam: File
           ref:
               type: File
               secondaryFiles:
                 - ^.dict
                 - ^.fasta.fai
           gatk_jar_path: string
           java_temp: string
           markers: string
           markers_bed: string
           tumor_sample_name: string
           normal_sample_name: string
        outputs:
           tpileout:
                type: File
                outputSource: run-pileup-tumor/out_file
           npileout:
                type: File
                outputSource: run-pileup-normal/out_file
        steps:
           run-pileup-tumor:
             run: conpair-pileup.cwl
             in:
                 bam: tumor_bam
                 ref: ref
                 gatk: gatk_jar_path
                 java_temp: java_temp
                 markers_bed: markers_bed
                 java_xmx:
                     valueFrom: ${ return ["24g"]; }
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

           run-pileup-normal:
             run: conpair-pileup.cwl
             in:
                 bam: normal_bam
                 ref: ref
                 gatk: gatk_jar_path
                 java_temp: java_temp
                 markers_bed: markers_bed
                 java_xmx:
                     valueFrom: ${ return ["24g"]; }
                 outfile:
                     valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
             out: [out_file]

   pair-pileups:
     run: conpair-pileup-pairing.cwl
     in:
        tpileups: run-pileups-contamination/tpileout
        npileups: run-pileups-contamination/npileout
     out: [ tpileup_ordered, npileup_ordered ]

   run-contamination:
     run: conpair-contaminations.cwl
     in:
        tpileup: pair-pileups/tpileup_ordered
        npileup: pair-pileups/npileup_ordered
        markers: markers
        pairing_file: pairing_file
        output_prefix: file_prefix
     out: [ outfiles, pdf ]

   run-concordance:
     run: conpair-concordances.cwl
     in:
        tpileup: pair-pileups/tpileup_ordered
        npileup: pair-pileups/npileup_ordered
        markers: markers
        pairing_file: pairing_file
        output_prefix: file_prefix
     out: [ outfiles, pdf ]

   put-conpair-files-into-directory:
     in:
       concordance_files: run-concordance/outfiles
       contamination_files: run-contamination/outfiles
       files:
         valueFrom: ${ return inputs.concordance_files.concat(inputs.contamination_files); }
       output_directory_name:
         valueFrom: ${ return "conpair_output_files"; }
     out: [ directory ]
     run: consolidate-conpair-files.cwl
