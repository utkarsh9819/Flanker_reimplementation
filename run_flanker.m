%% RUN FLANKER PRACTICE
% Main entry point for the Arrow Flanker task (Psychtoolbox).
% Collects participant information, sets up the screen, creates the trial
% structure, and launches the experimental loop.
%
% Requires: Psychtoolbox-3
% See README.md for full documentation.

close all
clc

% Ensure helper functions are on the path
addpath(fullfile(pwd, 'helpers'));

%% Subject information

if ~exist('sub_info','var') && ~exist('subject_id','var')
    qstns                       = {'Participant number','Gender','Age','Experimenter'};
    dlg_title                   = 'Participant Information';
    num_lines                   = 1;
    def_val                     = {'','','',''};
    input_val                   = inputdlg(qstns,dlg_title,num_lines,def_val);
    [sub_info.subject_id,sub_info.gender,sub_info.age,sub_info.experimenter] ...
                                = deal(input_val{1},input_val{2},input_val{3},input_val{4});
    sub_info.date               = fix(clock);
elseif ~exist('sub_info','var') && exist('subject_id','var')
    [sub_info.subject_id,sub_info.gender,sub_info.age,sub_info.experimenter,sub_info.date] ...
                                = deal(subject_id,gender,age,experimenter,date);
    clear subject_id gender age date experimenter
end

savePath                        = [pwd,'/data/'];

%% Set-up screen & sound

% Skip psychtoolbox synctests
skip_sync_tests                 = 1;
Screen('Preference', 'SkipSyncTests', skip_sync_tests);
Screen('Preference', 'SuppressAllWarnings', 0);
Screen('Preference', 'VisualDebugLevel', 1);

PsychDefaultSetup(2);

% Screen
screens                         = Screen('Screens');
parameters.screenNumber         = max(screens);
black                           = BlackIndex(parameters.screenNumber);

% Initiate psychtoolbox
[windowPntr, windowDim]         = PsychImaging('OpenWindow', 0, black, [], 32, 2,[], [],  kPsychNeed32BPCFloat);
priorityLevel                   = MaxPriority(windowPntr); % prioritize
Priority(priorityLevel);
ListenChar(2);
HideCursor; 

parameters.windowPntr           = windowPntr;
parameters.windowDim            = windowDim;

%% Set practice
   
trial_parameters.no_of_trials   = 24;
trial_parameters.no_of_blocks   = 3;
trial_parameters.windowPntr     = parameters.windowPntr;
trial_parameters.windowDim      = parameters.windowDim;
trial_parameters.screenNumber   = parameters.screenNumber;
trial_parameters.trial_cond     = 'practice';     

trialStruct                     = set_trialStruct_flanker(trial_parameters.no_of_trials,trial_parameters.no_of_blocks);

% Switch screen
Screen('TextSize', windowPntr, 50);
Screen('TextFont', windowPntr, 'Verdana');
DrawFormattedText( windowPntr, 'Trials', 'center', 'center', [255 255 255]);
Screen('Flip', windowPntr);
WaitSecs(2);

[trialStruct]                   = flanker_task(trial_parameters, trialStruct, sub_info);
