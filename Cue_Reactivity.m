% Cue Reactivity.m is a script used to present drug cues to participants using
% the weights determined in the training/previous session The script will showcase
% a various panel of drug images while immediately allowing the subject to provide
% a rating of their craving. These ratings will automatically be recorded
% for analysis
%
% ---- Jacob Suffridge May 2022
% -------------------------------------------------------------------------
sca; clear; clc; close all;
KbName('UnifyKeyNames');

%% Subject ID and Session Number should be changed every time the task is ran
% -------------------------------------------------------------------------
subjectID = 'test';
sessionNum = 'training';
fetchNewImages = 0;
% -------------------------------------------------------------------------
%% Pre-Task setup ---------------------------------------------------------
% Call Config_Training.m to set path variables
config = Config_Training(subjectID);
cd(config.root)

% Add Library and Drug Cues to path
addpath(config.lib);
addpath(config.cues);
addpath(config.data);

tmp_dir = dir(config.data);
tmp_dir(ismember({tmp_dir.name},{'.','..'})) = [];

disp(['Loading ' tmp_dir(1).name])
temp = load(tmp_dir(1).name); temp = temp.data;

weights = temp.weights;
cues = temp.CuesTypes;

% Fetch new image list depending on the input list arguement
list = image_list_gen_CR(subjectID, weights, cues);
[preloaded_images, random_list] = preload_CR_images(list);

% Fetch the directory of drugs to get the folder names for later
folder_names = cues;
% folder_names = folder_names.folderNames;

% Get total number of images
numImgs = length(list);
numImgs = 10;

