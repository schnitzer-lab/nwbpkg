# nwbpkg

`nwbpkg` is a package containing functions that act as an interface for cell extraction algorithms to convert outputs into NWB format, either from files or directly from matrices produced after running cell extraction algorithms.

This code was written and tested on MATLAB R2019b and above and should be compatible with newer versions.

## Dependencies
To function properly, this code requires the following packages: 
 - **YamlMATLAB**: https://github.com/ewiger/yamlmatlab
 - **MATNWB**: https://github.com/NeurodataWithoutBorders/matnwb

## Save cell extraction outputs directly to NWB

Cell extraction outputs in the form of a matrix can be directly exported to NWB using the below code. Users can also see the `ciapkg.nwb.saveNeurodataWithoutBorders()` function in CIAtah (https://github.com/bahanonu/ciatah).

```MATLAB
% Get meta data and type of data being saved
metadata = yaml.ReadYaml(['+nwbpkg' filesep 'ExampleMetadata.yml']);
data_type = 'pcaica';

% Grab input images (inputImages, [x y nCells] matrix).
image_masks = inputImages;

% Grab input traces (inputTraces, [nCells time] matrix) from cell extraction.
roi_response_data.ROI_1 = inputTraces;

% Create NWB structure
nwbfile_input_args = nwbpkg.get_input_args(metadata, 'NWBFile');
% Convert to ISO 8601 format
nwbfile_input_args{4} = datestr(nwbfile_input_args{4}, 'yyyy-mm-dd HH:MM:SS');
nwb = NwbFile(nwbfile_input_args{:});
subject_input_args = nwbpkg.get_input_args(metadata, 'Subject');
nwb.general_subject = types.core.Subject(subject_input_args{:});

% Add cell extraction information to the file.
nwb = nwbpkg.add_processed_ophys(nwb, metadata, image_masks, roi_response_data, data_type);

% Export the NWB file.
nwbExport(nwb, outputFilePath);
```

## Convert existing MAT-files to NWB

`nwbpkg.mat2nwb()` converts Schnitzer lab, e.g. CIAtah (https://bahanonu.github.io/ciatah/data/), MATLAB data files to NWB. To execute the code use the command:

```Matlab
nwbpkg.mat2nwb
```

in MATLAB command window. For basic function no other commands are required, and you will be prompted for any additional info. 
 
Alternatively, the following parameters may be used:
 
<code>nwbpkg.matnwb('yamlpath','/examplepath/examplefile.yml')</code>:  manually input the location of the metadata
 yaml file. 
 
<code>nwbpkg.matnwb('datapath','/examplepath/examplefile.mat')</code>: manually input the location of the matlab
 data files. This code was developed and tested with the following file naming conventions:
 
- `*_cellmaxAnalysis.mat` - CELLMax cell extraction.
- `*_extractAnalysis.mat` - EXTRACT cell extraction.
- `*_cnmfAnalysis.mat` - CNMF cell extraction.
- `*_cnmfeAnalysis.mat` - CNMF-e cell extraction.
- `*_emAnalysis.mat` - CELLMax cell extraction (old, use prior).
- `*_pcaicaAnalysis.mat` - PCA-ICA cell extraction.
- `*_roiAnalysis.mat` - Any ROI-based cell extraction or thresholded version of the above algorithms.
 
Other data files may not be compatible.
 
<code>nwbpkg.matnwb('nwbpath','/examplepath/examplefile.nwb')</code>: manually enter the name and location of the
 resulting NWB file.

## Inspecting the output

TO test output files are working, run `nwbpkg.extract_nwb_data`. That function that extracts data from NWB file back to a format usable by other MATLAB functions

## License

Copyright (C) 2019-2021 Biafra Ahanonu, Ben Dichter, Ivan Smalianchuk

This project is licensed under the terms of the MIT license. See LICENSE file for details.