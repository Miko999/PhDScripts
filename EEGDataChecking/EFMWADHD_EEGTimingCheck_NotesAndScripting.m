%% Executive Functioning and Mind Wandering in ADHD Study - Part 2 - EEG - Timing Check Script

% Chelsie H.
% Started: June 7, 2023
% Last updated: June 16, 2023

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

%% Clear all and Select Directories

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES

clc
clear

LaptopOrDesktop = input('Which device are you using? (1 for Desktop, 2 for Laptop):');

fprintf('Setting directories\n')

if LaptopOrDesktop == 1
    % on desktop 
    maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');

else
    % on laptop 
    maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/EEGDataChecking/');
end

rawdatadir = [maindir 'RawData/'];
addpath(genpath(maindir))

% create storage table

AllMarkers = table;
TimingDifferences = table;

%% Load in Psychopy Data

fprintf('Loading in raw psychopy data\n')

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called));

              % NEED TO FIND A WAY TO GET IT TO ONLY SELECT SPECIFIC FILES
              % BY PARTICIPANT
              % Could look for unique RADXXX, but for psychopy data there
              % are many .csv and we need to select the one that doesn't
              % have 'loop' at the end.

              % dir(fullfile(rawdatadir,'RAD*EEG Metronome Counting Task*.csv')) 
              % gives all of the filesr related to this
              % but need to omit those with 'loop'

              % test = dir(fullfile(rawdatadir,'RAD*EEG Metronome Counting Task*.csv'));
              % test = struct2table(test);
              % keeprows = find(~contains(test.name,'loop'));
              % test = test(keeprows,:);

              % would have to do something like this to just get the .csvs
              % for this script and loop through each participant

filenames = dir(fullfile(rawdatadir,'RAD*EEG Metronome Counting Task*.csv'));
filenamestable = struct2table(filenames);
keeprows = find(~contains(filenamestable.name,'loop'));
filenamestable = filenamestable(keeprows,:);
filenamescell = table2cell(filenamestable);
filenamesmatrix = cell2mat(filenamescell(3,1));
% extract only the file name of the third file for the demo data.

            % LATER TO GET THE FILE NAMES ONE AT A TIME, NEED TO CHANGE THE
            % COLUMN VALUE.
            % EACH FILENAME IS PART OF A SEPARATE COLUMN
            % THIS COULD BE A GOOD POINT FOR LOOPING

