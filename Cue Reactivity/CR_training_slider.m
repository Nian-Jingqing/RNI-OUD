function data = CR_training_slider(subjectID, sessionID, protocolID, noExposure)
% Training.m is a script used to determine the best visual drug cues for
% the OUD task. The script will showcase a various panel of drug images
% while allowing the subject to provide a rating of their craving. These
% ratings will be used to automatically generate image sets to be used in
% the other OUD task such as DBS, Cue Reactivity, etc...
%
% ---- Jacob Suffridge May 2022
%
% Updated August 10th 2022
% Modify input methods to use keys across the top of the keyboard instead
% of the numpad
%
% Updated August 17th 2022
% Modify task to use a slider has the method of input instead of 0-9. Allow
% the participant to use leftKey to increase slider, rightKey to decrease slider and
% downKey to submit slider value. Also changed the ratings scales to
% config.slider_scales which is 0-10 with 0.25 tick spacing, without number
% labels.
%
% Updated September 6th 2022
% Added new standard images recieved from Daisy. Add sessionID, protocolID
% to the pathing and integrated into the app.
%
% Script Dependencies:
% Config_CR.m, image_list_gen_training.m, preload_training_images.m
%
% Config Parameters:
% config.textSize, config.fixSize, config.image_duration, config.baseFixation_duration
%
% Example Inputs:
% subjectID = 'test';
% sessionID = 'training';
% protocolID = 'DISCO';
% noExposure = {};
% ------------------------------------------------------------------------


%% Pre-Task setup ---------------------------------------------------------
% KbCheck Commands
KbName('UnifyKeyNames');
leftKey = 'LeftArrow';
rightKey = 'RightArrow';
acceptKey = 'DownArrow';

RestrictKeysForKbCheck([KbName(leftKey),KbName(rightKey),KbName(acceptKey)]);

% Add path to lib to initialize Config_Training function
addpath('/home/helpdesk/Documents/MATLAB/RNI-OUD/Cue Reactivity/Lib');

% Call Config_Training.m to set path variables
config = Config_CR(subjectID);
cd(config.root)

% Path to load the training cue list
list_load_path = [config.root, '/Training_Cue_List.mat']; %#ok<*NASGU> 

% Add Library and Drug Cues to path
addpath(config.lib);
addpath(config.cues);

% % New activeKeys for slider input
% activeKeys = [KbName('a'), KbName('b'), KbName('space')];
% RestrictKeysForKbCheck(activeKeys);

% Create save_name for output file
save_name = [config.data_short, protocolID, '/', subjectID '_' sessionID,'_', datestr(now,'mm_dd_yyyy__HH_MM_SS') '.mat'];

commandwindow;

%% Adjustable Parameters
% Strings for Instruction Screens
% ScreenInstruct1 = '\n\n During this task, you will be presented with various stimuli, \n\n your job is to rate your craving for each image \n\n on a scale from 1 (lowest) to 9 (highest) \n\n\n\n\n\n Press "1" to continue';
% ScreenInstruct2 = '\n\n Please wait for the Craving Rating Scale to appear on screen \n\n before entering your response.  \n\n\n\n Press "2" to continue';
% ScreenInstruct3 = 'When presented with a "+" please rest with your \n\n eyes open and wait for the next block to start. \n\n\n\n Press "3" to continue';

% ScreenInstruct1 = 'During this task, you will be shown a series of images \n\n\n Press the "a" button to continue';
% ScreenInstruct2 = 'Before and after each image you will be asked to \n\n rate your craving on a slider scale \n\n\n Press the "b" button to continue';
% ScreenInstruct3 = 'When the slider is on screen: \n\n\n Press the "a" button to increase the slider \n\n\n Press the "b" button to decrease the slider \n\n\n Press the "spacebar" to submit your answer \n\n\n Press the "a" button to continue';
% ScreenInstruct4 = 'Please wait for the MRI to start';

ScreenInstruct1 = 'During this task, you will be shown a series of images \n\n\n Press the LEFT arrow button to continue';
ScreenInstruct2 = 'Before and after each image you will be asked to \n\n rate your craving on a slider scale \n\n\n Press the RIGHT arrow button to continue';
ScreenInstruct3 = 'When the slider is on screen: \n\n\n Press the RIGHT arrow button to increase the slider \n\n\n Press the LEFT arrow button to decrease the slider \n\n\n Press the DOWN arrow button to submit your answer \n\n\n Press the DOWN arrow button to continue';
ScreenInstruct4 = 'Press the LEFT arrow button to start the task';

