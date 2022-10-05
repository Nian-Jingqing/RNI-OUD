function [] = Foraging(subjectID)
% Main Script for flanker
% written June 2022 Jacob Suffridge
% subjectID must be a string, EX: subjectID = '1234';
% -------------------------------------------------------------------------
% subjectID = 'jacob';
% Define the base and data paths

basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Foraging/';
dataPath = [basePath, 'Foraging Data/'];
imgPath = [basePath, 'Foraging_targets/'];

% Create save directory in DD data folder
cd(dataPath)
mkdir(subjectID)
cd(basePath)

% Create string to save the data later
saveName = [dataPath, '/' subjectID, '/' subjectID '_Virtual_Foraging_' , datestr(now,'mm_dd_yyyy') '.mat'];

%% Parameters to Adjust
harvestDelay = 0.5;
travelTime = 0.5;

textSize = 55;
fixSize = 250;
time2wait = 6;
baseFixationTime = 4;
InterTrialFixationTime = 14;

% Strings for Instruction Screens
ScreenInstruct1 = 'You will choose between two hypothetical amounts \n of money at varing times til pay out \n\n\n Press the 1 button (YELLOW) to continue';
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
img = cell(1,7);
for i = 1:6
    for j = 1:10
        img{j,i} = imresize(imread([imgPath 'Slide' num2str(i) '.JPG']),[screenYpixels/j,screenXpixels/j]);
    end
end
empty_tree = imresize(imread([imgPath 'Slide0.jpg']),[screenYpixels,screenXpixels]);

% Allocate space to store ratings and reaction times
ratings = cell(1,6);
RT = cell(1,6);

% %% Instruction Set 1
% % Create screen for first set of instructions
% Screen('TextStyle',w, 1);
% Screen('TextSize',w, textSize);
% Screen('TextFont',w, 'Arial');
% DrawFormattedText(w, ScreenInstruct1, 'center', 'center', black, [], 0, 0);
% Screen('Flip', w);
%
% str = []; %#ok<*NASGU>
% FlushEvents('KeyDown');
% % trigger release check for first instructions
% while 1
%     str = GetChar(0);
%     disp(str)
%     if strcmp(str,'a')
%         break;
%     end
% end
%
% %% Instruction Set 2
% % Create screen for second set of instructions
% Screen('TextStyle',w,1);
% Screen('TextSize',w,textSize);
% Screen('TextFont',w,'Arial');
% DrawFormattedText(w,ScreenInstruct2,'center', 'center', black,[],0,0);
% Screen('Flip', w);
%
% str = []; %#ok<*NASGU>
% FlushEvents('KeyDown');
% % trigger release check for second instructions
% while 1
%     str = GetChar(0);
%     disp(str)
%     if strcmp(str,'b')
%         break;
%     end
% end
%
% %% Instruction Set 3
% % Create screen for third set of instructions
% Screen('TextStyle',w,1);
% Screen('TextSize',w,textSize);
% Screen('TextFont',w,'Arial');
% DrawFormattedText(w,ScreenInstruct3,'center', 'center', black,[],0,0);
% Screen('Flip', w);
%
% str = [];
% FlushEvents('KeyDown');
% % trigger release check for third instructions
% while 1
%     str = GetChar(0);
%     disp(str)
%     if strcmp(str,'a')
%         break;
%     end
% end
%
% %% Waiting for MRI Trigger
% % Set screen to wait for MRI trigger
% Screen('TextStyle',w,1);
% Screen('TextSize',w, textSize);
% Screen('TextFont',w, 'Arial');
% DrawFormattedText(w, ScreenInstruct4,'center', 'center', black,[],0,0);
% Screen('Flip', w);
%
% str = [];
% FlushEvents('KeyDown');
% % trigger release check
% while 1
%     str = GetChar(0);
%     disp(str);
%     if strcmp(str,'T')
%         mri_onset = GetSecs;
%         break;
%     end
% end
% disp('MRI Trigger received')
% clc;

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
% Loop through the different trees
appleCounter = 0;
numApples = [4,2,5,6,1,3];
% Get the travel distance which is randomly generated between [2,10]
distance = randi([2 10],1,length(numApples));

% Loop through the number of apples on the tree
for i = 1:length(numApples)-1 % number of apples will be random
    % tmp is the number of apples on the current tree
    tmp = numApples(i);

    % Next tree for background
    next_tree = numApples(i+1);
    next_distance = distance(i+1);

    %% Initalize the tree/counter/instructions
    % Pull background image and set text style
    Screen('TextStyle',w,1);
    Screen('TextSize',w,textSize);
    Screen('TextFont',w,'Arial');
    Screen('PutImage', w, img{1,tmp});
