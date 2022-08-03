% Training.m is a script used to determine the best visual drug cues for
% the OUD task. The script will showcase a various panel of drug images
% while allowing the subject to provide a rating of their craving. These
% ratings will be used to automatically generate image sets to be used in
% the other OUD task such as DBS, Cue Reactivity, etc...
%
% ---- Jacob Suffridge May 2022
% -------------------------------------------------------------------------
sca; clear; clc; close all;
KbName('UnifyKeyNames');

%% Subject ID and Session Number should be changed every time the task is ran
% -------------------------------------------------------------------------
subjectID = 'test';
sessionNum = 'CR1';

%% Pre-Task setup ---------------------------------------------------------
% Call Config_Training.m to set path variables
config = Config_Training(subjectID);
cd(config.root)

% Add Library and Drug Cues to path
addpath(config.lib);    addpath(config.cues);   addpath(config.data);

% Load the Craving Rating Scales
load([config.rating_scales, '\craving_scales.mat'])
base_rating = craving_scales{end};

% Load the most current training output (ideal there should only be 1 file here)
tmp_dir = dir(config.data);
tmp_dir(ismember({tmp_dir.name},{'.','..'})) = [];
tmp_dir(~contains({tmp_dir.name},'.mat')) = [];

disp(['Loading ' tmp_dir(end).name])
training = load(tmp_dir(end).name); training = training.data;

weights = training.weights;
cues = training.CuesTypes;
folder_names = cues;
noExposure = training.excludedCues;

% Pull image list, fetch the folder names for later
[list, folder_names] = image_list_gen_training(subjectID, noExposure);

% Preload the stimulus images into memory
[preloaded_images, random_list] = preload_CR_images(list);

% Get total number of images (Can set a low number for debugging)
numImgs = length(list);
numImgs = 5;

%% Adjustable Parameters
% Size of onscreen text and the fixation "+"
textSize = 50;
fixSize = 250;

% Time to wait for a response and the duration of image presentation
time2wait = config.response_duration;
img_duration = config.image_duration;
feedback_duration = config.feedback_duration;
% Base Fixation Duration before task starts
baseFixationTime = config.baseFixation_duration;

% Strings for Instruction Screens
ScreenInstruct1 = '\n\n During this task, you will be presented with various stimuli, \n\n your job is to rate your craving for each image \n\n on a scale from 1 (lowest) to 9 (highest) \n\n\n\n\n\n Press "1" to continue';
ScreenInstruct2 = '\n\n Please wait for the Craving Rating Scale to appear on screen \n\n before entering your response.  \n\n\n\n Press "2" to continue';
ScreenInstruct3 = 'When presented with a "+" please rest with your \n\n eyes open and wait for the next block to start. \n\n\n\n Press "3" to continue';

% % Confirm Valid Input Arguements will terminate code if not correct
% if ~ischar(subjectID) || ~ischar(sessionNum)
%     disp('Check Input Parameters, error has occurred');
%     return;
% end
% clc;
%
% % Display the input parameters to verify that they are accurate
% disp(' ');
% disp(['Subject ID: ' subjectID]);
% disp(['Session Number: ' sessionNum]);
% disp(' ');
%
% pause(1);
% prompt = 'IS THIS THE CORRECT SUBJECT ID AND SESSION NUMBER?(y/n)..........';
% warning = input(prompt, 's');
% if strcmp(warning,'y') || strcmp(warning, 'Y')
% else
%     return;
% end

% Call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Initialize screen preferences
Screen('Preference', 'ConserveVRAM', 4096);
% Screen('Preference','VBLTimestampingMode',-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference','SkipSyncTests', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference','VisualDebugLevel', 0);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if available
screenNumber = max(screens);
% screenNumber = 2;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', w);
% main window dimensions
[X,Y] = RectCenter(windowRect);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Initialize storage for task information
RT = cell(1,numImgs);
ratings = cell(1,numImgs);

%% Instruction Set 1
% Create screen for first set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, textSize);
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
Screen('TextStyle',w,1);
Screen('TextSize',w,textSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,ScreenInstruct2,'center', 'center', black,[],0,0);
Screen('Flip', w);

str = []; %#ok<*NASGU>
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
Screen('TextStyle',w,1);
Screen('TextSize',w,textSize);
Screen('TextFont',w,'Arial');
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
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);
while GetSecs - initialFixationOnset <= baseFixationTime, end

%% Start of Image Presentation
for j = 1:numImgs
    % Pull the current image to the screen
    Screen('PutImage', w, preloaded_images{j});
    imgOnset = Screen('Flip',w);

    % Allow the image to be on screen for x seconds
    while (GetSecs - imgOnset) <= img_duration, end

    % Draw the rating screen
    Screen('PutImage', w, base_rating);

    % Flip rating scales to the screen
    imgOffset = Screen('Flip', w);

    % Have to wait to prevent CPU hogging
    WaitSecs(0.001);

    % Waiting for participant response
    timedOut = 0;
    while ~timedOut
        % check if a specified key is pressed
        [ keyIsDown, keyTime, keyCode ] = KbCheck;
        if(keyIsDown), break; end
    end

    % Records Reaction Time and Response Key
    if (~timedOut)
        RT{j} = keyTime - imgOffset;
        tmp_rating = KbName(find(keyCode));
        ratings{j} = tmp_rating(1);
    end

    % Draw the rating feedback image to the screen 
    Screen('PutImage', w, craving_scales{str2double(ratings{j})+1});
    rating_feedback = Screen('Flip', w);

    % Allow the image to be on screen for x seconds
    while (GetSecs - rating_feedback) <= config.feedback_duration, end
end

% Clear screen at the end of the task
sca;

%% Calculate and Save Task Variables
% Store labeled ratings in ftemp
ratings = ratings';
ftemp = [random_list(1:numImgs,:), ratings];

% fake_ratings = num2cell(randi(10,[1,108])-1)';
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
data.save_time = datestr(now,'mm-dd-yyyy_HH:MM:SS');
data.random_list = ftemp;
data.excludedCues = noExposure;
data.config = config;

% Save name to
save([config.data '\' subjectID '_' sessionNum, '_', datestr(now,'mm_dd_yyyy'),'.mat'],'data');
disp('Saving participant data')

figure
bar(data.weights)
xticklabels(folders_used)
cd(config.root)
