function [image_masks, roi_response_data] = extract_nwb_data_cnmfe(fpath)

dat = load(fpath);
image_masks = dat.cnmfeAnalysisOutput.extractedImages;
roi_response_data.first = dat.cnmfeAnalysisOutput.extractedSignals;
roi_response_data.second = dat.cnmfeAnalysisOutput.extractedSignalsEst;

end