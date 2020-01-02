function extractAnalysisOutput_test=nwb2mat_schnitzer(nwb)
%% filters
step1=nwb.processing.values;
step2=step1{1, 1}.nwbdatainterface.values;
step3=step2{1, 2}.planesegmentation.values;
extractAnalysisOutput_test.filters=step3{1, 1}.image_mask.data.load;
clear step3
%% traces
step3=step2{1}.roiresponseseries.values;
    extractAnalysisOutput_test.traces=step3{1, 1}.data.load;
%% info
%% config
%% file
% probably not needed?
%% userInputConfig
%% opts
%% time
end