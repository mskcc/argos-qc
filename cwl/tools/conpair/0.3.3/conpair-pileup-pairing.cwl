#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: ExpressionTool

requirements:
  InlineJavascriptRequirement: {}

inputs:

  tpileups:
    type:
        type: array
        items: File

  npileups:
    type:
        type: array
        items: File

outputs:
  tpileup_ordered:
    type:
        type: array
        items: File

  npileup_ordered:
    type:
        type: array
        items: File

expression: '${
function dict_files(pileup_data) {
    var d = {};
    for (var i = 0; i < pileup_data.length; i++){
        var fname = pileup_data[i].basename;
        if (!(fname in d)){
                d[fname] = {};
                d[fname] = {"path": pileup_data[i]};
        };
    };
    return d;
}

function pair(d1, d2){
        var results = [];
        for (var key1 in d1){
            var p1 = d1[key1];
            for (var key2 in d2){
                var p2 = d2[key2];
              results.push([p1,p2]);
        };
    };
    return results;
}

function ordered_results(data){
  var project_object = {};
  project_object["tpileup_ordered"] = [];
  project_object["npileup_ordered"] = [];
  for (var i = 0; i < data.length; i++){
      var tpath = data[i][0]["path"];
      var npath = data[i][1]["path"];
      project_object["tpileup_ordered"].push(tpath);
      project_object["npileup_ordered"].push(npath);
  };
  return project_object;
}

var t = dict_files(inputs.tpileups);
var n = dict_files(inputs.npileups);

var pairs = pair(t,n);
var project_object = ordered_results(pairs);
return project_object;
}'
