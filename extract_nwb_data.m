function [image_masks, roi_response_data] = extract_nwb_data(fpath,data_type)

% changelog
	% 2020.02.13 [09:22:07] - Added support for CELLMax (EM), CNMF, PCA-ICA, and ROI.

% used with mat2nwb. Extracts appropriate data based on the type of the
% input .mat file

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
    image_masks = dat.cnmfAnalysisOutput.extractedImages;
    
    data_fields=fields(dat.cnmfAnalysisOutput);
    MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    touse=data_fields(MatchedFields);
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.cnmfAnalysisOutput.(touse{i});
    end
    return
elseif strcmp(data_type,'em') % for CELLMax
	image_masks = dat.emAnalysisOutput.cellImages;
    
    % data_fields=fields(dat.emAnalysisOutput);
    % MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    % touse=data_fields(MatchedFields);
	touse = {'scaledProbability','cellTraces'};
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.emAnalysisOutput.(touse{i});
    end
    %disp('at time of development em files had no data')
    return  
elseif strcmp(data_type,'pcaica') % for PCA-ICA
    image_masks = dat.pcaicaAnalysisOutput.IcaFilters;
    
    % data_fields=fields(dat.emAnalysisOutput);
    % MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    % touse=data_fields(MatchedFields);
	touse = {'IcaTraces'};
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.pcaicaAnalysisOutput.(touse{i});
    end
    return  
elseif strcmp(data_type,'roi')
    image_masks = dat.roiAnalysisOutput.filters;
    
    % data_fields=fields(dat.emAnalysisOutput);
    % MatchedFields=cellfun(@(x) contains(x,'extractedSignals'), data_fields);
    % touse=data_fields(MatchedFields);
	touse = {'traces'};
    
    for i=1: length(touse)
        roi_response_data.(['ROI_' num2str(i)]) = dat.roiAnalysisOutput.(touse{i});
    end
    return  
end
end