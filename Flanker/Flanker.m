function [] = Flanker(subjectID, sessionID, protocolID)
% Main Script for Flanker outside the MRI scanner
% written June 2022 Jacob Suffridge
%
% Example Inputs: (input must be a string that can be used in a directory name)
subjectID = 'jacobS';
sessionID = 'testz';
protocolID = 'DISCO';
%
% Updated September 6th 2022
% Add sessionID, protocolID to the pathing and integrated into the OUD app.
% Made other modifications to timestamp and store all relevant task data in
% the data struct (in line with other OUD tasks such as DD). Changed inputs
% to be arrow keys since task will be outside MRI
%
% Updated September 13th 2022
% Added scoring functionality and added the ability to write the output
% data to csv.
%
% TO DO:
% Still need to add report functionality. Add configurations just in case, make MRI version.
%% ------------------------------------------------------------------------
clc;

% flag for demo mode
demoMode = 1;

% KbCheck Commands
KbName('UnifyKeyNames');
leftKey = 'LeftArrow';
rightKey = 'RightArrow';
RestrictKeysForKbCheck([KbName(leftKey),KbName(rightKey)]);

% Shift focus to the command window 
commandwindow

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Flanker/';
dataPath = [basePath, 'Flanker Data/', protocolID, '/'];
targetPath = [basePath, 'Flanker Targets/'];

% Create save directory in "Flanker Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)
% Create string to save the data later
saveName = [dataPath, subjectID, '/', subjectID, '_Flanker_', sessionID, '_', datestr(now,'mm_dd_yyyy'), '.mat'];
csvName = [saveName(1:end-4), '.csv'];
%% Parameters to Adjust
textSize = 60;
fixSize = 250;
time2wait = 1.0;

baseFixationTime = 4;
InterTrialFixationTime = 1.0;   %14

% Strings for Instruction Screens
ScreenInstruct1 = 'Select the direction of the middle arrow as quickly as possible \n\n\n Press the left arrow button to continue';
ScreenInstruct2 = 'If the center arrow is facing RIGHT press the RIGHT arrow button, \n\n\n if the center arrow is facing LEFT push the LEFT arrow button \n\n\n Press the right arrow button to continue';
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
[screenXpixels, screenYpixels] = Screen('WindowSize', w); %#ok<*ASGLU> 

% Load the target patterns into memory
scale_factor = 1.75;
target1 = imresize(imread([targetPath, 'Target1.bmp']), scale_factor); %#ok<*NASGU> 
target2 = imresize(imread([targetPath, 'Target2.bmp']), scale_factor);
target3 = imresize(imread([targetPath, 'Target3.bmp']), scale_factor);
target4 = imresize(imread([targetPath, 'Target4.bmp']), scale_factor);
target5 = imresize(imread([targetPath, 'Target5.bmp']), scale_factor);
target6 = imresize(imread([targetPath, 'Target6.bmp']), scale_factor);

% Create random listing to call flanker targets
target_list = [];
num_trials = 60;
for i = 1:6
    C    = cell(1, round(num_trials/6));
    C(:) = {['target', num2str(i)]};
    target_list = [target_list; C]; %#ok<AGROW>
end
target_list = reshape(target_list, num_trials, []);
target_list = target_list(randperm(num_trials));

target_imgs = cell(size(target_list));
congruency = cell(size(target_list));
correctResp = cell(size(target_list));
for i = 1:num_trials
    target_imgs{i} = eval(target_list{i});
    
    % Record whether the trial is neutral incongruent or congruent and the
    % correct response for each trial in correctResp
    tmp = target_list{i};
    if strcmp(tmp,'target1') 
        congruency{i} = 'neutral';
        correctResp{i} = 1;
    elseif strcmp(tmp,'target2')
        congruency{i} = 'neutral';
        correctResp{i} = 0;
    elseif strcmp(tmp,'target3') 
        congruency{i} = 'incongruent';
        correctResp{i} = 0;
    elseif strcmp(tmp,'target4')
        congruency{i} = 'congruent';
        correctResp{i} = 1;
     elseif strcmp(tmp,'target5')
        congruency{i} = 'congruent';
        correctResp{i} = 0;
    elseif strcmp(tmp,'target6')
        congruency{i} = 'incongruent';
        correctResp{i} = 1;
    else
        disp('Error in trial typing')
    end 
