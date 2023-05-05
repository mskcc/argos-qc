#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: Workflow
id: qc-merge-and-hotspots
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  bams:
    type:
      type: array
      items: File
    secondaryFiles: [^.bai]
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
  project_prefix: string
  fp_genotypes: File
  pairing_file: File
  hotspot_list_maf: File
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
  genome: string
  grouping_list: string[]

outputs:

  merged_mdmetrics:
    type: File
    outputSource: qc_merge/merged_mdmetrics

  merged_hsmetrics:
    type: File
    outputSource: qc_merge/merged_hsmetrics

  merged_hstmetrics:
    type: File
    outputSource: qc_merge/merged_hstmetrics

  merged_insert_size_histograms:
    type: File
    outputSource: qc_merge/merged_insert_size_histograms

  fingerprints_output:
    type: File[]
    outputSource: qc_merge/fingerprints_output

  fingerprint_summary:
    type: File
    outputSource: qc_merge/fingerprint_summary

  qual_files_r:
    type: File
    outputSource: qc_merge/qual_files_r

  qual_files_o:
    type: File
    outputSource: qc_merge/qual_files_o

  hs_portal_fillout:
    type: File
    outputSource: hotspots_fillout/portal_fillout

  hs_in_normals:
    type: File?
    outputSource: run_hotspots_in_normals/hs_in_normals

  minor_contam_freqlist:
    type: File
    outputSource: run_minor_contam_binlist/minor_contam_freqlist

  qc_merged_directory:
    type: Directory
    outputSource: compiled_output_directory/directory

steps:

  qc_merge:
    run: qc-merge.cwl
    in:
      md_metrics: md_metrics
      hs_metrics: hs_metrics
      per_target_coverage: per_target_coverage
      grouping_list: grouping_list
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
      project_prefix: project_prefix
      fp_genotypes: fp_genotypes
      pairing_file: pairing_file
    out: [ merged_mdmetrics, merged_hsmetrics, merged_hstmetrics, merged_insert_size_histograms, fingerprints_output, fingerprint_summary, minor_contam_output, qual_files_r, qual_files_o ]

  hotspots_fillout:
    run: ../cmo-utils/1.9.15/cmo-fillout.cwl
    in:
      maf: hotspot_list_maf
      bams: bams
      ref_fasta: ref_fasta
      output_format:
        valueFrom: ${ return "1"; }
      project_prefix: project_prefix
    out: [ portal_fillout ]

  run_hotspots_in_normals:
    run: create-hotspots-in-normals.cwl
    in:
      fillout_file: hotspots_fillout/portal_fillout
      project_prefix: project_prefix
      pairing_file: pairing_file
    out: [ hs_in_normals ]

  run_minor_contam_binlist:
    run: create-minor-contam-binlist.cwl
    in:
      minor_contam_file: qc_merge/minor_contam_output
      fp_summary: qc_merge/fingerprint_summary
      min_cutoff:
        default: 0.01
      project_prefix: project_prefix
    out: [ minor_contam_freqlist ]

  compiled_output_directory:
    run: ../consolidate-files/consolidate-files.cwl
    in:
      merged_files: [ qc_merge/merged_mdmetrics, qc_merge/merged_hsmetrics, qc_merge/merged_hstmetrics, qc_merge/merged_insert_size_histograms, qc_merge/fingerprint_summary, qc_merge/minor_contam_output, qc_merge/qual_files_r, qc_merge/qual_files_o, run_hotspots_in_normals/hs_in_normals, run_minor_contam_binlist/minor_contam_freqlist ]
      fp_output: qc_merge/fingerprints_output
      files:
        source: [ qc_merge/merged_mdmetrics, qc_merge/merged_hsmetrics, qc_merge/merged_hstmetrics, qc_merge/merged_insert_size_histograms, qc_merge/fingerprint_summary, qc_merge/minor_contam_output, qc_merge/qual_files_r, qc_merge/qual_files_o, run_hotspots_in_normals/hs_in_normals, run_minor_contam_binlist/minor_contam_freqlist, qc_merge/fingerprints_output ]
        linkMerge: merge_flattened
      output_directory_name:
        valueFrom: ${ return "qc_merged_directory"; }
    out: [ directory ]
