function config = Config_CR(subjectID,sessionID,protocolID)
% Configuration file for the RNI-OUD Cue Reactivity project
% written Jan 2022 Jacob Suffridge
% --------------------------------------------------------------------------

config = struct();

% Main root directory
config.root = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Cue Reactivity/';

% Path to function Library
config.lib = [config.root '/Lib/'];

% Set the text and background color and adjust the slider color accordingly
% Assume white text + black bckgrd or black text + white bckgrd

config.backgroundColor = 0.5;
config.textColor = 0;

if config.backgroundColor == 0.5
    config.slider_scales = [config.root '/Rating_Scales/SliderScale05_greybackground_noTicks_blackSlider'];
    config.slider_scales_submitted = [config.root '/Rating_Scales/SliderScale05_greybackground_noTicks_redTicks'];
else
    config.slider_scales = [config.root '/Rating_Scales/SliderScale05_blackbackground_noTicks'];
end

% config.rating_scales = [config.root '/Rating_Scales/Craving_Scales_0to9/'];
% config.MRI_rating_scales = [config.root '/Rating_Scales/Craving_Scales_1to4/'];

% Path to Drug cues
config.cues = [config.root, 'Cue Images/DISCO CUES/Cue Media/finalcueset'];
config.cues = [config.root 'Cue Images/DO-0001'];


% Path to save data recorded during RNI-OUD task
config.data = [config.root '/CR Data/',protocolID, '/' subjectID];
config.data_short = [config.root '/CR Data/'];

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
config.initialFixation_Duration = 0.5; % 500ms
config.blankScreen_duration = 1;


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
config.sliderDuration = 5;


%% Integrate Jitter into CR with triggers
% % Get drug folder names
% folderNames = dir(config.cues);

% % Remove neutrals from considered categories
% noExposure{end+1} = 'Neutral';

% % Remove extra directories
% folderNames(contains({folderNames.name},'.')) = [];
% folderNames(ismember({folderNames.name},noExposure)) = [];

% config.num_images = ceil((config.total_training_duration/(config.image_duration+config.response_duration))/length(folderNames));
% config.num_images = 120;
% 
% tmp_img_durations = [250:100:1000];
% tmp_blankScreen1_durations = [750:50:1250];
% tmp_blankScreen2_durations = [1000:100:1500];

end