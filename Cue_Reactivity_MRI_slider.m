function data = Cue_Reactivity_MRI_slider(subjectID,sessionNum,taskType)
% Main Script to run Weighted and Static Cue Reactivity in the MRI with
% pre/post block sliders
%
% ---J Suffridge July 2022
% 
% Updated August 10th 2022
% Started adding report generating functionality to the post task process. 
% 
% 
% 
% Script Dependencies:
% Config_CR.m, image_list_gen_CR.m, preload_CR_images.m
%
% Config Parameters:
% config.textSize, config.fixSize, config.image_duration, config.interTrial_duration,
% config.baseFixation_duration, config.slider_durationei
%
% Example Inputs:
% subjectID = 'Cody';
% sessionNum = 'CR_MRI';
% taskType = 'Weighted';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add path to lib to initialize Config_Training function
addpath('/home/helpdesk/Documents/MATLAB/RNI-OUD/Lib');

% Initialize config and add paths
config = Config_CR(subjectID);
% Add Library to path
addpath(config.lib)
addpath(config.data)

% Create save_name for output file
save_name = [subjectID '_' sessionNum, '_', taskType, '_', datestr(now,'mm_dd_yyyy__HH_MM_SS') '.mat'];
KbName('UnifyKeyNames');

%% Adjustable Parameters
% Strings for Instruction Screens
ScreenInstruct1 = 'During this task, you will be shown a series of images \n\n\n Press the 1 button (YELLOW) to continue';
ScreenInstruct2 = 'Before and after each block of images \n\n you will be asked to rate your craving on a scale of 0 to 9 \n\n\n Press the 2 button (BLUE) to continue';
ScreenInstruct3 = 'When the slider is on screen: \n\n\n Press the 1 button (Yellow) to increase the slider \n\n\n Press the 2 button (Blue) to finalize your answer \n\n\n Press the 1 button (Yellow) to continue';
ScreenInstruct4 = 'Please wait for the MRI to start';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of Blocks and Images per Block
% numBlocks = length(list);
% numImgs = length(list{1});
numBlocks = 1;
numImgs = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Screen Setup
% Call some default settings for Psychtoolbox set up
PsychDefaultSetup(2);
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
% screenNumber = 2;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

%% Load the Craving Rating Scales (After Screen calls to set screen dims automatically)
craving_scales = load([config.rating_scales, '/craving_scales.mat']).craving_scales;
for i = 1:length(craving_scales)
    craving_scales{i} = imresize(craving_scales{i},[screenYpixels,screenXpixels]);
end
base_rating = craving_scales{end};

% Add functionality to toggle between Weighted and Static Cues
if strcmp(taskType,'Weighted')

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

% Initialize storage for "for" loop
% img_timestamps = cell(length(list{1}), length(list));
img_timestamps = cell(1,10);

pre_block = [];
post_block = [];
pre_RT = [];
post_RT = [];

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
    if strcmp(str,'a')
        break;
    end
end

%% Instruction Set 2
% Create screen for second set of instructions
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
% Create screen for fourth set of instructions
DrawFormattedText(w, ScreenInstruct3, 'center', 'center', black, [], 0, 0);
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

%% Instruction Slider
% Draw the base rating screen
Screen('PutImage', w, base_rating);
Screen('Flip', w);

str = [];
slider_count = 0;
while 1
    % Keyboard is listening for key-presses
    str = GetChar(0);

    % Increase slider_count and update slider image
    if strcmp(str,'a')
        slider_count = slider_count + 1;

        % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales{slider_count+1});
        Screen('Flip', w);

        % If 'b' then accept the slider value and continue
    elseif strcmp(str,'b')
        break;
    end

    % Reset str at the end of while loop, also reset slider_count if at end of slider
    str = [];
    if slider_count == 10
        slider_count = 0;
    end
end

%% Waiting for MRI Trigger
% Set screen to wait for MRI trigger
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
    elseif strcmp(str,' ')
        return
    end
end
disp('MRI Trigger received')

