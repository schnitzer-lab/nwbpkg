function nwb = init_nwb_session(metadata_struct)

nwbfile_input_args = get_input_args(metadata_struct, 'NWBFile');
nwb = nwbfile(nwbfile_input_args{:});

series_names=fieldnames(metadata_struct.RoiResponseSeries);
NumOfSeries=length(fieldnames(metadata_struct.RoiResponseSeries));
for ser=1:NumOfSeries
    object_name=series_names{ser};
    RoiResponse_input_args.(object_name) = get_input_args(metadata_struct.RoiResponseSeries, object_name);
end

subject_input_args = get_input_args(metadata_struct, 'Subject');
nwb.general_subject = types.core.Subject(subject_input_args{:});


end
