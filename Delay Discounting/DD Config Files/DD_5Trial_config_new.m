function config = DD_5Trial_config_new(subjectID,sessionID,protocolID)
% Configuration file for RNI-OUD Baseline Delay Discount Task 
% written Sept 2022 Jacob Suffridge
% --------------------------------------------------------------------------

config = struct();
% Main root directory
config.basePath = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/';
config.dataPath = [config.basePath, 'Delay Discounting Data/', protocolID, '/'];

% Create save directory in "Delay Discounting data" folder
if not(isfolder([config.dataPath, subjectID]))
    mkdir([config.dataPath, subjectID])
end

% Create string to save the data later
config.saveName = [config.dataPath, subjectID, '/' subjectID, '_DD_5Trial_' sessionID,'_', datestr(now,'mm_dd_yyyy_HH_MM') '.mat'];
config.excelName = [config.saveName(1:end-4), '_updating.csv'];

%% Adjustable Parameters
% Input Parameters
config.keys = {'LeftArrow','RightArrow'};

% Appearance Parameters
config.textSize = 55;
config.fixationSize = 250;
config.fontStyle = 'arial';
config.textColor = 1;
config.backgroundColor = 0;
config.instructionTextSize = 65;

% Strings for Instruction Screens
ScreenInstruct1 = 'You will choose between two hypothetical amounts \n\n of money at varing pay out times \n\n\n\n Press the left arrow button to continue';
ScreenInstruct2 = 'Use the left arrow button to select the value on the left \n\n Use the right arrow button to select the value on the right \n\n\n\n Press the right arrow button to continue';
ScreenInstruct3 = 'Read each question carefully \n\n because the amounts and times will change \n\n\n\n Press the left arrow button to continue';
ScreenInstruct4 = 'Press the right arrow button to begin the task';

config.instructionCell = {ScreenInstruct1,ScreenInstruct2,ScreenInstruct3,ScreenInstruct4};

% number of trials per time point
config.num_choices = 6;

% time points to use
config.time_in_days_sorted = [1,7,30,90,365,5*365,25*365];
config.time_strings_sorted = {'1 day','1 week','1 month','3 months','1 year','5 years','25 years'};

config.interTrialDuration = 1;
config.fixationTime = 0.5;
config.InterBlockFixationTime = 4;

config.eqValue = 1000;
config.amountsToAdjust = config.eqValue./(2.^(2:config.num_choices+1));
end