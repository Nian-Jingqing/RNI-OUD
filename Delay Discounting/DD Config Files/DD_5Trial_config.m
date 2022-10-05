function config = DD_baseline_config()
% Configuration file for RNI-OUD Baseline Delay Discount Task 
% written Sept 2022 Jacob Suffridge
% --------------------------------------------------------------------------

config = struct();
% Main root directory
% config.root = 'C:\Users\jesuffridge\Documents\MATLAB\Projects\RNI-OUD';
config.root = '/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting';

% Path to configs
config.configs = [config.root '/DD Config Files/'];

%% Adjustable Parameters
config.textSize = 55;
config.fixationSize = 250;
config.fontStyle = 'arial';
config.textColor = 1;
config.backgroundColor = 0;
config.instructionTextSize = 65;

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