%% Baseline Fixation Screen
Screen('TextStyle',w,1);
Screen('TextSize',w,config.fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Initial Fixation pre-task timestamp to determine remaining duration
initialFixationOnset = Screen('Flip', w);

% Show the base fixation for var seconds
WaitSecs(config.baseFixation_duration);

ListenChar(2)
for i = 1 %:numBlocks
    %% Pre-block slider
    block_start = GetSecs;
    % Start Slider Loop
    str = [];
    slider_count_pre = 0;
    pre_break = nan;
   
    % Draw the base rating screen
    Screen('PutImage', w, base_rating);
    Screen('Flip', w);

    while GetSecs - block_start < config.slider_duration
        % Waiting for participant response
        while 1
            % check if a specified key is pressed
            [ keyIsDown, ~, keyCode ] = KbCheck;
            if(keyIsDown)
                while KbCheck, end
                break;
            elseif GetSecs - block_start >= config.slider_duration
                break;
            end
        end
        str = KbName(find(keyCode));

        % Increase slider_count_pre and update slider image
        if strcmp(str,'a')
            slider_count_pre = slider_count_pre + 1;

            % Draw the rating feedback image to the screen
            Screen('PutImage', w, craving_scales{slider_count_pre+1});
            Screen('Flip', w);

            % If 'b' then accept the slider value and continue with fixation
        elseif strcmp(str,'b')
            pre_break = GetSecs;
            DrawFormattedText(w,'+','center', 'center', black,[],0,0);
            Screen('Flip', w);

            WaitSecs(config.slider_duration - (pre_break - block_start));
            break;
        else
        end

        % Reset str at the end of while loop, also reset slider_count if at end of slider
        str = [];
        if slider_count_pre == 10
            slider_count_pre = 0;
        end
    end

    % Save the pre-block craving rating
    pre_block = [pre_block; slider_count_pre];  %#ok<*AGROW>
    pre_RT = [pre_RT; pre_break - block_start];

    % Allow interTrial fixation to be on screen for var seconds
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);
    Screen('Flip', w);
    WaitSecs(config.interTrial_duration);

    %% Image Blocks
    for j = 1:numImgs
        % Pull the current image to the screen
        Screen('PutImage', w, output{i}{j});
        imgOnset = Screen('Flip',w);
        img_timestamps{i}{j} = imgOnset;

        % Allow the image to be on screen for 2 seconds
        WaitSecs(config.image_duration);

        % InterTrial Fixation
        DrawFormattedText(w, '+','center', 'center', black,[],0,0);
        fixationOnset = Screen('Flip', w);

        % Allow interTrial fixation to be on screen for var seconds
        WaitSecs(config.interTrial_duration);
    end

    %% Post-block slider
    block_end = GetSecs;
    % Start Slider Loop
    str = [];
    slider_count_post = 0;
    post_break = nan;

    % Draw the base rating screen
    Screen('PutImage', w, base_rating);
    Screen('Flip', w);

    while GetSecs - block_end < config.slider_duration
        % Waiting for participant response
        while 1
            % check if a specified key is pressed
            [ keyIsDown, ~, keyCode ] = KbCheck;
            if(keyIsDown)
                while KbCheck, end
                break;
            elseif GetSecs - block_start >= config.slider_duration
                break;
            end
        end
        str = KbName(find(keyCode));

        % Increase slider_count_post and update slider image
        if strcmp(str,'a')
            slider_count_post = slider_count_post + 1;

            % Draw the rating feedback image to the screen
            Screen('PutImage', w, craving_scales{slider_count_post+1});
            Screen('Flip', w);

            % If 'b' then accept the slider value and continue
        elseif strcmp(str,'b')
            post_break = GetSecs;
            DrawFormattedText(w,'+','center', 'center', black,[],0,0);
            Screen('Flip', w);

            WaitSecs(config.slider_duration - (post_break - block_end));
            break;
        end

        % Reset str at the end of while loop, also reset slider_count if at end of slider
        str = [];
        if slider_count_post == 10
            slider_count_post = 0;
        end
    end

    % Save the post-block craving rating
    post_block = [post_block;slider_count_post];
    post_RT = [post_RT; post_break - block_end];

    % Allow interTrial fixation to be on screen for var seconds
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);
    Screen('Flip', w);
    WaitSecs(config.interTrial_duration);
end
% Get the duration of the task starting with the end - the MRI onset
time = GetSecs - mri_onset;
% Clear screen at the end of the task
sca;
ListenChar(0)

%% Save Task Variables
% Create a new data struct to store the task variables
Data.MRIonset = mri_onset;
% Slider Ratings from before and after each block
Data.preBlockRatings = pre_block;
Data.postBlockRatings = post_block;
% Slider Reaction Times from before and after each block
Data.preBlockRT = pre_RT;
Data.postBlockRT = post_RT;
Data.save_time = datestr(now,'mm-dd-yyyy_HH:MM:SS');

% Change directories and save task variables in correct location
cd(config.data)
mkdir('CR MRI')
cd('CR MRI')
save(save_name,'Data')
cd(config.root)

CR_MRI_report_generator(data,Data,subjectID);
end