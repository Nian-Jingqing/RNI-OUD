function [] = Cue_Reactivity_MRI(subjectID,sessionNum,taskType)
% Main Script to run Weighted and Static Cue Reactivity in the MRI
% written June 2022 Jacob Suffridge
% 
% Script Dependencies:
% Config_Training.m, image_list_gen_CR.m, preload_CR_images.m
% 
% Example Inputs:
% subjectID = 'test';
% sessionNum = 'CR1';
% taskType = 'Weighted';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize config and add paths
config = Config_Training(subjectID);
% Add Library to path
addpath(config.lib)
addpath(config.data)

% Create save_name for output file
save_name = [subjectID '_' sessionNum, '_', taskType, '_', datestr(now,'mm_dd_yyyy') '.mat'];
KbName('UnifyKeyNames');

% Determine the mat file to load from training session
cd(config.data)
try
    load_file = dir('*.mat');
    load_file = load_file(end).name;
    disp(['Loading weights from ' load_file])
catch
    disp('Training file not found check path or call support')
    return 
end
cd(config.root)

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
ScreenInstruct1 = 'During this task, you will be shown a series of images \n\n\n Press the 1 button (YELLOW) to continue';
ScreenInstruct2 = 'After each image you will be asked to rate your craving on a scale of 1 to 4 \n\n\n The next screen will show an example rating scale \n\n\n Press the 2 button (BLUE) to continue';
ScreenInstruct3 = 'Please wait until you see the rating screen to enter your craving \n\n\n Press the 4 button (GREEN) to continue';
ScreenInstruct4 = 'Please wait for the MRI to start';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of Blocks and Images per Block
% numBlocks = length(list);
numBlocks = 1;
numImgs = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', w);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Load the Craving Rating Scales
base_rating = imresize(imread([config.MRI_rating_scales 'Slide1.jpg']),[screenYpixels,screenXpixels]);
base_rating_instruct = imresize(imread([config.MRI_rating_scales 'Slide1_instruct.jpg']),[screenYpixels,screenXpixels]);

% Add functionality to toggle between Weighted and Static Cues
if strcmp(taskType,'Weighted')
    % Load weight/cues etc. from training session
    data = load(load_file).data;
    cues = data.CuesTypes;
    weights = data.weights;
    % Fetch image list depending on the input "list" arguement
    list = image_list_gen_CR(subjectID, weights, cues);

elseif strcmp(taskType,'Static')
    list = load('static_cues_list.mat');
end
output = preload_CR_images(list,screenYpixels, screenXpixels);

% Initialize storage for task information
ratings = cell(numBlocks,numImgs);
RT = cell(numBlocks,numImgs);
numRatings = cell(numBlocks,numImgs);

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
    if strcmp(str,'a')
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
    if strcmp(str,'b')
        break;
    end
end

%% Instruction Set 3
% Create screen for third set of instructions
Screen('PutImage', w, base_rating_instruct);
Screen('Flip',w);

str = [];
FlushEvents('KeyDown');
% trigger release check for third instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'c')
        break;
    end
end

%% Instruction Set 4
% Create screen for fourth set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct3, 'center', 'center', black, [], 0, 0);
Screen('Flip', w);

str = []; %#ok<*NASGU>
FlushEvents('KeyDown');
% trigger release check for first instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'d')
        break;
    end
end

%% Waiting for MRI Trigger
% Set screen to wait for MRI trigger
Screen('TextStyle',w,1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct4,'center', 'center', black,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check
while 1
    str = GetChar(0);
    disp(str);
    if strcmp(str,'T')
        mri_onset = GetSecs;
        break;
    end
end
disp('MRI Trigger recieved')

% Baseline Fixation Screen
Screen('TextStyle',w,1);
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

%% Initial Fixation pre-Task
% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

% while GetSecs - initialFixationOnset <= baseFixationTime, end
WaitSecs(baseFixationTime)

RestrictKeysForKbCheck();

% Initialize storage for timestamps
img_timestamps = cell(1,10);
rating_timestamps = cell(1,10);

%% Start of Blocks
for i = 1:numBlocks
    for j = 1:numImgs
        % Pull the current image to the screen
        Screen('PutImage', w, output{i}{j});
        imgOnset = Screen('Flip',w);
        img_timestamps{i}{j} = imgOnset;

        % Draw the rating screen
        Screen('PutImage', w, base_rating);

        % Allow the image to be on screen for 2 seconds
        %         while (GetSecs - imgOnset) <= img_duration, end
        WaitSecs(img_duration)

        % Flip rating scales to the screen
        ratingOnset = Screen('Flip', w);
        rating_timestamps{i}{j} = ratingOnset;

        % Have to wait to prevent CPU hogging
        WaitSecs(0.0001);

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
            RT{i,j} = keyTime - tStart;
            ratings{i,j} = KbName(find(keyCode));
        else
            RT{i,j} = 100;
            ratings{i,j} = [];
        end

        % Show Fixation Screen (RT+fixation time = time2wait seconds)
        Screen('TextStyle',w, 1);
        Screen('TextSize',w, fixSize);
        Screen('TextFont',w, 'Arial');
        DrawFormattedText(w, '+','center', 'center', black,[],0,0);
        Screen('Flip', w);

        % Rating RT + fixation = time2wait seconds
        %         while GetSecs - tStart <= time2wait,     end
        WaitSecs(time2wait-RT{i,j})
    end

    % Baseline Fixation Screen again (baseFixationTime in sec)
    Screen('TextStyle',w, 1);
    Screen('TextSize',w, fixSize);
    Screen('TextFont',w, 'Arial');
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);
    fixationOnset = Screen('Flip', w);

    % Allows fixation cross to remain on screen for 20 seconds
    %     while GetSecs - fixationOnset <= baseFixationTime, end
    WaitSecs(baseFixationTime)

end

% Get the duration of the task starting with the end - the first image onset
time = GetSecs - mri_onset;

% Clear screen at the end of the task
sca;

%% Convert the keyCodes to number codes
for i = 1:numBlocks
    for j = 1:numImgs
        % Convert Character to Number
        if strcmp(ratings{i,j},'a')
            numRatings{i,j} = 1;
        elseif strcmp(ratings{i,j},'b')
            numRatings{i,j} = 2;
        elseif strcmp(ratings{i,j},'c')
            numRatings{i,j} = 3;
        elseif strcmp(ratings{i,j},'d')
            numRatings{i,j} = 4;
        else
        end
    end
end

%% Save Task Variables
% Create a new data struct to store the task variables
clear data
data.MRIonset = mri_onset;
data.numberRating = numRatings;
data.RT = RT;

data.img_timestamps = img_timestamps;
data.rating_timestamps = rating_timestamps;

% Change directories and save task variables in correct location
cd(config.data)
save(save_name,'data')
cd(config.root)

end