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
% milliseconds or seconds) for psychopy and EEG data
% Check time differences between triggers, photodiodes, and relevant
% stimuli
% Compare trigger time from psychopy with trigger time from EEG data
% Determine when photodiode start times are in EEG data
% Compare psychopy and EEG photodiode start times
% Compare EEG photodiode and trigger times
% psychopy data also need to look at start and stop times for tones

%% SO FAR
% calculated timing between triggers in EEG data

%% Clear all and Select Directories

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES

clc
clear

fprintf('Setting directories\n')

% on laptop 
% maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');

% on desktop 
maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');

rawdatadir = [maindir 'RawData/'];
addpath(genpath(maindir))

              % NEED TO FIND A WAY TO GET IT TO ONLY SELECT SPECIFIC FILES
              % BY PARTICIPANT
              % Could look for unique RADXXX, but for psychopy data there
              % are many .csv and we need to select the one that doesn't
              % have 'loop' at the end.

%% Load in Psychopy Data

fprintf('Loading in raw psychopy data\n')

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called));

opts = detectImportOptions([rawdatadir 'RAD_DEMO_EEG Metronome Counting Task_2023-06-06_14h58.38.178.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
rawdata = readtable([rawdatadir 'RAD_DEMO_EEG Metronome Counting Task_2023-06-06_14h58.38.178.csv'],opts);
% creates a table where all variables are 'cell'

clear opts

%% For RADAR_DEMO data, need to relabel some columns
rawdata = renamevars(rawdata,["TaskStartPhotoDiode.started","TaskStartPhotoDiode.stopped","tone_sound.started","SoundTestSignal.started", ...
    "SoundTestSignal.stopped","tone_resp_2.keys","tone_resp_2.rt","tone_signal.started","tone_signal.stopped"], ...
    ["TaskStartPhotoDiode_6.started","TaskStartPhotoDiode_6.stopped","SoundTest_sound.started","SoundTestTrigger.started","SoundTestTrigger.stopped", ...
    "AfterSoundTest_resp.keys","AfterSoundTest_resp.rt","tone_trigger.started","tone_trigger.stopped"]);

%% Extract EEG Data

fprintf('Loading in raw EEG marker data\n')

%[data]=ft_read_data([rawdatadir 'RAD_DEMO.eeg']);
%[hdr]=ft_read_header([rawdatadir 'RAD_DEMO.vhdr']);
[markers]=ft_read_event([rawdatadir 'RAD_DEMO.vmrk']);

%% Trying different methods

        % Convert sample values to seconds without including trigger values

% Only interested in markers to check timing.
% markers structure has 6 fields: type (trigger type), value (trigger value
% given by comment or psychopy; see TriggerValueKey.xlsx for information),
% sample (sample number relative to start at 1), 
% duration (should always be 1), timestamp (not recorded), offset (not
% recorded)

% create a double with just the sample values
%samples = extractfield(markers,'sample');
% flip from N x 1 to 1 x N
%samples=samples';

% row 1 should always be just '1' for samples
%for sampleidx =2:346
    % for all other rows
    % add a second column with the value of the first column divided by
    % sampling rate (500 Hz; 500 samples per second)
    % this second column is the sample time point in seconds relative to
    % the start of recording
%    samples(sampleidx,2) = (samples(sampleidx,1)-samples(sampleidx-1,1))/500;
%end

        % Extract information for specific markers.

% to check within markers array for one of the columns
% test1 = struct2cell(markers);
% then use test1(2,:,:)
% test1(2,1,(strcmp(test1(2,:,:),'S  50'))) returns all columns with the ''
% value, in this case 0.


% convert the markers structure into a cell
% markerscell = struct2cell(markers);

% for this cell, the first dimension is used to go through each part of the
% data (the columns in the markers structure)
% the second dimension is only equal to 1.
% the third dimension goes through each sample point.

% markerscell(2,:,:) returns all of the trigger values in single quotes,
% can also just use (2,1,:) in this data. 2 because value is the second value in each
% part of the cell (type is the first value)
% e.g., {'S   5'}

% to check for markers
% test = markerscell(2,1,(strcmp(markerscell(2,:,:),'S  1')));
% test is a cell where the third dimension is the number of 'S  1'
% test = markerscell(:,:,(strcmp(markerscell(2,:,:),'S  1')));
% by asking for all of the first two dimensions of markerscell, now test
% has all of the markers' information for only those with withe value 'S  1'

% However, this does not allow us to find out what rows of samples are the
% ones of interest in order to compare timing across multiple trigger
% values

%% Determine rows with trigger timing and values

fprintf('Extracting EEG trial trigger timing from markers\n')

% What if we change it to a table?
markerstable = struct2table(markers);

% find(strcmp('S  1',markerstable.value))
% gives us all rows where marker values are equal to 'S  1'

% really, we want to get the timing for each trigger type, as well as the
% difference in timing between a trigger and a previous trigger (except
% with the very first trigger).

        % we will need to use the task start trigger to put all of the times into
        % the same scale as the psychopy data

% to check timing we don't need any of the 'markers' where type is
% 'Comment' or 'New Segment'
% the new segment rows are also where the marker value is lost sample
% find these rows
commentrow  = strcmp('Comment',markerstable.type);
newsegrow = strcmp('New Segment',markerstable.type);

% combine logical
excessEEGrows = commentrow | newsegrow;

% remove those rows
cleanmarkers = markerstable(~excessEEGrows,1:3);

clear commentrow newsegrow excessEEGrows

% for a cleanmarkers structure, cleanmarkers = markers(~excessEEGrows)

% remove extra fields for cleanmarkers structure
% cleanmarkers = rmfield(cleanmarkers,"duration");
% cleanmarkers = rmfield(cleanmarkers,"timestamp");
% cleanmarkers = rmfield(cleanmarkers,"offset");

% create a new column in the table for timing

cleanmarkers.time = cleanmarkers.sample/500;

% create new column for time since task start

for markerrowidx = 2:nrows(cleanmarkers)
    % for all rows except the first
    cleanmarkers.timesincestart(markerrowidx) = cleanmarkers.time(markerrowidx) - cleanmarkers.time(find(strcmp('S160',cleanmarkers.value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    cleanmarkers.timesinceprev(markerrowidx) = cleanmarkers.time(markerrowidx) - cleanmarkers.time(markerrowidx-1);
    % and time since the previous trigger is 
end

% now we have the seconds since the start of hte task and the seconds
% between triggers.


%% Calculate mean and sd for time between beats according to triggers

% need to select only those triggers with values from 'S  1' to 'S 25' and
% 'S101' through 'S125'
% can strcmp('string',cleanmarkers.value) to find the rows where value is
% equal to each, or where value is not equal to all other values

alltrigvals = unique(cleanmarkers.value);
% storing all trigger values for later.
no1trialtrigvals = alltrigvals((find(strcmp('S  2',alltrigvals))):(find(strcmp('S 25',alltrigvals)))); 
no1practicetrialtrigvals = alltrigvals((find(strcmp('S102',alltrigvals))):(find(strcmp('S125',alltrigvals))));
% not hard coding in row numbers for the values of interest. unique() puts
% them in order though.

        % NOTE THAT TRIALS WITH MARKER VALUES 'S  1' AND 'S101' ARE NOT
        % INCLUDED HERE BECAUSE TIMING ON THOSE TRIALS DEPENDS ON HOW LONG
        % PARTICIPANTS TOOK ON THE 'CONTINUE' SCREEN. THEY ARE TIME SINCE THE
        % CONTINUE SCREEN TRIGGER AND ARE NOT RELATIVE TO PSYCHOPY ROUTINE ONSET.

no1alltrialtrigvals = [no1trialtrigvals; no1practicetrialtrigvals];

trialtimes = [];

for trigvalidx = 1:nrows(no1alltrialtrigvals)
    trialtimes = [trialtimes; (cleanmarkers.timesinceprev(find(strcmp(no1alltrialtrigvals(trigvalidx),cleanmarkers.value))))];
end

clear trigvalidx

EEGmeanbeattime = mean(trialtimes);
EEGbeattimesd = std(trialtimes);
EEGmeanbeattimediff = EEGmeanbeattime - 1.575;

fprintf(strcat("From EEG markers data, average time between beats is ", string(EEGmeanbeattime), "seconds.\n"));
fprintf(strcat("Which differs from the desired timing of 1.575 seconds by ", string(EEGmeanbeattimediff), "seconds.\n"));
fprintf(strcat("From EEG markers data, standard deviation for time between beats is ", string(EEGbeattimesd), "seconds.\n"));

%% Calculate Psychopy Time Differences

% between photodiodes and triggers

% rename columns

        % DEPENDS ON IF THE DATA CONTAINS SoundTest_sound.stopped
        % COLUMN NAMES FOR PSYCHOPY DEPEND ON IF PARTICIPANT MAKES AN
        % ERROR DURING MCT PRACTICE

% if they made an error during practice

rawdata = renamevars(rawdata,["StartTrigger.started","TaskStartPhotodiode_1.started","SoundTest_sound.started","SoundTestTrigger.started", ...
    "SoundTestPhotodiode_1.started","SoundTest_sound.stopped","practice_getready.started","PracticeStartTrigger.started", ...
    "PracticeStartPhotodiode_1.started","tone_practicetrial_sound.started","tone_practicetrial_sound.stopped","tone_practice_trigger.started", ...
    "tone_practice_Photodiode.started","practiceprobetrigger.started","practiceprobe_photodiode_1.started","practiceonofftrigger.started", ...
    "practiceonoff_photodiode_1.started","practiceawaretrigger.started","practiceaware_photodiode_1.started","practiceintenttrigger.started", ...
    "practiceintent_photodiode_1.started","continuetrigger.started","ContinuePhotoDiode.started","getready.started", ...
    "BlockStartSignal.started","BlockStartPhotodiode_1.started","tone_trial_sound.started","tone_trial_sound.stopped", ...
    "tone_trigger.started","tone_photodiode.started","probestarttrigger.started","probe_photodiode_1.started", ...
    "onofftrigger.started","onoff_photodiode_1.started","awaretrigger.started","aware_photodiode_1.started", ...
    "intenttrigger.started","intent_photodiode1.started","breaktrigger.started","break_photodiode_1.started", ...
    "EndTrigger.started","endphotodiode_1.started"], ...
    ["StartTrigger","StartPhotodiode","SoundTestToneStart","SoundTestTrigger","SoundTestPhotodiode","SoundTextToneStop", ...
    "PracticeStartText","PracticeStartTrigger","PracticeStartPhotodiode","PTrialToneStart","PTrialToneStop","PTrialTrigger", ...
    "PTrialPhotodiode","PProbeTrigger","PProbePhotodiode","POnOffTrigger","POnOffPhotodiode","PAwareTrigger","PAwarePhotodiode", ...
    "PIntentTrigger","PIntentPhotodiode","ContinueTrigger","ContinuePhotodiode","BlockStartText","BlockStartTrigger", ...
    "BlockStartPhotodiode","TrialToneStart","TrialToneStop","TrialTrigger","TrialPhotodiode","ProbeTrigger","ProbePhotodiode", ...
    "OnOffTrigger","OnOffPhotodiode","AwareTrigger","AwarePhotodiode","IntentTrigger","IntentPhotodiode","BreakTrigger","BreakPhotodiode", ...
    "EndTrigger","EndPhotodiode"]);

% if they did not make an error during practice

rawdata = renamevars(rawdata,["StartTrigger.started","TaskStartPhotodiode_1.started","SoundTest_sound.started","SoundTestTrigger.started", ...
    "SoundTestPhotodiode_1.started","SoundTest_sound.stopped","practice_getready.started","PracticeStartTrigger.started", ...
    "PracticeStartPhotodiode_1.started","tone_practicetrial_sound.started","tone_practicetrial_sound.stopped","tone_practice_trigger.started", ...
    "tone_practice_Photodiode.started","practiceprobetrigger_2.started","practiceprobe_photodiode_3.started","practiceonofftrigger.started", ...
    "practiceonoff_photodiode_1.started","practiceawaretrigger.started","practiceaware_photodiode_1.started","practiceintent_endprobe_photodiode_1.started", ...
    "practiceintenttrigger_2.stopped","continuetrigger.started","ContinuePhotoDiode.started","getready.started", ...
    "BlockStartSignal.started","BlockStartPhotodiode_1.started","tone_trial_sound.started","tone_trial_sound.stopped", ...
    "tone_trigger.started","tone_photodiode.started","probestarttrigger.started","probe_photodiode_1.started", ...
    "onofftrigger.started","onoff_photodiode_1.started","awaretrigger.started","aware_photodiode_1.started", ...
    "intenttrigger.started","intent_photodiode1.started","breaktrigger.started","break_photodiode_1.started", ...
    "EndTrigger.started","endphotodiode_1.started"], ...
     ["StartTrigger","StartPhotodiode","SoundTestToneStart","SoundTestTrigger","SoundTestPhotodiode","SoundTextToneStop", ...
    "PracticeStartText","PracticeStartTrigger","PracticeStartPhotodiode","PTrialToneStart","PTrialToneStop","PTrialTrigger", ...
    "PTrialPhotodiode","PProbeTrigger","PProbePhotodiode","POnOffTrigger","POnOffPhotodiode","PAwareTrigger","PAwarePhotodiode", ...
    "PIntentTrigger","PIntentPhotodiode","ContinueTrigger","ContinuePhotodiode","BlockStartText","BlockStartTrigger", ...
    "BlockStartPhotodiode","TrialToneStart","TrialToneStop","TrialTrigger","TrialPhotodiode","ProbeTrigger","ProbePhotodiode", ...
    "OnOffTrigger","OnOffPhotodiode","AwareTrigger","AwarePhotodiode","IntentTrigger","IntentPhotodiode","BreakTrigger","BreakPhotodiode", ...
    "EndTrigger","EndPhotodiode"]);