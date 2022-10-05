function [] = Delay_Discounting_LFP(subjectID,sessionID,protocolID,trainingFilePath)
% Main Script for Delay Discounting for Behavioral Data
% written August 25th 2022 Jacob Suffridge
%
% this script requires Indifference points collected from a session of
% Delay_Discounting_training.m, this script will auto check for this file
% and error out if it doesnt exist
%
% Updated August 26th 2022
% Add functionality to pull in the training data to determine the monetary
% values used during this task.
%
% Updated September 26th
% Incorporated showInstructScreens functionality. Add Serial port triggers
% to send triggers when each trial is presented on screen. Changed trial
% structure to [fixation --> Trial --> blank screen]
%
% Example Inputs: (input must be a string that can be used as a directory name
% subjectID = 'Test_10_3';
% protocolID = 'DISCO';
% sessionID = '1';

selectedChoiceFeedbackColor = [255 255 0];
%% Establish Port Communication
% Get the deviceNames, portName and baudrate
deviceNames = dir('/dev/ttyACM*');
portName = ['/dev/' deviceNames.name];
baudrate = 115200;

try
    % Close all IOPorts
    IOPort('CloseAll');
    % Open the IOPort
    [handle, errormsg] = IOPort('OpenSerialPort', portName, sprintf('Baudrate=%d',baudrate));
catch
    disp('No serial port detected')
end
%% Pre-Task Setup ---------------------------------------------------------
% Add path to general OUD function library
addpath('/home/helpdesk/Documents/MATLAB/RNI-OUD/OUD Function Library')

% KbCheck Commands
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([KbName('LeftArrow'),KbName('RightArrow')]);

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/';
dataPath = [basePath, 'Delay Discounting Data/', protocolID, '/'];

% Create string to save the data later
saveName = [dataPath, subjectID, '/' subjectID '_Delay_Discounting_LFP_' , sessionID, '_' datestr(now,'mm_dd_yyyy_HH_MM') '.mat'];
excelName = [saveName(1:end-4), '_updating.csv'];

% Try to load the training data
try
    % Create string to load the training data
%     loadFiles = dir([dataPath, subjectID, '/*5Trial*.mat']);
%     trainingFilePath = [loadFiles(end).folder, '/', loadFiles(end).name];

    disp(['Loading ' trainingFilePath]);

    % Load Indif Points from training session
    trainingData = load(trainingFilePath).data;
    k = trainingData.k;
    indiffPoints = trainingData.indiffPoints;
    eqValue = trainingData.eqValue;
catch
    disp('Training data not found check files')
    return;
end

% Proportion Amounts taken from the 2017 paper
proportionAmounts = 0.05:0.1:0.95;

hardTrials = [];
% Shuffle the columns of each row independently
for i = 1:length(indiffPoints)
    tmp = [proportionAmounts, indiffPoints(i).*[0.92,0.96,1.0,1.04,1.08]];

    tmpHigh = find(tmp>1);
    %     for j = 1:length(tmpHigh)
    tmp(tmpHigh) = tmp(tmpHigh) - 0.1;
    %     end

    tmpLow = find(tmp<0);
    %     for k = 1:length(tmpLow)
    tmp(tmpLow) = tmp(tmpLow) + 0.1;
    %     end

    % Check that all testpoints are above 0 and less than 1 for j = 1:length(tmpHigh)
    % ???? Add +-0.04, +-0.08
    testPoints(i,:) = tmp(randperm(length(tmp)));
end
testPoints = testPoints.*eqValue;

% time points to use
time_in_days = [1,7,30,90,365,5*365,25*365];
time_strings = {'1 day','1 week','1 month','3 months','1 year','5 years','25 years'};

% Logic to select the time points using the k thresholds from 2017 paper
if k > 0.03542
    time_in_days = time_in_days(1:4);
    time_strings = time_strings(1:4);
    testPoints(5:7,:) = [];
    indiffPoints(5:7) = [];

elseif k > 0.0098
    time_in_days = time_in_days(2:5);
    time_strings = time_strings(2:5);
    testPoints([1,6:7],:) = [];
    indiffPoints([1,6:7]) = [];
elseif k > 0.002813
    time_in_days = time_in_days(3:6);
    time_strings = time_strings(3:6);
    testPoints([1:2,7],:) = [];
    indiffPoints([1:2,7]) = [];
elseif k > 0
    time_in_days = time_in_days(4:7);
    time_strings = time_strings(4:7);
    testPoints(1:3,:) = [];
    indiffPoints(1:3) = [];
else 
    disp('Check k value from 5 Trial Session')
end

%% Adjustable Parameters
% Input parameters
leftKey = 'LeftArrow';
rightKey = 'RightArrow';
keys = {leftKey,rightKey};

% Appearance Parameters
textSize = 55;
fixationSize = 250;
fontStyle = 'arial';
textColor = 1;
backgroundColor = 0;
instructionTextSize = 65;

% Other Parameters

% Generate a matrix of 0's and 1's to randomize the choice locations
randomTextLocation = randi(2,length(time_strings),length(testPoints))-1;
defaultTxt = 'Would you rather have';

trialDuration = 6;
fixationTime = 0.5;
InterTrialFixationTime = 4;

% Will be used to flag which side is impulsive
% tags = {'b','a'};
tags = flip(keys);

% Strings for Instruction Screens
ScreenInstruct1 = 'You will choose between two hypothetical amounts \n of money at varing pay out times \n\n\n Press the Left Arrow button to continue';
ScreenInstruct2 = 'Use the Left Arrow button to select the value on the left \n\n Use the Right Arrow button to select the value on the right \n\n\n Press the Right Arrow button to continue';
ScreenInstruct3 = 'Read each question carefully \n the amounts and times will change \n\n\n Press the Left Arrow button to continue';
ScreenInstruct4 = 'Press the Right Arrow button to start the task';

instructionCell = {ScreenInstruct1,ScreenInstruct2,ScreenInstruct3,ScreenInstruct4};
advanceKeys = {'LeftArrow','RightArrow','LeftArrow','RightArrow'};

% Generate the random jitter timings
numTrials = length(testPoints)*length(time_strings);
tmp_blankScreen_durations = (1000:100:1500)./1000;

% Randomize the blank screen timings
blankScreen_durations = zeros(1,numTrials);
for i = 1:numTrials
    % Randomly select a duration from the tmp arrays above
    blankScreen_durations(i) = tmp_blankScreen_durations(randi(numel(tmp_blankScreen_durations)));
end

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
[w, wrect] = PsychImaging('OpenWindow', screenNumber, backgroundColor);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('Preference', 'TextRenderer', 1);
% Screen('Preference', 'TextAntiAliasing', 2);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% Useful later when positioning the rectangles
[scrX,scrY] = RectCenter(wrect);

% Create rectangles in background to center text in later
rect1 = CenterRectOnPoint([0 0 600 600],0.5*scrX,scrY);
rect2 = CenterRectOnPoint([0 0 600 600],1.5*scrX,scrY);

% Allocate space to store ratings and reaction times
ratings = cell(length(time_strings), length(testPoints));
RT = cell(length(time_strings),length(testPoints));

% Present the instruction screens
instructionTimestamps = showInstructionScreens(w,instructionCell,advanceKeys,textColor,textSize);
clc;


%% Task
% Suppress keyboard echo to command window
ListenChar(2)

% counter records all choice we present to them
counter = [];

% Randomize the time points
time_tmp = randperm(length(time_strings));
time_strings = time_strings(time_tmp);
indiffRandom = indiffPoints(time_tmp);
testPoints = testPoints(time_tmp,:);

% Create cell arrays to collect timestamps for trials, intertrial/interblock fixations
fixationOnset = cell(length(time_strings),length(testPoints));
trialTimestamps = cell(length(time_strings),length(testPoints));
blankScreenTimestamps = cell(length(time_strings),length(testPoints));
% interTrialFixationStamps = cell(length(time_strings),length(testPoints));
% interBlockFixationStamps = cell(length(time_strings),1);

triggerTimes = cell(length(time_strings),length(testPoints));
% Loop through the different time points
for j = 1:length(time_strings)

    % Loop through the predefined number of choices (12)
    for i = 1:length(testPoints)

        % Display fixation 500ms
        Screen('TextSize',w,fixationSize);
        DrawFormattedText(w,'+','center', 'center', textColor,[],0,0);
        % Get timestamp for Initial fixation to determine remaining duration
        fixationOnset{j,i} = Screen('Flip', w);
        WaitSecs(fixationTime);

        % Grab the current amount
        tmp = testPoints(j,i);

        % Determine which trials are hard/easy
        hardTrial = abs(tmp - eqValue.*indiffRandom(j))/eqValue <= 0.2;

        % Set text style for the screen
        Screen('TextSize',w, textSize);

        % Create the strings to fill the boxes with text
        impTxt = ['<b>$' num2str(round(tmp*100)/100) ' now'];
        timeTxt = ['<b>$1000 in ' time_strings{j}];

        % Draw Question text on top of the screen
        DrawFormattedText(w, defaultTxt, 'center', screenYpixels*.145, textColor, [], 0, 0);

        % Draw the background rectangles to the screen
        Screen('FrameRect', w, textColor, rect1, 12);
        Screen('FrameRect', w, textColor, rect2, 12);

        % Switch the options around randomly using a randomization generated pre-task
        if randomTextLocation(j,i)
            % Impulsive decision is on the left
            DrawFormattedText2(impTxt,'win',w,'sx','center','sy','center','xalign','center','yalign','center','xlayout','center','winRect',rect1,'baseColor',textColor,'vSpacing',2);
            DrawFormattedText2(timeTxt,'win',w,'sx','center','sy','center','xalign','center','yalign','center','xlayout','center','winRect',rect2,'baseColor',textColor,'vSpacing',2);

        else
            % Impulsive decision is on the right
            DrawFormattedText2(timeTxt,'win',w,'sx','center','sy','center','xalign','center','yalign','center','xlayout','center','winRect',rect1,'baseColor',textColor,'vSpacing',2);
            DrawFormattedText2(impTxt,'win',w,'sx','center','sy','center','xalign','center','yalign','center','xlayout','center','winRect',rect2,'baseColor',textColor,'vSpacing',2);
        end
        % Flip everything to the screen
        trialTimestamps{j,i} = Screen('Flip', w,[],1);

        % Send trigger at image presentation ----------------------------------
        triggerTimes{j,i} = sendTrigger(handle,255,0.05);

        % Waiting for participant response
        timedOut = 0;
        tStart = GetSecs;
        while ~timedOut
            % check if a specified key is pressed
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            %             if(keyIsDown), break; end
            %
            if(keyIsDown)
                while KbCheck, end
                break;
                % Enable this for fixed duration response window
                %             elseif( (keyTime - tStart) > trialDuration)
                %                 timedOut = true;
            end
        end

        % Records Reaction Time and Response Key
        if (~timedOut)
            RT{j,i} = keyTime - tStart;
            ratings{j,i} = KbName(find(keyCode));
        else
            RT{j,i} = nan;
            ratings{j,i} = [];
        end

        %         % Show Fixation Screen (RT+fixation time = time2wait seconds)
        %         Screen('TextSize',w, fixationSize);
        %         DrawFormattedText(w, '+','center', 'center', textColor,[],0,0);
        %
        %         interTrialFixationStamps = Screen('Flip', w);
        %         WaitSecs(trialDuration - RT{j,i});

        % Get the side of the impulsive decision and log the displayed amount
        impulsive_tag = tags{randomTextLocation(j,i)+1};
        counter = [counter;{tmp, RT{j,i}, time_strings{j}, KbName(find(keyCode)), impulsive_tag, strcmp(impulsive_tag,KbName(find(keyCode))), hardTrial}]; %#ok<*AGROW>
        
        % Realtime data saving in case of crash fix later
        writecell(counter,excelName)

        if strcmp(ratings{j,i},keys{1})
         % Change the rectangle to indicated the selected option
        Screen('FrameRect', w, selectedChoiceFeedbackColor, rect1, 12);
        else
        Screen('FrameRect', w, selectedChoiceFeedbackColor, rect2, 12);
        end 
        
        Screen('Flip',w);
        WaitSecs(0.5);

        % Draw a blank screen -------------------------------------------------
        DrawFormattedText(w,' ','center','center',textColor,[],0,0);
        blankScreenTimestamps{j,i} = Screen('Flip',w);

        %     WaitSecs(config.blankScreen_duration);
        WaitSecs(blankScreen_durations(j));
    end

    %     %% Inter Block Fixation
    %     DrawFormattedText(w,'+','center','center',textColor,[],0,0);
    %     % Get timestamp for Initial fixation to determine remaining duration
    %     interBlockFixationStamps = Screen('Flip',w);
    %
    %     WaitSecs(InterTrialFixationTime);
end
% Renable the keyboard echo and screen clear all
ListenChar();
sca;

%% Convert ratings from a/b to 0/1
for i = 1:length(counter)
    % Change Response format
    if strcmp(counter{i,4},keys{1})
        counter{i,4} = 0; %#ok<*SAGROW>
    elseif strcmp(counter{i,4},keys{2})
        counter{i,4} = 1;
    end
    % Change impulsive location format
    if strcmp(counter{i,5},keys{1})
        counter{i,5} = 0;
    elseif strcmp(counter{i,5},keys{2})
        counter{i,5} = 1;
    end
end

%% Post-Task
% Create data struct to save the datainstructionTimestamps
data.ratings = ratings;
data.RT = RT;
% counter_labels = {'Impulsive amount','Reaction Time','Delay
% Time','Response','Impulsive Direction','Decision (0-Long, 1-Imp)','0-Easy, 1-Hard'}
data.counter = counter;
data.triggerTimes = triggerTimes;

% Save timestamps in data
data.instructionTimestamps = instructionTimestamps;
data.fixationOnset = fixationOnset;
data.trialTimestamps = trialTimestamps;
data.blankScreenTimestamps =  blankScreenTimestamps;

% data.interTrialFixationStamps = interTrialFixationStamps;
% data.interBlockFixationStamps = interBlockFixationStamps;

% data.MRI_onset = mri_onset;  will need to modify showInstruction function
% to capture this

DD_Behavioral_report_generator(data,subjectID,sessionID,protocolID);
% save data to DD Data >> subjectID
save(saveName,'data')
cd(basePath)
% end

