function mat2nwb(varargin)
	% MAT2NWB: convert Schnitzer matlab data to NWB data
	%
	% MAT2NWB() promts the user for a metadata yaml file, corresponding
	% .mat file and resulting .nwb file name and location.
	%
	% MAT2NWB('nwbpath','example.nwb','yamlpath','example.yml','datapath','example.mat')
	% executes the function without gui prompts for file names. Any missing
	% parameter will prompt the user for its location.
	%
	% Following packages are required:
	% - YAMLMATLAB: https://github.com/ewiger/yamlmatlab
	% - MATNWB: https://github.com/NeurodataWithoutBorders/matnwb
	%
	% Compatible matlab files:
	% - *cnmfeAnalysis.mat
	% - *extractAnalysis.mat
	%
	% changelong
		% 2020.02.12 [17:42:19] - Add support for NWB preferred ISO 8601 format.
		% 2021.11.08 [11:52:13] - Added nwbpkg support.
		% 2021.11.08 [11:59:59] - Added cellmax as an option

	defaultNWBpath = 'manual';
	defaultYamlPath = 'manual';
	defaultDataPath = 'manual';

	p = inputParser;
	addParameter(p, 'nwbpath', defaultNWBpath)
	addParameter(p, 'yamlpath', defaultYamlPath)
	addParameter(p, 'datapath', defaultDataPath)
	parse(p,varargin{:})

	% fid = H5F.create('temp_compressed');% initialize file for compressed data

	if strcmp(p.Results.yamlpath,'manual')
		fpathYML = uigetfile('*.yml','YAML file with metadata');
	else
		fpathYML = p.Results.yamlpath;
	end

	metadata = yaml.ReadYaml(fpathYML);

	if strcmp(p.Results.datapath,'manual')
		[file,path] = uigetfile('*.mat','matlab file with data');
		data_path = fullfile(path,file);
	else
		data_path = p.Results.datapath;
	end

	if strcmp(p.Results.nwbpath,'manual')
		fpath = uiputfile('*.nwb','location and name of NWB file');
	else
		fpath = p.Results.nwbpath;
	end

	% Determine what type of file the user has given
	if contains(data_path,'extract')
		data_type = 'extract';
	elseif contains(data_path,'cnmf') && ~contains(data_path,'cnmfe')
		data_type = 'cnmf';
	elseif contains(data_path,'cnmfe')
		data_type = 'cnmfe';
	elseif contains(data_path,'em') % CELLMax
		data_type = 'em';
	elseif contains(data_path,'cellmax')
		data_type = 'cellmax';
	elseif contains(data_path,'pcaica')
		data_type = 'pcaica';
	elseif contains(data_path,'roi')
		data_type = 'roi';
	end

	[image_masks, roi_response_data] = nwbpkg.extract_nwb_data(data_path, data_type);

	nwbfile_input_args = nwbpkg.get_input_args(metadata, 'NWBFile');
	% Convert to ISO 8601 format
	nwbfile_input_args{4} = datestr(nwbfile_input_args{4}, 'yyyy-mm-dd HH:MM:SS');
	nwb = NwbFile(nwbfile_input_args{:});

	subject_input_args = nwbpkg.get_input_args(metadata, 'Subject');
	nwb.general_subject = types.core.Subject(subject_input_args{:});

	nwb = nwbpkg.add_processed_ophys(nwb, metadata, image_masks, roi_response_data,data_type);
	nwbExport(nwb, fpath);

end