end 

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
    if strcmp(KbName(find(keyCode)),leftKey)
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
    if strcmp(KbName(find(keyCode)),rightKey)
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
    if strcmp(KbName(find(keyCode)),leftKey)
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
% if in demo mode reduce the number of trials from length(trial_list) to 6
if demoMode
    num_trials = 6; %#ok<*UNRCH> 
end 

% Allocate space to store ratings, reaction times and timestamps
ratings = cell(num_trials, 1);
RT = cell(num_trials, 1);

trialTimestamps = cell(num_trials, 1);
interTrialFixationStamps = cell(num_trials, 1);

% Suppress keyboard echo to command window
ListenChar(2)
% Loop through the predefined presentation list
for i = 1:num_trials
    
    % Pull target for current iteration
    tmp_target = target_imgs{i};

    % Draw target on center of the screen
    Screen('PutImage', w, tmp_target);
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
    Screen('TextStyle',w, 1);
    Screen('TextSize',w, 250);
    Screen('TextFont',w, 'Arial');
    DrawFormattedText(w, '+','center', 'center', black,[],0,0);

    % Get fixation timestamp
    interTrialFixationStamps{i} = Screen('Flip', w);
    WaitSecs(time2wait - RT{i});

end

% Renable the keyboard echo and screen clear all
ListenChar();
sca;

%% Post-Task
% Process the trial accuracy after the task has completed
accuracy = cell(length(target_list), 1);
for i = 1:length(ratings)

    % Convert the ratings to boolean
    if strcmp(ratings{i},leftKey)
        ratings{i} = 0;
    elseif strcmp(ratings{i},rightKey)
        ratings{i} = 1;
    end

    % Calculate the accuracy
    if ratings{i} == correctResp{i}
       accuracy{i} = 1;
    else
       accuracy{i} = 0;
    end

end 

% % Create data struct to save the data
% data.ratings = ratings;
% data.RT = RT;
% data.target_list = target_list;
% data.congruency = congruency;
% data.correctResp = correctResp;
% data.accuracy = accuracy;
% 
% % Split the trial accuracy by congruency
% data.neutralAccuracy = sum([data.accuracy{strcmp(data.congruency,'neutral')}])/(num_trials/3);
% data.congruentAccuracy = sum([data.accuracy{strcmp(data.congruency,'congruent')}])/(num_trials/3);
% data.incongruentAccuracy = sum([data.accuracy{strcmp(data.congruency,'incongruent')}])/(num_trials/3);
% 
% % Split the trial Reaction Time by congruency
% data.neutralRT = [data.RT{strcmp(data.congruency,'neutral')}];
% data.meanNeutralRT = mean(data.neutralRT);
% data.congruentRT = [data.RT{strcmp(data.congruency,'congruent')}];
% data.meanCongruentRT = mean(data.congruentRT);
% data.incongruentRT = [data.RT{strcmp(data.congruency,'incongruent')}];
% data.meanIncongruentRT = mean(data.incongruentRT);
% 
% % Save timestamps in data
% data.instructionStamps = instructionStamps;
% data.taskOnset = taskOnset;
% data.initialFixationOnset = initialFixationOnset;
% data.trialTimestamps = trialTimestamps;
% data.interTrialFixationStamps = interTrialFixationStamps;
% 
% % Create table to save output csv file
% tblNames = {'Response','Accuracy','Reaction Time','Congruency','Neutral Accuracy','Congruent Accuracy','Incongruent Accuracy','Neutral Mean RT','Congruent Mean RT','Incongruent Mean RT'};
% tbl = [data.ratings,data.accuracy,data.RT,data.congruency];
% tbl{1,end+1} = data.neutralAccuracy;
% tbl{1,end+1} = data.congruentAccuracy;
% tbl{1,end+1} = data.incongruentAccuracy;
% 
% tbl{1,end+1} = data.meanNeutralRT;
% tbl{1,end+1} = data.meanCongruentRT;
% tbl{1,end+1} = data.meanIncongruentRT;
% 
% % Write Data to csv
% Flanker_tbl = cell2table(tbl,'VariableNames',tblNames);
% writetable(Flanker_tbl,csvName);
% 
% % save data to Flanker Data >> protocolID >> subjectID
% save(saveName,'data')
% cd(basePath)

% end