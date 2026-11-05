# Short Research Summary – Arrow Flanker Task

This code implements a classic Eriksen Flanker task (arrow version) using MATLAB and Psychtoolbox. Participants respond to the direction of a central target arrow while ignoring surrounding flanker arrows that can be congruent or incongruent with the target.

The Flanker task is a standard paradigm for studying selective attention and cognitive control. The typical finding is a “flanker effect”: slower and less accurate responses on incongruent trials compared with congruent trials. The present implementation records trial-level reaction times, accuracy, and stimulus timing with high temporal precision, and provides online performance feedback after each block.

The code is structured so that it can be readily extended into a full experimental protocol and combined with computational models of decision making (for example, Drift Diffusion Modelling) to decompose behavioural effects into evidence accumulation rate, response caution, and non-decision time. It therefore serves both as a clean demonstration of precise behavioural experiment programming and as a foundation for computational cognitive modelling.
