#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: generate-qc
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


outputs:

  consolidated_results:
    type: Directory
    outputSource: consolidate_metrics/directory
  qc_pdf:
    type: File
    outputSource: generate_qc/qc_pdf


steps:

  create_pairing_file:
      in:
        normal_sample_names: normal_sample_names
        tumor_sample_names: tumor_sample_names
        echoString:
          valueFrom: ${ var pairString = inputs.normal_sample_names[0] + "\t" + inputs.tumor_sample_names[0]; for (var i=1; i<inputs.normal_sample_names.length; i++) { pairString=pairString + "\n" + inputs.normal_sample_names[i] + "\t" + inputs.tumor_sample_names[i]; } return pairString; }
        output_filename:
          valueFrom: ${ return "tn_pairing_file.txt"; }
      out: [ pairfile ]
      run:
        class: CommandLineTool
        baseCommand: ['echo', '-e']
        id: create_TN_pair
        stdout: $(inputs.output_filename)
        requirements:
          InlineJavascriptRequirement: {}
          MultipleInputFeatureRequirement: {}
          DockerRequirement:
            dockerPull: alpine:3.8
        inputs:
          normal_sample_names: string[]
          tumor_sample_names: string[]
          echoString:
            type: string
            inputBinding:
              position: 1
          output_filename: string
        outputs:
          pairfile:
            type: stdout
  run-contamination:
    run: ./tools/conpair/0.3.3/conpair-contaminations.cwl
    in:
      pileups: conpair_pileups
      npileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][1]); } return output; }
      tpileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][0]); } return output; }
      markers: conpair_markers
      pairing_file: create_pairing_file/pairfile
      output_prefix: project_prefix
    out: [ outfiles, pdf ]

  run-concordance:
    run: ./tools/conpair/0.3.3/conpair-concordances.cwl
    in:
      normal_homozygous:
        valueFrom: ${ return true; }
      pileups: conpair_pileups
      npileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][1]); } return output; }
      tpileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][0]); } return output; }
      markers: conpair_markers
      pairing_file: create_pairing_file/pairfile
      project_prefix: project_prefix
      output_prefix:
        valueFrom: ${ return inputs.project_prefix + "_homo"; }
    out: [ outfiles, pdf ]

  run-concordance-non-homozygous:
    run: ./tools/conpair/0.3.3/conpair-concordances.cwl
    in:
      normal_homozygous:
        valueFrom: ${ return false; }
      pileups: conpair_pileups
      npileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][1]); } return output; }
      tpileup:
        valueFrom: ${ var output = []; for (var i=0; i<inputs.pileups.length; i++) { output=output.concat(inputs.pileups[i][0]); } return output; }
      markers: conpair_markers
      pairing_file: create_pairing_file/pairfile
      project_prefix: project_prefix
      output_prefix:
        valueFrom: ${ return inputs.project_prefix + "_nohomo"; }
    out: [ outfiles, pdf ]

  put-conpair-files-into-directory:
    run: ./tools/conpair/0.3.3/consolidate-conpair-files.cwl
    in:
      files:
        source: [ run-concordance/outfiles, run-concordance-non-homozygous/outfiles, run-contamination/outfiles ]
        linkMerge: merge_flattened
      output_directory_name:
        valueFrom: ${ return "conpair_output_files"; }
    out: [ directory ]

  qc_merge_and_hotspots:
    run: ./tools/roslin-qc/qc-merge-and-hotspots.cwl
    in:
      normal_bams: normal_bams
      tumor_bams: tumor_bams
      normal_sample_names: normal_sample_names
      tumor_sample_names: tumor_sample_names
      ref_fasta: ref_fasta
      bams:
        valueFrom: ${ var output = [];  for (var i=0; i<inputs.normal_bams.length; i++) { output=output.concat(inputs.normal_bams[i]); } for (var i=0; i<inputs.tumor_bams.length; i++) { output=output.concat(inputs.tumor_bams[i]); } return output; }
      grouping_list:
        valueFrom: ${ var output = []; var group=0; for (var i=0; i<inputs.normal_sample_names.length; i++) { var singleSample = inputs.normal_sample_names[i] + ":" + group.toString(); output=output.concat(singleSample); group++; } for (var i=0; i<inputs.tumor_sample_names.length; i++) { var singleSample = inputs.tumor_sample_names[i] + ":" + group.toString(); output=output.concat(singleSample); group++; } return output; }
      hs_metrics: hs_metrics
      md_metrics: md_metrics
      per_target_coverage: per_target_coverage
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
      project_prefix: project_prefix
      fp_genotypes: fp_genotypes
      pairing_file: create_pairing_file/pairfile
      hotspot_list_maf: hotspot_list_maf
      genome: genome
    out: [ qc_merged_directory ]
  generate_images:
    run: ./tools/roslin-qc/generate-images.cwl
    in:
      data_dir:  qc_merge_and_hotspots/qc_merged_directory
      file_prefix: project_prefix
    out: [ output, images_directory, project_summary, sample_summary ]
  consolidate_intermediate_files:
    run: ./tools/consolidate-files/consolidate-files-list.cwl
    in:
      hs_metrics: hs_metrics
      md_metrics: md_metrics
      per_target_coverage: per_target_coverage
      insert_metrics: insert_metrics
      doc_basecounts: doc_basecounts
      qual_metrics: qual_metrics
      file_lists:
        valueFrom: ${ var intermediate_metrics = []; intermediate_metrics=intermediate_metrics.concat(inputs.hs_metrics, inputs.md_metrics, inputs.per_target_coverage, inputs.insert_metrics, inputs.doc_basecounts, inputs.qual_metrics); return intermediate_metrics; }
      output_directory_name:
        valueFrom: ${ return "intermediate_metrics"; }
    out: [ directory ]
  consolidate_results:
    run: ./tools/consolidate-files/consolidate-files-mixed.cwl
    in:
      output_directory_name:
        valueFrom: ${ return "consolidated_metrics"; }
      input_directories: directories
      conpair_directory: put-conpair-files-into-directory/directory
      qc_merged_and_hotspots_directory: qc_merge_and_hotspots/qc_merged_directory
      generate_images_directory: generate_images/output
      files: files
      directories:
        valueFrom: ${ var metrics_data = [inputs.qc_merged_and_hotspots_directory, inputs.generate_images_directory, inputs.conpair_directory]; return metrics_data.concat(inputs.input_directories); }
    out: [ directory ]
  consolidate_metrics:
    run: ./tools/consolidate-files/consolidate-files-mixed.cwl
    in:
      consolidated_metrics: consolidate_intermediate_files/directory
      consolidated_results: consolidate_results/directory
      output_directory_name:
        valueFrom: ${ return "qc_metrics"; }
      directories:
        valueFrom: ${ return [inputs.consolidated_metrics, inputs.consolidated_results]}
      flatten_directories:
        valueFrom: ${ return false; }
    out: [directory]
  generate_qc:
    run: ./tools/roslin-qc/genlatex.cwl
    in:
      data_dir: consolidate_results/directory
      assay: assay
      pi: pi
      pi_email: pi_email
      project_prefix: project_prefix
    out: [ qc_pdf ]