%% Screen Setup
% Call some default settings for setting up Psychtoolbox
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
% screenNumber = 1;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Prepare a loading screen
Screen('TextStyle',w, 1);
Screen('TextSize',w, config.textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, 'Loading...', 'center', 'center', black, [], 0, 0);
Screen('Flip',w);

% Load the Craving Rating Scales
for i = 2:42
    craving_scales{i-1} = imresize(imread([config.slider_scales,'/Slide', num2str(i), '.JPG']),[screenYpixels,screenXpixels]);
end
% base_rating = imresize(imread([config.slider_scales,'/Slide1.JPG']),[screenYpixels,screenXpixels]);
base_rating = craving_scales{21};

% Pull image list, fetch the folder names for later
[list, folder_names] = image_list_gen_training(subjectID, noExposure);

% Preload the stimulus images into memory
[preloaded_images, random_list] = preload_training_images(list,screenYpixels, screenXpixels);

% Get total number of images (Can set a low number for debugging)
% numImgs = length(list);
numImgs = 5;

% Index the slider ticks
slider_ticks = 0:.25:10;

% Initialize storage for task information and timestamps
RT = cell(numImgs,1);
ratings = cell(numImgs,1);
img_starts = cell(numImgs,1);
rating_starts = cell(numImgs,1);

instructionStamps = cell(4,1);
%% Instruction Set 1
% Create screen for first set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, config.textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct1, 'center', 'center', black, [], 0, 0);
instructionStamps{1} = Screen('Flip', w);

% Listen for keyboard input to proceed
FlushEvents('KeyDown');
while true
    while true
        % check if a specified key is pressed
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if(keyIsDown)
            break;
        end
    end
    if strcmp(KbName(find(keyCode)),leftKey)
        break;
    end
end

%% Instruction Set 2
% Create screen for second set of instructions
DrawFormattedText(w,ScreenInstruct2,'center', 'center', black,[],0,0);
instructionStamps{2} = Screen('Flip', w);

% Listen for keyboard input to proceed
FlushEvents('KeyDown');
while true
    while true
        % check if a specified key is pressed
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if(keyIsDown)
            break;
        end
    end
    if strcmp(KbName(find(keyCode)),rightKey)
        break;
    end
end

%% Instruction Set 3
% Create screen for fourth set of instructions
DrawFormattedText(w, ScreenInstruct3, 'center', 'center', black, [], 0, 0);
instructionStamps{3} = Screen('Flip', w);

% Listen for keyboard input to proceed
FlushEvents('KeyDown');
while true
    while true
        % check if a specified key is pressed
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if(keyIsDown)
            break;
        end
    end
    if strcmp(KbName(find(keyCode)),acceptKey)
        break;
    end
end
%% Instruction Slider
% Draw the base rating screen
Screen('PutImage', w, base_rating);
Screen('Flip', w);

% Add some delay to not get carry over presses from previous instructions
WaitSecs(0.5);

% Suppress keyboard echo to the command window
ListenChar(2)

str = [];
% start the slider index at 1
slider_count = 21;

while true
    % Waiting for participant response
    while true
        % check if a specified key is pressed
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if(keyIsDown)
            while KbCheck, end
            break;
            %             elseif GetSecs - block_start >= config.slider_duration
            %                 break;
        end
    end
    % Get the string for the key press
    str = KbName(find(keyCode));

    % Increase slider_count and update slider image
    if strcmp(str,rightKey)

        % Increase the slider count
        slider_count = slider_count + 1;
        % If the slider is all the way right move it all the way left
        if slider_count > length(craving_scales)
            slider_count = 1;
        end

        % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales{slider_count});
        Screen('Flip', w);

        % Decrease the slider_count and update slider image
        % Disable this elseif to remove the decrease functionality, useful
        % for sticking to 2 buttons
    elseif strcmp(str,leftKey)

        % Decrease the slider count
        slider_count = slider_count - 1;
        % If the slider is all the way left move it all the way right
        if slider_count == 0
            slider_count = length(craving_scales);
        end

        % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales{slider_count});
        Screen('Flip', w);
        
        % if str is not empty and not the left/right key then its the escape key
    elseif strcmp(str,acceptKey)
        % Draw fixation to the screen between sliders/images
        Screen('TextSize',w, config.fixSize);
        DrawFormattedText(w,'+','center', 'center', black,[],0,0);
        Screen('Flip', w);
        WaitSecs(.5);
        break;
    else
    end
    % Reset str at the end of while loop, also reset slider_count if at end of slider
    str = [];
