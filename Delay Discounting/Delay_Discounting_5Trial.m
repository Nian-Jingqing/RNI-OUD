function [] = Delay_Discounting_5Trial(subjectID,sessionID,protocolID)
% Main Script for Delay Discounting 5 Trial
% written June 2022 Jacob Suffridge
%
% Updated August 22nd 2022
% Modified to be the out of scanner 5 Trial task to better inform the in
% scanner DD task. This included changing the adaptive algorithm to get to
% the decision point faster.
%
% Updated August 24th 2022
% Modified code to allow centering of text in the rectangles by redoing how
% the background is generated
% added ability to change background and text color easily
%
% Updated August 25th 2022
% export correct outputs in data structure, added curve fitting functionality
% to calculate k values and indifference points. Indif points will be
% passed along to Delay_Discounting_MRI.
%
% Updated August 26th 2022
% Added report generating functionality. Randomized the time points.
% Updated the output data struct to contain all info need for the DD MRI
% task.
%
% Updated August 31st 2022
% Add configuration functionality to allow the 5 Trial task to be
% dependent on a configuration file. Modified inputs to be
% leftarrow,rightarrow
%
% Example Inputs: (input must be a string that can be used as a directory name
% subjectID = 'Test_10_3';
% sessionID = '1';
% protocolID = 'DISCO';

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

% Add config folder to the path
addpath('/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/DD Config Files');

% Load the traing configuration struct
config = DD_5Trial_config_new(subjectID,sessionID,protocolID);

%% Adjustable Parameters
% Input parameters
keys = config.keys;

% Pull the instruction strings and keys
instructionCell = config.instructionCell;
advanceKeys = {keys{1},keys{2},keys{1},keys{2}};

% KbCheck Commands
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([KbName(keys{1}),KbName(keys{2})]);

% Appearance Parameters
textSize = config.textSize;
fixationSize = config.fixationSize;
% fontStyle = config.fontStyle;
textColor = config.textColor;
backgroundColor = config.backgroundColor;
instructionTextSize = config.instructionTextSize;

fixationTime = config.fixationTime;
% interTrialDuration = config.interTrialDuration;
% InterBlockFixationTime = config.InterBlockFixationTime;
selectedChoiceFeedbackColor = [255 255 0];

% Other Parameters
% number of trials per time point
num_choices = config.num_choices;
% time points to use
time_in_days_sorted = config.time_in_days_sorted ;
time_strings_sorted = config.time_strings_sorted ;

% eqValue is the long term choice amount and determines the step size between trials
eqValue = config.eqValue;
amountsToAdjust = config.amountsToAdjust;

% Randomize time points
time_perm = randperm(length(time_strings_sorted));
time_in_days = time_in_days_sorted(time_perm);
time_strings = time_strings_sorted(time_perm);

% Generate a matrix of 0's and 1's to randomize the choice locations
randomTextLocation = randi(2,length(time_strings),num_choices+1)-1;
defaultTxt = 'Would you rather have';

% Will be used to flag which side is impulsive
tags = flip(keys);

% Generate the random jitter timings
numTrials = num_choices*length(time_strings);
tmp_blankScreen_durations = (1000:100:1500)./1000;

% Randomize the blank screen timings
blankScreen_durations = zeros(1,numTrials);
for i = 1:numTrials
    % Randomly select a duration from the tmp arrays above
    blankScreen_durations(i) = tmp_blankScreen_durations(randi(numel(tmp_blankScreen_durations)));
end

%% Prepare the screen
PsychDefaultSetup(2);
% Initialize screen preferences
Screen('Preference', 'ConserveVRAM', 4096);
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if available
screenNumber = max(screens);
% screenNumber = 2;

% Open an on screen window
[w, wrect] = PsychImaging('OpenWindow', screenNumber, backgroundColor);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('Preference', 'TextRenderer', 1);
% Screen('Preference', 'TextAntiAliasing', 2);

% Get the size of the on screen window
[~, screenYpixels] = Screen('WindowSize', w);

% Useful later when positioning the rectangles
[scrX,scrY] = RectCenter(wrect);

% Create rectangles in background to center text in later
rect1 = CenterRectOnPoint([0 0 600 600],0.5*scrX,scrY);
rect2 = CenterRectOnPoint([0 0 600 600],1.5*scrX,scrY);

% Allocate space to store ratings and reaction times
ratings = cell(length(time_strings),num_choices);
RT = cell(length(time_strings),num_choices);

% Create cell arrays to collect timestamps for trials, intertrial/interblock fixations
fixationOnset = cell(length(time_strings),num_choices);
trialTimestamps = cell(length(time_strings),num_choices);
blankScreenTimestamps = cell(length(time_strings),num_choices);
% interTrialFixationStamps = cell(length(time_strings),num_choices);
% interBlockFixationStamps = cell(length(time_strings),1);

%% Task
% Present the instruction screens
instructionTimestamps = showInstructionScreens(w,instructionCell,advanceKeys,textColor,instructionTextSize);

clc;
% Suppress keyboard echo to command window
ListenChar(2);

% counter records all choices we present during the task
counter = [];

% Record the trigger timestamps
triggerTimes = cell(length(time_strings),num_choices);

% Loop through the different time strings
for j = 1:length(time_strings)
    % Restart each trial at half eqValue
    tmp = eqValue/2;
    % Count indexes as i would be allows us to control for nonresponse trials
    count = 1;

    % Loop through the predefined number of choices (12)
    for i = 1:num_choices

        % Display fixation 500ms
        Screen('TextSize',w,fixationSize);
        DrawFormattedText(w,'+','center', 'center', textColor,[],0,0);
        % Get timestamp for Initial fixation to determine remaining duration
        fixationOnset{j,i} = Screen('Flip', w);
        WaitSecs(fixationTime);

        % Create the strings to fill the boxes with text
        impTxt = ['<b>$' num2str(round(tmp*100)/100) '\n now'];
        timeTxt = ['<b>$1000\n in ' time_strings{j}];

        % Set text style for the screen
        Screen('TextSize',w, textSize);

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
            if(keyIsDown), break; end

            %             Removed to force participant to respond to each question
            %             if( (keyTime - tStart) > interTrialDuration)
            %                 timedOut = true;
            %             end
        end

        % Records Reaction Time and Response Key
        if (~timedOut)
            RT{j,i} = keyTime - tStart;
            ratings{j,i} = KbName(find(keyCode));
        else
            RT{j,i} = nan;
            ratings{j,i} = [];
        end

        % Get the side of the impulsive decision and log the displayed amount
        impulsive_tag = tags{randomTextLocation(j,i)+1};
        counter = [counter;{tmp,RT{j,i},time_strings{j},KbName(find(keyCode)),impulsive_tag, strcmp(impulsive_tag,KbName(find(keyCode)))}]; %#ok<*AGROW>
        
        % Realtime data saving in case of crash fix later
        writecell(counter,config.excelName)

        if isempty(ratings{j,i})
            % Dont change tmp or count
        elseif strcmp(KbName(find(keyCode)),impulsive_tag)
            % decrease the impulsive amount by amountToAdjust(count)
            tmp = tmp - amountsToAdjust(count);
            count = count + 1;
        elseif ~strcmp(KbName(find(keyCode)),impulsive_tag)
            % increase the impulsive amount by amountToAdjust(count)
            tmp = tmp + amountsToAdjust(count);
            count = count + 1;
        end

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

        WaitSecs(blankScreen_durations(j));
    end
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

%% Curve Fitting
% Unsort the indifference points
indiffPoints = [];
for i = 1:length(time_strings_sorted)
    tmp = counter(:,3);
    indiffPoints = [indiffPoints, counter{find(strcmp(tmp,time_strings_sorted{i}), 1, 'last' ),1}];
end
% Divide by eqValue to get the proportional value
indiffPoints = indiffPoints./eqValue;
% Create the recipocal function to curve fit the data
funct = @(k,time_in_days) 1./(1+(k.*time_in_days));

% Created try logic to prevent erroring out on shortened sessions
try
    % Fit the curve to the function with x0=0.01
    [k,resnorm] = lsqcurvefit(funct,0.01,time_in_days_sorted,indiffPoints);
catch
    % if the curve fitting isnt successful then write k/resnorm as nan and throw an error
    k = nan;
    resnorm = nan;
    disp('Curve Fitting unsuccessful, check data')
end

%% Post-Task
% Create data struct to save the data
data.counter = counter;
data.ratings = ratings;
data.RT = RT;
% counter_labels = {'Impulsive amount','Reaction Time','Delay Time','Response','Impulsive Direction','Decision (0-Long, 1-Imp)'}
data.k = k;
data.funct = funct;
data.eqValue = eqValue;
data.indiffPoints = indiffPoints;
data.resnorm = resnorm;

% Save timestamps in data
data.instructionTimestamps = instructionTimestamps;
% data.taskOnset = taskOnset;
data.fixationOnset = fixationOnset;
data.trialTimestamps = trialTimestamps;
data.blankScreenTimestamps = blankScreenTimestamps;


% Generate the post task report
DD_5Trial_report_generator(data,subjectID,sessionID,protocolID);

% save data to DD Data >> subjectID
save(config.saveName,'data')
cd(config.basePath)

end