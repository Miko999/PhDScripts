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

%% Clear all and Select Directories

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES
                            % At the moment this just find the demo data.

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

              % NEED TO FIND A WAY TO GET IT TO ONLY SELECT SPECIFIC FILES
              % BY PARTICIPANT
              % but for psychopy data there are many csvs and only one is
              % relevant.

% create storage tables
TimingDifferences = table; % to put the means and sds for everything in one place
CombinedMarkers = table; % to combine the information of interest from EEG and psychopy marker information

%% Load in Psychopy Data

fprintf('Loading in raw psychopy data\n')

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called));

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
% creates a table where all variables are cell types

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
% Note older files can have 'signal' instead of trigger.
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

fprintf('Loading in raw EEG marker data\n')

[markers]=ft_read_event([rawdatadir 'RAD_DEMO.vmrk']);

%% Determine rows with trigger timing and values

fprintf('Extracting EEG trial trigger timing from markers\n')

markerstable = struct2table(markers);

% to check timing we don't need any of the 'markers' where type is
% 'Comment' or 'New Segment'
% the new segment rows are also where the marker value is lost sample

commentrow  = strcmp('Comment',markerstable.type);
newsegrow = strcmp('New Segment',markerstable.type);

% combine logical
excessEEGrows = commentrow | newsegrow;

% remove those rows
EEGMarkers = markerstable(~excessEEGrows,1:3);

clear commentrow newsegrow excessEEGrows

% create a new column in the table for timing
EEGMarkers.time = EEGMarkers.sample/500;

% create new column for time since task start and time since previous
% trigger
for markerrowidx = 2:size(EEGMarkers,1)
    % for all rows except the first
    EEGMarkers.triggertimesincestart(markerrowidx) = EEGMarkers.time(markerrowidx) - EEGMarkers.time(find(strcmp('S160',EEGMarkers.value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    EEGMarkers.triggertimesinceprev(markerrowidx) = EEGMarkers.time(markerrowidx) - EEGMarkers.time(markerrowidx-1);
    % and time since the previous trigger is 
end

clear markerrowidx markerstable

%% Calculate mean and sd for time between beats according to EEG triggers

% need to select only those triggers with values from 'S  1' to 'S 25' and
% 'S101' through 'S125'

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

fprintf('Organizing psychopy marker data.\n')

warning('off','all');

PsychoPyMarkers = table;
% Task Start
PsychoPyMarkers.Label(1) = {'TaskStart'};
PsychoPyMarkers.Value(1) = {'S160'};
PsychoPyMarkers.TriggerTime(1) = rawdata.StartTrigger(1);
PsychoPyMarkers.PhotodiodeTime(1) = rawdata.StartPhotodiode(1);
PsychoPyMarkers.StimulusStartTime(1) = rawdata.PTrialToneStart(1);
PsychoPyMarkers.StimulusStopTime(1) = rawdata.PTrialToneStart(1);
% Sound Check
PsychoPyMarkers.Label(2) = {'SoundCheckStart'};
PsychoPyMarkers.Value(2) = {'S165'};
PsychoPyMarkers.TriggerTime(2) = rawdata.SoundTestTrigger(1);
PsychoPyMarkers.PhotodiodeTime(2) = rawdata.SoundTestPhotodiode(1);
PsychoPyMarkers.StimulusStartTime(2) = rawdata.SoundTestToneStart(1);
    % Should make this conditional on if they listed to the whole tone, but
    % not necessary really.
PsychoPyMarkers.StimulusStopTime(2) = rawdata.PTrialToneStart(1);
% practice get ready S190
PsychoPyMarkers.Label(3) = {'PGetReady'};
PsychoPyMarkers.Value(3) = {'S190'};
PsychoPyMarkers.TriggerTime(3) = rawdata.PracticeStartTrigger(2);
PsychoPyMarkers.PhotodiodeTime(3) = rawdata.PracticeStartPhotodiode(2);
PsychoPyMarkers.StimulusStartTime(3) = rawdata.PTrialToneStart(1);
PsychoPyMarkers.StimulusStopTime(3) = rawdata.PTrialToneStop(1);

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
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PTrialToneStart(MCTPRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PTrialToneStop(MCTPRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
       
        % if there is also probe information in that row
        if ~isnan(rawdata.PProbeTrigger(MCTPRowIdx))
            % add information for probe intro
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intro'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S180'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PProbePhotodiode(MCTPRowIdx);
            % no stimulus so adding the blank from the next row
            PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
             PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            
            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for onoff probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe OnOff'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.POnOffTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.POnOffPhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for aware probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Aware'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PAwareTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PAwarePhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
            
            % add information for intent probe
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Intent'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S170'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PIntentTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PIntentPhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

            PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers

            % add information for continue screen
            PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Practice Probe Continue'};
            PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 40'};
            PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ContinueTrigger(MCTPRowIdx);
            PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ContinuePhotodiode(MCTPRowIdx);
            PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);
            PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.tone_number(MCTPRowIdx+1);

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
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx); % anything with an NaN
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1;
    end
    
    % block start
    if ~isnan(rawdata.BlockStartText(MCTRowIdx))
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Block Start'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 90'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.BlockStartTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.BlockStartPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx); % anything with an NaN
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

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
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.TrialToneStart(MCTRowIdx); % anything with an NaN
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.TrialToneStop(MCTRowIdx);

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
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        
        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for onoff probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe OnOff'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.OnOffTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.OnOffPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for aware probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Aware'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.AwareTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.AwarePhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
        
        % add information for intent probe
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Intent'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 70'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.IntentTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.IntentPhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers

        % add information for continue screen
        PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'Probe Continue'};
        PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S 40'};
        PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.ContinueTrigger(MCTRowIdx);
        PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.ContinuePhotodiode(MCTRowIdx);
        PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
        PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

        PsychoPyMarkersRowIdx = PsychoPyMarkersRowIdx + 1; % add to the row counter for PsychoPyMarkers
    end
end

% DID NOT RECORD TIMING FOR END PHOTODIODE OR TRIGGERS IN PSYCHOPY

PsychoPyMarkers.Label(PsychoPyMarkersRowIdx) = {'TaskEnd'};
PsychoPyMarkers.Value(PsychoPyMarkersRowIdx) = {'S161'};
PsychoPyMarkers.TriggerTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);
PsychoPyMarkers.StimulusStopTime(PsychoPyMarkersRowIdx) = rawdata.PProbeTrigger(MCTRowIdx);