end

%% Waiting for Task to Start
% Set screen to wait task start
Screen('TextSize',w, config.textSize);
DrawFormattedText(w, ScreenInstruct4,'center', 'center', black,[],0,0);
instructionStamps{4} = Screen('Flip', w);

% Listen for keyboard input to proceed
FlushEvents('KeyDown');
while true
    while true
        % check if a specified key is pressed
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if(keyIsDown)
            break;
        end
    end
    if strcmp(KbName(find(keyCode)),leftKey)
        taskOnset = GetSecs;
        break;
    end
end
disp('Task Started')

%% Baseline Fixation Screen
Screen('TextSize',w,config.fixSize);
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Get timestamp for Initial fixation to determine remaining duration
Screen('Flip', w);
WaitSecs(config.baseFixation_duration);

%% Start of Image Presentation
ListenChar(2);
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

    %% Slider
    % Start Slider Loop
    str = [];
    % start the slider index at 1
    slider_count = 21;

    while true
        % Waiting for participant response
        while true
            % check if a specified key is pressed
            [ keyIsDown, ~, keyCode ] = KbCheck;
            if(keyIsDown)
                while KbCheck, end
                break;
                %             elseif GetSecs - block_start >= config.slider_duration
                %                 break;
            end
        end
        % Get the string for the key press
        str = KbName(find(keyCode));

        % Increase slider_count and update slider image
        if strcmp(str,rightKey)

            % Increase the slider count
            slider_count = slider_count + 1;
            % If the slider is all the way right move it all the way left
            if slider_count > length(craving_scales)
                slider_count = 1;
            end

            % Draw the rating feedback image to the screen
            Screen('PutImage', w, craving_scales{slider_count});
            Screen('Flip', w);

            % Decrease the slider_count and update slider image
            % Disable this elseif to remove the decrease functionality, useful
            % for sticking to 2 buttons
        elseif strcmp(str,leftKey)

            % Decrease the slider count
            slider_count = slider_count - 1;
            % If the slider is all the way left move it all the way right
            if slider_count == 0
                slider_count = length(craving_scales);
            end

            % Draw the rating feedback image to the screen
            Screen('PutImage', w, craving_scales{slider_count});
            Screen('Flip', w);

            % if str is not empty and not the left/right key then its the escape key
        elseif strcmp(str,acceptKey)
            % Record the slider rating
            ratings{j} = slider_ticks(slider_count);
            % Record the reaction time of the slider submission
            RT{j} = GetSecs - rating_starts{j};

            % Draw fixation to the screen between sliders/images
            DrawFormattedText(w,'+','center', 'center', black,[],0,0);
            Screen('Flip', w);
            WaitSecs(.5);
            %             WaitSecs(config.slider_duration - (pre_break - block_start));
            break;
        else
        end
        % Reset str at the end of while loop, also reset slider_count if at end of slider
        str = [];
    end
end
% Clear screen at the end of the task
sca;
ListenChar();

% Reenable all keys
RestrictKeysForKbCheck([]);
%% Calculate and Save Task Variables
% Store labeled ratings in ftemp
ftemp = [random_list(1:numImgs,:), ratings];

% Fake full size ratings (delete before final version)
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
data.ratings = ratings;
data.RT = RT;
data.cuesTypes = folders_used;
data.weights = [sorted_ratings{:,2}]'./sum([sorted_ratings{:,2}]);
data.min_weights = [sorted_ratings{:,3}]';
data.max_weights = [sorted_ratings{:,4}]';
data.save_time = datestr(now,'mm-dd-yyyy_HH:MM:SS');
data.img_starts = img_starts;
data.rating_starts = rating_starts;

% Save timestamps in data
data.instructionStamps = instructionStamps;
data.taskOnset = taskOnset;

save(save_name,'data');
cd(config.root)

end