% Script to generate img_list for Static Cue Reactivity

% Set path to image database
img_path = 'C:\Users\jesuffridge\Documents\MATLAB\Projects\RNI-OUD\Addiction Cues\Cue Library';
noExposure = {};

% Get drug folder names
folderNames = dir(img_path);
% Remove extra directories
folderNames(contains({folderNames.name},'.')) = [];
folderNames(ismember({folderNames.name},noExposure)) = [];

% Assuming even respresentation from each folder.
num_images = 5;

% Going to store paths and images so we can preload the images before the task
image_paths = cell(num_images);
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
        image_paths{i,j} = {[pwd '\' tmp_dir(temp(j)).name],folderNames(i).name}; %#ok<*AGROW>
        %         img_storage{i,j} = imread(img_paths{i,j}); %#ok<SAGROW>
    end
    cd ../
end

% Reshape img_paths to be a "vector"
image_paths = reshape(image_paths,i*j,1);
tmp = image_paths;
tmp_paths = cell(length(image_paths),1);
for i = 1:length(image_paths)
    tmp_paths{i,1} = image_paths{i,1}{1,1};
    tmp_paths{i,2} = image_paths{i,1}{1,2};
end 
image_paths = tmp_paths;











% Active Images
a = [4;5;6;8;9;11;13;14;17;18;20;26;28;29;32;33;36;39;40;44;46;47;48;49;50];
tmp_a = a(randperm(length(a)));
tmp_a = [tmp_a; a(randperm(length(a)))];

% Neutral Images
n = [1;2;3;7;10;12;15;16;19;21;22;23;24;25;27;30;31;34;35;37;38;41;42;43;45];
tmp_n = n(randperm(length(n)));
tmp_n = [tmp_n; n(randperm(length(n)))];

% Create Empty Cell Array
img_list = {{},{},{},{},{},{},{},{},{},{}};
for i = 1:length(img_list)
    
    % Create empty sub-Cell Array
    tmp_list = cell(10,1);
    tmp = [];
    
    if rem(i,2)                     % if even do neutral cues
        tmp = tmp_n(1:10);
        tmp_n(1:10) = [];
        
        for j = 1:length(tmp)
            tmp_list{j} = {[config.images num2str(tmp(j)) '.png']};
        end 
    else                            % if odd do active cues
        tmp = tmp_a(1:10);
        tmp_a(1:10) = [];
        
        for j = 1:length(tmp)
            tmp_list{j} = {[config.images num2str(tmp(j)) '.png']};
        end 
    end 
    
    img_list{i} = tmp_list;
end
% Create A by copying the img_list cell
img_list_A = img_list;

% Create B by shuffling the columns of img_list_A
img_list_B{1} = img_list_A{5};
img_list_B{2} = img_list_A{4};
img_list_B{3} = img_list_A{1};
img_list_B{4} = img_list_A{2};
img_list_B{5} = img_list_A{3};

img_list_B{6} = img_list_A{10};
img_list_B{7} = img_list_A{9};
img_list_B{8} = img_list_A{6};
img_list_B{9} = img_list_A{7};
img_list_B{10} = img_list_A{8};

% Save A and B image lists to current pwd
save('img_lists.mat','img_list_A','img_list_B')