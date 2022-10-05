function [ratings,RT,resp] = showRatingSlider(w,craving_scales,craving_scales_submitted,sliderStart,sliderDuration,keys,textColor,base_rating)
% showRatingSlider is a function to present the rating scale to the screen,
% allow the participant to move the slider and record the final response.

ratings = nan;
RT = nan;

% Extract the keys from the input keys
leftKey = keys{1};
rightKey = keys{2};
acceptKey = keys{3};

% Index the slider ticks
sliderTicks = 0:.25:10;
% start the slider index at sliderStart
sliderCount = sliderStart;

%% Start the Slider loop

Screen('PutImage', w, base_rating);
% Flip rating scales to the screen
rating_start = Screen('Flip', w);
resp = [];
while GetSecs - rating_start < sliderDuration
    % Waiting for participant response
    while true
        % check if a specified key is pressed
        [ keyIsDown, keyTime, keyCode ] = KbCheck;
        if(keyIsDown)
            while KbCheck, end
               resp = [resp;keyTime];
            break;
        elseif GetSecs - rating_start >= sliderDuration
            ratings = sliderTicks(sliderCount);
            RT = nan;
            break;
        end
    end
    % Get the string for the key press
    str = KbName(find(keyCode));

    % Increase slider_count and update slider image
    if strcmp(str,rightKey)

        % Increase the slider count
        sliderCount = sliderCount + 1;
        % If the slider is all the way right move it all the way left
        if sliderCount > length(craving_scales)
            sliderCount = length(craving_scales);
        end

        % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales{sliderCount});
        Screen('Flip', w);

        % Decrease the slider_count and update slider image
        % Disable this elseif to remove the decrease functionality, useful
        % for sticking to 2 buttons
    elseif strcmp(str,leftKey)

        % Decrease the slider count
        sliderCount = sliderCount - 1;
        % If the slider is all the way left move it all the way right
        if sliderCount == 0
            sliderCount = 1;
        end

        % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales{sliderCount});
        Screen('Flip', w);

    elseif strcmp(str,acceptKey)
        % Record the slider rating
        ratings = sliderTicks(sliderCount);
        % Record the reaction time of the slider submission
        RT = GetSecs - rating_start;

%         % Draw fixation to the screen between sliders/images
%         DrawFormattedText(w,' ','center', 'center', textColor,[],0,0);
%         Screen('Flip', w);

         % Draw the rating feedback image to the screen
        Screen('PutImage', w, craving_scales_submitted{sliderCount});
        Screen('Flip', w);

        % Wait so that the block time is consistent
        WaitSecs(sliderDuration - RT);
        break;
    else
    end
end
end