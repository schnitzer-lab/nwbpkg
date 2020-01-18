function nwb = init_nwb_session(metadata_struct)

nwbfile_input_args = get_input_args(metadata_struct, 'NWBFile');
nwb = NwbFile(nwbfile_input_args{:});
% 
% NumOfSeries=length(metadata_struct.Ophys.DFOverF.roi_response_series);
% for ser=1:NumOfSeries
%     series_names=fieldnames(metadata_struct.Ophys.DFOverF.roi_response_series{ser});
%     object_name=series_names{ser};
%     RoiResponse_input_args.(object_name) =...
%         get_input_args(metadata_struct.Ophys.DFOverF.roi_response_series, object_name);
% end

subject_input_args = get_input_args(metadata_struct, 'Subject');
nwb.general_subject = types.core.Subject(subject_input_args{:});


end
