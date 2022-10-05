function [] = Nback(subjectID,sessionID,protocolID)
% Main Script for NBack
% written June 2022 Jacob Suffridge
%
% Updated September 6th 2022
% Modified for baseline run for Daisy. Added sessionID, protocolID into the
% pathing. This script relies on loading a .mat file that will need to be
% set for future tasks
%
% Example Inputs: (input must be a string that can be used as a directory name
subjectID = 'test123';
sessionID = '1';
protocolID = 'DISCO';
%% ------------------------------------------------------------------------
clc;

% KbCheck Commands
KbName('UnifyKeyNames');
targetKey = 'LeftArrow';
nonTargetKey = 'RightArrow';
RestrictKeysForKbCheck([KbName(targetKey),KbName(nonTargetKey)]);

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Nback/';
dataPath = [basePath, 'NBack Data/', protocolID, '/'];

% Create save directory in "NBack Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)

% Create string to save the data later
saveName = [dataPath, subjectID, '/', subjectID, '_N_Back_', sessionID, '_', datestr(now,'mm_dd_yyyy'), '.mat'];
csvName = [saveName(1:end-4), '.csv'];

% Load the trial lists
list = load('Nback_List_longer_from_ePrime.mat');
list = list.list;

%% Parameters to Adjust
textSize = 60;
fixSize = 250;
time2wait = 0.5;
baseFixationTime = 4;
InterBlockFixationTime = 4;
instructionTime2wait = 6;

Blocks = {'Zero','Two','Zero','Two','Zero','Two'};

% Strings for Instruction Screens
ScreenInstruct1 = 'This task involves viewing single letters \n\n presented one at a time.\n\n\n Your job is to determine if the letter on screen \n\n is a target or a non-target. \n\n\n Press the LEFT arrow button to continue';
ScreenInstruct2 = 'If the letter on the screen is a target, you \n\n should press the LEFT arrow button. \n\n If the letter on the screen is a non-target, you \n\n should press the RIGHT arrow button. \n\n\n Press the RIGHT arrown button to continue';
ScreenInstruct3 = 'When presented with a "+" please focus with \n\n your eyes open and wait for the next block to start. \n\n\n\n\n Please the LEFT arrow button to begin the task';

%#ok<*NASGU>
ScreenInstructZeroBack = 'Zero-back condition: \n\n A letter is a target if it is the letter A. \n\n\n LEFT arrow = Target \n\n RIGHT arrow = Non-target \n\n\n\n The task will begin shortly';
ScreenInstructOneBack = 'One-back condition: \n\n A letter is a target if it is the same as the letter \n\n that came ONE before it. \n\n\n LEFT arrow = Target \n\n RIGHT arrow = Non-target \n\n\n\n The task will begin shortly';
ScreenInstructTwoBack = 'Two-back condition: \n\n A letter is a target if it is the same as the letter \n\n that came TWO before it. \n\n\n LEFT arrow = Target \n\n RIGHT arrow = Non-target \n\n\n\n The task will begin shortly';

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

% Get the size of the on screen window
%#ok<*ASGLU>
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
    if strcmp(KbName(find(keyCode)),targetKey)
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
    if strcmp(KbName(find(keyCode)),nonTargetKey)
        break;
    end
end

%% Waiting for Task to Start
% Set screen to wait for MRI trigger
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
    if strcmp(KbName(find(keyCode)),targetKey)
        taskOnset = GetSecs;
        break;
    end
end
disp('Task Started')
clc;

%% Initial Fixation pre-Task
Screen('TextSize',w,fixSize);
DrawFormattedText(w,'+','center', 'center', black,[],0,0);
% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

WaitSecs(baseFixationTime);

%% Task
% Allocate space to store ratings and reaction times
ratings = cell(length(list), length(list{1}));
RT = cell(length(list), length(list{1}));

% Create timestamp cell arrays for the letter, fixations between letters and fixations between tasks.
% Also for when the instructions are presented to the screen
trialTimestamps = cell(length(list), length(list{1,1}));
interTrialFixationStamps = cell(length(list), length(list{1,1}));
interBlockFixationStamps = cell(length(list), 1);
instructionBlockStamps = cell(length(list), 1);

% Loop through the different time points
for j = 1:length(list)

    % Pull and format the instructions from Blocks variable
    instructionString = ['ScreenInstruct' Blocks{j} 'Back'];
    Screen('TextStyle',w, 1);
    Screen('TextSize',w, textSize);
    Screen('TextFont',w, 'Arial');
    DrawFormattedText(w, eval(instructionString), 'center', 'center', black, [], 0, 0);
    instructionBlockStamps{j} = Screen('Flip', w);

    WaitSecs(instructionTime2wait);

    tmp = list{j};
    % Loop through the predefined presentation list
    for i = 1:length(tmp)

        % Get the current trial's letter
        tmp_letter = tmp{i,1};

        % Draw text on center of the screen
        Screen('TextSize',w, fixSize);
        DrawFormattedText(w, tmp_letter, 'center', 'center', black, [], 0, 0);

        % Flip everything to the screen
        trialTimestamps{j,i} = Screen('Flip', w);

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
            RT{j,i} = keyTime - tStart;
            ratings{j,i} = KbName(find(keyCode));
        else
            RT{j,i} = time2wait;
            ratings{j,i} = [];
        end

        % Show Fixation Screen (RT+fixation time = time2wait seconds)
        DrawFormattedText(w, '+','center', 'center', black,[],0,0);
        interTrialFixationStamps{j,i} = Screen('Flip', w);
        WaitSecs(time2wait - RT{j,i} + 0.5);
    end

    %% Inter Block Fixation
    Screen('TextSize',w,fixSize);
    DrawFormattedText(w,'+','center', 'center', black,[],0,0);
    % Get timestamp for Initial fixation to determine remaining duration
    interBlockFixationStamps{j} = Screen('Flip', w);

    WaitSecs(InterBlockFixationTime);
end
sca;

%% Post-Task
% Process the trial accuracies after the task has completed
accuracy = cell(length(list),length(list{1,1}));
trialType = accuracy;
for i = 1:length(list)
    tmp = list{i};
    for j = 1:length(list{1,1})
        % Hit
        if strcmp(tmp(j,3),'a') && strcmp(ratings{i,j},targetKey)
            accuracy{i,j} = 1;
            trialType{i,j} = 'Hit';
            % Miss
        elseif strcmp(tmp(j,3),'a') && strcmp(ratings{i,j},nonTargetKey)
            accuracy{i,j} = 0;
            trialType{i,j} = 'Miss';
            % FA
        elseif strcmp(tmp(j,3),'b') && strcmp(ratings{i,j},targetKey)
            accuracy{i,j} = 0;
            trialType{i,j} = 'FA';
            % CR
        elseif strcmp(tmp(j,3),'b') && strcmp(ratings{i,j},nonTargetKey)
            accuracy{i,j} = 1;
            trialType{i,j} = 'CR';
        else
            accuracy{i,j} = nan;
            trialType{i,j} = 'No Response';
        end
    end

    if strcmp(ratings{i,j},targetKey)
        ratings{i,j} = 0;
    elseif strcmp(ratings{i,j},nonTargetKey)
        ratings{i,j} = 1;
    end
end



%%
total = [];
total_tbl = [];
tblNames = {'Letter Shown','Trial Type','Correct Response','User Response','Response Type','Reaction Time','Hit Rate','Miss Rate','FA Rate','CR Rate','No Response Rate','Hit RT','Miss RT','FA RT','CR RT'};
for i = 1:length(list)
    
    tmp_list = list{i};
    % Recode the correct responses as 0/1. Delete the original
    total = [tmp_list, num2cell(strcmp(tmp_list(:,3),'b'))];
    total(:,3) = [];

    % Recode the input responses to 0/1
    tmp_ratings = ratings(i,:)';
    total = [total, num2cell(strcmp(tmp_ratings,nonTargetKey))];

    % Add the trialType and Reaction Time
    tmp_trialType = trialType(i,:)';
    tmp_RT = data.RT(i,:)';
    total = [total, tmp_trialType, tmp_RT]; %#ok<*AGROW>
    tmp_RT = cell2mat(tmp_RT);

    % Calculate hit/miss/FA/CR indices for rates and reaction times
    hit = strcmp(tmp_trialType,'Hit');
    miss = strcmp(tmp_trialType,'Miss');
    FA = strcmp(tmp_trialType,'FA');
    CR = strcmp(tmp_trialType,'CR');
    NP = strcmp(tmp_trialType,'No Response');

    % Calculate the rates
    trials = length(tmp_list);
    hit_rate = sum(hit)/trials;
    miss_rate = sum(miss)/trials;
    FA_rate = sum(FA)/trials;
    CR_rate = sum(CR)/trials;
    NP_rate = sum(NP)/trials;

    % Calculate the average reaction times
    hit_RT = mean(tmp_RT(hit));
    miss_RT = mean(tmp_RT(miss));
    FA_RT = mean(tmp_RT(FA));
    CR_RT = mean(tmp_RT(CR));

    % Add the rates and RT to the array
    total{1,end+1} = hit_rate;
    total{1,end+1} = miss_rate;
    total{1,end+1} = FA_rate;
    total{1,end+1} = CR_rate;
    total{1,end+1} = NP_rate;

    total{1,end+1} = hit_RT;
    total{1,end+1} = miss_RT;
    total{1,end+1} = FA_RT;
    total{1,end+1} = CR_RT;

    total_tbl = [total_tbl; total];
    total_tbl{end+1,1} = ' ';
    total_tbl{end+1,1} = Blocks{i};
end
% Write Data to csv
NBack_tbl = cell2table(total_tbl,'VariableNames',tblNames);
writetable(NBack_tbl,csvName);


% Create data struct to save the data
data.list = list;
data.ratings = ratings;
data.RT = RT;
data.accuracy = accuracy;
data.trialType = trialType;

% Save timestamps in data
data.initialFixationOnset = initialFixationOnset;
data.instructionStamps = instructionStamps;
data.taskOnset = taskOnset;
data.trialTimestamps = trialTimestamps;
data.interTrialFixationStamps = interTrialFixationStamps;
data.interBlockFixationStamps = interBlockFixationStamps;
data.instructionBlockStamps = instructionBlockStamps;

% save data to NBack Data >> subjectID
save(saveName,'data')
cd(basePath)

end