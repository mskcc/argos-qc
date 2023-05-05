#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool
id: consolidate-files-mixed

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string

  directories:
    type:
      type: array
      items:
        - Directory
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

    var input_directories = inputs.directories.filter(single_file => String(single_file).toUpperCase() != 'NONE');
    for (var i = 0; i < input_directories.length; i++) {
      for (var j = 0; j < inputs.directories[i].listing.length; j++) {
           var item = inputs.directories[i].listing[j];
           if(item){
             output_files.push(item);
           }
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
