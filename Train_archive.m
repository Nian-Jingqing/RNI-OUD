% Training.m is a script used to determine the best visual drug cues for
% the OUD task. The script will showcase a various panel of drug images
% while allowing the subject to provide a rating of their craving. These
% ratings will be used to automatically generate image sets to be used in
% the other OUD task such as DBS, Cue Reactivity, etc...
%
% ---- Jacob Suffridge Feb 24, 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sca; clear; clc; close all;

% setenv('DRI_PRIME','1'); 
%% Script Dependencies: 
%

% Add Library and Drug Cues to path
addpath('C:\Users\jesuffridge\Documents\MATLAB\Projects\DBS-OUD\Lib');
addpath('C:\Users\jesuffridge\Documents\MATLAB\Projects\DBS-OUD\Drug_Cues');

% Call config.m to set path variables
Config;
cd(config.root);
gpuDevice([]);

%% Subject ID and Session Number should be changed every time the task is ran
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectID = 'test';
sessionNum = 'test';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Confirm Valid Input Arguements will terminate code if not correct
if ~ischar(subjectID) || ~ischar(sessionNum)
    disp('Check Input Parameters, error has occurred');
    return;
end
clc;

% Display the input parameters to verify that they are accurate
disp(' ');
disp(['Subject ID: ' subjectID]);
disp(['Session Number: ' sessionNum]);
disp(' ');

pause(2);
prompt = 'IS THIS THE CORRECT SUBJECT ID AND SESSION NUMBER?(y/n)..........';
warning = input(prompt, 's');
if strcmp(warning,'y') || strcmp(warning, 'Y')
else
    return;
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-Task setup
KbName('UnifyKeyNames');

% Fetch image list depending on the input "list" arguement
% output = preload_images(list);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adjustable Parameters
% Time to wait for a response and the duration of image presentation
time2wait = 10;     % seconds
img_duration = 5;   % seconds
numBlocks = 1;
img_scale = 0.85;

% Size of onscreen text and the fixation "+"
textSize = 40;
fixSize = 250;

% Strings for Instruction Screens
ScreenInstruct1 = '\n\n During this task, you will be presented with various stimuli, \n\n your job is to rate your craving for the images \n\n on a scale from 0 to 9 \n\n\n\n\n\n Press "0" to continue';
ScreenInstruct2 = '\n\n Please wait for the Craving Rating to appear on screen \n\n before entering your response.  \n\n\n\n Press "1" to continue';

% MRI
% activeKeys = [KbName(97) KbName(98) KbName(99) KbName(100) KbName(65) KbName(66) KbName(67) KbName(68)]; % keys:1,2,3,4,a,b,c,d

% Numpad : Add extra line to take input from numpad and num keys across top of keyboard
activeKeys = [KbName(96) KbName(97) KbName(98) KbName(99) KbName(100) KbName(101) KbName(102) KbName(103) KbName(104) KbName(105)]; % keys: 0,1,2,3,4,5,6,7,8,9
activeKeys = [activeKeys KbName('0') KbName('1') KbName('2') KbName('3') KbName('4') KbName('5') KbName('6') KbName('7') KbName('8') KbName('9')];

% Img list will be generated per subject
img_dir = [config.cues 'Heroin\'];
img_list = {[img_dir '01.jpg'],[img_dir '02.jpg'],[img_dir '\03.jpg']};

% img_list = {'01.jpg','02.jpg','03.jpg'};
rating_list = dir(config.rating_scales); rating_list(1:2) = [];

%Pre-run 
preTaskGen(subjectID);

% Initialize screen preferences
Screen('Preference', 'ConserveVRAM', 4096);
% Screen('Preference','VBLTimestampingMode',-1);
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);

% Get the screen numbers
screens = Screen('Screens');

% Call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
if config.debug
    PsychDebugWindowConfiguration();
end

% Draw to the external screen if available
screenNumber = max(screens);
% screenNumber = 2;

% Define black and white
white   = WhiteIndex(screenNumber);
black   = BlackIndex(screenNumber);
grey    = white / 2;

% Open an on screen window
[w, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
% [w, windowRect] =  Screen('OpenWindow',screenNumber);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%% Instruction Block
Screen('TextSize',w, 30);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct1,'center', 'center', white,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check for 1st instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'0')
        break;
    end
end

Screen('TextSize',w, 30);
Screen('TextFont',w, 'Arial');
DrawFormattedText(w, ScreenInstruct2,'center', 'center', white,[],0,0);
Screen('Flip', w);

str = [];
FlushEvents('KeyDown');
% trigger release check for 2nd instructions
while 1
    str = GetChar(0);
    disp(str)
    if strcmp(str,'1')
        break;
    end
end


% Query the frame duration
ifi = Screen('GetFlipInterval', w);

% main window dimensions
[X,Y] = RectCenter(windowRect);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

% % center screen position
% dispW   = windowRect(3) - windowRect(1);
% dispH   = windowRect(4) - windowRect(2);
% x0      = round(dispW/2);
% y0      = round(dispH/2);

% Get location information for timestamp
timestampX = 'center';
timestampY = round((1 - (1 - img_scale)/4) * screenYpixels);

% Initialize storage for task information
ratings = [];
RT = cell(numBlocks,6);
keys = cell(numBlocks,6);
times = cell(numBlocks,length(img_list)+1);

for i = 1:numBlocks
    
    % Loop through the current block of images
    for j = 1:length(img_list)
        
        % Load the current image
        img = imread(img_list{j});
        
        % resize image to img_scale % of the screen
        img = imresize(img, img_scale*[screenYpixels,screenXpixels]);
        
        % Pull the image to the screen
        Screen('PutImage', w, img);
        % Display the time stamp on screen (TEMPORARY)
        Screen('TextSize',w, 30);
        Screen('TextFont',w, 'Geneva');
        
        % Get the current time for the timestamp
        tmp_date = datestr(now,'HH:MM:SS');
        DrawFormattedText(w, tmp_date, 'center', timestampY, black,[],0,0);
        
        times{i,j} = tmp_date;
        
        % Flip all current events to the screen and wait for the image duration
        Screen('Flip',w);
        WaitSecs(img_duration);
    end
    
    % Loop through the select rating scales
    for k = 1:length(rating_list)
        
        % read current rating scale
        rating_img = imread([config.rating_scales rating_list(k).name]);
        % resize to full screen4
        rating_img = imresize(rating_img, [screenYpixels,screenXpixels]);
        
        % Get the time that the rating scales starts for the plots
        times{i,end} = datestr(now,'HH:MM:SS');
        
        % Pull rating scale to the screen
        Screen('PutImage', w, rating_img);
        Screen('Flip',w);
        
        % Need to wait a small amount of time to correct the flow
        WaitSecs(0.2);
        
        [tmp1,tmp2] = checkForKb(activeKeys, time2wait);
        RT{i,k} = tmp1;
        keys{i,k} = str2double(tmp2(1));
        
        % Just to be safe clear the tmp variables
        clear tmp1 tmp2
    end
    ratings = [ratings; [keys{i,:}]]; %#ok<AGROW>

    plotRatings(ratings,times)
end

% save the RT,keys,times, img_list into Session#_date.mat
save([config.data '\' subjectID '\Session' sessionNum '_' char(datetime('now','Format','MM-dd-yyyy')) '.mat'],'RT','keys','times','img_list');


sca; clc;
% end

%%

% reshape([keys{:,:}], [], length(rating_list))