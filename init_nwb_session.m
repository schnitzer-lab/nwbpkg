function nwb = init_nwb_session(metadata_struct)

nwbfile_input_args = get_input_args(metadata_struct, 'NWBFile');
nwb = NwbFile(nwbfile_input_args{:});

subject_input_args = get_input_args(metadata_struct, 'Subject');
nwb.general_subject = types.core.Subject(subject_input_args{:});


end
