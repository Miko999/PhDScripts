%% Executive Functioning and Mind Wandering (RPS) Study - Task Scoring Code

% Chelsie H.
% Started: June 28, 2023
% Last updated: June 28, 2023
% Last tested: (once script is complete)

    % Purpose: 
% Take cleaned task data from data cleaning script and score each task and 
% practice task as outlined in the preregistration for this study
% Also, grabbing some descriptive statistics for checking the data

    % Input:
% .csv files from CleanedData and CleanedPracticeData folders
% raw file names are usually PARTICIPANTID_TASK.csv or
% PARTICIPANTID_TASKP.csv for practice

    % Current Output:
% TBD - likely a single csv with desired scores and descriptives for all
% participants

    % Example data files:
% RPS003_demo...csv and Test_...csv
% RPS003_demo does not have reaction time for the symmetry span task as it
% is an older data file from before this issue was corrected.

%% Notes

    % To do's:
% Make a basic output csv with columns defined
% import this with proper data types for each column

% Create basic skeleton for scripting with notes on how to approach each
% part
% Score each task excluding dummies
% Derive useful descriptive statistics for each task excluding dummies (e.g., mean, sd, min, max
% for reaction time to see if anyone had any odd trials).

% Add a check for non-responders to MCT
% Count the number of probes for MCT
% Count response types for MCT

% Do a re-check of accuracy in case psychopy accuracy is not correct

% add this all to the data cleaning script 
% add task info to the output file too

    % Future ideas:
% combine this with researcher notes 
% combine this with questionnaires scoring and demographics
% check for participants that may have responded too early or too late on
% some trials (only the final response is recorded)
% create a standardized scoring reference?

%% Versions and Packages

% Main PC: Matlab R2021b update 6
% Packages: Stats and machine learning toolbox version 12.2, simulink
% version 10.4, signal processing toolbox version 8.7, image processing
% toolbox version 11.4; FieldTrip 1.0.1.0

% Laptop:
% Packages:


%% Clear all and Select Directory - REMOVE WHEN THIS IS ADDED TO CLEANING LOOP
% WHEN THIS IS ADDED TO DATA CLEANING LOOP Just use the data for each task

clc
clear

% Request for which device to set directory
LaptopOrDesktop = input('Which device are you using? (1 for Desktop, 2 for Laptop):');

fprintf('Setting directories\n')

if LaptopOrDesktop == 1
    % on desktop 
    maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSPsychoPyDataCleaning/');

else
    % on laptop 
    maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSPsychoPyDataCleaning/');
end

cleaneddatadir = [maindir 'CleanedData/'];
cleanedpdatadir = [maindir 'CleanedPracticeData/'];
addpath(genpath(maindir))

opts = detectImportOptions([maindir 'RPS_PsychoPyTaskInfo.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskInfo = readtable([maindir 'RPS_PsychoPyTaskInfo.csv'],opts);
    
clear opts

%%  JUST USING FIRST DEMO DATA FOR TESTING THE SCRIPT
ID = "RPS003_Demo";

% Just to check that opts are correct
% SARTDataFile = fullfile(cleaneddatadir, strcat(ID,"_SART.csv"));
% SwitchDataFile = fullfile(cleaneddatadir, strcat(ID,"_Switch.csv"));
% SymSpanDataFile = fullfile(cleaneddatadir, strcat(ID,"_SymSpan.csv"));
% NBackDataFile = fullfile(cleaneddatadir, strcat(ID,"_NBack.csv"));
% MCTDataFile = fullfile(cleaneddatadir, strcat(ID,"_MCT.csv"));

% opts = detectImportOptions(MCTDataFile);
% all importing seems to be fine except if the participant has no symspan
% reaction times, the columns may be imported as characters.

SARTData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SART.csv")));
SwitchData = readtable(fullfile(cleaneddatadir, strcat(ID,"_Switch.csv")));
SymSpanData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SymSpan.csv")));
NBackData = readtable(fullfile(cleaneddatadir, strcat(ID,"_NBack.csv")));
MCTData = readtable(fullfile(cleaneddatadir, strcat(ID,"_MCT.csv")));

SARTPData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SARTP.csv")));
SwitchPData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SwitchP.csv")));
SymSpanPData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SymSpanP.csv")));
NBackPData = readtable(fullfile(cleaneddatadir, strcat(ID,"_NBackP.csv")));
MCTPData = readtable(fullfile(cleaneddatadir, strcat(ID,"_MCTP.csv")));

%% Scoring SART
% difference between correct response to non-targets (hit) and falsely responding
% to 3 (false alarm)
% if hit rate or false alarm rate are 0 or 1, adjust by 0.01

% so need to find:
% number of trials (should be consistent across participants)
    % should also just be maximum of SARTTrial/SARPTrial
% number of correct responses to numbers other than 3
    % if SARTst
% number of incorrectly responding to number 3
% hit rate = correct responses to numbers other than 3 / total numbers
% other than 3
% false alarm rate = incorrect response to 3 / total 3s
% measure of interest (d prime) = correct to non targets - incorrect
% responses to 3

% some studies report mean accuracy rates

% Practice

% Actual

%% Scoring Switch
% calculating switch cost for reaction time
% average reaction time for switch - average reaction time for stay
% this is for TRIALS not subtasks, calculated within the mixed blocks.

% need to calculate:
% number of mixed block stay and switch trials (should be conssitent across
% participants)
% average reaction time for mixed blocks switch trials
% average reaction time for mixed blocks stay trials
% difference between these averages

%% Scoring SymmSpan

% symspan without SymSpanMixSymRT and SymSpanMixRecRT data need to be set to
% double
% so could check if these rows are empty, if empty just add data of
% interest as "NaN"

% partial score, total number of squares recalled in the correct serial
% position (regardless of if whole series was correct)

% need to find:
% (number of red squares; should be consistent across participants)
% total correct red squares

%% Scoring NBack
% d prime, difference between correct response and false alarm to incorrect
% stimuli

% separately and together for 1-back and 2-back, Some studies calculate an
% average across n-back loads...
% need to calculate
% number of trials (should be consistent across participants)
% number of correct responses to target
% number of incorrectly responding to number non-target
% hit rate = correct responses to target/ total number of targets
% false alarm rate = incorrect response to non-target / non-targets
% measure of interest (d prime) = correct to target - incorrect
% to non-target

% some studies have also found a ceiling effect with the 1-back

%% Scoring Working Memory
% z-score transform and average symmetry span and n-back task scores

%% Scoring MCT
% proportion of probes where participant was MW
% proportion of probes where participant was MW and aware/unaware
% proportion of probes where participant was MW and had
% intentional/unintentional thoughts

% will want to get total probes for the record as well
% total probes of each type (miscount, lost count, time out)

% percentage of trials where the participant did not respond

%% OUTPUT
% will be like task info, loading in a file and adding all new information
% to it.

