% Script to generate img_list for OUD Cue Reactivity Training Task
% Will randomly select mulitiple images from each drug folder to present in
% the training session. Task will last approximately 5 mins so roughly 50
% images will be presented.
% --------------------------------------------------------------------------
clear; clc;
Config_CR;
cd(config.cues)

% change save_string to dave different image lists
% -------------------------------------------------------------------------
save_string1 = 'OUD_CR_Training_List.mat';
save_string2 = 'OUD_CR_Training_Cue_Names.mat';
% -------------------------------------------------------------------------

% Parameters pulled from config file
image_duration = config.image_duration;
response_duration = config.response_duration;
total_task_duration = config.total_training_duration;

% Get drug folder names
folderNames = dir(config.cues);
% Remove extra directories
folderNames(contains({folderNames.name},'.')) = [];

% Assuming even respresentation from each folder. Calculate the number of images to pull from each folder.
% If this number isnt an integer then round up.
num_images = ceil((total_task_duration/(image_duration+response_duration))/length(folderNames));

% Going to store paths and images so we can preload the images before the task
image_paths = {};

for i = 1:length(folderNames)
    % Move into drug folders one by one
    cd(folderNames(i).name)
    tmp_dir = dir();
    % Remove unusable directories
    tmp_dir(1:2) = [];
    tmp_dir(contains({tmp_dir.name},'.db')) = [];

    % Randomly grab num_images from the folder
    temp = randperm(length(tmp_dir));
    temp = temp(1:num_images);

    % store path to selected images
    for j = 1:num_images
        image_paths{i,j} = {[pwd '\' tmp_dir(temp(j)).name],folderNames(i).name}; %#ok<SAGROW>
        %         img_storage{i,j} = imread(img_paths{i,j}); %#ok<SAGROW>
    end
    cd ../
end
% Reshape img_paths to be a "vector"
image_paths = reshape(image_paths,i*j,1);

% Use this loop to also collect the name of the folder that the image is
% from. Easier to grab this way now instead of from the path later.
img_tmp = image_paths{1};
for i = 2:length(image_paths)
    img_tmp = [img_tmp; image_paths{i}]; %#ok<AGROW>
end
image_paths = img_tmp;

% Adjust save location to be in Lib
save([config.lib '\' save_string1], 'image_paths')

% Also save the name of the Drug folders being used
save([config.lib '\' save_string2], 'folderNames')

% Return to root directory
cd(config.root)