function [] = Delay_Discounting_5Trial_DEMO
% DEMO Script for Delay Discounting 5 Trial
% written October 2022 Jacob Suffridge

% Example Inputs: (input must be a string that can be used as a directory name
subjectID = 'DEMO';
sessionID = '1';
protocolID = 'DEMO';
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
demo_values = [500,800,100,350,250,600];
% Loop through the different time strings
for j = 1%:length(time_strings)
    % Restart each trial at half eqValue
    tmp = eqValue/2;
    % Count indexes as i would be allows us to control for nonresponse trials
    count = 1;

    % Loop through the predefined number of choices (12)
    for i = 1:num_choices
        tmp = demo_values(i);

        % Display fixation 500ms
        Screen('TextSize',w,fixationSize);
        DrawFormattedText(w,'+','center', 'center', textColor,[],0,0);
        % Get timestamp for Initial fixation to determine remaining duration
        fixationOnset{j,i} = Screen('Flip', w);
        WaitSecs(fixationTime);

        temp = randperm(length(time_strings));
        % Create the strings to fill the boxes with text
        impTxt = ['<b>$' num2str(round(tmp*100)/100) '\n now'];
        timeTxt = ['<b>$1000\n in ' time_strings{temp(1)}];

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

        % Waiting for participant response
        timedOut = 0;
        tStart = GetSecs;
        while ~timedOut
            % check if a specified key is pressed
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            if(keyIsDown), break; end
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
        
        if strcmp(ratings{j,i},keys{1})
         % Change the rectangle to indicated the selected option
        Screen('FrameRect', w, selectedChoiceFeedbackColor, rect1, 12);
        else
        Screen('FrameRect', w, selectedChoiceFeedbackColor, rect2, 12);
        end 
        
        Screen('Flip',w);
        WaitSecs(0.5);

        % Draw a blank screen ---------------------------------------------
%         DrawFormattedText(w,' ','center','center',textColor,[],0,0);
        blankScreenTimestamps{j,i} = Screen('Flip',w);

        WaitSecs(blankScreen_durations(j));
    end
end
% Renable the keyboard echo and screen clear all
ListenChar();
sca;


end