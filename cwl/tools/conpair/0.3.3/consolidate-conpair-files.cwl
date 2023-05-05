#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool
id: consolidate-conpair-files

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string

  files:
    type:
      type: array
      items:
        - File
        - string
        - 'null'

outputs:

  directory:
    type: Directory

# This tool returns a Directory object,
# which holds all output files from the list
# of supplied input files
expression: |
  ${
    var output_files = [];

    var input_files = inputs.files.filter(single_file => String(single_file).toUpperCase() != 'NONE');

    for (var i = 0; i < input_files.length; i++) {
      if(input_files[i]){
        output_files.push(input_files[i]);
      }
    }

    return {
      'directory': {
        'class': 'Directory',
        'basename': inputs.output_directory_name,
        'listing': output_files
      }
    };
  }