filenamestring = mat2str(filenamesmatrix);
filenamestring = strrep(filenamestring,'''','');


opts = detectImportOptions([rawdatadir filenamestring]);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
rawdata = readtable([rawdatadir filenamestring],opts);
% creates a table where all variables are 'cell'

clear opts filenames filenamestable filenamesmatrix filenamestring keeprows
% would keep filenamescell for looping

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

fprintf('Loading in raw EEG data\n')

[data]=ft_read_data([rawdatadir 'RAD_DEMO.eeg']);
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
EEGMarkers = markerstable(~excessEEGrows,1:3);

clear commentrow newsegrow excessEEGrows remove* demoremove

% for a cleanmarkers structure, cleanmarkers = markers(~excessEEGrows)

% remove extra fields for cleanmarkers structure
% cleanmarkers = rmfield(cleanmarkers,"duration");
% cleanmarkers = rmfield(cleanmarkers,"timestamp");
% cleanmarkers = rmfield(cleanmarkers,"offset");

% create a new column in the table for timing

EEGMarkers.time = EEGMarkers.sample/500;

% create new column for time since task start

for markerrowidx = 2:size(EEGMarkers,1)
    % for all rows except the first
    EEGMarkers.triggertimesincestart(markerrowidx) = EEGMarkers.time(markerrowidx) - EEGMarkers.time(find(strcmp('S160',EEGMarkers.value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    EEGMarkers.triggertimesinceprev(markerrowidx) = EEGMarkers.time(markerrowidx) - EEGMarkers.time(markerrowidx-1);
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

fprintf('Calculating time between beats for EEG data.\n')

alltrigvals = unique(EEGMarkers.value);
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

for trigvalidx = 1:size(no1alltrialtrigvals,1)
    eegtrialtimes = [eegtrialtimes; (EEGMarkers.triggertimesinceprev(find(strcmp(no1alltrialtrigvals(trigvalidx),EEGMarkers.value))))];
end

clear trigvalidx

EEGmeanbeattime = mean(eegtrialtimes);
EEGbeattimesd = std(eegtrialtimes);
EEGmeanbeattimediff = EEGmeanbeattime - 1.575;

TimingDifferences.EEGMarkerMeanTimeBetweenBeats = EEGmeanbeattime;
TimingDifferences.EEGMarkerSDTimeBetweenBeats = EEGbeattimesd;
TimingDifferences.EEGMarkerTrialLengthDiffFromIdea = abs(EEGmeanbeattimediff);

fprintf(strcat("From EEG markers data, average time between beat triggers is ", string(EEGmeanbeattime), "seconds (SD = ",string(EEGbeattimesd),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(EEGmeanbeattimediff), "seconds.\n"));

clear EEGbeat* eegtrialtimes EEGmean*

%% Combine All Trigger, Photodiode, and Stimuli timing information from psychopy data to roughly match EEG markers

% how do I combine all of the separate columns so that they all create unified columns for
% triggers, photodiodes, and stimuli?

% manually input rows but make loops for trial blocks? will have to
% manually add rows 'start' and probes because they occupy the same row in
% the psychopy data.

warning('off','all');

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

% probe information is included in the same row as the trial which
% triggered the probe. Trial information has to be recorded before probe
% information for that row.

% for the range of rows where pactice tone information is present

for MCTPRowIdx = min(find(~isnan(rawdata.PTrialToneStart))) : max(find(~isnan(rawdata.PTrialToneStart)))

    % if there is tone information in the row (it isn't NaN)
    if ~isnan(rawdata.tone_number(MCTPRowIdx))
        % record information for that row into the next row for pPsychoPyMarkers
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Trial'};
    
        if rawdata.tone_number(MCTPRowIdx) < 10 % if the tone number is a single digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S10",string(rawdata.tone_number(MCTPRowIdx))))};
            % the trigger/marker value is S with 10 before the
            % number, converted to characters
        else % if the tone number is a double digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S1",string(rawdata.tone_number(MCTPRowIdx))))};
            % the trigger/marker value is S with 1 before the
            % number, converted to characters
        end
        
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PTrialTrigger(MCTPRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PTrialPhotodiode(MCTPRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PTrialToneStart(MCTPRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
       
        % if there is also probe information in that row
        if ~isnan(rawdata.PProbeTrigger(MCTPRowIdx))
            % add information for probe intro
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intro'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S180'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PProbePhotodiode(MCTPRowIdx);
            % no stimulus so adding the blank from the next row
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            
            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for onoff probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe OnOff'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.POnOffTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.POnOffPhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for aware probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Aware'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PAwareTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PAwarePhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for intent probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intent'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PIntentTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PIntentPhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers

            % add information for continue screen
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Continue'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 40'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ContinueTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ContinuePhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        end

    end

end

% probes are in the same rows as trials
% block start and break are in the same rows as trials
% breaks come before block start
% breaks and block start are in the same row as the first trial, so they
% must be entered before the trial information for that row.

% so in each row, prioritize break, then block start, then trial info, then
% probe info.



for MCTRowIdx = min(find(~isnan(rawdata.TrialToneStart))):max(find(~isnan(rawdata.TrialToneStart)))
    
    % break
    if ~cellfun('isempty', rawdata.BreakTrigger(MCTRowIdx))
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Break'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 30'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = str2double(rawdata.BreakTrigger(MCTRowIdx));
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = str2double(rawdata.BreakPhotodiode(MCTRowIdx));
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx); % anything with an NaN

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1;
    end
    
    % block start
    if ~isnan(rawdata.BlockStartText(MCTRowIdx))
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Block Start'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 90'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.BlockStartTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.BlockStartPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.BlockStartText(MCTRowIdx); % anything with an NaN

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1;
    end

    % trial
    if ~isnan(rawdata.TrialToneStart(MCTRowIdx))
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Trial'};

        if rawdata.tone_number(MCTRowIdx) < 10 % if the tone number is a single digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S  ",string(rawdata.tone_number(MCTRowIdx))))};
            % the trigger/marker value is S with two spaces before the
            % number, converted to characters
        else % if the tone number is a double digit
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {convertStringsToChars(strcat("S ",string(rawdata.tone_number(MCTRowIdx))))};
            % the trigger/marker value is S with one space before the
            % number, converted to characters
        end

        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.TrialTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.TrialPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.TrialToneStart(MCTRowIdx); % anything with an NaN

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1;
    end

    % probes
    if ~isnan(rawdata.ProbeTrigger(MCTRowIdx))
        % add information for probe intro
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Intro'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 80'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ProbePhotodiode(MCTRowIdx);
        
        % filling in with an NaN
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        
        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for onoff probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe OnOff'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.OnOffTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.OnOffPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for aware probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Aware'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.AwareTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.AwarePhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for intent probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Intent'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.IntentTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.IntentPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers

        % add information for continue screen
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Continue'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 40'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ContinueTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ContinuePhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
    end
end

% DID NOT RECORD TIMING FOR END PHOTODIODE OR TRIGGERS IN PSYCHOPY

PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'TaskEnd'};
PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S161'};
PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);


clear PsychoPyMarkersRowIdx MCTPRowIdx MCTRowIdx
        


warning('on','all');

%% Calculate time between beats according to psychopy Triggers, Photodiodes, and Stimuli

% calculate time difference for triggers, photodiodes, and tone start
% use tone_number, when tone_number is 1 do not substract previous
% trial time

% standardize as time stince the start of the task and find time difference
% between all triggers

for PsychoPyMarkerRowIdx = 2:size(PsychoPyMarkers,1)
    % for all rows except the first
    PsychoPyMarkers.TriggerTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.TriggerTime(find(strcmp('S160',PsychoPyMarkers.Value)));
    PsychoPyMarkers.PhotodiodeTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.PhotodiodeTime(find(strcmp('S160',PsychoPyMarkers.Value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    % for stimuli there is no task start stimuli to compare to so can take
    % the average of timing for starting trigger and photodiode
    PsychoPyMarkers.StimuliTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.StimulusTime(PsychoPyMarkerRowIdx) - ((PsychoPyMarkers.TriggerTime(find(strcmp('S160',PsychoPyMarkers.Value))) + PsychoPyMarkers.PhotodiodeTime(find(strcmp('S160',PsychoPyMarkers.Value))))/2);
    

    PsychoPyMarkers.TriggerTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx - 1);
    PsychoPyMarkers.PhotodiodeTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx - 1);
    % time since previous trigger is tricky for stimulus time as there are
    % many routines without stimuli.
    if ~isnan(PsychoPyMarkers.StimulusTime(PsychoPyMarkerRowIdx))
        % if the current row has a stimulus
        if ~isnan(PsychoPyMarkers.StimulusTime(PsychoPyMarkerRowIdx - 1))
            % and the previous row has a stimulus
            % do the subtraction
            PsychoPyMarkers.StimuliTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.StimulusTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.StimulusTime(PsychoPyMarkerRowIdx - 1);
        else
            % if the previous row has no data
            PsychoPyMarkers.StimuliTimeSincePrev(PsychoPyMarkerRowIdx) = NaN;
        end
    else
        PsychoPyMarkers.StimuliTimeSincePrev(PsychoPyMarkerRowIdx) = NaN;
    end
end


clear PsychoPyMarkerRowIdx

% using the no1alltrialtrigvalues from before can just take data for trials
% could also use label Practice Trial or Trial, but would need to remove
% all of the S101 and S  1 valued markers.

PsychoPyTrialTimes = [];

for trigvalidx = 1:size(no1alltrialtrigvals,1)
    PsychoPyTrialTimes = [PsychoPyTrialTimes; (PsychoPyMarkers((find(strcmp(no1alltrialtrigvals(trigvalidx),PsychoPyMarkers.Value))),9:11))];
end

clear trigvalidx

PsychoPyMeanBeatTriggerTime = mean(PsychoPyTrialTimes.TriggerTimeSincePrev);
PsychoPySDBeatTriggerTime = std(PsychoPyTrialTimes.TriggerTimeSincePrev);
PsychoPyMeanBeatTriggerTimeDifference = PsychoPyMeanBeatTriggerTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatTriggers(1) = PsychoPyMeanBeatTriggerTime;
TimingDifferences.PsychoPySDTimeBetweenBeatTriggers(1) = PsychoPySDBeatTriggerTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatTriggerDifference = abs(PsychoPyMeanBeatTriggerTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat triggers is ", string(PsychoPyMeanBeatTriggerTime), "seconds (SD = ",string(PsychoPySDBeatTriggerTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatTriggerTimeDifference), "seconds.\n"));

PsychoPyMeanBeatPhotodiodeTime = mean(PsychoPyTrialTimes.PhotodiodeTimeSincePrev);
PsychoPySDBeatPhotodiodeTime = std(PsychoPyTrialTimes.PhotodiodeTimeSincePrev);
PsychoPyMeanBeatPhotodiodeTimeDifference = PsychoPyMeanBeatPhotodiodeTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatPhotodiodes(1) = PsychoPyMeanBeatPhotodiodeTime;
TimingDifferences.PsychoPySDTimeBetweenBeatPhotodiodes(1) = PsychoPySDBeatPhotodiodeTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatPhotodiodeDifference = abs(PsychoPyMeanBeatPhotodiodeTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat photodiodes is ", string(PsychoPyMeanBeatPhotodiodeTime), "seconds (SD = ",string(PsychoPySDBeatPhotodiodeTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatPhotodiodeTimeDifference), "seconds.\n"));

PsychoPyMeanBeatStimuliTime = mean(PsychoPyTrialTimes.StimuliTimeSincePrev);
PsychoPySDBeatStimuliTime = std(PsychoPyTrialTimes.StimuliTimeSincePrev);
PsychoPyMeanBeatStimuliTimeDifference = PsychoPyMeanBeatStimuliTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatStimuli = PsychoPyMeanBeatStimuliTime;
TimingDifferences.PsychoPySDTimeBetweenBeatStimuli = PsychoPySDBeatStimuliTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatStimuliDifference = abs(PsychoPyMeanBeatStimuliTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat sound is ", string(PsychoPyMeanBeatStimuliTime), "seconds (SD = ",string(PsychoPySDBeatStimuliTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatStimuliTimeDifference), "seconds.\n"));

clear nPsychoPyMean* PsychoPySD* PsychoPyTrialTimes

%% Find photodiode sample points

% can graph data to see how the photodiodes look
% figure;
% plot(eeg(66,167900:273100))

% find sample points for all photodiode triggers
% photodiode is programmed to start at the same time as the sound
% trigger is conditional on the sound playing

% so at sample values from 300 before trigger and 300 after trigger, find
% where the value for eeg(66) is greater than 500

for EEGMarkerRowsIdx = 1:size(EEGMarkers,1)
    % for each marker
    if isempty(find(strcmp('S150',EEGMarkers.value(EEGMarkerRowsIdx))))
        if isempty(find(strcmp('S 50',EEGMarkers.value(EEGMarkerRowsIdx))))
            TriggerTimeWindow = (EEGMarkers.sample(EEGMarkerRowsIdx)-300):(EEGMarkers.sample(EEGMarkerRowsIdx)+300);
            % trigger time window is the 300 samples before and after that trigger.
            for SampleRowIdx = 1:601
                if data(66,TriggerTimeWindow(SampleRowIdx)) > 499
                    flag = 1;
                    break;
                end
            end
            if flag == 1
                EEGMarkers.PhotodiodeSample(EEGMarkerRowsIdx) = TriggerTimeWindow(SampleRowIdx);
            end
        end
    end
end

clear EEGMarkerRowsIdx TriggerTimeWindow SampleRowIdx flag

EEGMarkers.PhotodiodeTime = EEGMarkers.PhotodiodeSample/500;


%% Calculate time difference for EEG photodiodes

for markerrowidx = 2:size(EEGMarkers,1)
    % for all rows except the first
    EEGMarkers.photodiodetimesincestart(markerrowidx) = EEGMarkers.PhotodiodeTime(markerrowidx) - EEGMarkers.PhotodiodeTime(find(strcmp('S160',EEGMarkers.value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    EEGMarkers.photodiodetimesinceprev(markerrowidx) = EEGMarkers.PhotodiodeTime(markerrowidx) - EEGMarkers.PhotodiodeTime(markerrowidx-1);
    % and time since the previous trigger is 
end

clear markerrowidx 

%% Calculate Trial length according to photodiodes

PhotodiodeTrialTimes = [];

for trigvalidx = 1:size(no1alltrialtrigvals,1)
    PhotodiodeTrialTimes = [PhotodiodeTrialTimes; (EEGMarkers((find(strcmp(no1alltrialtrigvals(trigvalidx),EEGMarkers.value))),:))];
end

clear trigvalidx

EEGMeanBeatPhotodiodeTime = mean(PhotodiodeTrialTimes.photodiodetimesinceprev);
EEGSDBeatPhotodiodeTime = std(PhotodiodeTrialTimes.photodiodetimesinceprev);
EEGMeanBeatPhotodiodeTimeDifference = EEGMeanBeatPhotodiodeTime - 1.575;

TimingDifferences.EEGMeanTimeBetweenBeatPhotodiodes = EEGMeanBeatPhotodiodeTime;
TimingDifferences.EEGSDTimeBetweenBeatPhotodiodes = EEGSDBeatPhotodiodeTime;
TimingDifferences.EEGMeanTimeBetweenBeatPhotodiodeDifference = abs(EEGMeanBeatPhotodiodeTimeDifference);

fprintf(strcat("From EEG data, average time between beat photodiodes is ", string(EEGMeanBeatPhotodiodeTime), " seconds (SD = ",string(EEGSDBeatPhotodiodeTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(EEGMeanBeatPhotodiodeTimeDifference), " seconds.\n"));

clear nEEGMean* EEGSD* PhotodiodeTrialTimes

%% Calculate time difference between triggers and photodiodes for EEG data


EEGMarkers.TriggerVPhotodiodeTime = EEGMarkers.PhotodiodeTime - EEGMarkers.time;

EEGMeanPhotoVTrigger = mean(EEGMarkers.TriggerVPhotodiodeTime,"omitnan");
EEGSDPhotoVTrigger = std(EEGMarkers.TriggerVPhotodiodeTime,"omitnan");

TimingDifferences.EEGMeanTimeBetweenPhotodiodeAndTrigger = EEGMeanPhotoVTrigger;
TimingDifferences.EEGSDTimeBetweenPhotodiodeAndTrigger = EEGSDPhotoVTrigger;

fprintf(strcat("From EEG data, average time between corresponding photodiodes and triggers is ", string(EEGMeanPhotoVTrigger), " seconds (SD = ",string(EEGSDPhotoVTrigger),").\n"));

clear EEGMean* EEGSD*


%% Calculate Time Differences Between Triggers, Photodiodes, and Stimuli according to psychopy

        % MADE THE FOLLOWING SCRIPT BEFORE I MADE THE SCRIPT TO CREATE THE
        % PSYCHOPYMARKERS TABLE. So could have used that in here instead
        % and made a new column for these differences that skips over NaNs

        % EASIEST TO TAKE PSYCHOPYMARKERS TABLE AND SUBTRACT ONE COLUMN
        % FROM THE OTHER
        % REMEMBER THAT PROBES FOR ONOFF AND AWARE DO NOT HAVE TIMING SET
        % PROPERLY SO THE TIME DIFFERENCE IS NOT ACCURATE

PsychoPyMarkers.TriggerVPhotodiodeTime = PsychoPyMarkers.PhotodiodeTime - PsychoPyMarkers.TriggerTime;
PsychoPyMarkers.TriggerVStimulusTime = PsychoPyMarkers.StimulusTime - PsychoPyMarkers.TriggerTime;
PsychoPyMarkers.PhotodiodeVStimulusTime = PsychoPyMarkers.PhotodiodeTime - PsychoPyMarkers.StimulusTime;

        % I didn't do this at first because I thought the NaNs would be an
        % issue

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

for rawdatarowidx = 1:size(rawdata,1)
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
PracticeTrialTimes = [rawdata.rownumber,rawdata.PTrialTrigger,rawdata.PTrialPhotodiode,rawdata.PTrialToneStart,rawdata.PTrialToneStop,rawdata.tone_number];
TrialTimes = [rawdata.rownumber,rawdata.TrialTrigger,rawdata.TrialPhotodiode,rawdata.TrialToneStart,rawdata.TrialToneStop,rawdata.tone_number];
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

% PP for psychopy

PPTriggerVPhotoMean = mean(TriggerVPhotodiode.TimeDifference);
PPTriggerVPhotoSD = std(TriggerVPhotodiode.TimeDifference);

PPTriggerVStimMean = mean(TriggerVStimuli.TimeDifference);
PPTriggerVStimSD = std(TriggerVStimuli.TimeDifference);

PPPhotoVStimMean = mean(PhotodiodeVStimuli.TimeDifference);
PPPhotoVStimSD = std(PhotodiodeVStimuli.TimeDifference);

TimingDifferences.PsychoPyMeanTimeBetweenTriggersAndPhotodiode = PPTriggerVPhotoMean;
TimingDifferences.PsychoPyMeanTimeBetweenTriggersAndStimuli = PPTriggerVStimMean;
TimingDifferences.PsychoPyMeanTimeBetweenPhotodiodeAndStimuli = PPPhotoVStimMean;


fprintf(strcat("From psychopy data, average time between corresponding triggers and photodiodes is ", string(PPTriggerVPhotoMean), "seconds, (SD = ",string(PPTriggerVPhotoSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding triggers and stimuli is ", string(PPTriggerVStimMean), "seconds, (SD = ",string(PPTriggerVStimSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding photodiodes and stimuli is ", string(PPPhotoVStimMean), "seconds, (SD = ",string(PPPhotoVStimSD),").\n"));

clear Probe*

%% Calculate psychopy tone length

% if they have SoundTestToneEnd, SoundTestToneEnd - SoundTestToneStart
% should be 120 seconds
% PTrialToneStart, PTrialToneStop
% TrialToneStart, TrialToneStop
% not all trial tones will have tone stop recorded for some reason

% start and end tones
StartStopTone = table;
StartStopTone.StartTime = [PracticeTrialTimes(:,4);TrialTimes(:,4)];
StartStopTone.StopTime = [PracticeTrialTimes(:,5);TrialTimes(:,5)];

% remove NAs from Start and Stop
StartStopTone = StartStopTone(find((~isnan(StartStopTone.StopTime))),:);
StartStopTone.Difference = StartStopTone.StopTime - StartStopTone.StartTime;

PPStartStopMean = mean(StartStopTone.Difference);
PPStartStopSD = std(StartStopTone.Difference);
PPStartStopDiff = PPStartStopMean - 0.075;

TimingDifferences.PsychoPyMeanToneLength = PPStartStopMean;
TimingDifferences.PsychoPySDToneLength = PPStartStopSD;
TimingDifferences.PsychoPyMeanToneLengthDiff = abs(PPStartStopDiff);

fprintf(strcat("From psychopy data, average length of a beat sound is ", string(PPStartStopMean), "seconds, (SD = ",string(PPStartStopSD),");\n","which differs from the desired time of 0.075 by ",string(PPStartStopDiff),".\n"));

clear *Times PP* PsychoPyMean* PsychoPySD* no1* eeg* *V*


%% For demo data only, need to remove last six rows of data from resting state

EEGMarkers = EEGMarkers((1:(find(strcmp('S161',EEGMarkers.value)))),:);

%% Combine PsychoPy Markers and EEG Markers

        % NOTE THAT PSYCHOPY HAS NO TRIGGERS FOR WHEN THE PARTICIPANT
        % PRESSES 'UP'

% PsychoPy and EEG markers may not be the same length if S150 or S050
% exist.

warning('off','all');


CombinedMarkers = table;

PsychoPyMarkersRowCounter = 1;

for MarkersRowIdx = 1:(size(EEGMarkers,1))

    CombinedMarkers.TriggerValue(MarkersRowIdx) = EEGMarkers.value(MarkersRowIdx);

    if ~strcmp(EEGMarkers.value(MarkersRowIdx),PsychoPyMarkers.Value(PsychoPyMarkersRowCounter))

        CombinedMarkers.Label(MarkersRowIdx) = {'Pressed Up'};
        
        CombinedMarkers.EEGTriggerTime(MarkersRowIdx) = EEGMarkers.time(MarkersRowIdx);
        CombinedMarkers.EEGPhotodiodeTime(MarkersRowIdx) = EEGMarkers.PhotodiodeTime(MarkersRowIdx);

        CombinedMarkers.PsyTriggerTime(MarkersRowIdx) = NaN;
        CombinedMarkers.PsyPhotodiodeTime(MarkersRowIdx) = NaN;
        CombinedMarkers.PsyStimulusTime(MarkersRowIdx) = NaN;

        PsychoPyMarkersRowCounter = PsychoPyMarkersRowCounter + 1;

    else
        CombinedMarkers.Label(MarkersRowIdx) = PsychoPyMarkers.Label(PsychoPyMarkersRowCounter);

        CombinedMarkers.EEGTriggerTime(MarkersRowIdx) = EEGMarkers.time(MarkersRowIdx);
        CombinedMarkers.EEGPhotodiodeTime(MarkersRowIdx) = EEGMarkers.PhotodiodeTime(MarkersRowIdx);

        CombinedMarkers.PsyTriggerTime(MarkersRowIdx) = PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowCounter);
        CombinedMarkers.PsyPhotodiodeTime(MarkersRowIdx) = PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowCounter);
        CombinedMarkers.PsyStimulusTime(MarkersRowIdx) = PsychoPyMarkers.StimulusTime(PsychoPyMarkersRowCounter);

        PsychoPyMarkersRowCounter = PsychoPyMarkersRowCounter + 1;

    end

end

warning('on','all');

% get psychopy trigger vs stim, photodiode vs stim, trigger vs photodiode
% get EEG trigger vs photodiode

%% Adjust to have the same starting times.

% calibrating on Stimulus Time
%TriggerAdjust = CombinedMarkers.EEGTriggerTime(2) - CombinedMarkers.PsyStimulusTime(2);
%PhotodiodeAdjust = CombinedMarkers.EEGPhotodiodeTime(2) - CombinedMarkers.PsyStimulusTime(2);

%CombinedMarkers.AdjustedEEGTriggerTime = CombinedMarkers.EEGTriggerTime - TriggerAdjust;
%CombinedMarkers.AdjustedEEGPhotodiodeTime = CombinedMarkers.EEGPhotodiodeTime - PhotodiodeAdjust;

    % THIS MAKES THE ADJUSTED EEG TIME COME BEFORE THE PSYCHOPY TIMES WHICH
    % DOESN'T MAKE SENSE.

%% Compare psychopy times to eeg times

% Photodiode is supposed to be at the same time as the sound
% trigger is conditional on sound

% trigger - photodiode
% if it equals negative, the photodiode was earlier
% if it equals postiive, the trigger was earlier.

% EEG trigger - photodiode = negative every time; while psychopy difference
% is positive on instructions and probes and 0 on trials.

% Except the probes for onoff and aware that are miscalibrated.

% can at least check whether timing is consistent between the two

CombinedMarkers.EEGVPsyTrigger = CombinedMarkers.EEGTriggerTime - CombinedMarkers.PsyTriggerTime;
CombinedMarkers.EEGVPsyPhoto = CombinedMarkers.EEGPhotodiodeTime - CombinedMarkers.PsyPhotodiodeTime;
CombinedMarkers.EEGTriggerVPhotodiode = CombinedMarkers.EEGTriggerTime - CombinedMarkers.EEGPhotodiodeTime;
CombinedMarkers.PsyTriggerVPhotodiode = CombinedMarkers.PsyTriggerTime - CombinedMarkers.PsyPhotodiodeTime;

%% Export

% just going to export the table

writetable(CombinedMarkers,"RAD_DEMO_CombinedMarkerTiming.xlsx")

% Remember that onoff and aware probe timing is off!

%% Clear everything else

clear LaptopOrDesktop