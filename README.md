# Arrow Flanker Task (Psychtoolbox)


---

## Overview

This repository contains a complete MATLAB/Psychtoolbox implementation of an Eriksen Flanker task (arrow version). The code runs a practice version of the task with online feedback of reaction time and accuracy after each block.

The task presents a central target arrow (`<` or `>`) flanked by congruent or incongruent arrows. Participants respond to the direction of the central arrow while ignoring the flankers. This is a classic paradigm for studying selective attention and cognitive control.

## Experimental Design

- **Task**: Arrow Flanker
- **Conditions**: Congruent (e.g., `>>>>>`) vs Incongruent (e.g., `>><>>`)
- **Response**: Left / Right arrow keys
- **Trial structure** (per trial):
  1. Fixation cross (≈ 900 ms + jitter)
  2. Flankers alone (100 ms)
  3. Full stimulus (flankers + target) — response window up to 1.5 s
  4. Inter-trial interval
- **Practice parameters** (current settings): 24 trials, 3 blocks
- **Online feedback**: After each block the code displays mean RT (correct trials) and accuracy, and saves a performance figure.

## File Structure

```
Flanker_Task_CodeSample/
│
├── README.md
├── run_flanker.m              % Main entry point
├── set_trialStruct_flanker.m  % Creates balanced trial table
├── flanker_task.m             % Core experimental loop
│
├── helpers/
│   ├── psy_await_keypress.m   % Key press collection
│   └── plot_online_rt_acc.m   % Online RT/accuracy plots
│
└── data/                      % Subject data and figures are saved here
```

## Requirements

- MATLAB (tested with R2019a and later)
- Psychtoolbox-3
- A computer with a keyboard (in-built keyboard supported; USB button box optional)

## How to Run

1. Open MATLAB and navigate to this folder.
2. Make sure Psychtoolbox is installed and on the MATLAB path.
3. Run:
   ```matlab
   run_flanker
   ```
4. Enter participant information when prompted.
5. Follow the on-screen instructions.
6. Data and performance figures are saved in the `data/` folder under a subject-specific subfolder.

## Notes

- This is configured as a **practice version** (small number of trials, online feedback after every block).
- Timing uses Psychtoolbox screen flips and frame intervals for precision.
- The code records trial-level data: RT, accuracy, onset times, response key, block number, target direction, and flanker direction.
- Pause the experiment with the space bar; quit with Escape.

## Short Research Context

The Flanker task is a standard paradigm in cognitive psychology and cognitive neuroscience for measuring selective attention and interference control. Congruent trials typically produce faster and more accurate responses than incongruent trials (the “flanker effect”). The present implementation was prepared as a clean, well-documented practice version suitable for teaching, pilot testing, or as a starting point for full experimental protocols that can later be combined with computational models (e.g., Drift Diffusion Modelling) of decision processes.
