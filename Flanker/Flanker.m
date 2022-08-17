function [] = Flanker(subjectID)
% Main Script for flanker
% written June 2022 Jacob Suffridge
% subjectID must be a string, EX: subjectID = '1234';

clc;
% subjectID = 'jacob';

% Shift focus to the command window 
commandwindow

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Flanker/';
dataPath = [basePath, 'Flanker Data/'];
targetPath = [basePath, 'Flanker Targets/'];

% Create save directory in "Flanker Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)
% Create string to save the data later
saveName = [dataPath, subjectID, '/' subjectID '_Flanker_' , datestr(now,'mm_dd_yyyy') '.mat'];

%% Parameters to Adjust
textSize = 60;
fixSize = 250;
time2wait = 1.2;

baseFixationTime = 4;
InterTrialFixationTime = 1;   %14

% Strings for Instruction Screens
ScreenInstruct1 = 'Please select the direction of the middle arrow as quickly as possible \n\n\n Press the 1 button (YELLOW) to continue';
ScreenInstruct2 = 'If the center arrow is facing RIGHT press the ONE button (YELLOW), \n\n\n if the center arrow is facing LEFT push the TWO button (BLUE) \n\n\n Press the 2 button (BLUE) to continue';
ScreenInstruct3 = 'Please wait for the MRI to start';

%% Prepare the screen
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
% screenNumber = 2;

% Define black and white screens
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% % Query the frame duration
% ifi = Screen('GetFlipInterval', w);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Load the target patterns into memory
scale_factor = 1.75;
target1 = imresize(imread([targetPath, 'Target1.bmp']), scale_factor);
target2 = imresize(imread([targetPath, 'Target2.bmp']), scale_factor);
target3 = imresize(imread([targetPath, 'Target3.bmp']), scale_factor);
target4 = imresize(imread([targetPath, 'Target4.bmp']), scale_factor);
target5 = imresize(imread([targetPath, 'Target5.bmp']), scale_factor);
target6 = imresize(imread([targetPath, 'Target6.bmp']), scale_factor);

% Create pseudo random listing to call flanker targets
target_list = [];
num_trials = 60;
for i = 1:6
    C    = cell(1, num_trials/6);
    C(:) = {['target', num2str(i)]};
    target_list = [target_list; C]; %#ok<AGROW>
end
target_list = reshape(target_list, num_trials, []);
target_list = target_list(randperm(num_trials));

target_imgs = cell(size(target_list));
for i = 1:num_trials
    target_imgs{i} = eval(target_list{i});
end 
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

%% Waiting for MRI Trigger
% Set screen to wait for MRI trigger
Screen('TextStyle',w,1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct3,'center', 'center', black,[],0,0);
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
disp('MRI Trigger received')
clc;

%% Initial Fixation pre-Task
Screen('TextStyle',w,1);
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);
% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

% while GetSecs - initialFixationOnset <= baseFixationTime, end
WaitSecs(baseFixationTime);

%% Task
num_trials = 5;
% num_trials = length(target_list);

% Allocate space to store ratings and reaction times
ratings = cell(num_trials, 1);
RT = cell(num_trials, 1);

% Suppress keyboard echo to command window
ListenChar(2)
% Loop through the predefined presentation list
for i = 1:num_trials
    
    % Pull target for current iteration
    tmp_target = target_imgs{i};

    % Draw target on center of the screen
    Screen('PutImage', w, tmp_target);
    % Flip everything to the screen
    Screen('Flip', w);

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
        RT{i} = keyTime - tStart;
        ratings{i} = KbName(find(keyCode));
    else
        RT{i} = nan;
        ratings{i} = [];
    end

    % Show Fixation Screen (RT+fixation time = time2wait seconds)
    Screen('TextStyle',w, 1);
    Screen('TextSize',w, 250);
    Screen('TextFont',w, 'Arial');
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);
    Screen('Flip', w);
    WaitSecs(time2wait - RT{i});

end

% Renable the keyboard echo and screen clear all
ListenChar();
sca;

%% Post-Task
% Create data struct to save the data
data.ratings = ratings;
data.RT = RT;
data.MRI_onset = mri_onset;

% save data to DD Data >> subjectID
save(saveName,'data')
cd(basePath)
% end