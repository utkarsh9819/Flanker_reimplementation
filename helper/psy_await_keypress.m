%% GET KEY RESPONSE

% DESCRIPTION: This function checks if any of the keys mentioned in 
% key_options has been pressed. Accordingly it returns a flag. If the 
% subject does not press any key during the time (max_time) a flag=4 is 
% send indicating that no key had been pressed.

% INPUT ARGUMENTS: The keys which will be checked (key_options) and the
% maximum time for a response (max_time)

% OUTPUT: A flag representing which key was pressed (flag) and the time 
% when the key was pressed (key_time)

% Sumitash, 18-Oct-2012

%% 

function varargout = psy_await_keypress(varargin)

keys = varargin{1};                                         % what keys will be considered for response
RestrictKeysForKbCheck(keys);
max_time = varargin{2};
if nargin > 2
    deviceIndex = varargin{3};
else
    deviceIndex = -1;
end
t0 = GetSecs();                                             % time before key press

% Wait till max time is reached or a key is pressed 
iskeypressed = 0;
while (GetSecs() - t0)<=max_time && iskeypressed == 0       % wait till max time is reached or a key is pressed 
    [iskeypressed,key_time,seq] = KbCheck(deviceIndex);
end
RestrictKeysForKbCheck([]);

% Find which key is pressed and save as flag
key_pressed = find(seq);                                    % find which key is pressed and save as flag

% If no key is pressed make flag = 5
if isempty(key_pressed)                                    
    flag = 5;
else
    [~,flag] = ismember(key_pressed,keys);
end

% Output variables
if nargout == 3
    % In case all the keys are possible inputs
    if ~isempty(key_pressed)
        flag = 1;                   % Put flag = 1 if any key is pressed
    end
    if (key_pressed == double(' ')) % Ascii: 32 (space)
        flag = 3;                   % Put flag = 3 if space is pressed
    end
    if (key_pressed == double('0'))
        flag = 4;                   % Put flag = 4 if '0' is pressed
    end
    varargout{1} = flag;
    varargout{2} = key_time;
    varargout{3} = key_pressed;
else
    varargout{1} = flag;
    varargout{2} = key_time;
end

end