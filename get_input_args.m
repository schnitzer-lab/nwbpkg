function input_args = get_input_args(metadata_struct, object_name)

if ~isempty(object_name)
    workingStruct = metadata_struct.(object_name);
else
    workingStruct = metadata_struct;
end

if isa(workingStruct,'cell')
    fields=fieldnames(workingStruct{1});
    workingStruct=workingStruct{1};
else
    fields=fieldnames(workingStruct);
end

if strcmp(object_name,'ImagingPlanes')
    workingStruct=rmfield(workingStruct,'optical_channels');
    fields(strcmp(fields,'optical_channels'))=[];
    fields(strcmp(fields,'name'))=[];
end
    fields(strcmp(fields,'name'))=[];
    fields(strcmp(fields,'tag'))=[];

input_args = {};
for i = 1:length(fields)
    if isa(workingStruct.(fields{i}), 'cell')
        
        input_args{end+1} = fields{i};
        input_args{end+1} = workingStruct.(fields{i});
    else
        
        try
            if strcmp(fields(i),'session_start_time')
                fields(i).(char(fieldnames(fields(i))))=datetime(fields(i).(char(fieldnames(fields(i)))));
            end
        end
        input_args{end+1} = fields{i};
        input_args{end+1} = workingStruct.(fields{i});
    end
end

end