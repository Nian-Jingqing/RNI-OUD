
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
[w, ~] = PsychImaging('OpenWindow', screenNumber, black);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% % Query the frame duration
% ifi = Screen('GetFlipInterval', w);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', w);


Blue = [0 0 255];
Green = [0 255 0];
Red = [255 0 0];
Yellow = [255 255 0];
Pink = [252,142,172];

Screen('TextStyle',w,1);
Screen('TextSize',w,70);
Screen('TextFont',w,'Arial');
DrawFormattedText(w,'Hello','center', 100, Blue,[],0,0);
DrawFormattedText(w,'Hello','center', 300, Green,[],0,0);
DrawFormattedText(w,'Hello','center', 500, Red,[],0,0);
DrawFormattedText(w,'Hello','center', 700, Yellow,[],0,0);
DrawFormattedText(w,'Hello','center', 900, Pink,[],0,0);

Screen('Flip', w);
WaitSecs(10);


sca



% rate = 1;
% moviename = '/home/helpdesk/Documents/MATLAB/RNI-OUD/PVT/AdobeStock_419830417_Video_HD_Preview.mov';
% [movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', w, moviename);
% Screen('PlayMovie', movie, rate, 1, 1.0);
% Screen('Flip',w)
% WaitSecs(20)
% sca