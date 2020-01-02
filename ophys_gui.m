f_size = [200,200,700,700];

f = uifigure('Visible','off','Position', f_size);

field_map = ReadYaml('matnwb_map.yml');
field_handles = containers.Map;


% general

field_handles = make_group(f, field_map.NWBFile, ...
    [10, 295, 325, 355], 'NWBFile', field_handles);

field_handles = make_group(f, field_map.Subject, ...
    [10, 70, 325, 210], 'Subject', field_handles);

% ophys
ophys_fields = [field_map.ImagingPlane, field_map.OpticalChannel, ...
    field_map.PlaneSegmentation, field_map.Device];

field_handles = make_group(f, ophys_fields, ...
    [350, 300, 325, 350], 'ophys', field_handles);

load_button = uibutton(f, 'Position', [10, 675, 100, 25], ...
    'Text', 'Load Metadata', ...
    'ButtonPushedFcn', @(btn,event) load_metadata(btn, field_handles));

save_button = uibutton(f, 'Position', [120, 675, 100, 25], ...
    'Text', 'Save Metadata', ...
    'ButtonPushedFcn', @(btn,event) save_metadata(btn, field_handles));

text_handle = uieditfield(f, 'Position', [440, 675, 200, 25]);

locate_ophys_button = uibutton(f, 'Position', [230, 675, 200, 25], ...
    'Text', 'Locate Processed Ophys', ...
    'ButtonPushedFcn', @(btn,event) locate_processed_ophys(btn, text_handle));

nwb_save_button = uibutton(f, 'Position', [10,10,100,25], ...
    'Text', 'Save NWB', ...
    'ButtonPushedFcn', @(btn,event) save_nwb(btn, text_handle.Value, field_handles));


f.Visible = 'on';


function load_metadata(btn, field_handles)
fpath = uigetfile('*.yml');
metadata = ReadYaml(fpath);
fields_list = fields(metadata);
for i = 1:length(fields_list)
    if ~field_handles.isKey(fields_list{i})
        keyboard
    end
    h = field_handles(fields_list{i});
    value = metadata.(fields_list{i});
    if isa(value, 'DateTime')
        value = datestr(value);
    elseif isa(value, 'cell')
        value = strjoin(value, ';');
    end
    try
        h.Value = string(value);
    catch
        keyboard
    end
end
end


function locate_processed_ophys(btn, edit_handle)
[file, path] = uigetfile('*.mat');
edit_handle.Value = [path, file];
end

function save_metadata(btn, field_handles)
fpath = uiputfile('*.yml');
metadata = construct_metadata_struct(field_handles);
WriteYaml(fpath, metadata)
end

function field_handles = make_group(f, fields, panel_pos, title, field_handles)

p = uipanel(f, 'Position', panel_pos, 'Scrollable', true);
p.Title = title;

start = [10, panel_pos(4) - 50, 150, 25];
gap = 25;

for i = 1:length(fields)
    
    if isa(fields{i}, 'cell')
        show_text = fields{i}{1};
    else
        show_text = fields{i};
    end
    lbl = uilabel(p, 'HorizontalAlignment','right', ...
        'Position', start - [0,1,0,0] * gap * (i-1));
    lbl.Text = [show_text ':'];
    
    field_handles(show_text) = uieditfield(p, ...
        'HorizontalAlignment','left', ...
        'Position', start - [0,1,0,0] * gap * (i-1) + [160,0,-20,0]);
end

end

function metadata = construct_metadata_struct(field_handles)
metadata = struct;
keys = field_handles.keys;
for i = 1:length(keys)
    key = keys{i};
    handle = field_handles(key);
    value = handle.Value;
    if any(strcmp(key, {'keywords','experimenter'})) && ...
            contains(value, ';')
        value = strsplit(value, ';');
    elseif strcmp(key, {'sesssion_start_time', 'date_of_birth'})
        value = datenum(value);
    elseif isfinite(str2double(value))
        value = str2double(value);
    end
    metadata.(key) = value;
end

end

function save_nwb(btn, data_path, field_handles)

fpath = uiputfile('*.nwb');
metadata = construct_metadata_struct(field_handles);
[image_masks, roi_response_data] = extract_nwb_data(data_path);
nwb = init_nwb_session(metadata);
nwb = add_processed_ophys(nwb, metadata, image_masks, roi_response_data);
nwbExport(nwb, fpath);

end