clear PsychoPyMarkersRowIdx MCTPRowIdx MCTRowIdx
        
warning('on','all');

%% Calculate time between beats according to psychopy Triggers, Photodiodes, and Stimuli

% calculate time difference for triggers, photodiodes, and tone start
% use tone_number, when tone_number is 1 do not substract previous
% trial time

% standardize as time stince the start of the task and find time difference
% between all triggers

fprintf('Calculating time between beats for psychopy data.\n')

for PsychoPyMarkerRowIdx = 2:size(PsychoPyMarkers,1)
    % for all rows except the first
    PsychoPyMarkers.TriggerTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.TriggerTime(find(strcmp('S160',PsychoPyMarkers.Value)));
    PsychoPyMarkers.PhotodiodeTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.PhotodiodeTime(find(strcmp('S160',PsychoPyMarkers.Value)));
    % time since start is the time for that row minus the time for the
    % trigger for the start of the task (where value is S160)
    % for stimuli there is no task start stimuli to compare to so can take
    % the average of timing for starting trigger and photodiode
    PsychoPyMarkers.StimuliTimeSinceStart(PsychoPyMarkerRowIdx) = PsychoPyMarkers.StimulusStartTime(PsychoPyMarkerRowIdx) - ((PsychoPyMarkers.TriggerTime(find(strcmp('S160',PsychoPyMarkers.Value))) + PsychoPyMarkers.PhotodiodeTime(find(strcmp('S160',PsychoPyMarkers.Value))))/2);
    

    PsychoPyMarkers.TriggerTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.TriggerTime(PsychoPyMarkerRowIdx - 1);
    PsychoPyMarkers.PhotodiodeTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.PhotodiodeTime(PsychoPyMarkerRowIdx - 1);
    % time since previous trigger is tricky for stimulus time as there are
    % many routines without stimuli.
    if ~isnan(PsychoPyMarkers.StimulusStartTime(PsychoPyMarkerRowIdx))
        % if the current row has a stimulus
        if ~isnan(PsychoPyMarkers.StimulusStartTime(PsychoPyMarkerRowIdx - 1))
            % and the previous row has a stimulus
            % do the subtraction
            PsychoPyMarkers.StimuliTimeSincePrev(PsychoPyMarkerRowIdx) = PsychoPyMarkers.StimulusStartTime(PsychoPyMarkerRowIdx) - PsychoPyMarkers.StimulusStartTime(PsychoPyMarkerRowIdx - 1);
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


