function [preloaded_images, random_list] = preload_training_images(list,screenY,screenX)
% Quick script to preload all the images into memory before the task starts
% instead of during the task in an attempt to preserve precision timing
% this script also puts the image in a random order
% -------------------------------------------------------------------------
% 
% preallocate space for output   % Added - [0,1] to get rid of empty values
% from logging the folder names
preloaded_images = cell(size(list));
randomly_sorted = randperm(length(list));
for i = 1:length(preloaded_images)
    % Load and resize Drug cues to 1920x1080
    preloaded_images{i,1} = imresize(imread(list{randomly_sorted(i)}),[screenY,screenX]);

    % Save the new image presentation list after the randomization
    random_list{i,1} = list{randomly_sorted(i),1}; %#ok<AGROW>
    random_list{i,2} = list{randomly_sorted(i),2}; %#ok<AGROW> 
end
end