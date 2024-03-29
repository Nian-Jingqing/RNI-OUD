function [list, folderNames] = image_list_gen_training(subjectID, sessionID, protocolID, noExposure)
% Script to generate img_list for OUD Cue Reactivity Training Task
% Will randomly select mulitiple images from each drug folder to present in
% the training session. Task will last approximately 5 mins so roughly 50
% images will be presented.
% --------------------------------------------------------------------------
config = Config_CR(subjectID,sessionID,protocolID);
cd(config.cues)

% -------------------------------------------------------------------------
% change save_string to save different image lists

save_string1 = [subjectID '_Training_List_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat'];
save_string2 = [subjectID '_Training_Cues_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat'];

% save_string1 = ['OUD_CR_' subjectID '_List_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat']
% save_string2 = ['OUD_CR_' subjectID '_Cues_Names_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat']
% -------------------------------------------------------------------------

% Parameters pulled from config file
% config.image_duration, config.response_duration, config.total_training_duration

% Get drug folder names
folderNames = dir(config.cues);
% Remove neutrals from considered categories
noExposure{end+1} = 'Neutral';
% Remove extra directories
folderNames(contains({folderNames.name},'.')) = [];
folderNames(ismember({folderNames.name},noExposure)) = [];

% Assuming even respresentation from each folder. Calculate the number of images to pull from each folder.
% If this number isnt an integer then round up.
num_images = ceil((config.total_training_duration/(config.image_duration+config.response_duration))/length(folderNames));
num_images = 40;

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
        image_paths{i,j} = {[pwd '/' tmp_dir(temp(j)).name],folderNames(i).name}; %#ok<*AGROW>
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
    img_tmp = [img_tmp; image_paths{i}];
end
image_paths = img_tmp;

% Adjust save location to Load Files
save([config.load_files '/' save_string1], 'image_paths')

% Also save the name of the Drug folders being used
save([config.load_files '/' save_string2], 'folderNames')

% Return to root directory
cd(config.root)

list = image_paths;
end