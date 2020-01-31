function mat2nwb(varargin)

% MAT2NWB: convert Schnitzer matlab data to NWB data
%
% MAT2NWB() promts the user for a metadata yaml file, corresponding
% .mat file and resulting .nwb file name and location.
%
% MAT2NWB('nwbpath','example.nwb','yamlpath','example.yml','datapath','example.mat')
% executes the function without gui prompts for file names. Any missing
% parameter will prompt the user for its location.
%
% Following packages are required:
% - YAMLMATLAB: https://github.com/ewiger/yamlmatlab
% - MATNWB: https://github.com/NeurodataWithoutBorders/matnwb
%
% Compatible matlab files:
% - *cnmfeAnalysis.mat
% - *extractAnalysis.mat
%

defaultNWBpath='manual';
defaultYamlPath='manual';
defaultDataPath='manual';

p=inputParser;
addParameter(p, 'nwbpath', defaultNWBpath)
addParameter(p, 'yamlpath', defaultYamlPath)
addParameter(p, 'datapath', defaultDataPath)
parse(p,varargin{:})

if strcmp(p.Results.yamlpath,'manual')
    fpathYML = uigetfile('*.yml','YAML file with metadata');
else
    fpathYML=p.Results.yamlpath;
end

metadata = ReadYaml(fpathYML);

if strcmp(p.Results.datapath,'manual')
    [file,path] = uigetfile('*.mat','matlab file with data');
    data_path = fullfile(path,file);
else
    data_path=p.Results.datapath;
end

if strcmp(p.Results.nwbpath,'manual')
    fpath = uiputfile('*.nwb','location and name of NWB file');
else
    fpath = p.Results.nwbpath;
end

if contains(data_path,'extract')
    data_type='extract';
elseif contains(data_path,'cnmf') && ~contains(data_path,'cnmfe')
    data_type='cnmf';
elseif contains(data_path,'cnmfe')
    data_type='cnmfe';
elseif contains(data_path,'em')
    data_type='em';
end


[image_masks, roi_response_data] = extract_nwb_data(data_path, data_type);

nwbfile_input_args = get_input_args(metadata, 'NWBFile');
nwb = NwbFile(nwbfile_input_args{:});

subject_input_args = get_input_args(metadata, 'Subject');
nwb.general_subject = types.core.Subject(subject_input_args{:});

nwb = add_processed_ophys(nwb, metadata, image_masks, roi_response_data);
nwbExport(nwb, fpath);

end
