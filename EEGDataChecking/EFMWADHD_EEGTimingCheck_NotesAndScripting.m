%% Executive Functioning and Mind Wandering in ADHD Study - Part 2 - EEG - Timing Check Script

% Chelsie H.
% Started: June 7, 2023
% Last updated: June 8, 2023

% Purpose: to ensure timing of EEG information from brainvision recorder
% and psychopy task timing are consistent.

% File with column key and content information is
% PsychoPyData_EEGMCT_ColumnKey.xlsx for psychopy output

% Example data files: RAD_DEMO_EEG Metronome Counting Task_2023-06-06_14h58.38.178.csv 
% RAD_DEMO.eeg RAD_DEMO.vhdr RAD_DEMO.vmrk

% Raw filesnames for psychopy are usually formatted: ParticipantID_Task
% Name_ followed by digits for YYYY-MM-DD_HHhMM.SS.MsMsMs (the h is 'h', Ms are millisecond digits)

% THIS SCRIPT IS NOT FOR REMOVING TRIALS WHERE THERE WERE ISSUES DURING
% DATA COLLECTION OR DUMMY TRIALS

% Note that because the data is being created through a python program,
% automatic counters will always start at '0' for the first item for the
% psychopy data. 1 will have to be added to counters when necessary
% to make this more intuitive in cleaned data.

%% TO DO
% Make code to extract relevant EEG data
% Determine what parts of EEG data are needed
% Create equal time scales (i.e., same starting point and convert to
% milliseconds) for psychopy and EEG data
% Check time differences between triggers, photodiodes, and relevant
% stimuli
% Compare trigger time from psychopy with trigger time from EEG data
% Determine when photodiode start times are in EEG data
% Compare psychopy and EEG photodiode start times
% Compare EEG photodiode and trigger times

%% Clear all and Select Directory

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES

clc
clear

fprintf('Setting directories\n')

% on laptop 
maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');

% on desktop 
% maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');

%% Load in Data
% on laptop
rawdatadir = [maindir 'RawData/'];
addpath(genpath(maindir))

              % NEED TO FIND A WAY TO GET IT TO ONLY SELECT SPECIFIC FILES
              % BY PARTICIPANT
              % Could look for unique RADXXX, but for psychopy data there
              % are many .csv and we need to select the one that doesn't
              % have 'loop' at the end.
% load in psychopy data
fprintf('Loading in raw psychopy data\n')

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called));

opts = detectImportOptions([rawdatadir 'RAD_DEMO_EEG Metronome Counting Task_2023-06-06_14h58.38.178.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
rawdata = readtable([rawdatadir 'RAD_DEMO_EEG Metronome Counting Task_2023-06-06_14h58.38.178.csv'],opts);
% creates a table where all variables are 'cell'


%% Extract EEG Data

%[data]=ft_read_data([rawdatadir 'RAD_DEMO.eeg']);
%[hdr]=ft_read_header([rawdatadir 'RAD_DEMO.vhdr']);
[markers]=ft_read_event([rawdatadir 'RAD_DEMO.vmrk']);

% Only interested in markers to check timing.
% markers structure has 6 fields: type (trigger type), value (trigger value
% given by comment or psychopy; see TriggerValueKey.xlsx for information),
% sample (sample number relative to start at 1), 
% duration (should always be 1), timestamp (not recorded?), offset (not
% recorded?)


samples = extractfield(markers,'sample');
samples=samples';
for r=2:346
    samples(r,2) = (samples(r,1)-samples(r-1,1))/500;

    % sample frequency is 500 Hz (500 samples per second)

end

% to check within markers array for one of the columns have to use
% test1 = struct2cell(markers);
% then use test1(2,:,:)
% test1(2,1,(strcmp(test1(2,:,:),'S  50'))) returns all columns with the ''
% value, in this case 0.

%% Calculate Psychopy Time Differences

% between photodiodes and triggers

% rename columns

% EXAMPLE
SARTPData = renamevars(SARTPData,["SARTkey_resp_practice.keys", ...
    "SARTkey_resp_practice.corr", "SARTkey_resp_practice.rt",  ...
    "SARTpracticeloop.thisN","number","correctkey"], ...
    ["SARTPResp","SARTPAcc","SARTPRT","SARTPTrial","SARTPStim","SARTPCResp"]);

SARTData = renamevars(SARTData,["SARTkey_resp_trials.keys","SARTkey_resp_trials.corr", ...
    "SARTkey_resp_trials.rt","SARTblock1loop.thisN","number","correctkey"], ...
    ["SARTResp","SARTAcc","SARTRT","SARTTrial","SARTStim","SARTCResp"]);

