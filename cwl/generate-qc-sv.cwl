#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: generate-qc-sv
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  ref_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  normal_bams:
    type:
      type: array
      items: File
    secondaryFiles: [^.bai]
  tumor_bams:
    type:
      type: array
      items: File
    secondaryFiles: [^.bai]
  normal_sample_names: string[]
  tumor_sample_names: string[]
  project_prefix: string
  genome: string
  assay: string
  pi: string
  pi_email: string
  fp_genotypes: File
  hotspot_list_maf: File
  conpair_markers: string
  md_metrics:
    type:
      type: array
      items:
        type: array
        items: File
  hs_metrics:
    type:
      type: array
      items:
        type: array
        items: File
  insert_metrics:
    type:
      type: array
      items:
        type: array
        items: File
  per_target_coverage:
    type:
      type: array
      items:
        type: array
        items: File
  qual_metrics:
    type:
      type: array
      items:
        type: array
        items: File
  doc_basecounts:
    type:
      type: array
      items:
        type: array
        items: File
  conpair_pileups:
    type:
      type: array
      items:
        type: array
        items: File
  directories:
    type:
      type: array
      items: Directory
  files:
    type:
      type: array
      items: File
  mafs:
    type:
      type: array
      items: File


outputs:

  consolidated_results:
    type: Directory
    outputSource: generate_qc/consolidated_results
  qc_pdf:
    type: File
    outputSource: generate_qc/qc_pdf


steps:

  run_cdna_contam_check:
    run: ./tools/roslin-qc/create-cdna-contam.cwl
    in:
      input_mafs: mafs
      project_prefix: project_prefix
    out: [ cdna_contam_output ]

  generate_qc:
    run: generate-qc.cwl
    in:
      fp_genotypes: fp_genotypes
      hotspot_list_maf: hotspot_list_maf
      conpair_markers: conpair_markers
      normal_bams: normal_bams
      tumor_bams: tumor_bams
      normal_sample_names: normal_sample_names
      tumor_sample_names: tumor_sample_names
      project_prefix: project_prefix
      genome: genome
      assay: assay
      pi: pi
      pi_email: pi_email
      ref_fasta: ref_fasta
      md_metrics: md_metrics
      hs_metrics: hs_metrics
      insert_metrics: insert_metrics
      per_target_coverage: per_target_coverage
      qual_metrics: qual_metrics
      doc_basecounts: doc_basecounts
      conpair_pileups: conpair_pileups
      cdna_contam_output: run_cdna_contam_check/cdna_contam_output
      files:
        valueFrom: ${ return [inputs.cdna_contam_output]; }
      directories:
        valueFrom: ${ return []; }
    out: [consolidated_results,qc_pdf]
