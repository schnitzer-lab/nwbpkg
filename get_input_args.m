function input_args = get_input_args(metadata_struct, object_name)

aa = ReadYaml('matnwb_map.yml');

fields = aa.(object_name);
input_args = {};
for i = 1:length(fields)
    if isa(fields{i}, 'cell')
        meta_match = fields{i}{1};
        key = fields{i}{2};
    else
        meta_match = fields{i};
        key = fields{i};
    end
    if isfield(metadata_struct, fields{i})
        value = metadata_struct.(fields{i});
        if isa(value, 'DateTime')
            value = datetime(datestr(value));
        end
        if any(key) && any(value)
            input_args{end+1} = key;
            input_args{end+1} = value;
        end
    end
end


end