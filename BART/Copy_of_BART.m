function [] = BART(subjectID, protocolID)
% Main Script for BART
% written August 2022 Jacob Suffridge
% subjectID must be a string, EX: subjectID = '1234';

% clc;
% subjectID = 'jacob';
% Shift focus to the command window 
commandwindow

% Define the base path, data path and the path to BART target images
basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/BART/';
dataPath = [basePath, 'BART Data/'];
targetPath = [basePath, 'BART Targets/'];

% Create save directory in "BART Data" folder
cd(dataPath)
if not(isfolder(subjectID))
    mkdir(subjectID)
end
cd(basePath)

% Create string to save the data later
saveName = [dataPath, subjectID, '/' subjectID '_BART_' , datestr(now,'mm_dd_yyyy') '.mat'];
%% ADD protocol ID to the path

%% Parameters to Adjust
%--- Started 8/11
numTrials = 1;
timeToWatchPopped = 3;
minPressLimit = 20;
maxPressLimit = 50;
activeKeys = [KbName('a'),KbName('b')];
%---

textSize = 50;
fixSize = 250;
time2wait = 1.2;

initialFixationTime = 2;
InterTrialFixationTime = 2;   %14

% Strings for Instruction Screens
ScreenInstruct1 = 'In this task, you will be asked to pump up a balloon using the "a" button \n\n\n If you inflate the balloon too much it will explode! \n\n\n\n Press "a" to continue';
ScreenInstruct2 = 'Inflate the balloon until you think its just about to pop \n\n then press the "b" button. \n\n\n The more you inflate the balloon, the more points you will recieve. \n\n\n\n Press the "b" button to continue';
ScreenInstruct3 = 'Please wait for the MRI to start';

%% Preload the Balloon Images
% Get names of all BART Targets
files = dir(targetPath);
% Get names of regular balloons
balloon = files(~contains({files.name},'exp'));
% Remove extra directory names '.' and '..'
balloon(ismember({balloon.name},{'.','..'})) = [];
% Get names of popped balloons
popped = files(contains({files.name},'exp'));

% Preallocated space to store regular and popped balloon images. Allows us
% to preload the images instead of loading during task execution
balloonImgs = cell(100,1);
poppedImgs = cell(100,1);
for i = 1:length(balloon)
    balloonImgs{i} = imresize(imread([targetPath, balloon(i).name]),2);
    poppedImgs{i} = imresize(imread([targetPath, popped(i).name]),2);
end

% Generate a list of maximum values (i.e. balloon will pop after n+1 presses)
maxList = randi([minPressLimit, maxPressLimit],[numTrials,1]);

%% Prepare the screen
% Call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Initialize screen preferences
% Screen('Preference', 'ConserveVRAM', 4096);
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

%% Waiting for MRI Trigger
% Set screen to wait for MRI trigger
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
% Format and Draw the onscreen fixation +
Screen('TextStyle',w,1);
Screen('TextSize',w,fixSize);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'+','center', 'center', black,[],0,0);

% Get timestamp for Initial fixation to determine remaining duration
initialFixationOnset = Screen('Flip', w);

WaitSecs(initialFixationTime);

%% Start of BART Task
RestrictKeysForKbCheck(activeKeys);

% Allocate space to store ratings and reaction times
buttonPresses = cell(numTrials, 100);
RT = cell(numTrials, 100);
exitMsg = cell(numTrials,1);
pointsEarned = cell(numTrials,1);

% Suppress keyboard echo to command window
ListenChar(2)
% Loop through the predefined presentation list
for i = 1:numTrials
    % Pull the current number of iterations before the balloon pops
    currentThreshold = maxList(i);

    % Loop through the balloon sizes starting at 1 until exit or pop
    for j = 1:currentThreshold

        % Draw the balloon on center of the screen
        Screen('PutImage', w, balloonImgs{j});
        % Format the onscreen text
        Screen('TextStyle',w,1);
        Screen('TextSize',w,textSize);
        Screen('TextFont',w,'Arial');
        % Temp counter for debugging will be deleted from finished task
        DrawFormattedText(w,[num2str(j),'/',num2str(currentThreshold)], 100, 200, black,[],0,0);

        % Flip everything to the screen
        balloonOnsetTime = Screen('Flip', w);

        % Waiting for participant response
        timedOut = 0;
        while ~timedOut
            % check if a specified key is pressed
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            if(keyIsDown)
                while KbCheck, end
                break;
                %             if( (keyTime - balloonOnsetTime) > time2wait)
                %                 timedOut = true;
                %             end
            end
        end

        % Records the key that was pressed
        str = KbName(find(keyCode));
        % Records Reaction Time and Response Key
        if (~timedOut)
            % Capture the reaction time and button presses
            RT{i,j} = keyTime - balloonOnsetTime;
            buttonPresses{i,j} = str;
        else
            % Capture the reaction time and button presses
            RT{i,j} = nan;
            buttonPresses{i,j} = [];
        end

        % Handle the button presses
        if strcmp(str,'b')
            % Record the points earned
            pointsEarned{i} = 5*(j-1);

            % Record that the trial ended as "Quit Early"
            exitMsg{i} = 'Quit Early';
            DrawFormattedText(w,['You scored ', num2str(pointsEarned{i}), ' points'], 'center', screenYpixels*0.85, black,[],0,0);
            break;

        elseif strcmp(str,'a') && j == currentThreshold
            % Record the points earned
            pointsEarned{i} = 0;

            % Flip popped balloon image to the screen
            Screen('PutImage', w, poppedImgs{currentThreshold});
            DrawFormattedText(w, ['You scored ', num2str(pointsEarned{i}), ' points'], 'center', screenYpixels*0.85, black,[],0,0);
            
            Screen('Flip',w);
            % Let the image stay on screen for timeToWatchPopped seconds
            WaitSecs(timeToWatchPopped);

            % Record that the trial ended as "Popped"
            exitMsg{i} = 'Popped';
        else
            % Only option that goes here is str == 'b' and j ~= currentThreshold
            % do nothing and continue on to next iteration
        end
    end

    % Inter Trial Fixation
    Screen('TextStyle',w,1);
    Screen('TextSize',w,fixSize);
    Screen('TextFont',w,'Arial');
    DrawFormattedText(w,'+','center', 'center', black,[],0,0);
    % Get timestamp for Initial fixation to determine remaining duration
    Screen('Flip', w);

    % Leave the fixation on the screen for InterTrialFixationTime seconds
    % before moving to the next trial
    WaitSecs(InterTrialFixationTime);

end

% Renable the keyboard echo and screen clear all
ListenChar();
sca;

%% Post-Task Proccess
% Create data struct to capture useful variables
data.buttonPresses = buttonPresses;
data.RT = RT;
data.exitMsg = exitMsg;
data.pointsEarned = pointsEarned;
data.totalPoints = sum([pointsEarned{:}]);

% save data to BART Data >> subjectID
save(saveName,'data')
cd(basePath)
end