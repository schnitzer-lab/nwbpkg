function nwb = add_processed_ophys(nwb, metadata, image_masks, ...
    roi_response_data, frame_times, frames)

if ~ exist('frame_times','var') || isempty(frame_times)
    frame_times = [];
end

if ~ exist('frames','var') || isempty(frames)
    frames = [];
end

n_rois = size(image_masks, 1);

op_input_args = get_input_args(metadata, 'OpticalChannel');
optical_channel = types.core.OpticalChannel(op_input_args{:});

nwb.general_devices.set(metadata.Device{1}.device_name, types.core.Device());

ip_input_args = get_input_args(metadata, 'ImagingPlane');
imaging_plane = types.core.ImagingPlane('device', ...
    types.untyped.SoftLink(['/general/devices/' metadata.Device{1}.device_name]), ...
    'optical_channel', optical_channel, ip_input_args{:});

nwb.general_optophysiology.set(metadata.ImagingPlane{1}{1}.imaging_plane_name, imaging_plane);

imaging_plane_path = ['/general/optophysiology/' metadata.ImagingPlane{1}{1}.imaging_plane_name];

ophys_module = types.core.ProcessingModule(...
    'description', 'holds processed calcium imaging data');

ps_input_args = get_input_args(metadata, 'PlaneSegmentation');
plane_segmentation = types.core.PlaneSegmentation( ...
    'imaging_plane', imaging_plane, ...
    'colnames', {'imaging_mask'}, ...
    'id', types.core.ElementIdentifiers('data', int64(0:n_rois-1)), ...
    ps_input_args{:});

plane_segmentation.image_mask = types.core.VectorData( ...
    'data', image_masks, 'description', 'image masks');

img_seg = types.core.ImageSegmentation();
img_seg.planesegmentation.set('PlaneSegmentation', plane_segmentation);

ophys_module.nwbdatainterface.set('ImageSegmentation', img_seg);
nwb.processing.set('ophys', ophys_module);

plane_seg_object_view = types.untyped.ObjectView( ...
    '/processing/ophys/ImageSegmentation/PlaneSegmentation');

roi_table_region = types.core.DynamicTableRegion( ...
    'table', plane_seg_object_view, ...
    'description', 'all_rois', ...
    'data', [0 n_rois-1]');

series_names=fieldnames(metadata.RoiResponseSeries);
NumOfSeries=length(fieldnames(metadata.RoiResponseSeries));
for ser=1:NumOfSeries
    object_name=series_names{ser};
    roi_response_series_varargin{ser} = get_input_args(metadata.RoiResponseSeries, object_name);
end

ROIfields=fields(roi_response_data);
numOfROIs=length(ROIfields);

fluorescence = types.core.Fluorescence();

for i=1:numOfROIs
    varIn=roi_response_series_varargin{i};
    if frame_times
        roi_response_series = types.core.RoiResponseSeries( ...
            'rois', roi_table_region, ...
            'data', roi_response_data.(ROIfields{i}), ...
            'data_unit', 'lumens', ...
            'timestamps', frame_times, ...
            varIn{:});
    else
        roi_response_series = types.core.RoiResponseSeries( ...
            'rois', roi_table_region, ...
            'data', roi_response_data.(ROIfields{i}), ...
            'data_unit', 'lumens', ...
            'starting_time_rate',  metadata.ImagingPlane{4}.imaging_rate, ...
            varIn{:});
    end
fluorescence.roiresponseseries.set(['RoiResponseSeries' num2str(i)], roi_response_series);
end

ophys_module.nwbdatainterface.set('Fluorescence', fluorescence);

nwb.processing.set('ophys', ophys_module);

if ~isempty(frames)
    image_series_name = 'TwoPhotonSeries';
    
    image_series = types.core.TwoPhotonSeries( ...
        'imaging_plane', types.untyped.SoftLink(imaging_plane_path), ...
        'starting_time_rate',  metadata.ImagingPlane{4}.imaging_rate, ...
        'data', frames, ...
        'data_unit', 'lumens');
    
    nwb.acquisition.set(image_series_name, image_series);
end







end