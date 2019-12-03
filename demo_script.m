metadata_path = 'template_meta_file.yml'; 
data_path = '/Users/bendichter/dev/calciumImagingAnalysis/data/2014_04_01_p203_m19_check01_raw/2014_04_01_p203_m19_check01_extractAnalysis.mat';
nwb_save_path = 'test.nwb';

metadata = ReadYaml(metadata_path);

[image_masks, roi_response_data] = extract_nwb_data(data_path);
nwb = init_nwb_session(metadata);
nwb = add_processed_ophys(nwb, metadata, image_masks, roi_response_data);
nwbExport(nwb, nwb_save_path);