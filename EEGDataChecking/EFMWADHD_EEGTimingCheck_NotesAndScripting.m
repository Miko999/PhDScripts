%% Executive Functioning and Mind Wandering in ADHD Study - Part 2 - EEG - Timing Check Script

% Chelsie H.
% Started: June 7, 2023
% Last updated: June 7, 2023

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

%% Extract EEG Data
[data]=ft_read_data('D:\EFMWADHD_Demo\RED0000_1.eeg');
[hdr]=ft_read_header('D:\EFMWADHD_Demo\RED0000_1.vhdr');
[markers]=ft_read_event('D:\EFMWADHD_Demo\RED0000_1.vmrk');
samples = extractfield(markers,'sample');
samples=samples';
for r=2:346
    samples(r,2) = (samples(r,1)-samples(r-1,1))/500;

end

% to check within markers array for one of the columns have to use
% test1 = struct2cell(markers);
% then use test1(2,:,:)
% test1(2,1,(strcmp(test1(2,:,:),'S  50'))) returns all columns with the ''
% value, in this case 0.
