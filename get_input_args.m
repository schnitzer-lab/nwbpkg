function input_args = get_input_args(metadata_struct, object_name)

% aa = ReadYaml('matnwb_map.yml');

fields = metadata_struct.(object_name);

input_args = {};
for i = 1:length(fields)
    if isa(fields{i}, 'cell')
        if isa(fields{i}{1},'struct')
            if isempty(fields{i}{1}.(char(fieldnames(fields{i}{1}))))
                fields{i}{1}.(char(fieldnames(fields{i}{1})))='empty';
            end
            input_args{end+1} = fields{i}{2};
            
            input_args{end+1} = fields{i}{1}.(char(fieldnames(fields{i}{1})));
        else
            input_args{end+1} = fields{i}{1};
            input_args{end+1} = fields{i}{2};
        end
    else
        try
            if isempty(fields{i}.(char(fieldnames(fields{i}))))
                fields{i}.(char(fieldnames(fields{i})))='empty';
            end
        end
        try
            if strcmp(fieldnames(fields{i}),'session_start_time');
                fields{i}.(char(fieldnames(fields{i})))=datetime(fields{i}.(char(fieldnames(fields{i}))));
            end
        end
        input_args{end+1} = char(fieldnames(fields{i}));
        input_args{end+1} = fields{i}.(char(fieldnames(fields{i})));
    end
end
% for i=1:length(input_args)
%     if isa(input_args{i},'numeric')
%         input_args{i}=num2str(input_args{i});
%     end
% end

end