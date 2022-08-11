function [] = Adaptive_Delay_Discounting(subjectID)
% Main Script for Adaptive Delay Discounting
% written June 2022 Jacob Suffridge
clc;

% Define the base and data paths
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/';
dataPath = [basePath, 'Delay Discounting Data'];

% Create save directory in DD data folder
cd(dataPath)
mkdir(subjectID)
cd(basePath)

% Create string to save the data later
saveName = [dataPath, '/' subjectID, '/' subjectID '_Delay_Discounting_' , datestr(now,'mm_dd_yyyy') '.mat'];

%% Parameters to Adjust
num_choices = 12;
time_points = [1,2,30,180,365,750];
textSize = 60;
fixSize = 250;
time2wait = 6;
randomTextLocation = randi(2,length(time_points),num_choices)-1;
defaultTxt = 'Would you rather have';
baseFixationTime = 4;
InterTrialFixationTime = 14;
% Will be used to flag which side is impulsive
tags = {'b','a'};

% Strings for Instruction Screens
ScreenInstruct1 = 'You will choose between two hypothetical amounts \n of money at varing times til pay out \n\n\n Press the 1 button (<color=ffff00>YELLOW) to continue';
ScreenInstruct2 = 'Use the 1 button (Yellow) to select the value on the left \n\n\n Use the 2 button (Blue) to select the value on the right \n\n\n Press the 2 button (BLUE) to continue';
ScreenInstruct3 = 'Read each question carefully \n because the amounts and times will change \n\n\n Press the 1 button (Yellow) to continue';
ScreenInstruct4 = 'Please wait for the MRI to start';

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

% Load the background image with the boxes auto adjust size to fit screen
img = imresize(imread('Slide1.JPG'),[screenYpixels,screenXpixels]);

% Allocate space to store ratings and reaction times
ratings = cell(length(time_points),num_choices);
RT = cell(length(time_points),num_choices);
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
% Create screen for third set of instructions
DrawFormattedText(w,ScreenInstruct3,'center', 'center', black,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check for third instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'a')
        break;
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
% Loop through the different time points
for j = length(time_points)
    % Restart the task at $1000, allocate space for tracker, counter, switch_tag
    tmp = 1000;
    % Tracker records impulsive decisions made
    tracker = [];
    % counter records all impulsive choice we present to them
    counter = [];
    % Switch tag is useful for major adjustment at the start of a block
    switch_tag = 0;

    % Loop through the predefined number of choices (12)
    for i = 1:num_choices

        % Pull background image and set text styles
        Screen('TextStyle',w, 1);
        Screen('TextSize',w, textSize);
        Screen('TextFont',w, 'Arial');
        Screen('PutImage', w, img);

        % Create the strings to fill the boxes with text
        adaptTxt = ['$' num2str(round(tmp*100)/100) ' now'];
        timeTxt = ['$1000 in ' num2str(time_points(j)) ' days'];

        % Draw Question text on top of the screen
        DrawFormattedText(w, defaultTxt, 'center', screenYpixels*.145, black, [], 0, 0);

        % Switch the options around randomly using a randomization generated pre-task
        % Impulsive decision is on the left
        if randomTextLocation(j,i)
            DrawFormattedText(w, adaptTxt, screenXpixels*.165, 'center', black, [], 0, 0);
            DrawFormattedText(w, timeTxt, screenXpixels*.610, 'center', black, [], 0, 0);

            % Impulsive decision is on the right
        else
            DrawFormattedText(w, timeTxt, screenXpixels*.115, 'center', black, [], 0, 0);
            DrawFormattedText(w, adaptTxt, screenXpixels*.665, 'center', black, [], 0, 0);
        end
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
            RT{j,i} = keyTime - tStart;
            ratings{j,i} = KbName(find(keyCode));
        else
            RT{j,i} = 100;
            ratings{j,i} = [];
        end

        % Show Fixation Screen (RT+fixation time = time2wait seconds)
        Screen('TextStyle',w, 1);
        Screen('TextSize',w, fixSize);
        Screen('TextFont',w, 'Arial');
        DrawFormattedText(w, '+','center', 'center', black,[],0,0);
        Screen('Flip', w);
        WaitSecs(time2wait - RT{j,i});

        % Get the side of the impulsive decision and log the displayed amount
        impulsive_tag = tags{randomTextLocation(j,i)+1};
        counter = [counter;{tmp,KbName(find(keyCode)),impulsive_tag}];

        % if its an impulsive decision and no long term picks have been
        % made the drop the amount signficantly by 200
        if isempty(ratings{j,i})
            if j == 1
                tracker = [tracker;tmp];
            end
        elseif strcmp(KbName(find(keyCode)),impulsive_tag) && ~switch_tag
            % records the impulsive decision made
            tracker = [tracker;tmp]; %#ok<*AGROW>
            tmp = tmp - 200;

            % if its an impulsive decision and atleast one long term pick has been made
        elseif strcmp(KbName(find(keyCode)),impulsive_tag) && switch_tag
            % records the impulsive decision made
            tracker = [tracker;tmp];
            if abs(counter{end-1,1} - tmp) > 10
                tmp = mean([counter{end-1,1},tmp]);
            else
                tmp = tmp + 100;
            end
        elseif ~strcmp(KbName(find(keyCode)),impulsive_tag)
            tmp = mean([tracker(end),tmp]);
            switch_tag = 1;
        else
        end
    end

    %% Inter Trial Fixation
    DrawFormattedText(w,'+','center', 'center', black,[],0,0);
    % Get timestamp for Initial fixation to determine remaining duration
    Screen('Flip', w);

    WaitSecs(InterTrialFixationTime);
end
sca;

%% Post-Task
% Create data struct to save the data
data.ratings = ratings;
data.RT = RT;
data.counter = counter;
data.tracker = tracker;
data.MRI_onset = mri_onset;

% save data to DD Data >> subjectID
save(saveName,'data')
cd(basePath)
end