# MAT2NWB 

mat2nwb converts Schnitzer lab MATLAB datafiles to NWB.  
This code was written and tested on MATLAB R2019b, compatability will vary for other versions.

## Dependencies
To function properly, this code requires the following packages: 
 - **YamlMATLAB**: https://github.com/ewiger/yamlmatlab
 - **MATNWB**: https://github.com/NeurodataWithoutBorders/matnwb


## Usage

To execude the code use the command <code>mat2nwb</code> in MATLAB command window. 
 For basic function no other commands are required, and you will be prompted for any additional
 info. 
 
 Alternatively, the following parameters may be used:
 
 <code>matnwb('yamlpath','/examplepath/examplefile.yml')</code>:  manually input the location of the metadata
 yaml file. 
 
 <code>matnwb('datapath','/examplepath/examplefile.mat')</code>: manually input the location of the matlab
 data files. This code was developed and tested with the following file naming conventions:
 
 *_cnmfAnalysis.mat
 *_cnmfeAnalysis.mat
 *_extractAnalysis.mat
 *_emAnalysis.mat
 
 Other datafiles may not be compatible
 
 <code>matnwb('nwbpath','/examplepath/examplefile.nwb')</code>: manually enter the name and location of the
 resulting NWB file.
 

## Inspecting the output

extract_nwb_data.m is a basic example function that extracts data from NWB file back to the matlab format. 
