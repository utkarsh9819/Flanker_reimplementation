function [trialStruct] = flanker_task(parameters, trialStruct, sub_info)
%
% [modified_trialinfo] = FLANKER_PRACTICE(trial_params,trialinfo,Subinfo) 
% runs the flanker task. Congruent trials consists of central right and
% left arrows surrounded by right and left arrows respectively. In the 
% incongruent trials, the central arrow by arrows of the opposite direction. 
% Allowed inputs are right & left key-press, space (pauses the trials), 
% Escape (exits task).  Further, RT are displayed after each block. Some of
% the key-presses work only for the inbuilt keyboard
% 
% PLEASE USE THE SUITABLE FLAG FOR THE TYPE OF DEVICE USED FOR INPUT (LINE 28-34)
% 
% Required helper files: a) plot_online_rt_acc (plots RT and accuracy in each block)
%                        b) psy_await_keypress (gets keypress responses)
% 
% Conjured by Sumitash, June 30, 2017 (MATLAB R2016b)
% Modified for HSL724 by Sumitash, Jan 12, 2023 (MATLAB R2019a)
% 
% ===================================================================================

clc;

% % Flag for either using USB or in-built keyboard
isButton                        = 0;
isInbuilt                       = 1;

% Find out the attached devices (Detects button-box as USB keyboard)
deviceIndex                     = PsychHID('Devices');
if isButton
    keyDeviceIndex              = find(arrayfun(@(x) strcmp(x.usageName,'Keyboard') && strcmp(x.transport,'USB'),deviceIndex)); % USB for scanner
end
if isInbuilt
    keyDeviceIndex              = find(arrayfun(@(x) strcmp(x.usageName,'Keyboard') && strcmp(x.transport,'SPI'),deviceIndex)); % SPI for laptop
end

% Screen
screens                         = Screen('Screens');
screenNumber                    = max(screens);

windowPntr                      = parameters.windowPntr;
windowDim                       = parameters.windowDim;

% Query the frame duration
ifi = Screen('GetFlipInterval', windowPntr);

% Trial parameters
trls_per_block                  = sum(trialStruct.BlockNo==1);
trialno                         = 1;
trialDuration                   = 2;

% Durations
taskSettings.stimulusduration   = 1.5;      % Duration of stimulus display & response duration
taskSettings.BlankTime          = 1;        % Duration of the blank screen
taskSettings.FixTime            = 0.9;      % Fixation duration
taskSettings.FlankerTime        = 0.1;      % Duration of display of flanker stimuli
taskSettings.xtraDuration       = 0.5;      % Extra response duration
waitPeriod                      = 3;        % Countdown time

% Colors
white                           = WhiteIndex(screenNumber);
taskSettings.textClr            = white;
taskSettings.fixColor           = white;

% Stimuli
stimulus.rightCenter            = '>';
stimulus.leftCenter             = '<';
stimulus.rightFlanker           = '> >   > >';
stimulus.leftFlanker            = '< <   < <';

% Response keys
if isInbuilt
    leftresp                    = KbName('leftarrow');
    rightresp                   = KbName('rightarrow');
end

Screen('TextFont',windowPntr, 'Verdana');
Screen('TextSize', windowPntr, 50);

% Instruction screen
str1 = 'INSTRUCTIONS\n';
str2 = '------------------------\n\n';
str3 = 'Press left/right key depending on the direction \n\nof the CENTRAL arrow\n\n\n';
str4 = 'Ignore all the other arrows\n\n\n';
str5 = 'Please be as quick and accurate as possible\n\n';
str6 = 'Press any key to continue ...';
DrawFormattedText(windowPntr,strcat(str1,str2,str3,str4,str5,str6),'center', 'center', taskSettings.textClr);
Screen(windowPntr,'Flip');
KbStrokeWait;

Screen('TextSize', windowPntr, 80);

% TRIALS

