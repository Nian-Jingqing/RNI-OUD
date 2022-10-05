function data = Training(subjectID, noExposure)
% Training.m is a script used to determine the best visual drug cues for
% the OUD task. The script will showcase a various panel of drug images
% while allowing the subject to provide a rating of their craving. These
% ratings will be used to automatically generate image sets to be used in
% the other OUD task such as DBS, Cue Reactivity, etc...
%
% ---- Jacob Suffridge May 2022
% ---- Last Edited July 28th
%
% Updated August 10th 2022
% Modify input methods to use keys across the top of the keyboard instead
% of the numpad
% 
% 
% Script Dependencies:
% Config_CR.m, image_list_gen_training.m, preload_training_images.m
%
% Config Parameters:
% config.textSize, config.fixSize, config.image_duration, config.baseFixation_duration
% 
% Example Inputs:
% subjectID = 'test';
% noExposure = {};
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sessionNum = 'training';

%% Pre-Task setup ---------------------------------------------------------
% Add path to lib to initialize Config_Training function
addpath('/home/helpdesk/Documents/MATLAB/RNI-OUD/Lib');

% Call Config_Training.m to set path variables
config = Config_CR(subjectID);
cd(config.root)

% Path to load the training cue list
list_load_path = [config.root, '/Training_Cue_List.mat'];

% Add Library and Drug Cues to path
addpath(config.lib);
addpath(config.cues);
KbName('UnifyKeyNames');

% Numpad : Add extra line to take input from numpad and num keys across top of keyboard
% activeKeys = [KbName(96) KbName(97) KbName(98) KbName(99) KbName(100) KbName(101) KbName(102) KbName(103) KbName(104) KbName(105)]; % keys: 0,1,2,3,4,5,6,7,8,9
% activeKeys = [activeKeys KbName('0') KbName('1') KbName('2') KbName('3') KbName('4') KbName('5') KbName('6') KbName('7') KbName('8') KbName('9')];
%  
activeKeys = [KbName('1!'),KbName('2@'),KbName('3#'),KbName('4$'),KbName('5%'),KbName('6^'),KbName('7&'),KbName('8*'),KbName('9(')];
RestrictKeysForKbCheck(activeKeys);
%% Adjustable Parameters
% Strings for Instruction Screens
ScreenInstruct1 = '\n\n During this task, you will be presented with various stimuli, \n\n your job is to rate your craving for each image \n\n on a scale from 1 (lowest) to 9 (highest) \n\n\n\n\n\n Press "1" to continue';
ScreenInstruct2 = '\n\n Please wait for the Craving Rating Scale to appear on screen \n\n before entering your response.  \n\n\n\n Press "2" to continue';
ScreenInstruct3 = 'When presented with a "+" please rest with your \n\n eyes open and wait for the next block to start. \n\n\n\n Press "3" to continue';

%% Screen Setup
% Call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% PsychJavaTrouble(1);

% Initialize screen preferences
Screen('Preference', 'ConserveVRAM', 4096);
% Screen('Preference','VBLTimestampingMode',-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference','SkipSyncTests', 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference','VisualDebugLevel', 0);
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if available
screenNumber = max(screens);
% screenNumber = 1;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', w);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Load the Craving Rating Scalesca
craving_scales = load([config.rating_scales, '/craving_scales.mat']).craving_scales;
for i = 1:length(craving_scales)
    craving_scales{i} = imresize(craving_scales{i},[screenYpixels,screenXpixels]);
end
base_rating = craving_scales{end};

% Pull image list, fetch the folder names for later
[list, folder_names] = image_list_gen_training(subjectID, noExposure);

% Preload the stimulus images into memory
[preloaded_images, random_list] = preload_training_images(list,screenYpixels, screenXpixels);

% Get total number of images (Can set a low number for debugging)
numImgs = length(list);
% numImgs = 5;

