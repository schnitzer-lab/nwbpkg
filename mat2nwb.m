function mat2nwb(nwbPath,varargin)
% defined inputs and input parser
defaultYmlPath='manual';
defaultDataPath='manual';
defaultDataType='manual';

p=inputParser;
addRequired(p,'nwbPath')
addParameter(p, 'ymlPath', defaultYmlPath)
addParameter(p, 'dataType', defaultDataType)
addParameter(p,'dataPath', defaultDataPath)
parse(p,nwbPath,varargin{:})

if strcmp(p.Results.ymlPath,'manual')
    fpathYAML = uigetfile('*.yml');
else
    fpathYAML=p.Results.ymlPath;
end

metadata = ReadYaml(fpathYAML);

field_map = ReadYaml('matnwb_map.yml');
field_handles = containers.Map;

% populate field_handles

allfields=[...
    [field_map.NWBFile] [field_map.Subject]...
    [field_map.ImagingPlane] [field_map.OpticalChannel]...
    [field_map.PlaneSegmentation] [field_map.Device]...
    ];

for i=1:length(allfields)
    if isa(allfields{i}, 'cell')
        needed_fields=char(allfields{i}(1));
    else
        needed_fields=char(allfields(i));
    end
    if isfield(metadata,needed_fields)
        field_handles(needed_fields)=metadata.(needed_fields);
    else
        field_handles(needed_fields)='';
    end
end

if strcmp(p.Results.dataPath,'manual')
    [file,path] = uigetfile('*.mat');
    data_path = fullfile(path,file);
else
    data_path=p.Results.dataPath;
end

if strcmp(p.Results.nwbPath,'manual')
    fpath = uiputfile('*.nwb');
else
    fpath = p.Results.nwbPath;
end

if strcmp(p.Results.dataType,'manual')
    if contains(data_path,'extract')
        data_type='extract';
    elseif contains(data_path,'cnmf') && ~contains(data_path,'cnmfe')
        data_type='cnmf';
    elseif contains(data_path,'cnmfe')
        data_type='cnmfe';
    elseif contains(data_path,'em')
        data_type='em';
    end
else
    data_type = p.Results.dataType;
end

metadata = construct_metadata_struct(field_handles);
[image_masks, roi_response_data] = extract_nwb_data_cnmfe(data_path, data_type);
nwb = init_nwb_session(metadata);
nwb = add_processed_ophys(nwb, metadata, image_masks, roi_response_data);
nwbExport(nwb, fpath);

    function metadata = construct_metadata_struct(field_handles)
        metadata = struct;
        keys = field_handles.keys;
        for i = 1:length(keys)
            key = keys{i};
            handle = field_handles(key);
            value = handle;
            if any(strcmp(key, {'keywords','experimenter'})) && ...
                    any(contains(value, ';'))
                value = strsplit(value, ';');
            elseif strcmp(key, {'sesssion_start_time', 'date_of_birth'})
                value = datenum(value);
            elseif isfinite(str2double(value))
                value = str2double(value);
            end
            metadata.(key) = value;
        end
        
    end
end
