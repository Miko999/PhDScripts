%% Executive Functioning and Mind Wandering in ADHD Study - Part 2 - EEG - Timing Check Script

% Chelsie H.
% Started: June 7, 2023
% Last updated: June 13, 2023

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

%% Relabel psychopy data columns
% rename columns

fprintf('Relabelling data columns of interest\n')

% if they did not make an error during practice
if isempty(find(strcmp("practiceprobetrigger.started",rawdata.Properties.VariableNames),1)) % if they made an error, this would not be empty
    rawdata = renamevars(rawdata,["StartTrigger.started","TaskStartPhotodiode_1.started","SoundTest_sound.started","SoundTestTrigger.started", ...
        "SoundTestPhotodiode_1.started","practice_getready.started","PracticeStartTrigger.started", ...
        "PracticeStartPhotodiode_1.started","tone_practicetrial_sound.started","tone_practicetrial_sound.stopped","tone_practice_trigger.started", ...
        "tone_practice_Photodiode.started","practiceprobetrigger_2.started","practiceprobe_photodiode_3.started","practiceonofftrigger.started", ...
        "practiceonoff_photodiode_1.started","practiceawaretrigger.started","practiceaware_photodiode_1.started","practiceintent_endprobe_photodiode_1.started", ...
        "practiceintenttrigger_2.stopped","continuetrigger.started","ContinuePhotoDiode.started","getready.started", ...
        "BlockStartSignal.started","BlockStartPhotodiode_1.started","tone_trial_sound.started","tone_trial_sound.stopped", ...
        "tone_trigger.started","tone_photodiode.started","probestarttrigger.started","probe_photodiode_1.started", ...
        "onofftrigger.started","onoff_photodiode_1.started","awaretrigger.started","aware_photodiode_1.started", ...
        "intenttrigger.started","intent_photodiode1.started","breaktrigger.started","break_photodiode_1.started", ...
        "EndTrigger.started","endphotodiode_1.started"], ...
         ["StartTrigger","StartPhotodiode","SoundTestToneStart","SoundTestTrigger","SoundTestPhotodiode",...
        "PracticeStartText","PracticeStartTrigger","PracticeStartPhotodiode","PTrialToneStart","PTrialToneStop","PTrialTrigger", ...
        "PTrialPhotodiode","PProbeTrigger","PProbePhotodiode","POnOffTrigger","POnOffPhotodiode","PAwareTrigger","PAwarePhotodiode", ...
        "PIntentTrigger","PIntentPhotodiode","ContinueTrigger","ContinuePhotodiode","BlockStartText","BlockStartTrigger", ...
        "BlockStartPhotodiode","TrialToneStart","TrialToneStop","TrialTrigger","TrialPhotodiode","ProbeTrigger","ProbePhotodiode", ...
        "OnOffTrigger","OnOffPhotodiode","AwareTrigger","AwarePhotodiode","IntentTrigger","IntentPhotodiode","BreakTrigger","BreakPhotodiode", ...
        "EndTrigger","EndPhotodiode"]);
    % relabel accordingly