% Initialize storage for task information and timestamps
RT = cell(1,numImgs);
ratings = cell(1,numImgs);
img_starts = cell(1,numImgs);
rating_starts = cell(1,numImgs);

%% Instruction Set 1
% Create screen for first set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, config.textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct1, 'center', 'center', black, [], 0, 0);
Screen('Flip', w);

str = []; %#ok<*NASGU>
FlushEvents('KeyDown');
% trigger release check for first instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'a') || strcmp(str,'1')
        break;
    end
end

%% Instruction Set 2
% Create screen for second set of instructions
DrawFormattedText(w,ScreenInstruct2,'center', 'center', black,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check for second instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'b') || strcmp(str,'2')
        break;
    end
end

%% Instruction Set 3
% Create screen for third set of instructions
DrawFormattedText(w,ScreenInstruct3,'center', 'center', black,[],0,0);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% trigger release check for third instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'c') || strcmp(str,'3')
        break;
    end
end

%% Baseline Fixation Screen
Screen('TextStyle',w,1);
Screen('TextSize',w,config.fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);
WaitSecs(config.baseFixation_duration);

%% Start of Image Presentation
for j = 1:numImgs
    % Pull the current image to the screen
    Screen('PutImage', w, preloaded_images{j});
    img_starts{j} = Screen('Flip',w);

    % Allow the image to be on screen for x seconds
    WaitSecs(config.image_duration);

    % Draw the rating screen
    Screen('PutImage', w, base_rating);

    % Flip rating scales to the screen
    rating_starts{j} = Screen('Flip', w);

    % Have to wait to prevent CPU hogging
%     WaitSecs(0.001);

    % Waiting for participant response
    while 1
        % check if a specified key is pressed
        [ keyIsDown, keyTime, keyCode ] = KbCheck;
        if(keyIsDown)
%             while KbCheck, end
            break;
        end
    end

    % Records Reaction Time and Response Key
    if 1
        RT{j} = keyTime - rating_starts{j};
        tmp_rating = KbName(find(keyCode));
        ratings{j} = str2double(tmp_rating(1));
    end

    % Draw the rating feedback image to the screen
    Screen('PutImage', w, craving_scales{ratings{j}+1});
    Screen('Flip', w);

    % Allow the image to be on screen for x seconds
    %     WaitSecs(config.feedback_duration - RT{j})
    WaitSecs(0.5);
end
% Clear screen at the end of the task
sca;
% Reenable all keys
RestrictKeysForKbCheck([])
%% Calculate and Save Task Variables
% Store labeled ratings in ftemp
ratings = ratings';
ftemp = [random_list(1:numImgs,:), ratings];

% fake_ratings = num2cell(randi(10,[1,length(list)])-1)';
% ftemp = [random_list(:,2),fake_ratings];

folders_used = cell(length(folder_names),1);
% This loop extracts the ratings for each image type since the images were randomized
for i = 1:length(folder_names)
    tmp = [];
    for j = 1:length(ftemp)
        if strcmp(ftemp{j,2},folder_names(i).name)
            tmp = [tmp, ftemp{j,3}]; %#ok<*AGROW>
        end
    end
    sorted_ratings{i,1} = tmp;
    sorted_ratings{i,2} = mean(tmp,2);
    sorted_ratings{i,3} = min(tmp,[],2);
    sorted_ratings{i,4} = max(tmp,[],2); %#ok<*SAGROW>
    folders_used{i,1} = folder_names(i).name;
end

% Create data struct to store the task variables
data.Ratings = ratings;
data.RT = RT';
data.CuesTypes = folders_used;
data.weights = [sorted_ratings{:,2}]'./sum([sorted_ratings{:,2}]);
data.min_weights = [sorted_ratings{:,3}]';
data.max_weights = [sorted_ratings{:,4}]';
data.save_time = datestr(now,'mm-dd-yyyy_HH:MM:SS');Bxticklabels(folders_used)
cd(config.root)

end