% Configuration file for the DBS-OUD Cue Reactivity project
% written Jan 2022 Jacob Suffridge

config = struct();
% Main root directory
config.root = 'C:\Users\jesuffridge\Documents\MATLAB\Projects\DBS-OUD';

% Path to function Library
config.lib = [config.root '\Lib\'];

% Path to rating scales 
config.rating_scales = [config.root '\Rating_Scales\Rating_Scales_0to9\'];
% config.rating_scales = [config.root '\Rating_Scales\Rating_Scales\'];
% config.rating_scales = [config.root '\Rating_Scales\Rating_Scales_1to4\'];

% Path to Drug cues
config.cues = [config.root '\Addiction Cues\Cue Library'];
% config.heroin = [config.cues '\Heroin'];
% config.nicotine = [config.cues '\Nicotine\'];

config.demo_cues = [config.root '\Drug_Cues\Heroin'];
% Path to save data recorded during OUD-DBS task
config.data = [config.root '\Data\'];

% Parameter to enable debug mode
config.debug = 0;

% image_list_generator parameters -----------------------------------------
config.image_duration = 3;
config.response_duration = 3;
config.total_training_duration = 300;
config.training_list = 'OUD_CR_Training_List.mat';
config.drug_names = 'OUD_CR_Training_Cue_Names.mat';

config.total_task_duration = 300;
config.CR_list = 'jacob_demo_CueReactivity_list_05_19_2022.mat';
                 