% if they made an error during the practice
elseif isempty(find(strcmp("practiceprobetrigger_2.started",rawdata.Properties.VariableNames),1))
    rawdata = renamevars(rawdata,["StartTrigger.started","TaskStartPhotodiode_1.started","SoundTest_sound.started","SoundTestTrigger.started", ...
        "SoundTestPhotodiode_1.started","practice_getready.started","PracticeStartTrigger.started", ...
        "PracticeStartPhotodiode_1.started","tone_practicetrial_sound.started","tone_practicetrial_sound.stopped","tone_practice_trigger.started", ...
        "tone_practice_Photodiode.started","practiceprobetrigger.started","practiceprobe_photodiode_1.started","practiceonofftrigger.started", ...
        "practiceonoff_photodiode_1.started","practiceawaretrigger.started","practiceaware_photodiode_1.started","practiceintenttrigger.started", ...
        "practiceintent_photodiode_1.started","continuetrigger.started","ContinuePhotoDiode.started","getready.started", ...
        "BlockStartSignal.started","BlockStartPhotodiode_1.started","tone_trial_sound.started","tone_trial_sound.stopped", ...
        "tone_trigger.started","tone_photodiode.started","probestarttrigger.started","probe_photodiode_1.started", ...
        "onofftrigger.started","onoff_photodiode_1.started","awaretrigger.started","aware_photodiode_1.started", ...
        "intenttrigger.started","intent_photodiode1.started","breaktrigger.started","break_photodiode_1.started", ...
        "EndTrigger.started","endphotodiode_1.started"], ...
        ["StartTrigger","StartPhotodiode","SoundTestToneStart","SoundTestTrigger","SoundTestPhotodiode", ...
        "PracticeStartText","PracticeStartTrigger","PracticeStartPhotodiode","PTrialToneStart","PTrialToneStop","PTrialTrigger", ...
        "PTrialPhotodiode","PProbeTrigger","PProbePhotodiode","POnOffTrigger","POnOffPhotodiode","PAwareTrigger","PAwarePhotodiode", ...
        "PIntentTrigger","PIntentPhotodiode","ContinueTrigger","ContinuePhotodiode","BlockStartText","BlockStartTrigger", ...
        "BlockStartPhotodiode","TrialToneStart","TrialToneStop","TrialTrigger","TrialPhotodiode","ProbeTrigger","ProbePhotodiode", ...
        "OnOffTrigger","OnOffPhotodiode","AwareTrigger","AwarePhotodiode","IntentTrigger","IntentPhotodiode","BreakTrigger","BreakPhotodiode", ...
        "EndTrigger","EndPhotodiode"]);
    % relabel accordingly
end

        % NOTE: ONLY TAKING FIRST PHOTODIODE FOR WHEN THERE ARE MULTIPLE
        % FOR SPECIFIC ROUTINE.

% if they listened to the whole sound check
if ~isempty(find(strcmp("SoundTest_sound.stopped",rawdata.Properties.VariableNames),1)) % if they listened to the whole check, this would not be empty
    rawdata = renamevars(rawdata,["SoundTest_sound.stopped"],["SoundTestToneStop"]);
end

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

clear markerrowidx
% now we have the seconds since the start of hte task and the seconds
% between triggers.


%% Calculate mean and sd for time between beats according to EEG triggers

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

eegtrialtimes = [];

for trigvalidx = 1:nrows(no1alltrialtrigvals)
    eegtrialtimes = [eegtrialtimes; (cleanmarkers.timesinceprev(find(strcmp(no1alltrialtrigvals(trigvalidx),cleanmarkers.value))))];
end

clear trigvalidx

EEGmeanbeattime = mean(eegtrialtimes);
EEGbeattimesd = std(eegtrialtimes);
EEGmeanbeattimediff = EEGmeanbeattime - 1.575;

fprintf(strcat("From EEG markers data, average time between beats is ", string(EEGmeanbeattime), "seconds (SD = ",string(EEGbeattimesd),").\n"));
fprintf(strcat("Which differs from the desired timing of 1.575 seconds by ", string(EEGmeanbeattimediff), "seconds.\n"));

%clear EEG* eeg*

%% Combine All Trigger, Photodiode, and Stimuli timing information from psychopy data to roughly match EEG markers

% how do I combine all of the separate columns so that they all create unified columns for
% triggers, photodiodes, and stimuli?

% manually input rows but make loops for trial blocks? will have to
% manually add rows 'start' and probes because they occupy the same row in
% the psychopy data.

