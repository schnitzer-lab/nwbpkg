function mat2nwb_ivan(varargin)

%% write an nwb file

metadata = ReadYaml(fpathYAML);
fields_list = fields(metadata);

field_map = ReadYaml('matnwb_map.yml');
field_handles = containers.Map;

% populate field_handles

fields=[...
    [field_map.NWBFile] [field_map.Subject]...
    [field_map.ImagingPlane] [field_map.OpticalChannel]...
    [field_map.PlaneSegmentation] [field_map.Device]...
    ];

for i=1:length(fields)
    if isa(fields{i}, 'cell')
        needed_fields=char(fields{i}(1));
    else
        needed_fields=char(fields(i));
    end
    if isfield(metadata,needed_fields)
        field_handles(needed_fields)=metadata.(needed_fields);
    else
        field_handles(needed_fields)='';
    end
end

data_path='D:\Downloads\2014_04_01_p203_m19_check01_cnmfeAnalysis.mat';

% fpath = uiputfile('*.nwb');
fpath = 'test.nwb';
metadata = construct_metadata_struct(field_handles);
[image_masks, roi_response_data] = extract_nwb_data_cnmfe(data_path);
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
