function [img_list] = preTaskGen(subjectID)
% Script to perform task items before launching the task
% written Jan 2022 Jacob Suffridge

% cues_present = [1,1];
cue_weights = [1,1];
cue_weights = cue_weights./sum(cue_weights);

Config_CR;

%% i) create directories to save subject data
% Move to Data and create "subjectID" folder 
cd(config.data)
mkdir(subjectID)
cd(config.root)


%% ii) generate the image list to be used for the task, taken from the drug 
% of choice folders
cd(config.demo_cues)
cues_folders = dir(); 
cues_folders = cues_folders(~ismember({cues_folders.name},{'.','..'}));
cd(config.root)
%% iii) img_list needs to contain the path from Drug_Cues to the image

end 