for blockno = 1:max(trialStruct.BlockNo)

    for tm = waitPeriod:-1:1
        waitstr = ['Beginning trials in',' ',num2str(tm),' ...'];
        DrawFormattedText(windowPntr,waitstr,'center', 'center', taskSettings.textClr);
        Screen(windowPntr,'Flip');
        WaitSecs(1);
    end

    response_flag = 0;
    Screen('TextSize', windowPntr, 80);

    for trl = 1:trls_per_block   

        trial_start_time             = GetSecs;
        response                     = 0;                                       % Response flag

        % --- Display fixation ---
        DrawFormattedText(windowPntr, '+', 'center', 'center', taskSettings.fixColor); 
        [vbl,stimulus_fix]           = Screen(windowPntr,'Flip');
        FixTime_new                  = (0.1*taskSettings.FixTime).*rand(1) + taskSettings.FixTime;    % Add jitter in fixation delay
        FixTime_new                  = round(FixTime_new/ifi)*ifi;
        trialStruct.fixOnset(trialno)      = stimulus_fix - trial_start_time;

        % --- Display flanker stimulus ---
        if trialStruct.ArrowDir(trialno) == 1
            flankercommand           = stimulus.rightFlanker;
        else
            flankercommand           = stimulus.leftFlanker;
        end
        DrawFormattedText(windowPntr, flankercommand, 'center', 'center', taskSettings.fixColor);
        [vbl, stimulus_flanker]      = Screen('Flip', windowPntr, vbl + FixTime_new - ifi/2);     % update screen
        trialStruct.flankerOnset(trialno)  = stimulus_flanker - stimulus_fix;

        % --- Display central stimulus ---
        if trialStruct.TargDir(trialno) == 1
            stimuluscommand          = stimulus.rightCenter;
        else
            stimuluscommand          = stimulus.leftCenter;
        end
        DrawFormattedText(windowPntr, flankercommand, 'center', 'center', taskSettings.fixColor);
        DrawFormattedText(windowPntr, stimuluscommand, 'center', 'center', taskSettings.fixColor);
        [vbl, stimulus_center]       = Screen('Flip', windowPntr, vbl + taskSettings.FlankerTime - ifi/2);     % update screen
        trialStruct.stimOnset(trialno)     = stimulus_center - stimulus_fix;

        % --- Loop through the trial duration ---
        while (GetSecs - stimulus_center) <= taskSettings.stimulusduration

            % Break loop if any key press is made
            if response == 0

                % Try-catch in case subject presses both keys
                try
                    if isInbuilt
                        [response_flag, key_time] = psy_await_keypress([rightresp leftresp KbName('space') KbName('escape')], taskSettings.stimulusduration/1000, keyDeviceIndex);  
                        if (response_flag == 1 || response_flag == 2 || response_flag == 3 || response_flag == 4)
                            response = 1; 
                            break
                        end
                    end

                catch

                    % If subject presses both buttons, choose first button
                    response_flag = response_flag(1);
                    response = 1; 
                    break

                end

            end

        end

        % --- Save values ---
        if (response_flag == 1 || response_flag == 2)
            rt = key_time - stimulus_center;                % reaction time of the subject 
            trialStruct.RT(trialno) = rt;
            trialStruct.RespKey(trialno)  = response_flag;        
        else
            trialStruct.RT(trialno)       = NaN;
            trialStruct.RespKey(trialno)  = NaN;
        end

        % --- Trial result ---
        switch response_flag
            case 1  

                if trialStruct.TargDir(trialno) == 1
                    trialStruct.TrialOutcome(trialno) = true;
                elseif trialStruct.TargDir(trialno) == 0
                    trialStruct.TrialOutcome(trialno) = false;
                end
            case 2                  

                if trialStruct.TargDir(trialno) == 1 
                    trialStruct.TrialOutcome(trialno) = false;
                elseif trialStruct.TargDir(trialno) == 0
                    trialStruct.TrialOutcome(trialno) = true;
                end
            case 3                               
                trialStruct.TrialOutcome(trialno) = NaN;          % Pause the task
            case 4                               
                break;                                     % Quitting the task
            case 5
                trialStruct.TrialOutcome(trialno) = NaN;          % No response
        end

        % --- Wait ITI ---
        [~,stimulus_endTrial] = Screen('Flip',windowPntr);
        trialStruct.itiOnset(trialno)     = stimulus_endTrial - stimulus_fix;
        waitITI = trialDuration - (GetSecs - stimulus_fix);
        while (GetSecs - stimulus_endTrial) <= waitITI;   end
        trialStruct.itiEnd(trialno)     = GetSecs() - stimulus_fix;

        % --- Pause trials if space is pressed (only for inbuilt keyboard) ---
        if response_flag == 3                                          
            DrawFormattedText(windowPntr, 'PAUSED\n\n\nPress ENTER to continue :)', 'center', 'center', [255 255 0]); % set text
            Screen(windowPntr,'Flip'); 
            pause_flag = 0;
            while (pause_flag ~= 1)
                [pause_flag, key_time] = psy_await_keypress([KbName('return')], 5);  
            end
        end

        trialno = trialno + 1;

    end 

    % Display performance
    plot_online_rt_acc(trialStruct,sub_info,windowDim,windowPntr);        % Display block results
    Screen('TextSize', windowPntr, 40);
    DrawFormattedText(windowPntr, 'End of Block ... Press any key to continue ...', 'center', windowDim(4).*0.98, [255 255 0]); % set text
    Screen(windowPntr,'Flip');
    KbStrokeWait;               % Wait for a key press

end

if response_flag ~= 4
    DrawFormattedText(windowPntr, 'End of trials\n\nPress any key to exit ...', 'center','center', taskSettings.textClr); % set text
    Screen(windowPntr,'Flip');
else 
    % Message for the quiters
    DrawFormattedText(windowPntr, 'Practice quit midway ...\n\nPress any key to exit ...', 'center','center', taskSettings.textClr); % set text
    Screen(windowPntr,'Flip');
end
KbStrokeWait;               % Wait for a key press
  
Screen('CloseAll');
ShowCursor;
Priority(0);
ListenChar(0);

end