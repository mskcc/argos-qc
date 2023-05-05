#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool
id: consolidate-files-mixed

requirements:
  - class: InlineJavascriptRequirement

inputs:

  output_directory_name: string

  flatten_directories:
    type: boolean
    default: true

  files:
    type:
      type: array
      items:
        - File
        - string
        - 'null'
    default: []

  directories:
    type:
      type: array
      items:
        - Directory
        - string
        - 'null'
    default: []

outputs:

  directory:
    type: Directory

# This tool returns a Directory object,
# which holds all output files from the list
# of supplied input files
expression: |
  ${
    function addFile(input_file_list, flatten_directories) {
      var output_file_list = [];
      for (var i = 0; i < input_file_list.length; i++) {
        var input_file = input_file_list[i];
        if(input_file){
          if ( input_file["class"] == "File" ){
            output_file_list.push(input_file);
          }
          else if ( input_file["class"] == "Directory" ){
            output_file_list = output_file_list.concat(addDirectory([input_file], flatten_directories));
          }
        }
      }
      return output_file_list;
    }

    function addDirectory(input_directory_list, flatten_directories) {
      var output_file_list = [];
      if ( flatten_directories == true ){
        for (var i = 0; i < input_directory_list.length; i++) {
           for (var j = 0; j < input_directory_list[i].listing.length; j++) {
               var item = input_directory_list[i].listing[j];
               if(item){
                output_file_list = output_file_list.concat(addFile([item],flatten_directories));
               }
           }
        }
      }
      else {
        output_file_list = input_directory_list;
      }
      return output_file_list;
    }

    var output_files = [];
    var output_files_trimmed = [];
    var output_file_basename_dict = {};
    var input_files = inputs.files.filter(single_file => String(single_file).toUpperCase() != 'NONE');
    var input_directories = inputs.directories.filter(single_file => String(single_file).toUpperCase() != 'NONE');
    output_files = output_files.concat(addFile(input_files, inputs.flatten_directories));
    output_files = output_files.concat(addDirectory(input_directories, inputs.flatten_directories));


    for (var i = 0; i < output_files.length; i++) {
      var output_file =  output_files[i];
      var output_file_basename = output_file['basename'];
      if ( !(output_file_basename in output_file_basename_dict)){
        output_file_basename_dict[output_file_basename] = null;
        output_files_trimmed.push(output_file);
      }

    }


    return {
      'directory': {
        'class': 'Directory',
        'basename': inputs.output_directory_name,
        'listing': output_files_trimmed
      }
    };
  }