PsychoPyMarkers = table;
% Task Start
PsychoPyMarkers.Label(1) = {'TaskStart'};
PsychoPyMarkers.Value(1) = {'S160'};
PsychoPyMarkers.TriggerTime(1) = rawdata.StartTrigger(1);
PsychoPyMarkers.PhotodiodeTime(1) = rawdata.StartPhotodiode(1);
PsychoPyMarkers.StimulusTime(1) = rawdata.PTrialToneStart(1);
% Sound Check
PsychoPyMarkers.Label(2) = {'SoundCheckStart'};
PsychoPyMarkers.Value(2) = {'S165'};
PsychoPyMarkers.TriggerTime(2) = rawdata.SoundTestTrigger(1);
PsychoPyMarkers.PhotodiodeTime(2) = rawdata.SoundTestPhotodiode(1);
PsychoPyMarkers.StimulusTime(2) = rawdata.SoundTestToneStart(1);
% practice get ready S190
PsychoPyMarkers.Label(3) = {'PGetReady'};
PsychoPyMarkers.Value(3) = {'S190'};
PsychoPyMarkers.TriggerTime(3) = rawdata.PracticeStartTrigger(2);
PsychoPyMarkers.PhotodiodeTime(3) = rawdata.PracticeStartPhotodiode(2);
PsychoPyMarkers.StimulusTime(3) = rawdata.PTrialToneStart(1);

% practice trials and probes
PsychoPyMarkersRowIdx = 4; % counter for rows in psychopymarkers

