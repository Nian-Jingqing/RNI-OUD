function [img_list] = image_list_gen_CR(subjectID, weights, cues)
% Script to generate img_list for OUD Cue Reactivity Task
% Will create image list using the weights and cue types that were input to
% the function
% --------------------------------------------------------------------------
config = Config_CR(subjectID);
cd(config.cues)

%% Create active image list------------------------------------------------
% change save_string to save different image lists

save_string1 = [subjectID '_Task_List_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat'];
save_string2 = [subjectID '_Task_Cues_' datestr(now,'mm_dd_yyyy'), '_' num2str(length(dir(config.load_files))/2)  '.mat'];

% Parameters pulled from config file
% image_duration = config.image_duration;
% response_duration = config.response_duration;
% total_task_duration = config.total_training_duration;

folderNames = cues;

% Calculate the number of images to pull from each folder using input weights
% If this number isnt an integer then round up.
num_images = round(50*weights);

% Going to store paths and images so we can preload the images before the task
image_paths = {};

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
        image_paths{i,j} = {[pwd '/' tmp_dir(temp(j)).name],folderNames{i}}; %#ok<*AGROW>
        %         img_storage{i,j} = imread(img_paths{i,j}); %#ok<SAGROW>
    end
    cd ../
end
% Reshape img_paths to be a "vector"
image_paths = reshape(image_paths,[],1);

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

list_active = image_paths;
list_active_sorted = sortrows(list_active,2);

clear image_paths
%% Create neutral image list-----------------------------------------------
% Move into Neutral folder
cd([config.cues, '/Neutral/']);
tmp_dir = dir();
% Remove unusable directories
tmp_dir(ismember({tmp_dir.name},{'.','..'})) = [];
tmp_dir(contains({tmp_dir.name},'.db')) = [];

% Randomly grab num_images from the folder
temp = randperm(length(tmp_dir));
temp = temp(1:50);

% store path to selected images
for j = 1:length(temp)
    image_paths{j,1} = [pwd '/' tmp_dir(temp(j)).name];
    image_paths{j,2} = 'Neutral'; %#ok<*AGROW>
    %         img_storage{i,j} = imread(img_paths{i,j}); %#ok<SAGROW>
end
list_neutral = image_paths;

%% Create blocked image list ----------------------------------------------

% Will randomly shuffle the images
tmp_a_full = list_active(randperm(length(list_active)),:);
tmp_a = tmp_a_full(:,1);
tmp_n_full = list_neutral(randperm(length(list_neutral)),1);
tmp_n = tmp_n_full(:,1);

% Create Empty Cell Array
img_list = {{},{},{},{},{},{},{},{},{},{}};
for i = 1:length(img_list)
    
    % Create empty sub-Cell Array
    tmp_list = cell(10,1);
    tmp = []; %#ok<*NASGU> 
    
    if rem(i,2)                     % if even do neutral cues
        tmp = tmp_n(1:10);
        tmp_n(1:10) = [];
        
        for j = 1:length(tmp)
            tmp_list{j} = tmp{j};
        end 
    else                            % if odd do active cues
        tmp = tmp_a(1:10);
        tmp_a(1:10) = [];
        
        for j = 1:length(tmp)
            tmp_list{j} = tmp{j};
        end 
    end    
    img_list{i} = tmp_list;
end

% Return to root directory
cd(config.root)
end
