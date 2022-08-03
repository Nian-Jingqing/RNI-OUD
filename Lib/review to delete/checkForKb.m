function [RT,keyName] = checkForKb(activeKeys, time2wait)
% activeKeys specifies the keys were interested in
% Example: activeKeys = [KbName(97) KbName(98) KbName(99) KbName(100)];

% time2wait is the max amount of time to wait for a rating response
% Example: time2wait = 10; Code will allow 10 seconds for response before proceeding

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% improve portability of your code across operating systems
KbName('UnifyKeyNames');

% Restrict KbCheck to active keys only
RestrictKeysForKbCheck(activeKeys);
% suppress echo to the command line for keypresses
ListenChar(2);

% Get start timestamp
tStart = GetSecs;
% repeat until a valid key is pressed or it times out
timedout = false;

% Loop to watch for the key presses
while ~timedout
    % check if a specified key is pressed
    [ keyIsDown, keyTime, keyCode ] = KbCheck;
    if(keyIsDown), break; end
    if( (keyTime - tStart) > time2wait), timedout = true; end
end

% store code for key pressed and reaction time
if(~timedout)
    
    RT = keyTime - tStart;
    keyName = KbName(keyCode);
    
%     rsp.RT      = keyTime - tStart;
%     rsp.keyName = KbName(rsp.keyCode);
end

% Reenable all keys
RestrictKeysForKbCheck;

% Reset command window echo
ListenChar(1)

end