% for the range of rows where pactice tone information is present
for PRowIdx = min(find(~isnan(rawdata.PTrialToneStart))) : max(find(~isnan(rawdata.PTrialToneStart)))

    % if there is tone information in the row (it isn't NaN)
    if ~isnan(rawdata.tone_number(PRowIdx))
        % record information for that row into the next row for pPsychoPyMarkers
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Trial'};
    
        if rawdata.tone_number(PRowIdx) < 10 % if the tone number is a single digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S10",string(rawdata.tone_number(PRowIdx))))};
            % the trigger/marker value is S with 10 before the
            % number, converted to characters
        else % if the tone number is a double digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S1",string(rawdata.tone_number(PRowIdx))))};
            % the trigger/marker value is S with 1 before the
            % number, converted to characters
        end
        
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PTrialTrigger(PRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PTrialPhotodiode(PRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PTrialToneStart(PRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
       
        % if there is also probe information in that row
        if ~isnan(rawdata.PProbeTrigger(PRowIdx))
            % add information for probe intro
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intro'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S180'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(PRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PProbePhotodiode(PRowIdx);
            % no stimulus so adding the blank from the next row
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(PRowIdx+1);
            
            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for onoff probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe OnOff'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.POnOffTrigger(PRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.POnOffPhotodiode(PRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(PRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for aware probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Aware'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PAwareTrigger(PRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PAwarePhotodiode(PRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(PRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for intent probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intent'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PIntentTrigger(PRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PIntentPhotodiode(PRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(PRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers

            % add information for continue screen
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Continue'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 40'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ContinueTrigger(PRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ContinuePhotodiode(PRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(PRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        end

    end

end

        % TEMP STORAGE WHILE TESTING THINGS
        TempPsychoPyMarkers = PsychoPyMarkers;

% Continue using PsychoPyMarkersRowIdx

% task get ready/block start S 90
    % find where this is not NaN

% task trials and probes and breaks
% probe intro S 80
% probe questions S 70
% separate onoff, aware, intent
% break S 30
    % similar to the loop for practice trials but have to add in something
    % for the break


if rawdata.tone_number(PRowIdx) < 10 % if the tone number is a single digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = convertStringsToChars(strcat("S  ",string(rawdata.tone_number(PRowIdx))));
            % the trigger/marker value is S with two spaces before the
            % number, converted to characters
        else % if the tone number is a double digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = convertStringsToChars(strcat("S ",string(rawdata.tone_number(PRowIdx))));
            % the trigger/marker value is S with one space before the
            % number, converted to characters
        end


% end S161
    % find where this is not empty.

% calculate time difference for triggers, photodiodes, and tone start
% use tone_number, when tone_number is 1 do not substract previous
% trial time

%% Calculate time between beats according to psychopy Triggers, Photodiodes, and Stimuli

%% Calculate time difference between triggers and photodiodes according to triggers


%% Calculate Time Differences Between Triggers, Photodiodes, and Stimuli according to psychopy

% between photodiodes, triggers, and stimuli

% could just do it one by one
% but if each row is a time difference, then I can't just subtract one
% variable by another.

%PsychoPyTimingDifferences = [];

%PsychoPyTimingDifferences.Comparison(1) = 'Start Trigger vs Photodiode';
%PsychoPyTimingDifferences.Difference(1) = 

% could I put all of the photodiode parts in one column and their
% corresponding triggers in another column?

% could just take the columns of interest in groups, remove all NAs and
% then combine into a larger array of two columns

% but also need a row number to re-order things to match the EEG clean
% markers data.

for rawdatarowidx = 1:nrows(rawdata)
    rawdata.rownumber(rawdatarowidx) =  double(rawdatarowidx);
end

% collect columns
StartTimes = [rawdata.rownumber,rawdata.StartTrigger, rawdata.StartPhotodiode];
SoundTestTimes = [rawdata.rownumber,rawdata.SoundTestTrigger, rawdata.SoundTestPhotodiode, rawdata.SoundTestToneStart];
PracticeStartTimes = [rawdata.rownumber,rawdata.PracticeStartTrigger,rawdata.PracticeStartPhotodiode,rawdata.PracticeStartText];
PracticeProbeIntroTimes = [rawdata.rownumber,rawdata.PProbeTrigger,rawdata.PProbePhotodiode];
PracticeProbeOnOffTimes = [rawdata.rownumber,rawdata.POnOffTrigger, rawdata.POnOffPhotodiode];
PracticeProbeAwareTimes = [rawdata.rownumber,rawdata.PAwareTrigger,rawdata.PAwarePhotodiode];
PracticeProbeIntentTimes = [rawdata.rownumber,rawdata.PIntentTrigger,rawdata.PIntentPhotodiode];
ContinueTimes = [rawdata.rownumber,rawdata.ContinueTrigger,rawdata.ContinuePhotodiode];
BlockStartTimes = [rawdata.rownumber,rawdata.BlockStartTrigger,rawdata.BlockStartPhotodiode,rawdata.BlockStartText];
ProbeIntroTimes = [rawdata.rownumber,rawdata.ProbeTrigger,rawdata.ProbePhotodiode];
ProbeOnOffTimes = [rawdata.rownumber,rawdata.OnOffTrigger, rawdata.OnOffPhotodiode];
ProbeAwareTimes = [rawdata.rownumber,rawdata.AwareTrigger,rawdata.AwarePhotodiode];
ProbeIntentTimes = [rawdata.rownumber,rawdata.IntentTrigger,rawdata.IntentPhotodiode];
PracticeTrialTimes = [rawdata.rownumber,rawdata.PTrialTrigger,rawdata.PTrialPhotodiode,rawdata.PTrialToneStart,rawdata.tone_number];
TrialTimes = [rawdata.rownumber,rawdata.TrialTrigger,rawdata.TrialPhotodiode,rawdata.TrialToneStart,rawdata.tone_number];
% error with the following triggers and photodiodes being imported as cells
% instead of doubles
BreakTimes = [rawdata.rownumber, str2double(rawdata.BreakTrigger),str2double(rawdata.BreakPhotodiode)];
EndTimes = [rawdata.rownumber,str2double(rawdata.EndTrigger),str2double(rawdata.EndPhotodiode)];

% remove NAs
StartTimes = StartTimes(find(~isnan(StartTimes(:,2))),:);
SoundTestTimes = SoundTestTimes(find(~isnan(SoundTestTimes(:,2))),:);
PracticeStartTimes = PracticeStartTimes(find(~isnan(PracticeStartTimes(:,2))),:);
PracticeProbeIntroTimes = PracticeProbeIntroTimes(find(~isnan(PracticeProbeIntroTimes(:,2))),:);
PracticeProbeOnOffTimes = PracticeProbeOnOffTimes(find(~isnan(PracticeProbeOnOffTimes(:,2))),:);
PracticeProbeAwareTimes = PracticeProbeAwareTimes(find(~isnan(PracticeProbeAwareTimes(:,2))),:);
PracticeProbeIntentTimes = PracticeProbeIntentTimes(find(~isnan(PracticeProbeIntentTimes(:,2))),:);
ContinueTimes = ContinueTimes(find(~isnan(ContinueTimes(:,2))),:);
BlockStartTimes = BlockStartTimes(find(~isnan(BlockStartTimes(:,2))),:);
ProbeIntroTimes = ProbeIntroTimes(find(~isnan(ProbeIntroTimes(:,2))),:);
ProbeOnOffTimes = ProbeOnOffTimes(find(~isnan(ProbeOnOffTimes(:,2))),:);
ProbeAwareTimes = ProbeAwareTimes(find(~isnan(ProbeAwareTimes(:,2))),:);
ProbeIntentTimes = ProbeIntentTimes(find(~isnan(ProbeIntentTimes(:,2))),:);
BreakTimes = BreakTimes(find(~isnan(BreakTimes(:,2))),:);
EndTimes = EndTimes(find(~isnan(EndTimes(:,2))),:);
PracticeTrialTimes = PracticeTrialTimes(find(~isnan(PracticeTrialTimes(:,2))),:);
TrialTimes = TrialTimes(find(~isnan(TrialTimes(:,2))),:);


clear rawdatarowidx

% rather than make many loops to try to add a new column to each without
% stimuli to be a stimulus dummy, I'm just going to make several arrays for
% each comparison

% trigger vs photodiode

TriggerVPhotodiode = table;
TriggerVPhotodiode.RowNumber = [StartTimes(:,1);SoundTestTimes(:,1);PracticeStartTimes(:,1);PracticeTrialTimes(:,1);PracticeProbeIntroTimes(:,1);
    PracticeProbeOnOffTimes(:,1);PracticeProbeAwareTimes(:,1);PracticeProbeIntentTimes(:,1);ContinueTimes(:,1);BlockStartTimes(:,1);TrialTimes(:,1);
    ProbeIntroTimes(:,1);%ProbeOnOffTimes(:,1);ProbeAwareTimes(:,1);
    ProbeIntentTimes(:,1);BreakTimes(:,1);EndTimes(:,1)];
TriggerVPhotodiode.TriggerTime = [StartTimes(:,2);SoundTestTimes(:,2);PracticeStartTimes(:,2);PracticeTrialTimes(:,2);PracticeProbeIntroTimes(:,2);
    PracticeProbeOnOffTimes(:,2);PracticeProbeAwareTimes(:,2);PracticeProbeIntentTimes(:,2);ContinueTimes(:,2);BlockStartTimes(:,2);TrialTimes(:,2);
    ProbeIntroTimes(:,2);%ProbeOnOffTimes(:,2);ProbeAwareTimes(:,2);
    ProbeIntentTimes(:,2);BreakTimes(:,2);EndTimes(:,2)];
TriggerVPhotodiode.PhotodiodeTime = [StartTimes(:,3);SoundTestTimes(:,3);PracticeStartTimes(:,3);PracticeTrialTimes(:,3);PracticeProbeIntroTimes(:,3);
    PracticeProbeOnOffTimes(:,3);PracticeProbeAwareTimes(:,3);PracticeProbeIntentTimes(:,3);ContinueTimes(:,3);BlockStartTimes(:,3);TrialTimes(:,3);
    ProbeIntroTimes(:,3);%ProbeOnOffTimes(:,3);ProbeAwareTimes(:,3);
    ProbeIntentTimes(:,3);BreakTimes(:,3);EndTimes(:,3)];
TriggerVPhotodiode.TimeDifference = TriggerVPhotodiode.TriggerTime - TriggerVPhotodiode.PhotodiodeTime;

        % THESE TIMES LOOK MESSY
        % TRIGGERS FOR THE ONOFF AND AWARE ACTUAL PROBES ARE RELATIVE TO
        % ROUTINE START; PHOTODIODE IS RELATIVE TO TASK START.
        % can't think of a good way to deal with this, removing those
        % doubles from the table for now

% trigger vs stimuli

TriggerVStimuli = table;
TriggerVStimuli.RowNumber = [SoundTestTimes(:,1);PracticeStartTimes(:,1);PracticeTrialTimes(:,1);BlockStartTimes(:,1);TrialTimes(:,1)];
TriggerVStimuli.TriggerTime = [SoundTestTimes(:,2);PracticeStartTimes(:,2);PracticeTrialTimes(:,2);BlockStartTimes(:,2);TrialTimes(:,2)];
TriggerVStimuli.StimuliTime = [SoundTestTimes(:,4);PracticeStartTimes(:,4);PracticeTrialTimes(:,4);BlockStartTimes(:,4);TrialTimes(:,4)];
TriggerVStimuli.TimeDifference = TriggerVStimuli.TriggerTime - TriggerVStimuli.StimuliTime;

% photodiode vs stimuli

PhotodiodeVStimuli = table;
PhotodiodeVStimuli.RowNumber = [SoundTestTimes(:,1);PracticeStartTimes(:,1);PracticeTrialTimes(:,1);BlockStartTimes(:,1);TrialTimes(:,1)];
PhotodiodeVStimuli.PhotodiodeTime = [SoundTestTimes(:,3);PracticeStartTimes(:,3);PracticeTrialTimes(:,3);BlockStartTimes(:,3);TrialTimes(:,3)];
PhotodiodeVStimuli.StimuliTime = [SoundTestTimes(:,4);PracticeStartTimes(:,4);PracticeTrialTimes(:,4);BlockStartTimes(:,4);TrialTimes(:,4)];
PhotodiodeVStimuli.TimeDifference = PhotodiodeVStimuli.PhotodiodeTime - PhotodiodeVStimuli.StimuliTime;

clear *Times

% PP for psychopy

PPTriggerVPhotoMean = mean(TriggerVPhotodiode.TimeDifference);
PPTriggerVPhotoSD = std(TriggerVPhotodiode.TimeDifference);

PPTriggerVStimMean = mean(TriggerVStimuli.TimeDifference);
PPTriggerVStimSD = std(TriggerVStimuli.TimeDifference);

PPPhotoVStimMean = mean(PhotodiodeVStimuli.TimeDifference);
PPPhotoVStimSD = std(PhotodiodeVStimuli.TimeDifference);

fprintf(strcat("From psychopy data, average time between corresponding triggers and photodiodes is ", string(PPTriggerVPhotoMean), "seconds, (SD = ",string(PPTriggerVPhotoSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding triggers and stimuli is ", string(PPTriggerVStimMean), "seconds, (SD = ",string(PPTriggerVStimSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding photodiodes and stimuli is ", string(PPPhotoVStimMean), "seconds, (SD = ",string(PPPhotoVStimSD),").\n"));

%% Calculate psychopy tone length

% if they have SoundTestToneEnd, SoundTestToneEnd - SoundTestToneStart
% should be 120 seconds
% PTrialToneStart, PTrialToneStop
% TrialToneStart, TrialToneStop
% not all trial tones will have tone stop recorded for some reason

%% Compare psychopy times to eeg times

% need to subtract one of the start times from all other trial times.
% problem is the psychopy data won't be in order.

        % NOTE THAT PSYCHOPY HAS NO TRIGGERS FOR WHEN THE PARTICIPANT
        % PRESSES 'UP'
