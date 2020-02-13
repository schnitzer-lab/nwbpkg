function [image_masks, roi_response_data] = extract_nwb_data(fpath,data_type)

% EXTRACT_NWB_DATA: extracts data from the matlab file to add to NWB.
% 
%    EXTRACT_NWB_DATA(fpath) loads .mat dataset specified by the fpath.
%    
%    EXTRACT_NWB_DATA(fpath, data_type) specifies the data type to be
%    loaded. This forgoes the need to infer data type from filenames.
%
%    This function requires mat2nwb to function as intended.

dat = load(fpath);
if strcmp(data_type,'cnmfe')
    image_masks = dat.cnmfeAnalysisOutput.extractedImages;
    
    data_fields=fields(dat.cnmfeAnalysisOutput);
    MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    touse=data_fields(MatchedFields);
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.cnmfeAnalysisOutput.(touse{i});
    end
    
elseif strcmp(data_type,'extract')
    image_masks = dat.extractAnalysisOutput.filters;
    data_fields=fields(dat.extractAnalysisOutput);
    
    MatchedFields=cellfun(@(x) contains(x,'traces'), data_fields);
    touse=data_fields(MatchedFields);
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.extractAnalysisOutput.(touse{i});
    end
    
elseif strcmp(data_type,'cnmf')
    disp('at time of development cnmf files had no data')
    return
elseif strcmp(data_type,'em')
    disp('at time of development em files had no data')
    return  
end
end