PsychoPyMeanBeatTriggerTime = mean(PsychoPyMarkers.TriggerTimeSincePrev,"omitnan");
PsychoPySDBeatTriggerTime = std(PsychoPyMarkers.TriggerTimeSincePrev,"omitnan");
PsychoPyMeanBeatTriggerTimeDifference = PsychoPyMeanBeatTriggerTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatTriggers(1) = PsychoPyMeanBeatTriggerTime;
TimingDifferences.PsychoPySDTimeBetweenBeatTriggers(1) = PsychoPySDBeatTriggerTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatTriggerDifference = abs(PsychoPyMeanBeatTriggerTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat triggers is ", string(PsychoPyMeanBeatTriggerTime), "seconds (SD = ",string(PsychoPySDBeatTriggerTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatTriggerTimeDifference), "seconds.\n"));

PsychoPyMeanBeatPhotodiodeTime = mean(PsychoPyMarkers.PhotodiodeTimeSincePrev,"omitnan");
PsychoPySDBeatPhotodiodeTime = std(PsychoPyMarkers.PhotodiodeTimeSincePrev,"omitnan");
PsychoPyMeanBeatPhotodiodeTimeDifference = PsychoPyMeanBeatPhotodiodeTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatPhotodiodes(1) = PsychoPyMeanBeatPhotodiodeTime;
TimingDifferences.PsychoPySDTimeBetweenBeatPhotodiodes(1) = PsychoPySDBeatPhotodiodeTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatPhotodiodeDifference = abs(PsychoPyMeanBeatPhotodiodeTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat photodiodes is ", string(PsychoPyMeanBeatPhotodiodeTime), "seconds (SD = ",string(PsychoPySDBeatPhotodiodeTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatPhotodiodeTimeDifference), "seconds.\n"));

PsychoPyMeanBeatStimuliTime = mean(PsychoPyMarkers.StimuliTimeSincePrev,"omitnan");
PsychoPySDBeatStimuliTime = std(PsychoPyMarkers.StimuliTimeSincePrev,"omitnan");
PsychoPyMeanBeatStimuliTimeDifference = PsychoPyMeanBeatStimuliTime - 1.575;

TimingDifferences.PsychoPyMeanTimeBetweenBeatStimuli = PsychoPyMeanBeatStimuliTime;
TimingDifferences.PsychoPySDTimeBetweenBeatStimuli = PsychoPySDBeatStimuliTime;
TimingDifferences.PsychoPyMeanTimeBetweenBeatStimuliDifference = abs(PsychoPyMeanBeatStimuliTimeDifference);

fprintf(strcat("From PsychoPy data, average time between beat sound is ", string(PsychoPyMeanBeatStimuliTime), "seconds (SD = ",string(PsychoPySDBeatStimuliTime),");\n"));
fprintf(strcat("which differs from the desired timing of 1.575 seconds by ", string(PsychoPyMeanBeatStimuliTimeDifference), "seconds.\n"));

clear PsychoPyMean* PsychoPySD*

%% Find photodiode sample points

fprintf('Determining photodiode time points.\n')

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

fprintf('Calculating time between beats for EEG photodiode data.\n')

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

fprintf('Calculating trial length according to EEG photodiode data.\n')

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

clear nEEGMean* EEGSD* PhotodiodeTrialTimes no1*

%% Calculate time difference between triggers and photodiodes for EEG data
fprintf('Calculating time differences between triggers and photodiodes in EEG data.\n')

EEGMarkers.TriggerVPhotodiodeTime = EEGMarkers.PhotodiodeTime - EEGMarkers.time;

EEGMeanPhotoVTrigger = mean(EEGMarkers.TriggerVPhotodiodeTime,"omitnan");
EEGSDPhotoVTrigger = std(EEGMarkers.TriggerVPhotodiodeTime,"omitnan");

TimingDifferences.EEGMeanTimeBetweenPhotodiodeAndTrigger = EEGMeanPhotoVTrigger;
TimingDifferences.EEGSDTimeBetweenPhotodiodeAndTrigger = EEGSDPhotoVTrigger;

fprintf(strcat("From EEG data, average time between corresponding photodiodes and triggers is ", string(EEGMeanPhotoVTrigger), " seconds (SD = ",string(EEGSDPhotoVTrigger),").\n"));

clear EEGMean* EEGSD*


%% Calculate Time Differences Between Triggers, Photodiodes, and Stimuli according to psychopy

fprintf('Calculating time differences between psychopy trial markers.\n')

PsychoPyMarkers.TriggerVPhotodiodeTime = PsychoPyMarkers.PhotodiodeTime - PsychoPyMarkers.TriggerTime;
PsychoPyMarkers.TriggerVStimulusTime = PsychoPyMarkers.StimulusStartTime - PsychoPyMarkers.TriggerTime;
PsychoPyMarkers.PhotodiodeVStimulusTime = PsychoPyMarkers.PhotodiodeTime - PsychoPyMarkers.StimulusStartTime;

        % TRIGGERS FOR THE ONOFF AND AWARE ACTUAL PROBES ARE RELATIVE TO
        % ROUTINE START; PHOTODIODE IS RELATIVE TO TASK START.

% store rows to omit
OnOffRows = strcmp('Probe OnOff',PsychoPyMarkers.Label);
AwareRows = strcmp('Probe Aware',PsychoPyMarkers.Label);
OmitProbeRows = OnOffRows | AwareRows;
 
PPTriggerVPhotoMean = mean(PsychoPyMarkers.TriggerVPhotodiodeTime(~OmitProbeRows),"omitnan");
PPTriggerVPhotoSD = std(PsychoPyMarkers.TriggerVPhotodiodeTime(~OmitProbeRows), "omitnan");

PPTriggerVStimMean = mean(PsychoPyMarkers.TriggerVStimulusTime(~OmitProbeRows),"omitnan");
PPTriggerVStimSD = std(PsychoPyMarkers.TriggerVStimulusTime(~OmitProbeRows),"omitnan");

PPPhotoVStimMean = mean(PsychoPyMarkers.PhotodiodeVStimulusTime(~OmitProbeRows),"omitnan");
PPPhotoVStimSD = std(PsychoPyMarkers.PhotodiodeVStimulusTime(~OmitProbeRows),"omitnan");

TimingDifferences.PsychoPyMeanTimeBetweenTriggersAndPhotodiode = PPTriggerVPhotoMean;
TimingDifferences.PsychoPyMeanTimeBetweenTriggersAndStimuli = PPTriggerVStimMean;
TimingDifferences.PsychoPyMeanTimeBetweenPhotodiodeAndStimuli = PPPhotoVStimMean;

fprintf(strcat("From psychopy data, average time between corresponding triggers and photodiodes is ", string(PPTriggerVPhotoMean), "seconds, (SD = ",string(PPTriggerVPhotoSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding triggers and stimuli is ", string(PPTriggerVStimMean), "seconds, (SD = ",string(PPTriggerVStimSD),").\n"));
fprintf(strcat("From psychopy data, average time between corresponding photodiodes and stimuli is ", string(PPPhotoVStimMean), "seconds, (SD = ",string(PPPhotoVStimSD),").\n"));

clear Probe* OnOffRows AwareRows

%% Calculate psychopy tone length

fprintf('Calculating trial length according to psychopy markers data.\n')

% if they have SoundTestToneEnd, SoundTestToneEnd - SoundTestToneStart
% should be 120 seconds
% PTrialToneStart, PTrialToneStop
% TrialToneStart, TrialToneStop
% not all trial tones will have tone stop recorded for some reason

PsychoPyMarkers.StartVStop = PsychoPyMarkers.StimulusStopTime - PsychoPyMarkers.StimulusStartTime;


PPStartStopMean = mean(PsychoPyMarkers.StartVStop,"omitnan");
PPStartStopSD = std(PsychoPyMarkers.StartVStop,"omitnan");
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
        CombinedMarkers.PsyStimulusTime(MarkersRowIdx) = PsychoPyMarkers.StimulusStartTime(PsychoPyMarkersRowCounter);

        PsychoPyMarkersRowCounter = PsychoPyMarkersRowCounter + 1;

    end

end

warning('on','all');

clear PsychoPyMarkersRowCounter MarkersRowIdx

%% Compare psychopy times to eeg times

% the times may not have equal scales in terms of time 0 being different
% for the EEG data and the psychopy data, but the importance is to look at
% consistency.

CombinedMarkers.EEGVPsyTrigger = CombinedMarkers.EEGTriggerTime - CombinedMarkers.PsyTriggerTime;
CombinedMarkers.EEGVPsyPhoto = CombinedMarkers.EEGPhotodiodeTime - CombinedMarkers.PsyPhotodiodeTime;
CombinedMarkers.EEGTriggerVPhotodiode = CombinedMarkers.EEGTriggerTime - CombinedMarkers.EEGPhotodiodeTime;
CombinedMarkers.PsyTriggerVPhotodiode = CombinedMarkers.PsyTriggerTime - CombinedMarkers.PsyPhotodiodeTime;

VTriggerMean = mean(CombinedMarkers.EEGVPsyTrigger,"omitnan");
VTriggerSD = std(CombinedMarkers.EEGVPsyTrigger,"omitnan");

TimingDifferences.EEGVPsyTriggerMean = VTriggerMean;
TimingDifferences.EEGVPsyTriggerSD = VTriggerSD;

fprintf(strcat("The average difference between the EEG trigger timing and psychopy trigger timing is ", string(VTriggerMean), "seconds, (SD = ",string(VTriggerSD),").\n"));


VPhotodiodeMean = mean(CombinedMarkers.EEGVPsyPhoto,"omitnan");
VPhotodiodeSD = std(CombinedMarkers.EEGVPsyPhoto,"omitnan");

TimingDifferences.EEGVPsyPhotodiodeMean = VPhotodiodeMean;
TimingDifferences.EEGVPsyPhotodiodeSD = VPhotodiodeSD;

fprintf(strcat("The average difference between the EEG photodiode timing and psychopy photodiode timing is ", string(VPhotodiodeMean), "seconds, (SD = ",string(VPhotodiodeSD),").\n"));


EEGTriggerVPhotodiodeMean = mean(CombinedMarkers.EEGTriggerVPhotodiode,"omitnan");
EEGTriggerVPhotodiodeSD = std(CombinedMarkers.EEGTriggerVPhotodiode,"omitnan");

TimingDifferences.EEGTriggerVPhotodiodeMean = EEGTriggerVPhotodiodeMean;
TimingDifferences.EEGTriggerVPhotodiodeSD = EEGTriggerVPhotodiodeSD;

fprintf(strcat("The average difference between the EEG trigger photodiode timing is ", string(EEGTriggerVPhotodiodeMean), "seconds, (SD = ",string(EEGTriggerVPhotodiodeSD),").\n"));


PsychoPyTriggerVPhotodiodeMean = mean(CombinedMarkers.PsyTriggerVPhotodiode(~OmitProbeRows),"omitnan");
PsychoPyTriggerVPhotodiodeSD = std(CombinedMarkers.PsyTriggerVPhotodiode(~OmitProbeRows),"omitnan");

TimingDifferences.PsychoPyTriggerVPhotodiodeMean = PsychoPyTriggerVPhotodiodeMean;
TimingDifferences.PsychoPyTriggerVPhotodiodeSD = PsychoPyTriggerVPhotodiodeSD;

fprintf(strcat("The average difference between the PsychoPy trigger and photodiode timing is ", string(PsychoPyTriggerVPhotodiodeMean), "seconds, (SD = ",string(PsychoPyTriggerVPhotodiodeSD),").\n"));

%% Clear everything else

clear *Rows LaptopOrDesktop *Mean *SD 