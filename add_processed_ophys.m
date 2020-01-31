function nwb = add_processed_ophys(nwb, metadata, image_masks, ...
    roi_response_data, frames)

% used in mat2nwb to extract and assign ROI response data from .mat
% datafiles to nwb.

if ~ exist('frames','var') || isempty(frames)
    frames = [];
end

n_rois = size(image_masks, 1);

op_input_args = get_input_args(metadata.Ophys.ImagingPlanes{1}, 'optical_channels');
optical_channel = types.core.OpticalChannel(op_input_args{:});

numOfDevices=length(metadata.Ophys.Devices);

for i=1:numOfDevices
    nwb.general_devices.set(metadata.Ophys.Devices{numOfDevices}.name, types.core.Device());
end

ip_input_args = get_input_args(metadata.Ophys, 'ImagingPlanes');

yestag=1;
try
    Device_tags=cellfun(@(x) x.tag, metadata.Ophys.Devices,'uniform',0);
catch
    yestag=0;
end

numOfPlanes=length(metadata.Ophys.ImagingPlanes);
for i=1:numOfPlanes
    if yestag
        dev_name=find(strcmp(metadata.Ophys.ImagingPlanes{i}.tag,Device_tags));
    else
        dev_name=i;
    end
    imaging_plane{i} = types.core.ImagingPlane('device', ...
        types.untyped.SoftLink(['/general/devices/' metadata.Ophys.Devices{dev_name}.name]), ...
        'optical_channel', optical_channel, ip_input_args{:});
    nwb.general_optophysiology.set(metadata.Ophys.ImagingPlanes{i}.name, imaging_plane{i});
end


imaging_plane_path = ['/general/optophysiology/' metadata.Ophys.ImagingPlanes{1}.name];

ophys_module = types.core.ProcessingModule(...
    'description', 'holds processed calcium imaging data');

img_seg = types.core.ImageSegmentation();
for i=1:numOfPlanes 
    ps_input_args = get_input_args(metadata.Ophys.ImageSegmentation.plane_segmentations{i}, '');
    plane_segmentation{i} = types.core.PlaneSegmentation( ...
        'imaging_plane', imaging_plane{i}, ...
        'colnames', {'imaging_mask'}, ...
        'id', types.core.ElementIdentifiers('data', int64(0:n_rois-1)), ...
        ps_input_args{:});
    
    plane_segmentation{i}.image_mask = types.core.VectorData( ...
        'data', image_masks, 'description', 'image masks');
    
    img_seg.planesegmentation.set(metadata.Ophys.ImageSegmentation.plane_segmentations{i}.name,...
        plane_segmentation{i});
    
    plane_seg_object_view{i} = types.untyped.ObjectView( ...
    ['/processing/ophys/' metadata.Ophys.ImageSegmentation.name '/' metadata.Ophys.ImageSegmentation.plane_segmentations{i}.name]);
end

ophys_module.nwbdatainterface.set(metadata.Ophys.ImageSegmentation.name, img_seg);
nwb.processing.set('ophys', ophys_module);



NumOfSeries=length(metadata.Ophys.DFOverF.roi_response_series);
for ser=1:NumOfSeries
    roi_response_series_varargin{ser} = get_input_args(metadata.Ophys.DFOverF.roi_response_series{ser}, '');
end

ROIfields=fields(roi_response_data);
numOfROIs=length(ROIfields);

fluorescence = types.core.Fluorescence();

for i=1:numOfROIs
    
    roi_table_region = types.core.DynamicTableRegion( ...
    'table', plane_seg_object_view{i}, ...
    'description', 'all_rois', ...
    'data', [0 n_rois-1]');

    varIn=roi_response_series_varargin{i};
        roi_response_series = types.core.RoiResponseSeries( ...
            'rois', roi_table_region, ...
            'data', roi_response_data.(ROIfields{i}), ...
            'data_unit', 'lumens', ...
            varIn{:});
    fluorescence.roiresponseseries.set(metadata.Ophys.DFOverF.roi_response_series{i}.name,...
        roi_response_series);
end

ophys_module.nwbdatainterface.set('fluorescence', fluorescence);

nwb.processing.set('ophys', ophys_module);

if ~isempty(frames)
    yestag=1;
    try
        Device_tags=cellfun(@(x) x.tag, metadata.Ophys.ImagingPlanes,'uniform',0);
    catch
        yestag=0;
    end
    
    for i=1:length(metadata.Ophys.TwoPhotonSeries)
        
        if yestag
            TwoPhTag=find(strcmp(metadata.Ophys.TwoPhotonSeries{i}.tag,Device_tags));
        else
            TwoPhTag=i;
        end
        
        image_series_name = metadata.Ophys.TwoPhotonSeries{TwoPhTag}.name;
        
        image_series = types.core.TwoPhotonSeries( ...
            'imaging_plane', types.untyped.SoftLink(imaging_plane_path), ...
            'starting_time_rate',  metadata.Ophys.ImagingPlanes{TwoPhTag}.imaging_rate, ...
            'data', frames, ...
            'data_unit', 'lumens');
        
        nwb.acquisition.set(image_series_name, image_series);
    end
end
end