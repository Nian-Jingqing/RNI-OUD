function [] = Stroop(subjectID,sessionID,protocolID)
% Main Script for Stroop
% written September 13th Jacob Suffridge
%
%
% Example Inputs: (input must be a string that can be used as a directory name
subjectID = 'test123';
sessionID = '1';
protocolID = 'Inside Out';
%% ------------------------------------------------------------------------
clc;

% KbCheck Commands
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([KbName('a'),KbName('s'),KbName('d'),KbName('f')]);

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Stroop/';aasd
dataPath = [basePath, 'Stroop Data/', protocolID, '/'];

% Create save directory in "Stroop Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)

% Create string to save the data later
saveName = [dataPath, subjectID, '/', subjectID, '_Stroop_', sessionID, '_', datestr(now,'mm_dd_yyyy'), '.mat'];

% Generate the Color lists
keyColors = {'Red','Green','Blue','Yellow'};
% list = [keyColors,keyColors,keyColors];
list = [keyColors];

% Create a list for the words to used and the color of the fonts (also
% randomize the order)
wordList = list(randperm(length(list)));
colorList = list(randperm(length(list)));

% This loops converts the font color to rgb for drawformattedtext command later
rgbList = cell(length(colorList),1);
for i = 1:length(colorList)
    tmp = colorList{i};
    if strcmp(tmp,'Red')
        rgbList{i} = [255,0,0];
    elseif strcmp(tmp,'Green')
        rgbList{i} = [0,255,0];
    elseif strcmp(tmp,'Blue')
        rgbList{i} = [0,0,255];
    elseif strcmp(tmp,'Yellow')
        rgbList{i} = [255,255,0];
    end
end

%% Parameters to Adjust
backgroundColor = 0;
textColor = 1;
textSize = 60;
fixSize = 250;
time2wait = 1;
baseFixationTime = 4;

% Strings for Instruction Screens
ScreenInstruct1 = '\n\n\n Press "a" to continue';
ScreenInstruct2 = '\n\n\n Press the "s" button to continue';
ScreenInstruct3 = '\n\n\n Please "d" to begin the task';

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

% Open an on screen window
[w, ~] = PsychImaging('OpenWindow', screenNumber, backgroundColor);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen windowasd
[screenXpixels, screenYpixels] = Screen('WindowSize', w); %#ok<*ASGLU>

% Get instruction timestamps
instructionStamps = cell(3,1);
%% Instruction Set 1
% Create screen for first set of instructions
Screen('TextStyle',w, 1);
Screen('TextSize',w, textSize);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct1, 'center', 'center', textColor, [], 0, 0);
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
    if strcmp(KbName(find(keyCode)),'a')
        break;
    end
end

%% Instruction Set 2
% Create screen for second set of instructions
DrawFormattedText(w,ScreenInstruct2,'center', 'center', textColor,[],0,0);
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
    if strcmp(KbName(find(keyCode)),'s')
        break;
    end
end

%% Waiting for Task to Start
% Set screen to wait for MRI trigger
DrawFormattedText(w, ScreenInstruct3,'center', 'center', textColor,[],0,0);
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
    if strcmp(KbName(find(keyCode)),'d')
        taskOnset = GetSecs;
        break;
    end
end
disp('Task Started')
clc;

%% Initial Fixation pre-Task
Screen('TextSize',w,fixSize);
DrawFormattedText(w,'+','center', 'center', textColor,[],0,0);
% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

WaitSecs(baseFixationTime);

%% Task
% Allocate space to store ratings and reaction times
ratings = cell(length(list), 1);
RT = cell(length(list), 1);

% Create timestamp cell arrays for the letter, fixations between letters and fixations between tasks.
% Also for when the instructions are presented to the screen
trialTimestamps = cell(length(list), 1);
interTrialFixationStamps = cell(length(list), 1);
interBlockFixationStamps = cell(length(list), 1);

% Loop through the list of words
for j = 1:length(list)
    % Set the current word and font color
    tmp_word = wordList{j};
    tmp_color = rgbList{j};

    % Draw text on center of the screen
    Screen('TextSize',w, fixSize);
    DrawFormattedText(w, tmp_word, 'center', 'center', tmp_color, [], 0, 0);

    % Flip everything to the screen
    trialTimestamps{j} = Screen('Flip', w);

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
        RT{j} = time2wait;
        ratings{j} = [];
    end

    % Show Fixation Screen (RT+fixation time = time2wait seconds)
    DrawFormattedText(w, '+','center', 'center', textColor,[],0,0);
    interTrialFixationStamps{j} = Screen('Flip', w);
    WaitSecs(time2wait - RT{j} + 0.5);
end
sca;

%% Post-Task
% % Process the trial accuracies after the task has completed
% accuracy = cell(length(list),length(list{1,1}));
% for i = 1:length(list)
%     tmp_word = list{i};
%     for j = 1:length(list{1,1})
%         if strcmp(tmp_word(j,3),'a') && strcmp(ratings{i,j},'LeftArrow')
%             accuracy{i,j} = 1;
%         elseif strcmp(tmp_word(j,3),'a') && strcmp(ratings{i,j},'RightArrow')
%             accuracy{i,j} = 0;
%         elseif strcmp(tmp_word(j,3),'b') && strcmp(ratings{i,j},'LeftArrow')
%             accuracy{i,j} = 0;
%         elseif strcmp(tmp_word(j,3),'b') && strcmp(ratings{i,j},'RightArrow')
%             accuracy{i,j} = 1;
%         end
%     end
% end

% Create data struct to save the data
data.ratings = ratings;
data.RT = RT;
% data.accuracy = accuracy;

% Save timestamps in data
data.initialFixationOnset = initialFixationOnset;
data.instructionStamps = instructionStamps;
data.taskOnset = taskOnset;
data.trialTimestamps = trialTimestamps;
data.interTrialFixationStamps = interTrialFixationStamps;
data.interBlockFixationStamps = interBlockFixationStamps;

% save data to Stroop Data >> subjectID
save(saveName,'data')
cd(basePath)

end