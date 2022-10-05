function [] = PVT(subjectID, sessionID, protocolID)
% Main Script for PVT outside the MRI scanner
% written June 2022 Jacob Suffridge
%
% Example Inputs: (input must be a string that can be used in a directory name)
% subjectID = 'jacob';
% sessionID = 'testz';
% protocolID = 'DISCO';
%
%
%% ------------------------------------------------------------------------
clc;

% flag for demo mode
demoMode = 0;

% KbCheck Commands
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([KbName('LeftArrow'),KbName('RightArrow')]);

% Shift focus to the command window 
commandwindow

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/PVT/';
dataPath = [basePath, 'PVT Data/', protocolID, '/'];

% Create save directory in "PVT Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)
% Create string to save the data later
saveName = [dataPath, subjectID, '/', subjectID, '_PVT_', sessionID, '_', datestr(now,'mm_dd_yyyy'), '.mat'];

%% Parameters to Adjust
times = [1,2,3,2,1];

textSize = 60;
fixSize = 250;
time2wait = 1.2;

baseFixationTime = 4;
InterTrialFixationTime = 1;   %14

% Strings for Instruction Screens
ScreenInstruct1 = 'Press the left arrow button to continue';
ScreenInstruct2 = 'Press the right arrow button to continue';
ScreenInstruct3 = 'Press the left arrow button to begin the task';

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

% Get instruction timestamps
instructionStamps = cell(3,1);
%% Instruction Set 1
% Create screen for first set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, textSize);
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
    if strcmp(KbName(find(keyCode)),'LeftArrow')
        break;
    end
end

%% Instruction Set 2
% Create screen for second set of instructions
Screen('TextStyle',w,1);
Screen('TextSize',w,textSize);
Screen('TextFont',w,'Arial');
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
    if strcmp(KbName(find(keyCode)),'RightArrow')
        break;
    end
end

%% Waiting for Participant to start task
Screen('TextStyle',w,1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct3,'center', 'center', black,[],0,0);
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
    if strcmp(KbName(find(keyCode)),'LeftArrow')
        taskOnset = GetSecs;
        break;
    end
end
disp('Task Started')
clc;

%% Initial Fixation pre-Task
Screen('TextStyle',w,1);
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);
% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

WaitSecs(baseFixationTime);

%% Task

% Allocate space to store ratings, reaction times and timestamps
ratings = cell(num_trials, 1);
RT = cell(num_trials, 1);

trialTimestamps = cell(num_trials, 1);
interTrialFixationStamps = cell(num_trials, 1);

% Suppress keyboard echo to command window
ListenChar(2)
% Loop through the predefined presentation list
for i = 1:num_trials
    
    % while GetSecs - start < duration

    % Flip everything to the screen and timestamp the trial
    trialTimestamps{i} = Screen('Flip', w);

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
    Screen('TextSize',w, 250);
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);

    % Get fixation timestamp
    interTrialFixationStamps{i} = Screen('Flip', w);
    WaitSecs(time2wait - RT{i});

end

% Renable the keyboard echo and screen clear all
ListenChar();
sca;

%% Post-Task


% Create data struct to save the data
data.ratings = ratings;
data.RT = RT;


% Save timestamps in data
data.instructionStamps = instructionStamps;
data.taskOnset = taskOnset;
data.initialFixationOnset = initialFixationOnset;
data.trialTimestamps = trialTimestamps;
data.interTrialFixationStamps = interTrialFixationStamps;

% save data to Flanker Data >> subjectID
save(saveName,'data')
cd(basePath)

end