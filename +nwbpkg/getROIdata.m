function out = getROIdata(varargin)

	% GETROIDATA get response series data from .nwb file
	%
	%    GETROIDATA is a rudimentary example of reversing mat2nwb function.
	%    this example function extracts the image segmentation and roi response
	%    series from the NWB file. 
	%
	%    out = getROIdata(varargin) returns a structure where each row is a
	%    separate response series data. 'varargin' is a file path of the NWB
	%    data file. This field can be empty, in which case you will be prompted
	%    to pick a data file. 

	if isempty(varargin)
		path = uigetfile('*.nwb');
		nwb = nwbRead(path);
	else
		nwb = nwbRead(varargin);
	end
	Ophys = get(nwb.processing,'ophys');
	dataKeys = Ophys.nwbdatainterface.keys;
	for i = 1:length(dataKeys)
		temp_1.(dataKeys{i}) = get(Ophys.nwbdatainterface,dataKeys{i});
		CheckVals = fieldnames(temp_1.(dataKeys{i}));
		noHelp = CheckVals(~strcmp(CheckVals,'help'));
		numOfRois = temp_1.(dataKeys{i}).(noHelp{1}).values;
		for j = 1:length(numOfRois)
			out(j).(dataKeys{i}) = numOfRois{j}.loadAll;
		end
	end   
end