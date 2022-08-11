function config = Config_CR(subjectID)
% Configuration file for the RNI-OUD Cue Reactivity project
% written Jan 2022 Jacob Suffridge
% --------------------------------------------------------------------------

config = struct();
% Main root directory
% config.root = 'C:\Users\jesuffridge\Documents\MATLAB\Projects\RNI-OUD';
config.root = '/home/helpdesk/Documents/MATLAB/RNI-OUD/';

% Path to function Library
config.lib = [config.root '/Lib/'];

% Path to rating scales
config.rating_scales = [config.root '/Rating_Scales/Craving_Scales_0to9/'];
config.MRI_rating_scales = [config.root '/Rating_Scales/Craving_Scales_1to4/'];

% Path to Drug cues
config.cues = [config.root '/Addiction Cues/Cue Library'];

% Path to save data recorded during RNI-OUD task
config.data = [config.root '/CR Data/' subjectID];
% Create save folder for Data if it doesnt already exist
if not(isfolder(config.data))
    mkdir(config.data)
end

config.load_files = [config.data '/Load Files/'];
% Create save folder for Load Files and Data
if not(isfolder(config.load_files))
    mkdir(config.load_files)
end

config.baseFixation_duration = 2;
% image_list_generator parameters -----------------------------------------
config.image_duration = 3;
config.response_duration = 3;
config.total_training_duration = 600;
config.feedback_duration = 1;

config.training_list = 'OUD_CR_Training_List.mat';
config.drug_names = 'OUD_CR_Training_Cue_Names.mat';


config.interTrial_duration = 1;
config.textSize = 50;
config.fixSize = 250;
config.slider_duration = 10;
end