%     Screen('DrawTexture', w, img{5,tmp}, [], screenXpixels*.01, screenYpixels*.9, [], [], [], []);

    % Draw Instructions on the bottom left/right of screen
    DrawFormattedText(w,' Collect Apple \n Press 1 button',screenXpixels*.01, screenYpixels*.9, black, [], 0, 0);
    DrawFormattedText(w,' Move to next tree \n      Press 2 button',screenXpixels*.75, screenYpixels*.9, black, [], 0, 0)
    % Start the apple counter
    DrawFormattedText(w, ['Apples collected: ' num2str(appleCounter)],screenXpixels*.01, screenYpixels*.05, black, [], 0, 0);
    % Flip everything to the screen
    Screen('Flip', w);

    %% Iterate through the number of apples on current tree
    for j = tmp:-1:0
        %         % Have to wait to prevent CPU hogging
        %         WaitSecs(0.0001);

        % Waiting for participant response
        str = []; %#ok<*NASGU>
        FlushEvents('KeyDown');
        while 1
            str = GetChar(0);
            if strcmp(str,'a') || strcmp(str,'b')
                break;
            end
        end

        % User selects to stay at the current tree
        if strcmp(str, 'a')
            harvestDelay = 2*(exp(0.5*(1/j) + 1)-2.5);

            Screen('PutImage', w, img{1,j});
            DrawFormattedText(w, 'Harvesting Apples', 'center', screenYpixels*.05, black, [], 0, 0);
            % Flip everything to the screen
            Screen('Flip', w);

            % Harvest Delay
            WaitSecs(harvestDelay)
            % Update the apple counter
            appleCounter = appleCounter + 1;

            % Update counter and display j-1 apples on tree
            if j > 1
                Screen('PutImage', w, img{1,j-1});
                % push n-1 apples on the tree
                DrawFormattedText(w, ['Apples collected: ' num2str(appleCounter)],screenXpixels*.01, screenYpixels*.05, black, [], 0, 0);
                % Draw Instructions on the bottom left/right of screen
                DrawFormattedText(w,' Collect Apple \n Press 1 button',screenXpixels*.01, screenYpixels*.9, black, [], 0, 0);
                DrawFormattedText(w,' Move to next tree \n      Press 2 button',screenXpixels*.75, screenYpixels*.9, black, [], 0, 0);
                % Flip everything to the screen
                Screen('Flip', w);

                % Update counter and display empty tree
            elseif j == 1
                Screen('PutImage', w, empty_tree);
                % push n-1 apples on the tree
                DrawFormattedText(w, ['Apples collected: ' num2str(appleCounter)],screenXpixels*.01, screenYpixels*.05, black, [], 0, 0);
                % Draw Instructions on the bottom left/right of screen
                DrawFormattedText(w,' Collect Apple \n Press 1 button',screenXpixels*.01, screenYpixels*.9, black, [], 0, 0);
                DrawFormattedText(w,' Move to next tree \n      Press 2 button',screenXpixels*.75, screenYpixels*.9, black, [], 0, 0);
                % Flip everything to the screen
                Screen('Flip', w);

                % Wait for user to decided to leave tree. Delete this condition
                % to progress directly to the next tree
            else
                % Waiting for participant response
                str = []; %#ok<*NASGU>
                FlushEvents('KeyDown');
                while 1
                    str = GetChar(0);
                    if strcmp(str,'b')
                        break;
                    end
                end
            end

            % User selects to leave the current tree
        else  % i.e. pressed 2/b
            break;
        end

    end

    % Loop through the distance the user is from the next tree
    for k = distance:-1:1
        % push n-1 apples on the tree
        %         DrawFormattedText(w, ['Apples collected: ' num2str(appleCounter)],screenXpixels*.01, screenYpixels*.05, black, [], 0, 0);
        DrawFormattedText(w, 'Moving to next tree', 'center', screenYpixels*.05, black, [], 0, 0);
        % Draw Instructions on the bottom left/right of screen
        %         DrawFormattedText(w,' Move to next tree \n      Press 2 button',screenXpixels*.75, screenYpixels*.9, black, [], 0, 0)
        Screen('PutImage', w, img{k,next_tree});
        % Flip everything to the screen
        Screen('Flip', w);
        if k ~= 1
            WaitSecs(travelTime)
        end
    end
end

%     %% Inter Trial Fixation
%     Screen('TextStyle',w,1);
%     Screen('TextSize',w,fixSize);
%     Screen('TextFont',w,'Arial');
%     DrawFormattedText(w,'+','center', 'center', black,[],0,0);
%     % Get timestamp for Initial fixation to determine remaining duration
%     Screen('Flip', w);
%
%     WaitSecs(InterTrialFixationTime);

sca;

%% Post-Task
% Create data struct to save the data
data.ratings = ratings;
data.RT = RT;
% data.MRI_onset = mri_onset;

% save data to DD Data >> subjectID
save(saveName,'data')
cd(basePath)




end
