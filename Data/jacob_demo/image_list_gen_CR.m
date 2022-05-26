% Script to generate img_list for OUD Cue Reactivity Task
% Will randomly select mulitiple images from each drug folder to present in
% the CR session using the weights generated from training session
% --------------------------------------------------------------------------
clear; clc; close all;
Config_CR;
cd(config.data)

%% Subject ID and Session Number should be changed every time the task is ran
% -------------------------------------------------------------------------
subjectID = 'jacob_demo';
sessionNum = 'CueReactivity_list';
% change save_string to dave different image lists
save_string = [subjectID '_' sessionNum, '_', datestr(now,'mm_dd_yyyy'),'.mat'];

% Get the most recent set of weights in data struct (i.e. won't be needed if we don't
% adapt the weights)
cd(subjectID)
recent_weight_dir = dir([subjectID, '*']);
load(recent_weight_dir(end).name)
% -------------------------------------------------------------------------

% Parameters pulled from config file
image_duration = config.image_duration;
response_duration = config.response_duration;
total_task_duration = config.total_task_duration;

% Get drug folder names
folderNames = data.CuesTypes;
img_weights = data.weights;

% Generate figure to quickly visualize weights
figure;
bar(img_weights)
hold on;
xticklabels(folderNames)
ylabel('Normalized Weight')

% Calculate the number of images to pull from each folder using the training weights.
% Will always round to the near integer
total_num_images = ceil((total_task_duration/(image_duration+response_duration)));
num_images = round(img_weights.*total_num_images);
total_num_images_corrected = sum(num_images);

% Going to store paths and images so we can preload the images before the task
image_paths = {};

% Move to Cue Directory
cd(config.cues)
for i = 1:length(folderNames)
    % Move into drug folders one by one
    cd(folderNames{i})
    tmp_dir = dir();
    % Remove unusable directories
    tmp_dir(1:2) = [];
    tmp_dir(contains({tmp_dir.name},'.db')) = [];

    % Randomly grab num_images from the folder
    temp = randperm(length(tmp_dir));
    temp = temp(1:num_images(i));

    % store path to selected images
    for j = 1:num_images(i)
        image_paths{i,j} = {[pwd '\' tmp_dir(temp(j)).name],folderNames{i}}; %#ok<SAGROW>
        %         img_storage{i,j} = imread(img_paths{i,j}); %#ok<SAGROW>
    end
    cd ../
end
% Reshape img_paths to be a "vector"
image_paths = reshape(image_paths, [], 1);

% Use this loop to also collect the name of the folder that the image is
% from. Easier to grab this way now instead of from the path later.
img_tmp = image_paths{1};
for i = 2:length(image_paths)
    img_tmp = [img_tmp; image_paths{i}]; %#ok<AGROW>
end
image_paths = img_tmp;

% Adjust save location to be in Lib. Also save the name of the Drug folders being used
save([config.data subjectID '\' save_string], 'image_paths','folderNames')


% Return to root directory
cd(config.root)