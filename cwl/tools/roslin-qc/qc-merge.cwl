#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: Workflow
id: qc_merge
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
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
  per_target_coverage:
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
  doc_basecounts:
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
  project_prefix: string
  fp_genotypes: File
  pairing_file: File
  grouping_list: string[]

outputs:
  merged_mdmetrics:
    type: File
    outputSource: merge_mdmetrics/output

  merged_hsmetrics:
    type: File
    outputSource: merge_hsmetrics/output

  merged_hstmetrics:
    type: File
    outputSource: merge_hstmetrics/output

  merged_insert_size_histograms:
    type: File
    outputSource: merge_insert_size_histograms/output

  fingerprints_output:
    type: File[]
    outputSource: generate_fingerprint/output

  fingerprint_summary:
    type: File
    outputSource: generate_fingerprint/fp_summary

  minor_contam_output:
    type: File
    outputSource: generate_fingerprint/minor_contam_output

  qual_files_r:
    type: File
    outputSource: generate_qual_files/rqual_output

  qual_files_o:
    type: File
    outputSource: generate_qual_files/oqual_output

steps:

  merge_mdmetrics:
    in:
      files: md_metrics
      project_prefix: project_prefix
      outfile_name:
        valueFrom: ${ return inputs.project_prefix + "_markDuplicatesMetrics.txt"; }
    out: [ output ]
    run: ./merge-picard-metrics-markduplicates.cwl

  merge_hsmetrics:
    in:
      files: hs_metrics
      project_prefix: project_prefix
      outfile_name:
        valueFrom: ${ return inputs.project_prefix + "_HsMetrics.txt"; }
    out: [ output ]
    run: ./merge-picard-metrics-hsmetrics.cwl

  merge_hstmetrics:
    in:
      files: per_target_coverage
      project_prefix: project_prefix
      outfile_name:
        valueFrom: ${ return inputs.project_prefix + "_GcBiasMetrics.txt"; }
    out: [ output ]
    run: ./merge-gcbias-metrics.cwl

  merge_insert_size_histograms:
    in:
      files: insert_metrics
      project_prefix: project_prefix
      outfile_name:
        valueFrom: ${ return inputs.project_prefix + "_InsertSizeMetrics_Histograms.txt"; }
    out: [ output ]
    run: ./merge-insert-size-histograms.cwl

  generate_fingerprint:
    in:
      files: doc_basecounts
      file_prefix: project_prefix
      fp_genotypes: fp_genotypes
      grouping_list: grouping_list
      pairing_file: pairing_file
    out: [ output, fp_summary, minor_contam_output ]
    run: ./generate-fingerprint.cwl

  generate_qual_files:
    in:
      project_prefix: project_prefix
      files: qual_metrics
      rqual_output_filename:
        valueFrom: ${ return inputs.project_prefix + "_post_recal_MeanQualityByCycle.txt"; }
      oqual_output_filename:
        valueFrom: ${ return inputs.project_prefix + "_pre_recal_MeanQualityByCycle.txt"; }
    out: [ rqual_output, oqual_output ]
    run: ./generate-qual-files.cwl
