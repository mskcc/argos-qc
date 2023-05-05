#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool
id: consolidate-files-list

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string

  file_lists:
    type:
      type: array
      items:
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
# of supplied input file_lists
expression: |
  ${
    var output_files_list = [];
    function addFile(input_file_list) {
      var output_files = [];
      var input_files = input_file_list.filter(single_file => String(single_file).toUpperCase() != 'NONE');
      for (var i = 0; i < input_file_list.length; i++) {
        if(input_files[i]){
          output_files.push(input_file_list[i]);
        }
      }
      return output_files;
    }
    for (var i = 0; i < inputs.file_lists.length; i++) {
      if(inputs.file_lists[i]){
        output_files_list = output_files_list.concat(addFile(inputs.file_lists[i]));
      }

    }

    return {
      'directory': {
        'class': 'Directory',
        'basename': inputs.output_directory_name,
        'listing': output_files_list
      }
    };
  }
