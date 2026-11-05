function [trialStruct] = set_trialStruct_flanker(no_of_trials,no_of_blocks)

% Determine no of trials per block (corrects for unequal trial length)
min_trials_per_block        = 8;
if mod(no_of_trials,min_trials_per_block)~=0
    no_of_trials            = no_of_trials + (min_trials_per_block - mod(no_of_trials,min_trials_per_block));
end
trials_per_block            = round(no_of_trials/no_of_blocks);
if mod(trials_per_block,min_trials_per_block)~=0
    trials_per_block        = trials_per_block + min_trials_per_block - rem(trials_per_block,min_trials_per_block);
    no_of_trials            = round(trials_per_block*no_of_blocks);
end

% Initialise Infos (contains relevant information regarding trial structure)
trialStruct                 = table(zeros(no_of_trials,1), zeros(no_of_trials,1), zeros(no_of_trials,1), ...
                                    zeros(no_of_trials,1), zeros(no_of_trials,1), zeros(no_of_trials,1), zeros(no_of_trials,1), ...
                                    zeros(no_of_trials,1), zeros(no_of_trials,1), zeros(no_of_trials,1), zeros(no_of_trials,1), ...
                                    'VariableNames',{'BlockNo' 'TargDir' 'ArrowDir' 'RT' 'RespKey' 'TrialOutcome' 'fixOnset' 'flankerOnset' 'stimOnset' 'itiOnset' 'itiEnd'});

% Set the trial structure for each block separately
start_block                 = 1;
end_block                   = trials_per_block;

% Set default structure of each block
dummy                       = table(repmat([0 1]',2,1),[zeros(2,1);ones(2,1)],'VariableNames',{'TargDir' 'ArrowDir'});      % Direction,  1 = right, 0 = left
no_of_reps                  = ceil(no_of_trials/4);
trialStruct(:,2:3)          = repmat(dummy,no_of_reps,1);
                                            
for blockno = 1:no_of_blocks
    
    trialStruct(start_block:end_block,1) = table(ones(length(start_block:end_block),1)*blockno);                            % Save block number
    
    % Randomise the trials
    randindx = datasample(1:trials_per_block,trials_per_block,'Replace',false);
    trialStruct(start_block:end_block,:) = trialStruct(start_block+randindx-1,:);
       
    % Trial numbers for next block
    start_block = start_block + trials_per_block;
    end_block   = end_block + trials_per_block;
      
end

end