function [when, nwritten, errmsg] = sendTrigger(handle,triggerIntensity,triggerDuration)
% A quick function to send a serial port trigger when executed. This
% function requires a port handle, trigger intensity and trigger duration
% (time between high/low, usually very short)

% Send trigger
[nwritten, when, errmsg] = IOPort('Write', handle, uint8(triggerIntensity));
WaitSecs(triggerDuration);
IOPort('Write',handle,uint8(0));

end