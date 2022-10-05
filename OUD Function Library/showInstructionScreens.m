function [instructionTimestamps] = showInstructionScreens(w,instructionCell,advanceKeys,textColor,textSize)
% showInstructionScreens is a function that will sequentially display each set of
% instructions from the cell instructionCell and will wait for the
% advanceKey to progess. The length(instructCell) is the number of
% instruction screens that will be displayed.
% Example Inputs:
% window = w (for almost all instances of OUD code)
% instructionCell = {'Instructions 1','Instructions2,...InstructionsN};
% advanceKeys = {'advanceKey1','advanceKey2',...'advanceKeyN'};
%
%--------------------------------------------------------------------------
% Preallocate space for the instruction timestamps (function will return this cell)
instructionTimestamps = cell(length(instructionCell),1);
Screen('TextStyle',w,1);
Screen('TextFont',w,'arial');

% iteration through each set of instructions
for i = 1:length(instructionCell)

    % Create screen for each set of instructions
    Screen('TextSize',w, textSize);
    DrawFormattedText(w, instructionCell{i}, 'center', 'center', textColor, [], 0, 0);
    instructionTimestamps{i} = Screen('Flip', w);

    % Listen for keyboard input to proceed
    FlushEvents('KeyDown');
    while true
        while true
            % check if the specified key is pressed
            [ keyIsDown, ~, keyCode ] = KbCheck;
            if(keyIsDown)
                break;
            end
        end
        if strcmp(KbName(find(keyCode)),advanceKeys{i})
            break;
        end
    end
    % Iterate to the next set of instructions could add a WaitSecs command
    % here if needed.
end

end
