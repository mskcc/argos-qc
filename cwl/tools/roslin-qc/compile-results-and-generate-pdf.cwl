#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: Workflow
id: gather-metrics
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  db_files:
    type:
      type: record
      fields:
        refseq: File
        ref_fasta: string
        vep_path: string
        custom_enst: string
        vep_data: Directory
        hotspot_list: string
        hotspot_list_maf: File
        hotspot_vcf: string
        facets_snps: File
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: string
        conpair_markers_bed: string
        grouping_file: File
        request_file: File
        pairing_file: File

  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates:
          type:
            type: array
            items: string
        emit_original_quals: boolean
        genome: string
        mutect_dcov: int
        mutect_rf:
          type:
            type: array
            items: string
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        scripts_bin: string

  qc_merged_directory:
    type:
      type: array
      items: File

outputs:

  # qc
  compiled_metrics_data:
    type: Directory
    outputSource: group_data/directory
  pdf_report:
    type: File
    outputSource: stitch_together_pdf/compiled_pdf

steps:

  generate_pdf:
    run: ./generate-images.cwl
    in:
      runparams: runparams
      db_files: db_files
      data_dir: qc_merged_directory
      bin:
        valueFrom: ${ return inputs.runparams.scripts_bin; }
      file_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
    out: [ output, images_directory, project_summary, sample_summary ]

  group_data:
    run: ../consolidate-files/consolidate-files-mixed.cwl
    in:
      runparams: runparams
      project_summary: generate_pdf/project_summary
      sample_summary: generate_pdf/sample_summary
      image_dir: generate_pdf/images_directory
      output_directory_name:
        valueFrom: ${ return "compiled_metrics_data"; }
      directories:
        valueFrom: ${ var all_dirs = new Array(); all_dirs.push(inputs.image_dir); return all_dirs; }
      files:
        valueFrom: ${ var all_files = new Array(); all_files.push(inputs.project_summary); all_files.push(inputs.sample_summary); return all_files; }
    out: [ directory ]

  stitch_together_pdf:
    run: ./stitch-pdf.cwl
    in:
      runparams: runparams
      db_files: db_files
      file_prefix:
        valueFrom: ${ return inputs.runparams.project_prefix; }
      request_file:
        valueFrom: ${ return inputs.db_files.request_file; }
      data_dir: group_data/directory
    out: [ compiled_pdf ]