% Load the Craving Rating Scale and resize
craving_scale = imread([config.rating_scales, '\', 'Slide1.jpeg']);
craving_scale = imresize(craving_scale,[1080,1920]);
%% Adjustable Parameters
% Size of onscreen text and the fixation "+"
textSize = 50;
fixSize = 250;

% Time to wait for a response and the duration of image presentation
time2wait = config.response_duration;
img_duration = config.image_duration;

% Strings for Instruction Screens
ScreenInstruct1 = '\n\n During this task, you will be presented with various stimuli, \n\n your job is to rate your craving for each image \n\n on a scale from 1 (lowest) to 9 (highest) \n\n\n\n\n\n Press "1" to continue';
ScreenInstruct2 = '\n\n Please wait for the Craving Rating Scale to appear on screen \n\n before entering your response.  \n\n\n\n Press "2" to continue';
ScreenInstruct3 = 'When presented with a "+" please rest with your \n\n eyes open and wait for the next block to start. \n\n\n\n Press "3" to continue';

% Base Fixation Duration before task starts
baseFixationTime = 2;

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
% if config.debug
%     PsychDebugWindowConfiguration();
% end

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
screenNumber = 2;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Used for something else entirely delete me
% img = imresize(imread('download (12).jpg'),[1080,1920]);
% Screen('PutImage', w, img);
% Screen('Flip', w);

% Query the frame duration
ifi = Screen('GetFlipInterval', w);
% main window dimensions
[X,Y] = RectCenter(windowRect);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Initialize storage for task information
ratings = cell(1,numImgs);
RT = cell(1,numImgs);
numRatings = cell(1,numImgs);

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

%% Waiting for MRI Trigger
% Set screen to wait for MRI trigger
Screen('TextStyle',w,1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, 'Waiting on MRI.....','center', 'center', black,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check
while 1
    str = GetChar(0);
    disp(str);
    if strcmp(str,'T')
        mri_onset = datetime('now');
        break;
    end
end
disp('MRI Trigger recieved')

%% Baseline Fixation Screen
Screen('TextStyle',w,1);
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);
while GetSecs - initialFixationOnset <= baseFixationTime, end

%% Start of Image Presentation
for j = 1:sum(numImgs)
    % Pull the current image to the screen
    Screen('PutImage', w, preloaded_images{j});
    imgOnset = Screen('Flip',w);

    % Create Rating Screen
    Screen('TextStyle',w,1);
    Screen('TextSize',w, textSize);
    Screen('TextFont',w, 'Arial');

    % DrawFormattedText(w, 'Rate the painfulness of the image: \n\n 1 (none), 2 (slight), 3 (moderate), 4 (extreme)','center', 'center', black,[],0,0);
    Screen('PutImage', w, craving_scale);

    % Allow the image to be on screen for x seconds
    while (GetSecs - imgOnset) <= img_duration, end

    % Flip rating scales to the screen
    imgOffset = Screen('Flip', w);

    % Have to wait to prevent CPU hogging
    WaitSecs(0.001);

    % Waiting for participant response
    timedOut = 0;
    tStart = GetSecs;
    while ~timedOut
        % check if a specified key is pressed
        [ keyIsDown, keyTime, keyCode ] = KbCheck;
        if(keyIsDown), break; end
        if( (keyTime - tStart) > time2wait)
            timedOut = true;
        end
    end

    % Records Reaction Time and Response Key
    if (~timedOut)
        RT{j} = keyTime - tStart;
        ratings{j} = KbName(find(keyCode));
    else
        RT{j} = 'inf';
        ratings{j} = 'undefined';
    end

    % Show Fixation Screen (RT + fixation time = 3 seconds)
    Screen('TextStyle',w, 1);
    Screen('TextSize',w, fixSize);
    Screen('TextFont',w, 'Arial');
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);
    Screen('Flip', w);

    % Rating RT + fixation = 3 seconds
    while GetSecs - tStart <= time2wait, end
end
% Get the duration of the task starting with the end - the first image onset
time = datetime('now') - mri_onset;

% Clear screen at the end of the task
sca;

%% Convert the keyCodes to number codes
for i = 1:sum(numImgs)
    % Convert Character to Number
    if strcmp(ratings{i},'a') || strcmp(ratings{i},'1!')
        numRatings{i} = 1;
    elseif strcmp(ratings{i},'b') || strcmp(ratings{i},'2@')
        numRatings{i} = 2;
    elseif strcmp(ratings{i},'c') || strcmp(ratings{i},'3#')
        numRatings{i} = 3;
    elseif strcmp(ratings{i},'d') || strcmp(ratings{i},'4$')
        numRatings{i} = 4;
    elseif strcmp(ratings{i},'5%')
        numRatings{i} = 5;
    elseif strcmp(ratings{i},'6^')
        numRatings{i} = 6;
    elseif strcmp(ratings{i},'7&')
        numRatings{i} = 7;
    elseif strcmp(ratings{i},'8*')
        numRatings{i} = 8;
    elseif strcmp(ratings{i},'9(')
        numRatings{i} = 9;
    elseif strcmp(ratings{i},'0)')
        numRatings{i} = 0;
    elseif strcmp(ratings{i},'undefined')
        numRatings{i} = nan;
    else 
    end
end

% show ratings as function of time
figure;
scatter(1:length(numRatings), cell2mat(numRatings));
xticklabels({list{:,2}}) %#ok<CCAT1> 

%% Calculate and Save Task Variables
% Store labeled ratings in ftemp
% ftemp = [random_list(:,2), numRatings'];

fake_ratings = num2cell(randi(10,[1,101])-1)';
ftemp = [random_list(:,2),fake_ratings];


folders_used = cell(length(folder_names),1);
% This loop extracts the ratings for each image type since the images were randomized
for i = 1:length(folder_names)
    tmp = [];
    for j = 1:length(ftemp)
        if strcmp(ftemp{j,1},folder_names{i}) %&& isinteger(ftemp{j,2})
            tmp = [tmp, ftemp{j,2}]; %#ok<AGROW>
        end
    end
    sorted_ratings{i,1} = tmp; %#ok<SAGROW>
    sorted_ratings{i,2} = mean(tmp,2); %#ok<SAGROW>
    sorted_ratings{i,3} = min(tmp,[],2); %#ok<SAGROW>
    sorted_ratings{i,4} = max(tmp,[],2); %#ok<SAGROW>

    folders_used{i,1} = folder_names{i};

end

% Create data struct to store the task variables
data.MRIonset = mri_onset;
data.numberRating = numRatings;
data.RT = RT;
data.CuesTypes = folders_used;

data.weights = [sorted_ratings{:,2}]'./sum([sorted_ratings{:,2}]);
data.min_weights = [sorted_ratings{:,3}]';
data.max_weights = [sorted_ratings{:,4}]';
data.save_time = datestr(now,'mm-dd-yyyy_HH:MM:SS');
data.random_list = random_list;

% Change directories and save task variables in correct location
cd(config.data)
mkdir(subjectID)
cd(subjectID)
save_name = [subjectID '_' sessionNum, '_', datestr(now,'mm_dd_yyyy'),'.mat'];
save(save_name,'data')
cd(config.root)

%% Extras
% temp for now
% fake_ratings = num2cell(randi(10,[1,50])-1)';
% ftemp = [random_list(:,2),fake_ratings];

% Useful if the images are presented in order
% ratings = cell2mat(reshape(ftemp(:,2),[10,5]));
