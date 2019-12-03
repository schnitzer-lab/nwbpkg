function [image_masks, roi_response_data] = extract_nwb_data(fpath)

dat = load(fpath);
image_masks = dat.extractAnalysisOutput.filters;
roi_response_data = dat.extractAnalysisOutput.traces;

end