#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool
id: consolidate-reads

requirements:
  - class: InlineJavascriptRequirement

inputs:

  reads_dir: Directory

outputs:

  r1: File[]
  r2: File[]

expression: |
  ${
    var r1_files = [];
    var r2_files = [];

    for (var i = 0; i < inputs.reads_dir.listing.length; i++) {
      var current_file_obj = inputs.reads_dir.listing[i];
      if (current_file_obj.class == "Directory"){
        for (var j = 0; j < current_file_obj.listing.length; j++) {
          var current_fastq = current_file_obj.listing[j];
          if ( current_fastq.basename.includes("_R1_")){
            r1_files.push(current_fastq);
          }
          else if ( current_fastq.basename.includes("_R2_")){
            r2_files.push(current_fastq);
          }
        }
      }
    }

    return {
      'r1': r1_files,
      'r2': r2_files
    };
  }
