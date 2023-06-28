%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning Code

% Chelsie H.
% Started: November 8, 2022
% Last updated: June 19, 2023

% Purpose: Remove irrelevant data from raw data, save this cleaned data,
% calculate scores or variables of interest, save the scores.

% File with column key and content information is
% PsychoPyData_ColumnKey.xlsx

% Example data files: PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv and 
% PARTICIPANT_EFMW_Tasks_RPS_ExampleMCTErrors.csv

% to do:
% EDIT SCRIPT TO ACCOUNT FOR NEW DATA TYPES
% Edit text sent to command window to grab participant ID or file name
% Create script to score tasks
% Combine spreadsheet with scores with spreadsheet of questionnaire scores
% and demographics

% Future ideas:
% Could add something such that if the participant ID matches files in the
% cleaned data, the script should stop.

% Raw file names are usually in this format: PARTICIPANT_EFMW_Tasks_RPS_..
% followed by digits for YYYY-MM-DD_HHhMM.SS.MsMsMs (the h is 'h', Ms are millisecond digits)

% THIS SCRIPT IS NOT FOR REMOVING TRIALS WHERE THERE WERE ISSUES DURING
% DATA COLLECTION OR DUMMY TRIALS

% Note that because the data is being created through a python program,
% automatic counters will always start at '0' for the first item.
% 1 has been added to all counters to make this more intuitive in
% cleaned data.

%% Notes
% could separate data into different matrices, then look for the first
% indicator of a trial and delete all blank before it, then look for the
% last trial and delete everything after, just to conserve any trials where
% they did not response and no data was recorded.

%% Output Files
% ParticipantID_Task (for cleaned data of tasks only)
% ParticipantID_TaskP (for cleaned practice data)
% These will be made within matlab for each participant
% RPS_PsychoPyTaskInfo (will be RAD instead of RPS for RAD data; 
% made externally and added to within matlab)
% RPS_Task_Scores (will be RAD instead of RPS for RAD data; 
% made externally and added to within matlab)

%% Versions and Packages

% Main PC: Matlab R2021b update 6
% Packages: Stats and machine learning toolbox version 12.2, simulink
% version 10.4, signal processing toolbox version 8.7, image processing
% toolbox version 11.4; FieldTrip 1.0.1.0

% Laptop
% Packages:

% Surfacebook: Matlab R2021b update 6
% Packages: Stats and Machine Learning Toolbox 10.4,
% Simulink 10.4, Signal Processing Toolbox 8.7, Image Procesisng Toolbax 11.4, Images
% Acquision Toolbox 6.5
        % UPDATE STATS AND MACHINE LEARNING TOOLBOX ON SURFACEBOOK to see
        % if this makes things work.


%% Clear all and Select Directory

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES

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


%% Load in Data
rawdatadir = [maindir 'RawData/'];
cleaneddatadir = [maindir 'CleanedData/'];
cleanedpdatadir = [maindir 'CleanedPracticeData/'];
addpath(genpath(maindir))

fprintf('Collecting raw file names\n')

% need to get it to find all raw files or the raw files of interest too
filepattern = fullfile(rawdatadir, 'PARTICIPANT_EFMW_Tasks_RPS_*');
% previous line doesn't work on the surface book (has / as \)
% filepattern = [rawdatadir, 'PARTICIPANT_EFMW_Tasks_RPS_*'];

% finds all file with the string in the beginning of the file name
filename = dir(filepattern); 
% previous line doesn't work on the surface book (filename is empty
% structure)
% filename = dir('RawData/PARTICIPANT_EFMW_Tasks_RPS');
% neither does this one

% creates an array with file names X x 1 (X = number of files with matching
% names
filecell = struct2cell(filename);
% convert to cell array
filematrix = cell2mat(filecell(1,1));
% extract only the file name of the first file

            % LATER TO GET THE FILE NAMES ONE AT A TIME, NEED TO CHANGE THE
            % COLUMN VALUE.
            % EACH FILENAME IS PART OF A SEPARATE COLUMN
            % THIS COULD BE A GOOD POINT FOR LOOPING

filenamestring = mat2str(filematrix); 
% change filename to string
filenamestring = strrep(filenamestring,'''','');
%remove extra ' characters

% load in data file

% trying
% opts = detectImportOptions([rawdatadir 'ExampleRPSPsychoPyData_WithMCTErrors.csv']);
% preview([rawdatadir 'ExampleRPSPsychoPyData_WithMCTErrors.csv'],opts)
% mostly importing columns as character and double

% test = readmatrix([rawdatadir 'ExampleRPSPsychoPyData_WithMCTErrors.csv']);
% read matrix doesn't work because it puts everything as a double.

% [~,~,raw] = readmatrix([rawdatadir 'ExampleRPSPsychoPyData_WithMCTErrors.csv']);
% doesn't like the number of output arguments here

fprintf('Loading in raw data\n')

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called));

opts = detectImportOptions([rawdatadir filenamestring]);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax

for optsidx = 1:(size(opts.VariableNames,2))
    if contains(opts.VariableNames(optsidx),'keys') || contains(opts.VariableNames(optsidx),'condition') ||...
     contains(opts.VariableNames(optsidx),'letter')  || contains(opts.VariableNames(optsidx),'correct')  ||...
     contains(opts.VariableNames(optsidx),'presented') || contains(opts.VariableNames(optsidx),'.x') ||...
     contains(opts.VariableNames(optsidx),'.y') || contains(opts.VariableNames(optsidx),'clicked_name') ||...
     strcmp(opts.VariableNames(optsidx),'images') || strcmp(opts.VariableNames(optsidx),'loopnumber') || ...
     strcmp(opts.VariableNames(optsidx),'practicesymmresponse') || strcmp(opts.VariableNames(optsidx),'practicesymmaccuracy') ||...
     strcmp(opts.VariableNames(optsidx),'practicesquareresponse') || strcmp(opts.VariableNames(optsidx),'practicerecallaccuracy') ||...
     strcmp(opts.VariableNames(optsidx),'symmresponse') || strcmp(opts.VariableNames(optsidx),'symmaccuracy') || ...
     strcmp(opts.VariableNames(optsidx),'squareresponse') || strcmp(opts.VariableNames(optsidx),'recallaccuracy')
     
        opts = setvartype(opts,opts.VariableNames(optsidx),'char');

    else

        opts = setvartype(opts,opts.VariableNames(optsidx),'double');

    end

end

rawdata = readtable([rawdatadir filenamestring],opts);
% creates a table where all variables are 'cell'

% T2 = convertvars(T1,vars,dataType) converts the specified variables to the specified data type. The input argument T1 can be a table or timetable.
% doesn't do cell to double

            % LATER USE str2double INSTEAD TO GET NUMBERS
            % string() CONVERTS CELL TO STRING; CELL WORDS FINE FOR e.g.,
            % strcmp THOUGH.

            % cell2mat TO DO STUFF WITH NUMERIC VARIABLES

clear filename filenamestring opts*

% store column names
% rawdatavars = rawdata.Properties.VariableNames;

%% Constant Data Columns
% Participant ID (informed by researcher)
% date
% expName
% psychopyVersion , OS , and frameRate

% all will be copied to a new row of the RPS_PsychoPyTaskInfo file.
% columns renamed to: ID, date(YYYY-MM-DD_HHhMM.SS.MsMsMs), experiment
% psychopyVersion, OS, and frameRate can stay the same

% Could remake date so that it isn't in YYYY-MM-DD-HHhMM.SS.MsMsMs

%% Create indexes for constant data columns

% or just take the unique values

% RPS participants prior to November 13 will have ID = unique(rawdata.("Participant ID (informed by researcher)"));

if ~isempty(find(strcmp('Participant ID (informed by researcher)',rawdata.Properties.VariableNames),1))
    rawdata = renamevars(rawdata,'Participant ID (informed by researcher)','Participant ID');
end

ID = unique(rawdata.("Participant ID"));
Date = unique(rawdata.("date"));
expName = unique(rawdata.("expName"));
psychopyversion = unique(rawdata.("psychopyVersion"));
OS = unique(rawdata.("OS"));
frameRate = unique(rawdata.("frameRate"));

frameRate = num2cell(frameRate);

%% Creating Vector for adding to RPS_PsychoPyTaskInfo

%NewTaskInfo = [ID Date expName psychopyversion OS frameRate];

%% write task info to csv

%dlmwrite([maindir "RPS_PsychoPyTaskInfo.csv"], cell2mat(TaskInfo), 'delimiter', ',','append');
% doesn't work since data isn't all of the same type

% writecell(TaskInfo, [maindir "RPS_PsychoPyTaskInfo.csv"])
% did not append
% will have to load in, add the data, then re-write the file

opts = detectImportOptions([maindir 'RPS_PsychoPyTaskInfo.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskInfo = readtable([maindir 'RPS_PsychoPyTaskInfo.csv'],opts);

clear opts

% next look up how to add the cell array to the bottom of this table then
% resave the table

% could make cell array into a table

% NewTaskInfo = cell2table(NewTaskInfo);

% combine into one table
% NEEDS SAME NUMBER OF VARIABLES FIRST
% TaskInfo = [TaskInfo; NewTaskInfo];

% write to file
% writetable(TaskInfo, [maindir 'RPS_PsychoPyTaskInfo.csv']);

%% Define Column Indexes and Subject IDs?

            % find(strcmp(data, 'exact string of interest))) TO FIND ROWS
            % WITH SPECIFIC STRING VALUES

            % rawdata.Properties.VariableNames TO GET VARIABLE NAMES FOR
            % EACH COLUMN

            % T2 = renamevars(T1,vars,newNames) renames the table or timetable 
            % variables specified by vars using the names specified by newNames.

% could rename columns or just create column index variables

%% Randomizer Columns (to remove after creating task order variable(s))
% EFtasksrandomizerloop.thisRepN, EFtasksrandomizerloop.thisTrialN, EFtasksrandomizerloop.thisIndex
% EFtasksrandomizerloop.ran, EFTask1, EFTask2, EFTask3, EFTask4,
% counterbalance_switch_shapecolour.thisRepN,
% counterbalance_switch_shapecolour.thisTrialN,
% counterbalance_switch_shapecolour.thisN,
% counterbalance_switch_shapecolour.thisIndex,
% counterbalance_switch_shapecolour.ran, subtask1, subtask2
% symmspansubtasksloop.thisRepN, symmspansubtasksloop.thisTrialN, 
% symmspansubtasksloop.thisN, symmspansubtasksloop.thisIndex, symmspansubtasksloop.ran

%% Will need to create some sort of variable for task order...
% Likely with EFtasksrandomizerloop.thisIndex (which tells which column of
% the randomizer was used) and EFtasksrandomizerloop.thisN (which tells the
% times the loop has been referred to from 0 to 3)
% so when EFtasksrandomizerloop.thisN = 0, EFtasksrandomizerloop.thisIndex
% can be the first digit and so on to make a four digit identifier for
% randomizer task order.
% could also take EFtasksrandomizerloop.thisIndex and create a label with
% the task each row refers to.

% EFtasksrandomizerloop.thisIndex = 0 = EFTask3 = SymSpan = SY
% (same as above)"" = 1 = EFTask1 = Switch = SW
% "" = 2 = EFTask2 = Nback = N
% "" = 3 = EFTask4 = SART = SA

% can add this to the file with system information etc.

%% and Variable for which subtask was first
% May include subtasks
% Colour Shape Subtasks:
% counterbalance_switch_shapecolour.thisIndex = 0 = subtask1 = colour = c
% "" = 1 = subtask2 = shape = s
% Symetry Span Subtasks:
% symmspansubtasksloop.thisIndex = 0 = s (symmetry judgement)
% " = 1 = r (recall)

% within an if loop for index for task randomizer
% if index = # corresponding to SW
% if index = # corresponding to c
% then task and subtask order variable = SWc...
% concatonate things into a variable name e.g., NSWcsSYsrSAN

%% To get task order
fprintf('Determining task order\n')
% Create TaskOrder variable to hold letters
TaskOrder = [];
    % find EFtasksrandomizerloop.thisN
TaskRandCol = find(strcmp(rawdata.Properties.VariableNames,"EFtasksrandomizerloop.thisN"));
% for 'PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv' this should be 32
for TaskRandIdx = 0:3
    % for every value of this which should be 0 to 3
    % testing when this = 0
        % had trouble getting find/ismember working for this
        TaskRandRow = find(ismember(string(rawdata.("EFtasksrandomizerloop.thisN")),string(TaskRandIdx)));
        % for the example, this should be 416
 
    % take that row number and find the value for EFtasksrandomizerloop.thisIndex
        TaskRandIdxNum = rawdata.("EFtasksrandomizerloop.thisIndex")(TaskRandRow);
        % creates a 1 x 1 cell with the value (3, in the example)
        TaskRandIdxNum = cell2mat(TaskRandIdxNum(1));
        % but this makes it a character
            % or it DID, when I last ran this with the few errors data
            % with many errors data this str2double isn't necessary
        % TaskRandIdxNum = str2double(cell2mat(TaskRandIdxNum(1)));
        % now this makes it a double but with just the single number

    % if that value is 0
    if TaskRandIdxNum == 0
        % add SY to TaskOrder; TaskOrder = [TaskOrder 'SY']
        TaskOrder = [TaskOrder 'SY'];        % remember to use single quotes
        % find symmspansubtasksloop.thisN
        % SubTaskRandCol = find(strcmp(rawdata.Properties.VariableNames,"symmspansubtasksloop.thisN"));
            % find row where this is 0
        SymSubTaskRandRow = find(ismember(rawdata.("symmspansubtasksloop.thisN"),'0'));
        SymSubTaskRandIdxNum = rawdata.("symmspansubtasksloop.thisIndex")(SymSubTaskRandRow);
        SymSubTaskRandIdxNum = str2num(cell2mat(SymSubTaskRandIdxNum(1)));
            % for that row
            % if symmspansubtasksloop.thisIndex = 0
            if SymSubTaskRandIdxNum == 0
                % add 'sr' to task order
                TaskOrder = [TaskOrder 'sr'];
            % else if symmspansubtasksloop.thisIndex = 1
            elseif SymSubTaskRandIdxNum == 1
                % add 'rs' to task order
                TaskOrder = [TaskOrder 'rs'];
            end
    % else if the value for the task randomizer index is 1
    elseif TaskRandIdxNum == 1
        % add SW to task order variable
        TaskOrder = [TaskOrder 'SW'];
        % find counterbalance_switch_shapecolour.thisN
        % find row where this is 0
        SwitchSubTaskRandRow = find(ismember(rawdata.("counterbalance_switch_shapecolour.thisN"),0));
            % 0 needed single quotes previously when running few errors
            % data.
        SwitchSubTaskRandIdxNum = rawdata.("counterbalance_switch_shapecolour.thisIndex")(SwitchSubTaskRandRow);
        SwitchSubTaskRandIdxNum = str2num(cell2mat(SwitchSubTaskRandIdxNum(1)));
                % in more errors data, this IdxNum is already a double
        % for that row
        % if counterbalance_switch_shapecolour.thisIndex = 0
        if SwitchSubTaskRandIdxNum == 0
                % add 'cs' to task order
                TaskOrder = [TaskOrder 'cs'];
            % else if counterbalance_switch_shapecolour.thisIndex = 1
        elseif SwitchSubTaskRandIdxNum == 1
                % add 'sc' to task order
                TaskOrder = [TaskOrder 'sc'];
        end
    % else if value for task randomizer index is 2
    elseif TaskRandIdxNum == 2
        % add N to task order
        TaskOrder = [TaskOrder 'N'];
    % else if value for task randomizer index is 3
    elseif TaskRandIdxNum == 3
        % add SA to task order
        TaskOrder = [TaskOrder 'SA'];
    end
end    
% with test where TaskRandIdx = 0; the output TaskOrder should just be 'SA'
% for full run with 'PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv' the
% TaskOrder should be SASWscSYsrN

%% Now add this to the task info
NewTaskInfo = [ID Date expName psychopyversion OS frameRate TaskOrder];
% combine into one table
TaskInfo = [TaskInfo; NewTaskInfo];
% write to file
writetable(TaskInfo, [maindir 'RPS_PsychoPyTaskInfo.csv']);

        % COULD COMBINE ALL NEW TASK INFO BEFORE WRITING IT TO CSV TO
        % REDUCE READING AND WRITING STEPS

clear TaskRandCol TaskRandIdx TaskRandIdxNum TaskRandRow SymSubTaskRandRow 
clear SymSubTaskRandIdxNum SwitchSubTaskRandRow SwitchSubTaskRandIdxNum
clear psychopyversion OS frameRate TaskOrder NewTaskInfo TaskInfo

fprintf('Saving task info\n')
            
%% SART Practice:
fprintf('Processing SART data\n')
% SARTkey_resp_practice.keys, SARTkey_resp_practice.corr,
% SARTpracticeloop.thisRepN, SARTpracticeloop.thisTrialN,
% SARTpracticeloop.thisN, SARTpracticeloop.thisIndex, SARTpracticeloop.ran

%% SART Stimuli:
% number (this includes the practice numbers. refer to the SARTpracticeloop columns
% to find when both contain something...
%% SART Scoring
% correctkey (desired key)
% SARTkey_resp_trials.keys (key pressed)
% SARTkey_resp_trials.corr (correct = 1, incorrect = 0)
% SARTkey_resp_trials.rt (response time since routine start)
% SARTblock1loop.thisRepN (which repeat of the stimuli loop)
% SARTblock1loop.thisN (trial number starting at 0)
% Remove: SARTblock1loop.thisTrialN, SARTblock1loop.thisIndex,
% SARTblock1loop.ran
%% SART Excess:
% SARTloop.thisRepN, SARTloop.thisTrialN, SARTloop.thisN,
% SARTloop.thisIndex, SARTloop.ran,

%% Create separate tables for tasks SART

% cannot just concatinate with rawdata.variables
% create an index?

%T(:,ismember(T.Properties.VariableNames, {""list of variables""})) this
% doesn't work with wild cards

SARTCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'SART'));
SARTAllData = rawdata(:,rawdata.Properties.VariableNames(SARTCols));
% doesn't get us the extra column for number

SARTAllData.("number") = rawdata.("number");
SARTAllData.("correctkey") = rawdata.("correctkey");
% adds the extra column to the end.

%% Separating practice from task for SART

% for the practice columns, there is data only during the practice while
% the rest is NaN
% so if I select only those rows where the practice section is not NaN I
% can keep just the rows that matter from the 'numbers' column

SARTPRows = find(~isnan(SARTAllData.("SARTpracticeloop.ran")));
SARTPData = SARTAllData(SARTPRows,:);
% but this leaves us with extra columns.
SARTPNum = SARTPData.("number");
SARTPCKey = SARTPData.("correctkey");

SARTPCols = ~cellfun('isempty', regexp(SARTPData.Properties.VariableNames, 'practice'));
% using 'practice' won't work in some of the other tasks.

        % FUTURE VERSIONS OF THE TASKS NEED STANDARDIZED VARIABLE NAMING TO
        % MAKE THIS SEPARATION EASIER
        % OTHER VARIABLES SHOULD ALSO INCLUDE THE TASK LABEL AND BE
        % SEPARATED FOR PRACTICE AND ACTUAL TASKS

SARTPData = SARTPData(:,SARTPCols);
SARTPData.("number") = SARTPNum;
SARTPData.("correctkey") = SARTPCKey;

% data should have 10 columns in practice

% can use ~ to get the task data only.
SARTData = SARTAllData(~SARTPRows,~SARTPCols);

% data should have 15 columns for SART

SARTLoopCol = ~cellfun('isempty',regexp(SARTData.Properties.VariableNames,'SARTloop'));
SARTRows = ~isnan(SARTData.("SARTblock1loop.ran"));
% Don't need SARTloop columns either
% reduces it to 10 columns

SARTData = SARTData(SARTRows,~SARTLoopCol);

            % DON'T FORGET TO CLEAR UNNEEDED VARIABLES LATER

%% Remove more extra columns for SART
SARTPData = SARTPData(:,~ismember(SARTPData.Properties.VariableNames, ["SARTpracticeloop.thisRepN", ...
    "SARTpracticeloop.thisTrialN", "SARTpracticeloop.thisIndex", "SARTpracticeloop.ran"]));

SARTData = SARTData(:,~ismember(SARTData.Properties.VariableNames,["SARTblock1loop.thisRepN", ...
    "SARTblock1loop.thisTrialN","SARTblock1loop.thisIndex","SARTblock1loop.ran"]));

% 6 columns in practice and actual data

%% Add 1 to counters for SART
SARTPData.("SARTpracticeloop.thisN") = SARTPData.("SARTpracticeloop.thisN") + 1;

SARTData.("SARTblock1loop.thisN") = SARTData.("SARTblock1loop.thisN") + 1;

%% Rename SART columns
SARTPData = renamevars(SARTPData,["SARTkey_resp_practice.keys", ...
    "SARTkey_resp_practice.corr", "SARTkey_resp_practice.rt",  ...
    "SARTpracticeloop.thisN","number","correctkey"], ...
    ["SARTPResp","SARTPAcc","SARTPRT","SARTPTrial","SARTPStim","SARTPCResp"]);

SARTData = renamevars(SARTData,["SARTkey_resp_trials.keys","SARTkey_resp_trials.corr", ...
    "SARTkey_resp_trials.rt","SARTblock1loop.thisN","number","correctkey"], ...
    ["SARTResp","SARTAcc","SARTRT","SARTTrial","SARTStim","SARTCResp"]);

        % BEFORE ANALYZING THE DATA, REMEMBER TO CHECK WHETHER THE COLUMN FOR
        % ACCURACY IS CORRECT

clear SARTCols SARTPRows SARTPNum SARTPCKey SARTPCols SARTLoopCol
clear SARTRows


% For now, this puts the SART practice and SART data of use into separate
% tables with new labels and counters set to start at 1.

                    % eventually need to see if the practice and actual data can be put into
                    % one file somehow
                    % they'll probably have a different number of rows though
                    % so maybe they'll need to be saved into separate files per task

%% Switch Practice:
fprintf('Processing Switch data\n')
% Shape Only
% pshape_resp.keys, pshape_resp.corr, pshape_resp.rt,
% practiceshapeloop.thisRepN, practiceshapeloop.thisTrialN,
% practiceshapeloop.thisN, practiceshapeloop.thisIndex,  practiceshapeloop.ran
% Colour Only
% pcolour_resp.keys, pcolour_resp.corr, pcolour_resp.rt, practicecolourloop.thisRepN, 
% practicecolourloop.thisTrialN, practicecolourloop.thisN, practicecolourloop.thisIndex,
% practicecolourloop.ran
% Switch
% dummypracticeswitchstimuluscondition, dummypracticeswitchcondition, 
% dummypracticeswitchstimuluspresented, dummypracticeswitchcorrectresponse,
% mixpracticedummyresp.keys, mixpracticedummyresp.corr,
% mixpracticedummyresp.rt, practiceswitchstimuluscondition, practiceswitchcondition
% practiceswitchstimuluspresented, practiceswitchcorrectresponse,
% mixpracticeresp.keys, mixpracticeresp.corr, mixpracticeresp.rt,
% practicemixedloop.thisRepN, practicemixedloop.thisTrialN, practicemixedloop.thisN,  
% practicemixedloop.thisIndex, practicemixedloop.ran
%% Switch Stimuli:
% images (this includes practice images. Can refer to practice loop columns
% to find where both contain information and remove)
%% Switch Scoring
% correct (desired key; includes practice)
% Shape Only
% shapetrialsresp.keys (key pressed for shape trials)
% shapetrialsresp.corr (shape trials, correct = 1, incorrect = 0)
% shapetrialsresp.rt (response time since routine start)
% shapetrialsloop.thisN (trial number starting at 0)
% Remove: shapetrialsloop.thisRepN, shapetrialsloop.thisTrialN , shapetrialsloop.thisIndex, shapetrialsloop.ran,
% switch_shapetrials.thisRepN, switch_shapetrials.thisTrialN,
% switch_shapetrials.thisN, switch_shapetrials.thisIndex, switch_shapetrials.ran
% Colour Only
% colourtrialresp.keys (key pressed for colour trials)
% colourtrialresp.corr (colour trials, correct = 1, incorrect = 0)
% colourtrialresp.rt (response time since routine start)
% colourtrialsloop.thisN (trial number starting at 0)
% Remove: colourtrialsloop.thisRepN, colourtrialsloop.thisTrialN colourtrialsloop.thisIndex, colourtrialsloop.ran,
% switch_colourtrials.thisRepN, switch_colourtrials.thisTrialN,
% switch_colourtrials.thisN, switch_colourtrials.thisIndex, switch_colourtrials.ran
% Dummy
% dummystimuluscondition (Shape or Colour)
% dummyswitchcondition (dummy)
% dummystimuluspresented (which .png was shown)
% dummycorrectresponse (desired key)
% mixeddummyresp.keys (key pressed for dummy response)
% mixeddummyresp.corr (correct = 1, incorrect = 0)
% mixeddummyresp.rt (response time since routine start)
% Switch
% stimuluscondition (SHAPE or COLOUR)
% switchcondition (switch or stay)
% stimuluspresented (which .png was shown)
% correctresponse (desired key)
% mixedtrialsresp.keys (key pressed for dummy response)
% mixedtrialsresp.corr (correct = 1, incorrect = 0)
% mixedtrialsresp.rt (response time since routine start)
% mixedblock1.thisN (trial number)
% Remove: mixedblock1.thisRepN, mixedblock1.thisTrialN, mixedblock1.thisIndex,  
% mixedblock1.ran
%% Switch Excess
% colour_shape_switch_task.thisRepN, colour_shape_switch_task.thisTrialN, 
% colour_shape_switch_task.thisN, colour_shape_switch_task.thisIndex,
% colour_shape_switch_task.ran,

%% Create separate tables for Switch

% all switch columns have one of: shape, colour, switch, mixed, stimulus
% unique columns otherwise: images, dummycorrectresponse, correctresponse
% other columns with 'correctresponse' are used in other tasks

% doing all of shape, colour, mixed, stimulus, and switch would mean
% including much overlap

% to get minimal overlap but get all columns, could do: shape, colour, mixed,
% practiceswitch...

% some of these can grouped maybe to reduce single calls?

ShapeCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'shape'));
ColourCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'colour'));
MixedCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'mix'));
PracticeSwitchCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceswitch'));
SwitchCondCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'switchcond'));

SwitchAllCols = ShapeCols | ColourCols | MixedCols | PracticeSwitchCols | SwitchCondCols;
SwitchAllData = rawdata(:,SwitchAllCols);

%then add switchcond, dummyswitchcondition, switchcondition,
%dummystimuluspresented, stimuluscondition, dummystimuluscondition, 
% stimuluspresented, images, correct - separately
% add extra columns
SwitchAllData.("dummystimuluspresented") = rawdata.("dummystimuluspresented");
SwitchAllData.("stimuluscondition") = rawdata.("stimuluscondition");
SwitchAllData.("dummystimuluscondition") = rawdata.("dummystimuluscondition");
SwitchAllData.("stimuluspresented") = rawdata.("stimuluspresented");
SwitchAllData.("images") = rawdata.("images");
SwitchAllData.("correct") = rawdata.("correct");

% missed some
SwitchAllData.("correctresponse") = rawdata.("correctresponse");
SwitchAllData.("dummycorrectresponse") = rawdata.("dummycorrectresponse");

clear ShapeCols ColourCols PracticeSwitchmatch SwitchCondCols MixedCols SwitchAllCols
%% Separating practice from task for Switch

% for the practice columns, there is data only during the practice while
% the rest is NaN
% so if I select only those rows where the practice section is not NaN I
% can keep just the rows that matter from the 'numbers' column

% but colour, shape, and switch (mixed) have separate practice sections
% so...

%isnan doesn't work here because the empty parts aren't NAN for some
%reason.

SwitchPCols1 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'practice'));
SwitchPCols2 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pshape'));
SwitchPCols3 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pcolour'));

SwitchPCols = SwitchPCols1 | SwitchPCols2 | SwitchPCols3;

clear SwitchPCols1 SwitchPCols2 SwitchPCols3

ShapePRows = ~cellfun('isempty',SwitchAllData.("practiceshapeloop.ran"));
ColourPRows = ~cellfun('isempty',SwitchAllData.("practicecolourloop.ran"));
SwitchMixedPRows = ~cellfun('isempty',SwitchAllData.("practicemixedloop.ran"));
SwitchPRows = ShapePRows | ColourPRows | SwitchMixedPRows;

clear ShapePRows ColourPRows SwitchMixedPRows

SwitchPData = SwitchAllData(SwitchPRows,:);

% all practice columns have 'pshape' 'practice' 'pcolour'
% then need 'images' and 'correct'

SwitchPImages = SwitchPData.("images");
SwitchPCorrect = SwitchPData.("correct");

SwitchPData = SwitchPData(:,SwitchPCols);

SwitchPData.("images") = SwitchPImages;
SwitchPData.("correct") = SwitchPCorrect;

clear SwitchPRows SwitchPImages SwitchPCorrect

% practice should have 37 columns

% can use ~ to get the task data only.
ShapeRows = ~cellfun('isempty',SwitchAllData.("shapetrialsloop.ran"));
ColourRows = ~cellfun('isempty',SwitchAllData.("colourtrialsloop.ran"));
SwitchMixedRows = ~cellfun('isempty',SwitchAllData.("mixedblock1.ran"));
SwitchRows = ShapeRows | ColourRows | SwitchMixedRows;

clear ShapeRows ColourRows SwitchMixedRows

SwitchData = SwitchAllData(SwitchRows,~SwitchPCols);

clear SwitchRows SwitchPCols

% data should have 58 columns here

% can't use ~SwitchPRows to get switch rows here because there are other
% empty rows in addition to the practices

%% Remove extra columns from switch data
% loops are: switch_shapetrials* counterbalance_switch_shapecolour*
% switch_colourtrials* colour_shape_switch_task*

SwitchLoopCol1 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'switch_shapetrials'));
SwitchLoopCol2 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'counterbalance_switch_shapecolour'));
SwitchLoopCol3 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames, 'switch_colourtrials'));
SwitchLoopCol4 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames, 'colour_shape_switch_task'));

SwitchLoopCol = SwitchLoopCol1 | SwitchLoopCol2 | SwitchLoopCol3 | SwitchLoopCol4;

SwitchData = SwitchData(:,~SwitchLoopCol);

clear SwitchLoopCol*

%% Separate switch dummy
           
                    % DUMMY DATA IS BEING INCLUDED TO DO CHECKS IN CASE THE
                    % FIRST SWITCH IS IMMEDIATELY AFTER THE DUMMY

% identify dummy columns
SwitchPDummyCols = ~cellfun('isempty',regexp(SwitchPData.Properties.VariableNames,'dummy'));
SwitchDummyCols = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'dummy'));

SwitchPDummyData = SwitchPData(:,SwitchPDummyCols);
SwitchDummyData = SwitchData(:,SwitchDummyCols);

SwitchPData = SwitchPData(:,~SwitchPDummyCols);
SwitchData = SwitchData(:,~SwitchDummyCols);


% remove empty rows from dummy
SwitchPDummyData = rmmissing(SwitchPDummyData);
SwitchDummyData = rmmissing(SwitchDummyData);

clear SwitchDummyCols SwitchPDummyCols 


%% Remove Unnecessary columns from Switch data

SwitchPData = SwitchPData(:,~ismember(SwitchPData.Properties.VariableNames,["practicecolourloop.thisRepN", ...
   "practicecolourloop.thisTrialN", "practicecolourloop.thisIndex", "practicecolourloop.ran", ...
   "practiceshapeloop.thisRepN", "practiceshapeloop.thisTrialN", "practiceshapeloop.thisIndex", ...
   "practiceshapeloop.ran", "practicemixedloop.thisRepN", "practicemixedloop.thisTrialN", ...
   "practicemixedloop.thisIndex","practicemixedloop.ran"]));

SwitchData = SwitchData(:,~ismember(SwitchData.Properties.VariableNames, ["shapetrialsloop.thisRepN", ...
    "shapetrialsloop.thisTrialN","shapetrialsloop.thisIndex","shapetrialsloop.ran", ...
    "colourtrialsloop.thisRepN","colourtrialsloop.thisTrialN","colourtrialsloop.thisIndex", ...
    "colourtrialsloop.ran","mixedblock1.thisRepN","mixedblock1.thisTrialN", ...
    "mixedblock1.thisIndex","mixedblock1.ran"]));

% practice should have 18 columns; data should have 19 columns

%% Rename Switch Columns

% next can rename columns for switch data, than add in corresponding dummy
% data to a new row piece by piece, so column order will not be a problem

SwitchPData = renamevars(SwitchPData, ["pshape_resp.keys","pshape_resp.corr", ...
    "pshape_resp.rt", "practiceshapeloop.thisN","images","correct", ...
    "pcolour_resp.keys","pcolour_resp.corr","pcolour_resp.rt","practicecolourloop.thisN", ...
    "practiceswitchstimuluscondition","practiceswitchcondition","practiceswitchstimuluspresented", ...
    "practiceswitchcorrectresponse","mixpracticeresp.keys","mixpracticeresp.corr","mixpracticeresp.rt", ...
    "practicemixedloop.thisN"], ...
    ["SwitchPShapeResp","SwitchPShapeAcc","SwitchPShapeRT","SwitchPShapeTrial", ...
    "SwitchPStimSingle","SwitchPCRespSingle","SwitchPColourResp","SwitchPColourAcc","SwitchPColourRT", ...
    "SwitchPColourTrial","SwitchPRule","SwitchPCond","SwitchPStimMixed","SwitchPCRespMixed","SwitchPResp", ...
    "SwitchPAcc","SwitchPRT","SwitchPTrial"]);

SwitchData = renamevars(SwitchData, ["images", "correct","shapetrialsresp.keys", ...
    "shapetrialsresp.corr", "shapetrialsresp.rt", "shapetrialsloop.thisN", ...
    "colourtrialresp.keys", "colourtrialresp.corr", "colourtrialresp.rt", ...
    "colourtrialsloop.thisN","stimuluscondition","switchcondition","stimuluspresented", ...
    "correctresponse","mixedtrialsresp.keys","mixedtrialsresp.corr","mixedtrialsresp.rt", ...
    "mixedblock1.thisN"], ...
    ["SwitchStimSingle", "SwitchCRespSingle", "SwitchShapeResp","SwitchShapeAcc","SwitchShapeRT", ...
    "SwitchShapeTrial","SwitchColourResp","SwitchColourAcc","SwitchColourRT", ...
    "SwitchColourTrial","SwitchRule","SwitchCond","SwitchStimMixed","SwitchCRespMixed", ...
    "SwitchResp","SwitchAcc","SwitchRT","SwitchTrial"]);

                % some duplicate column names previously for the stimuli and correct
                % responses, may want to combine the single and mixed task
                % columns for these, just to simplify things.
                % could also fill in 'condition' and 'rule' to merge single
                % and mixed tasks but this might be easy to mix up.

%% Add 1 to counters for switch

% matlab is treating the columns as cells here, but treated them is doubles
% for SART.
SwitchPData.("SwitchPShapeTrial") = str2double(SwitchPData.("SwitchPShapeTrial")) + 1;
SwitchPData.("SwitchPColourTrial") = str2double(SwitchPData.("SwitchPColourTrial")) + 1;
SwitchPData.("SwitchPTrial") = str2double(SwitchPData.("SwitchPTrial")) + 2; % plus 2 so dummy is 1

SwitchData.("SwitchShapeTrial") = str2double(SwitchData.("SwitchShapeTrial")) + 1;
SwitchData.("SwitchColourTrial") = str2double(SwitchData.("SwitchColourTrial")) + 1;
SwitchData.("SwitchTrial") = str2double(SwitchData.("SwitchTrial")) + 2; % plus 2 so dummy is 1

%% Add Dummies to switch data

% can't just add an empty thing to the table...
% assuming the last row is always a mixed/actual switch task trial (which
% it should always be) can duplicate that into a new table and refill the
% rows

PDummyRow = SwitchPData(height(SwitchPData),:);

PDummyRow.("SwitchPRule") = SwitchPDummyData.("dummypracticeswitchstimuluscondition");
PDummyRow.("SwitchPCond") = SwitchPDummyData.("dummypracticeswitchcondition");
PDummyRow.("SwitchPStimMixed") = SwitchPDummyData.("dummypracticeswitchstimuluspresented");
PDummyRow.("SwitchPCRespMixed") = SwitchPDummyData.("dummypracticeswitchcorrectresponse");
PDummyRow.("SwitchPResp") = SwitchPDummyData.("mixpracticedummyresp.keys");
PDummyRow.("SwitchPAcc") = SwitchPDummyData.("mixpracticedummyresp.corr");
PDummyRow.("SwitchPRT") = SwitchPDummyData.("mixpracticedummyresp.rt");
PDummyRow.("SwitchPTrial") = 1;

SwitchPData = [SwitchPData ; PDummyRow];

DummyRow = SwitchData(height(SwitchData),:);

DummyRow.("SwitchRule") = SwitchDummyData.("dummystimuluscondition");
DummyRow.("SwitchCond") = SwitchDummyData.("dummyswitchcondition");
DummyRow.("SwitchStimMixed") = SwitchDummyData.("dummystimuluspresented");
DummyRow.("SwitchCRespMixed") = SwitchDummyData.("dummycorrectresponse");
DummyRow.("SwitchResp") = SwitchDummyData.("mixeddummyresp.keys");
DummyRow.("SwitchAcc") = SwitchDummyData.("mixeddummyresp.corr");
DummyRow.("SwitchRT") = SwitchDummyData.("mixeddummyresp.rt");
DummyRow.("SwitchTrial") = 1;

SwitchData = [SwitchData; DummyRow];

clear PDummyRow DummyRow SwitchDummyData SwitchPDummyData

%% Subtract extra time before stimulus onset so reaction time is always relative to stimuli.

% stimulus onset is at the start of the routine for shape only and colour
% only
% for the switch mixed block, the stimuli they have to respond to start
% 0.75  seconds after routine start.

% test = SwitchPData;
% test.SwitchPRT = cell2num(test.SwitchPRT)  - 0.75;
% Error using cell2num (line 40)
% can't convert cell array with empty cells to matrix

% on the other hand, after the data is exported, the table reads in with
% this column as a double.

% test.SwitchPRT = str2double(test.SwitchPRT) - 0.75;

% this creates negative numbers, these weren't time relative to routine
% start, they were time relative to when the response component was
% available. SO these reaction times don't need to be corrected

%% Symmetry Span Practice
fprintf('Processing SymSpan data\n')
% Sym
% practicepresentedsymmstim, practicesymmcorrectresponse,
% practicesymmresponse, practicesymmaccuracy, practiceresponse.clicked_name
% symmpracticeloop.thisRepN, symmpracticeloop.thisTrialN,
% symmpracticeloop.thisN, symmpracticeloop.thisIndex, symmpracticeloop.ran,
% symmetryloop.thisRepN, symmetryloop.thisTrialN, symmetryloop.thisN, symmetryloop.thisIndex, 
% symmetryloop.ran
% Recall
% practicesquarecorrectresponse, symmpracticesquareloop.thisRepN, symmpracticesquareloop.thisTrialN, 
% symmpracticesquareloop.thisN, symmpracticesquareloop.thisIndex, symmpracticesquareloop.ran, 
% practicesquareresponse, practicerecallaccuracy, square_resp_2.clicked_name, 
% symmpracticerecalloop.thisRepN, symmpracticerecalloop.thisTrialN, symmpracticerecalloop.thisN
% symmpracticerecalloop.thisIndex, symmpracticerecalloop.ran, 
% symmmempracticeloop.thisRepN, symmmempracticeloop.thisTrialN, symmmempracticeloop.thisN, 
% symmmempracticeloop.thisIndex, symmmempracticeloop.ran
% Mixed
% symmspansymmploop.thisRepN, symmspansymmploop.thisTrialN, symmspansymmploop.thisN, 
% symmspansymmploop.thisIndex, symmspansymmploop.ran, symmspanrecallploop.thisRepN, 
% symmspanrecallploop.thisTrialN, symmspanrecallploop.thisN, symmspanrecallploop.thisIndex, 
% symmspanrecallploop.ran, symmspanploop.thisRepN, symmspanploop.thisTrialN, 
% symmspanploop.thisN, symmspanploop.thisIndex, symmspanploop.ran
%% Symmetry Span Stimuli
% loopnumber (which spreadsheet was used for a series; includes recall and
% mixed practice)
% memnumber (number of items to recall based on loopnumber spreadsheet; includes
% recall and mixed practice)
%% Symmetry Span Scoring
% symmetrical (is the stimulus symmetrical, also part of practice)
% Symetry
% presentedsymmstim (.JPG presented)
% symmcorrectresponse (["name of correct response"])
% symmresponse (["name of actual response"])
% symmaccuracy (did they respond "Correct"ly or "Incorrect"ly)
% symmresponseclick.clicked_name (name of the actual response without brackets)
% squarecorrectresponse (square presented)
% symmspanblocksymmloop.thisTrialN, symmspanblocksymmloop.thisN, 
% symmspanblocksymmloop.thisIndex (all a trial number within loop, resets
% to 0 with every series of squares; good for keeping things in order WITHIN series)
% Remove: symmspanblocksymmloop.thisRepN, symmspanblocksymmloop.ran
% Recall
% squareresponse (["the square they selected"])
% recallaccuracy (did they respond "Correct"ly or "Incorrect"ly)
% square_resp.clicked_name (name of the response they selected)
% symmspanrecallblocksloop.thisRepN, symmspanrecallblocksloop.thisN (trial
% number within series. Good for keeping things in order WITHIN series).
% Remove: symmspanrecallblocksloop.thisTrialN,
% symmspanrecallblocksloop.thisIndex, symmspanrecallblocksloop.ran
% Series Loop
% columns are for the series loop just before the row with information for
% the series
% symmspanblocksloop.thisN (series number! Use this with trial number
% within series to keep things in order).
% Remove: symmspanblocksloop.thisRepN, symmspanblocksloop.thisTrialN
% (loops of the four length conditions), symmspanblocksloop.thisIndex, symmspanblocksloop.ran
%% Symmetry Span Excess
% Sym
% symmetryloop.thisRepN, symmetryloop.thisTrialN, symmetryloop.thisN, symmetryloop.thisIndex, 
% symmetryloop.ran
% Recall
% recallloop.thisRepN, recallloop.thisTrialN, recallloop.thisN, recallloop.thisIndex, 
% recallloop.ran
% Task
% symmspanendkey.keys, symmspanendkey.rt, symmspantaskloop.thisRepN, symmspantaskloop.thisTrialN, 
% symmspantaskloop.thisN, symmspantaskloop.thisIndex, symmspantaskloop.ran

%% Create separate tables for SymSpan

                % REMEMBER THAT OLDER DATA ARE MISSING THE ".time" COLUMNS
                % having timing also added other columns related to
                % mousec click

% most symmspan columns have "symm" or "square" in them
% creates overlap with "symmpracticesquareloop..." columns
% can also include "practiceresponse" items
% and "recallloop." items (period is needed to reduce overlap)
% and requires adding: practicerecallaccuracy, loopnumber, memnumber, recallaccuracy

SymCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'symm'));
SquareCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'square'));
PRespCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceresponse'));
RecallLoopCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'recallloop.'));

% combine
SymSpanAllCols = SymCols | SquareCols | PRespCols | RecallLoopCols;
SymSpanAllData = rawdata(:,SymSpanAllCols);

% add extra columns
SymSpanAllData.("practicerecallaccuracy") = rawdata.("practicerecallaccuracy");
SymSpanAllData.("loopnumber") = rawdata.("loopnumber");
SymSpanAllData.("memnumber") = rawdata.("memnumber");
SymSpanAllData.("recallaccuracy") = rawdata.("recallaccuracy");

clear SymCols SquareCols PRespCols RecallLoopCols SymSpanAllCols

%% Separating practice from task for SymSpan

% symmetry, recall, and the full combined task have practice sections.

SymPracticeCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'practice'));
RecalLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'recallloop'));
SymetryLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'symmetryloop'));
PLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'ploop'));
SquareRespPCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'square_resp_2'));

SymSpanPCols = SymPracticeCols | RecalLoopCols | SymetryLoopCols | PLoopCols | SquareRespPCols;

clear SymPracticeCols RecalLoopCols SymetryLoopCols PLoopCols SquareRespPCols

% for the practice columns, there is data only during the practice while
% the rest is empty cells, so rows can be eliminated this way
% there are, however, many rows that are separate for each loop within a
% loop

SymPRows = ~cellfun('isempty',SymSpanAllData.("symmpracticeloop.ran"));
RecallPresPRows = ~cellfun('isempty',SymSpanAllData.("symmpracticesquareloop.ran"));
RecallRespPRows = ~cellfun('isempty',SymSpanAllData.("symmpracticerecalloop.ran"));
RecallPRows = ~cellfun('isempty',SymSpanAllData.("symmmempracticeloop.ran"));
MixSymPRows = ~cellfun('isempty',SymSpanAllData.("symmspansymmploop.ran"));
MixRecallPRows = ~cellfun('isempty',SymSpanAllData.("symmspanrecallploop.ran"));
SymSpanMixPRows = ~cellfun('isempty',SymSpanAllData.("symmspanploop.ran"));

SymSpanPRows = SymPRows | RecallPresPRows | RecallRespPRows | RecallPRows | MixSymPRows | MixRecallPRows | SymSpanMixPRows;

clear SymPRows RecallPresPRows RecallRespPRows RecallPRows MixSymPRows MixRecallPRows SymSpanMixPRows

SymSpanPData = SymSpanAllData(SymSpanPRows,:);

% need to add 'symmetrical', 'loopnumber', 'memnumber'

SymSpanPSymetrical = SymSpanPData.("symmetrical");
SymSpanPLoopNum = SymSpanPData.("loopnumber");
SymSpanPMemNum = SymSpanPData.("memnumber");

SymSpanPData = SymSpanPData(:,SymSpanPCols);

SymSpanPData.("symmetrical") = SymSpanPSymetrical;
SymSpanPData.("loopnumber") = SymSpanPLoopNum;
SymSpanPData.("memnumber") = SymSpanPMemNum;

clear SymSpanPSymetrical SymSpanPLoopNum SymSpanPMemNum SymSpanPRows

% older data should have 57 columns in practice
% newer data should have 69 columns in practice

% can use ~ to get the task data only.

SymRows = ~cellfun('isempty',SymSpanAllData.("symmspanblocksymmloop.ran"));
RecallRows = ~cellfun('isempty',SymSpanAllData.("symmspanrecallblocksloop.ran"));
SymSpanMixedRows = ~cellfun('isempty',SymSpanAllData.("symmspanblocksloop.ran"));

SymSpanRows = SymRows | RecallRows | SymSpanMixedRows;

clear SymSpanMixedRows RecallRows SymRows

SymSpanData = SymSpanAllData(SymSpanRows,~SymSpanPCols);

clear SymSpanRows SymSpanPCols

% older data should have 39 columns
% newer data should have 51 columns

%% For older data only, add in columns we need.

% could try to do a check for if the variable exists
% on it's own, strcmp isn't great because it makes a logical array checking
% every variable name.

if isempty(find(strcmp("practiceresponse.time",SymSpanPData.Properties.VariableNames),1))
    % if there are no columns with this name
    
    SymSpanPData.("practiceresponse.time") = strings(height(SymSpanPData),1);
    SymSpanPData.("square_resp_2.time") = strings(height(SymSpanPData),1);
    % create that column
end

if isempty(find(strcmp("symmresponseclick.time",SymSpanData.Properties.VariableNames),1))
    % if there are no columns with this name
    
    SymSpanData.("symmresponseclick.time") = strings(height(SymSpanData),1);
    SymSpanData.("square_resp.time") = strings(height(SymSpanData),1);
    % create that column
end

% older practice data should now have 59 columns, data should have 41

%% Rename SymSpan Columns

% next can rename columns for SymSpan data, than add in corresponding dummy
% data to a new row piece by piece, so column order will not be a problem

SymSpanPData = renamevars(SymSpanPData, ["practicepresentedsymmstim","practicesymmcorrectresponse", "practicesymmaccuracy", ...
    "practiceresponse.time","practiceresponse.clicked_name","symmpracticeloop.thisN","practicesquarecorrectresponse", ...
    "symmpracticesquareloop.thisN","practicerecallaccuracy","square_resp_2.time","square_resp_2.clicked_name","symmmempracticeloop.thisN", ...
    "memnumber","symmspansymmploop.thisN","symmspanrecallploop.thisN","symmspanploop.thisN",], ...
    ["SymSpanPSymStim","SymSpanPSymCResp","SymSpanPSymAcc","SymSpanPSymRT","SymSpanPSymResp","SymSpanPSymTrial","SymSpanPRecStim", ...
    "SymSpanPRecTrialsPerSeries", "SymSpanPRecAcc","SymSpanPRecRT","SymSpanPRecResp","SymSpanPRecSeries","SymSpanPRecSeriesCond", ...
    "SymSpanPMixPresTrialsPerSeries","SymSpanPMixRecRespTrialsPerSeries","SymSpanPMixRecRespSeries",]);

SymSpanData = renamevars(SymSpanData, ["memnumber","presentedsymmstim","symmcorrectresponse","symmresponse","symmaccuracy", ...
    "symmresponseclick.time","squarecorrectresponse","symmspanblocksymmloop.thisTrialN","recallaccuracy","square_resp.time", ...
    "square_resp.clicked_name","symmspanrecallblocksloop.thisN","symmspanblocksloop.thisN"], ...
    ["SymSpanMixSeriesCond","SymSpanMixSymStim","SymSpanMixSymCResp","SymSpanMixSymResp","SymSpanMixSymAcc","SymSpanMixSymRT", ...
    "SymSpanMixRecStim","SymSpanMixPresTrialsPerSeries","SymSpanMixRecAcc","SymSpanMixRecRT","SymSpanMixRecResp", ...
    "SymSpanMixRecTrialsPerSeries","SymSpanMixRecRespSeries"]);

        % SINGLE AND MIXED PRACTICE SECTIONS SHARE SOME COLUMNS

%% Remove extra columns from SymSpan data
% loops must be removed after renaming since some extra loop columns are
% also counters

% all the data we care about starts with "Sym*"

SymSpanPCols = ~cellfun('isempty',regexp(SymSpanPData.Properties.VariableNames,'Sym*'));

SymSpanCols = ~cellfun('isempty',regexp(SymSpanData.Properties.VariableNames,'Sym*'));

SymSpanPData = SymSpanPData(:,SymSpanPCols);
SymSpanData = SymSpanData(:,SymSpanCols);

clear SymSpanPCols SymSpanCols

% practice data should have 16 columns
% data should have 13 columns

%% Add 1 to counters for SymSpan

SymSpanPData.("SymSpanPSymTrial") = str2double(SymSpanPData.("SymSpanPSymTrial")) + 1;
SymSpanPData.("SymSpanPRecTrialsPerSeries") = str2double(SymSpanPData.("SymSpanPRecTrialsPerSeries")) + 1;
SymSpanPData.("SymSpanPRecSeries") = str2double(SymSpanPData.("SymSpanPRecSeries")) + 1;
SymSpanPData.("SymSpanPMixPresTrialsPerSeries") = str2double(SymSpanPData.("SymSpanPMixPresTrialsPerSeries")) + 1;
SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries") = str2double(SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries")) + 1;
SymSpanPData.("SymSpanPMixRecRespSeries") = str2double(SymSpanPData.("SymSpanPMixRecRespSeries")) + 1;

SymSpanData.("SymSpanMixPresTrialsPerSeries") = str2double(SymSpanData.("SymSpanMixPresTrialsPerSeries")) + 1;
SymSpanData.("SymSpanMixRecTrialsPerSeries") = str2double(SymSpanData.("SymSpanMixRecTrialsPerSeries")) + 1;
SymSpanData.("SymSpanMixRecRespSeries") = str2double(SymSpanData.("SymSpanMixRecRespSeries")) + 1;

        % looking at the data at this point, it would be good to shift the
        % reponses up for the squares so that they're in the same rows.
        % it also may be good to assign series number and condition to every row just to
        % reduce the NaNs, but how?
        % for practice, could just shift SymSpanPRecResp, SymSpanPRecAcc,
        % and SymSpanPMixRecRespTrialsPerSeries up 2 rows
        % this makes the trials per series for stimulus presentatino and
        % response redundant but that would be good for checking things
        % later.

% test1 = SymSpanPData;
% test1.("SymSpanPRecResp") = circshift(test1.("SymSpanPRecResp"),[-2 0]);
% this works but doesn't account for the extra columns between responses
% from SymSpanPRecSeries

%% Assign Series Numbers and Conditions to All related rows

% need to identify the currently filled rows that are otherwise empty for
% removal later
% SymSpanPRecSeriesCond applies to all practices
% SymPSeriesRows = cellfun('isempty',SymSpanPData.("SymSpanPRecSeriesCond"));
% Need to remove more rows than this

% for all NaN rows for SymSpanPRecSeries (except the first ten rows from
% the symmetry practice).
% Assign the first encountered number down the rows to all previous rows...

% except this column is for the recall practice only, so need to stop this
% after the last number of SymSpanPRecSeries

% for precseriesidx = 11:(find(~isnan(SymSpanPData.("SymSpanPRecSeries")),1,'last'))
    % for those rows that are part of recall series
   % if isnan(SymSpanPData.("SymSpanPRecSeries")(precseriesidx))
        % if there is no number
        % find the next number in SymSpanPRecSeries
        
  %  end
%end

% test.("SymSpanPRecSeries") = fillmissing(test.("SymSpanPRecSeries"),'nearest');
% this works, just need to leave the non-series rows NaN

% can't use fill missing on one row at a time in a loop
MinPRecSeriesRow = find(~isnan(SymSpanPData.("SymSpanPRecTrialsPerSeries")),1,'first');
MaxPRecSeriesRow = find(~isnan(SymSpanPData.("SymSpanPRecSeries")),1,'last');

SymSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow) = fillmissing( ...
    SymSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow),'next');

% same thing for SymSpanPRecSeriesCond
MaxPCondRow = find(~cellfun('isempty',SymSpanPData.("SymSpanPRecSeriesCond")),1,'last');

SymSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow) = fillmissing( ...
    SymSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow),'next');

% same thing for SymSpanPMixRecRespSeries
MaxPMixSeriesRow = find(~isnan(SymSpanPData.("SymSpanPMixRecRespSeries")),1,'last');
% may be the same as max p cond row but doing this just in case

SymSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow) = fillmissing( ...
    SymSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow),'next');

clear MinPRecSeriesRow MaxPRecSeriesRow MaxPCondRow MaxPMixSeriesRow 

% Non-Practice doesn't have so many extra parts since it's just the mixed

SymSpanData.("SymSpanMixRecRespSeries") = fillmissing(SymSpanData.("SymSpanMixRecRespSeries"),'next');
SymSpanData.("SymSpanMixSeriesCond") = fillmissing(SymSpanData.("SymSpanMixSeriesCond"),'next');

%% Redefine Condition Number to Move Presentation and Response Data Into the Same Rows
% still can't just move other columns up because spacing differs between
% stimulus and response. Could use series condition number to find out how
% many rows to move up some values
% but need to convert these to numbers

SymSpanPData.("SymSpanPRecSeriesCond") = str2double(SymSpanPData.("SymSpanPRecSeriesCond"));

% for rows with data for SymSpanPRecResp (and SymSpanPRecAcc)
for SymPRespRow = 1:height(SymSpanPData)
    if ~cellfun('isempty',SymSpanPData.("SymSpanPRecResp")(SymPRespRow))
        % find the SymSpanPRecSeriesCond number
        PRowsUp = SymSpanPData.("SymSpanPRecSeriesCond")(SymPRespRow);
        SymSpanPData.("SymSpanPRecResp")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPRecResp")(SymPRespRow);
        SymSpanPData.("SymSpanPRecAcc")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPRecAcc")(SymPRespRow);
        SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries")(SymPRespRow);
    end
end

% move things up the number of rows corresponding to SymSpanPRecSeriesCond number
% test1.("SymSpanPRecResp") = circshift(test1.("SymSpanPRecResp"),[-2 0]);
% this only works when shifting the full row or column
% assign the value two cells up instead

clear SymPRespRow PRowsUp

% then for actual data

SymSpanData.("SymSpanMixSeriesCond") = str2double(SymSpanData.("SymSpanMixSeriesCond"));

for SymRespRow = 1:height(SymSpanData)
    if ~cellfun('isempty',SymSpanData.("SymSpanMixRecResp")(SymRespRow))
        RowsUp = SymSpanData.("SymSpanMixSeriesCond")(SymRespRow);
        SymSpanData.("SymSpanMixRecResp")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecResp")(SymRespRow);
        SymSpanData.("SymSpanMixRecAcc")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecAcc")(SymRespRow);
        SymSpanData.("SymSpanMixRecTrialsPerSeries")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecTrialsPerSeries")(SymRespRow);
    end
end

clear SymRespRow RowsUp

%% Remove extra rows

% then combine when SymSpanPSymStim and SymSpanPRecStim are empty
PSymStimRows = ~cellfun('isempty',SymSpanPData.("SymSpanPSymStim"));
PRecStimPRows = ~cellfun('isempty',SymSpanPData.("SymSpanPRecStim"));

SymPRows = PSymStimRows | PRecStimPRows;

SymSpanPData = SymSpanPData(SymPRows,:);

clear PSymStimRows PRecStimPRows SymPRows

% could probably just combine the presentation and response number columns
% but maybe there's a way these might not be equal. 
% coudl also combine response series columns but want the recall practice
% and mix practice to  be separate 


% combine when SymSpamMixSymStim and SymSpanMixRecStim are empty
SymStimRows = ~cellfun('isempty',SymSpanData.("SymSpanMixSymStim"));
RecStimRows = ~cellfun('isempty',SymSpanData.("SymSpanMixRecStim"));

SymRows = SymStimRows | RecStimRows;

SymSpanData = SymSpanData(SymRows,:);

clear SymStimRows RecStimRows SymRows

%% N-Back Practice
fprintf('Processing NBack data\n')
% 1 back
% presp_1back.keys, presp_1back.corr, practice1backloop.thisRepN, practice1backloop.thisTrialN, 
% practice1backloop.thisN, practice1backloop.thisIndex, practice1backloop.ran, letter, presp_1back.rt
% 2 back
% presp_2back.keys, presp_2back.corr, practice2backloop.thisRepN, practice2backloop.thisTrialN, 
% practice2backloop.thisN, practice2backloop.thisIndex, practice2backloop.ran, presp_2back.rt, 
%% N-Back Stimuli
% 1 back
% trialletter1back (letter presented)
% Dummmy
% dummyletter1back, resp_dummy1back.keys, resp_dummy1back.corr, dummy1backloop.thisRepN, 
% dummy1backloop.thisTrialN, dummy1backloop.thisN, dummy1backloop.thisIndex, dummy1backloop.ran
% 2 back
% trialletter2back (letter presented)
% Dummy
% dummyletter2back, resp_dummy2back.keys, resp_dummy2back.corr, dummy2backloop.thisRepN, 
% dummy2backloop.thisTrialN, dummy2backloop.thisN, dummy2backloop.thisIndex, dummy2backloop.ran
%% N-Back Scoring
% target (for both conditions, 0 = not a target, 1 = target letter matching
% the letter 1 or 2 back).
% 1 back
% resp_1back.keys (key pressed)
% resp_1back.corr (1 = correct, 0 = not correct)
% resp_1back.rt (time of key press since trial start)
% trials_1backloop.thisTrialN, trials_1backloop.thisN (trial number
% starting from 0)
% Remove: trials_1backloop.thisRepN, trials_1backloop.thisIndex, trials_1backloop.ran
% 2 back
% resp_2back.keys (key pressed)
% resp_2back.corr (1 = correct, 0 = not correct)
% resp_2back.rt (time of key press since trial start)
% trials_2backloop.thisTrialN, trials_2backloop.thisN (trial number
% starting from 0)
% Remove: trials_2backloop.thisRepN, trials_2backloop.thisIndex, trials_2backloop.ran
%% N-Back Excess
% nbacktask.thisRepN, nbacktask.thisTrialN, nbacktask.thisN, nbacktask.thisIndex, nbacktask.ran

%% Create separate tables for tasks NBack

% Most NBack columns should have the word 'back' in them except

NBackCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'back'));
NBackAllData = rawdata(:,rawdata.Properties.VariableNames(NBackCols));

% add columns for 'letter' and 'target'

NBackAllData.("letter") = rawdata.("letter");
NBackAllData.("target") = rawdata.("target");
% adds the extra column to the end.

clear NBackCols

%% Separating practice from task for NBack

% for the practice columns, there is data only during the practice while
% the rest is NaN
% so if I select only those rows where the practice section is not NaN I
% can keep just the rows that matter from the extra columns

% practices do not have dummys
% 'letter' corresponds to the letters in only the practice sections so can
% just select based on that

NBackPRows = ~cellfun('isempty',NBackAllData.("letter"));
NBackPData = NBackAllData(NBackPRows,:);

NBackPData(:,all(ismissing(NBackPData))) = [];
% clears all full empty oclumns so no extra columns in the practice.

clear NBackPRows

% Actual task data has two dummy rows before the 1-back and 2-back tasks
% could I just get not the columns in the practice data?
% Can't find a good way to do this.

NBackPCols1 = ~cellfun('isempty', regexp(NBackAllData.Properties.VariableNames, 'practice'));
NBackPCols2 = ~cellfun('isempty', regexp(NBackAllData.Properties.VariableNames, 'presp'));

NBackPCols = NBackPCols1 | NBackPCols2;

% combine rows where dummy1backloop.ran, dummy2backloop.ran, and target are
% empty

NBackDummy1Rows = ~cellfun('isempty',NBackAllData.("dummy1backloop.ran"));
NBackDummy2Rows = ~cellfun('isempty',NBackAllData.("dummy2backloop.ran"));
NBackTargetRows = ~cellfun('isempty',NBackAllData.("target"));

NBackRows = NBackDummy1Rows | NBackDummy2Rows | NBackTargetRows;

NBackData = NBackAllData(NBackRows,~NBackPCols);

% Can't just remove all empty variables because they should not respond to
% the dummys but might

% Practice should have 17 columns, actual should have 41 columns

clear NBackPCols* NBackDummy1Rows NBackDummy2Rows NBackTargetRows NBackRows

%% Remove more extra columns for NBack

NBackPData = NBackPData(:,~ismember(NBackPData.Properties.VariableNames,["practice1backloop.thisRepN", ...
    "practice1backloop.thisN", "practice1backloop.thisIndex","practice1backloop.ran", "practice2backloop.thisRepN", ...
    "practice2backloop.thisN","practice2backloop.thisIndex","practice2backloop.ran",]));

NBackData = NBackData(:,~ismember(NBackData.Properties.VariableNames,["letter","dummy1backloop.thisTrialN", ...
    "dummy1backloop.thisN","dummy1backloop.thisIndex","dummy1backloop.ran","trials_1backloop.thisRepN", ...
    "trials_1backloop.thisN","trials_1backloop.thisIndex","trials_1backloop.ran","dummy2backloop.thisTrialN", ...
    "dummy2backloop.thisN","dummy2backloop.thisIndex","dummy2backloop.ran","trials_2backloop.thisRepN","trials_2backloop.thisN", ...
    "trials_2backloop.thisIndex","trials_2backloop.ran","nbacktask.thisRepN","nbacktask.thisTrialN","nbacktask.thisN", ...
    "nbacktask.thisIndex","nbacktask.ran"]));

% wild card didn't work here

% 9 columns in practice, 20 columns in actual data. (number of columns in each data set

%% Add to counters for NBack

% add 1 to practice counters: practice1backloop.thisTrialN, practice2backloop.thisTrialN
% add 1 to dummy counters: dummy1backloop.thisTrialN, dummy2backloop.thisTrialN
% add 3 to non-dummy actual task counters: trials_1backloop.thisTrialN, trials_2backloop.thisTrialN

NBackPData.("practice1backloop.thisTrialN") = str2double(NBackPData.("practice1backloop.thisTrialN")) + 1;
NBackPData.("practice2backloop.thisTrialN") = str2double(NBackPData.("practice2backloop.thisTrialN")) + 1;

NBackData.("dummy1backloop.thisRepN") = str2double(NBackData.("dummy1backloop.thisRepN")) + 1;
NBackData.("dummy2backloop.thisRepN") = str2double(NBackData.("dummy2backloop.thisRepN")) + 1;

NBackData.("trials_1backloop.thisTrialN") = str2double(NBackData.("trials_1backloop.thisTrialN")) + 3;
NBackData.("trials_2backloop.thisTrialN") = str2double(NBackData.("trials_2backloop.thisTrialN")) + 3;

%% Separate NBack dummy
           
                    % DUMMY DATA IS BEING INCLUDED TO DO CHECKS IN CASE THE
                    % FIRST STIMULUS IS A TARGET
                    % Target may be indicated in a different column but
                    % want to check if scoring is accurate.

% identify dummy columns
% practice has no dummys
% dummys are also their own rows
% could have done this earlier when selecting task data but had to move
% things around anyway.
NBackDummyRows1 = ~isnan(NBackData.("dummy1backloop.thisRepN"));
NBackDummyRows2 = ~isnan(NBackData.("dummy2backloop.thisRepN"));

NBackDummyRows = NBackDummyRows1 | NBackDummyRows2;

NBackDummyCols = ~cellfun('isempty',regexp(NBackData.Properties.VariableNames,'dummy'));

NBackDummy1Data = NBackData(NBackDummyRows1,:);
NBackDummy2Data = NBackData(NBackDummyRows2,:);
NBackData = NBackData(~NBackDummyRows,~NBackDummyCols);

NBackDummyData = [NBackDummy1Data; NBackDummy2Data];
NBackDummyData = NBackDummyData(:,NBackDummyCols);

clear NBackDummyRows1 NBackDummyRows2 NBackDummyCols NBackDummyRows NBackDummy1Data NBackDummy2Data

% now dummy data should have 8 columns and actual data should have 11

%% Rename NBack Columns

% next can rename columns, than add in corresponding dummy
% data to a new row piece by piece, so column order will not be a problem

NBackPData = renamevars(NBackPData, ["presp_1back.keys","presp_1back.corr","practice1backloop.thisTrialN", ...
    "letter","presp_1back.rt","presp_2back.keys","presp_2back.corr","practice2backloop.thisTrialN","presp_2back.rt"], ...
    ["NBack1PResp","NBack1PAcc","NBack1PTrial","NBackPStim","NBack1PRT","NBack2PResp","NBack2PAcc","NBack2PTrial","NBack2PRT"]);

NBackData = renamevars(NBackData, ["trialletter1back","resp_1back.keys","resp_1back.corr","resp_1back.rt", ...
    "trials_1backloop.thisTrialN","trialletter2back","resp_2back.keys","resp_2back.corr","trials_2backloop.thisTrialN", ...
    "resp_2back.rt","target"], ...
    ["NBack1Stim","NBack1Resp","NBack1Acc","NBack1RT","NBack1Trial","NBack2Stim","NBack2Resp","NBack2Acc","NBack2Trial", ...
    "NBack2RT","Target"]);

%% Add Dummies to nback data

NBackDummyRow = NBackData(1:4,:);

NBackDummyRow.("NBack1Stim") = NBackDummyData.("dummyletter1back");
NBackDummyRow.("NBack1Resp") = NBackDummyData.("resp_dummy1back.keys");
NBackDummyRow.("NBack1Acc") = NBackDummyData.("resp_dummy1back.corr");
NBackDummyRow.("NBack1RT") = ["";"";"";""];
NBackDummyRow.("NBack1Trial") = NBackDummyData.("dummy1backloop.thisRepN");

NBackDummyRow.("NBack2Stim") = NBackDummyData.("dummyletter2back");
NBackDummyRow.("NBack2Resp") = NBackDummyData.("resp_dummy2back.keys");
NBackDummyRow.("NBack2Acc") = NBackDummyData.("resp_dummy2back.corr");
NBackDummyRow.("NBack2RT") = ["";"";"";""];
NBackDummyRow.("NBack2Trial") = NBackDummyData.("dummy2backloop.thisRepN");
NBackDummyRow.("Target") = ["D";"D";"D";"D"];

NBackData = [NBackData ; NBackDummyRow];

            % NBACK DUMMYS MAY BE SCORED AS 0 (INCORRECT) DESPITE BEING
            % CORRECT

clear NBackDummyRow NBackDummyData


            % REMEMBER - WITH DUMMY ROWS AT THE BOTTOM OF THE TABLE, ANY
            % SCORING CONDITIONAL ON DUMMYS OR ON PREVIOUS TRIALS MUST
            % REFER TO TRIAL NUMBER, NOT JUST TO THE PREVIOUS ROW

%% Centering n-back practice reaction times

% for 1-back prctice, response is available at the start of the routine
% (time 0); however the stimulus iof interest isn't presented until 0.5
% seconds.
% so need rt - 0.5; if rt is negative, they responded too early, if rt is
% positive, they responded after the stimulus was presented

NBackPData.("NBack1PRT") = str2double(NBackPData.("NBack1PRT")) - 0.5;

% however, during the actual 1-back, stimulus and response are available
% from the start of the routine so no correction needed.
% This would mean that if there were any anticipatory responses they would
% technically be from the trial before; however, repeated responses are not
% being recorded.

% 2-back practice is like 1-back practice

NBackPData.("NBack2PRT") = str2double(NBackPData.("NBack2PRT")) - 0.5;

% 2-back actual task is like 1-back actual task



%% MCT Instructions
fprintf('Processing MCT data\n')
%  onoff_resp_instructions_2.keys	onoff_resp_instructions_2.rt, aware_resp_instructions_2.keys,
% aware_resp_instructions_2.rt, intent_response_instructions_2.keys, intent_response_instructions_2.rt
% (responding to probe questions in instructions)
%% MCT Practice
% tone_practicetrial_resp.keys (key pressed)
% tone_practicetrial_resp.rt, and practiceloop.thisN (time of key press relative to the start of the trial)
% practiceloop.thisRepN, and practiceloop.thisIndex (both 0 for the practice)
% practiceloop.ran (always 1)
% Thought Probe: probetype (number used to indicate what the probe intro says)
% (probe type also applies to the actual trials) 
% probe_resp_practice_2.keys, probe_resp_practice_2.rt, onoff_resp_2.keys,
% onoff_resp_2.rt, aware_resp_2.keys, aware_resp_2.rt, intent_response_3.keys, intent_response_3.rt
% Thought probe logic loop: ifnoprobepracticeloop.thisRepN, ifnoprobepracticeloop.thisTrialN, 
% ifnoprobepracticeloop.thisN, ifnoprobepracticeloop.thisIndex, ifnoprobepracticeloop.ran
%% MCT Stimuli
% tone_number (beat number starting from 1; also part of practice)
% tone_trial_resp.keys (key pressed)
% tone_trial_resp.rt (time of key press relative to trial start)
% toneloop1.thisRepN, and toneloop1.thisN (beat number)
% toneloop1.thisTrialN, and toneloop1.thisIndex (all 0)
% toneloop1.ran (always 1)
% NOTE: trials and thought probes are misaligned such that tone_trial columns and thought probe
% columns are in the same row,  but toneloop columns are on the next row down
% tone loop columns also have no tone_number
% e.g., down 1.13 [] [] [] [] [] right 12.56...
%       []    []  300 0 300 0 1   []    []  ...
% will need to find an efficient way of combineing these rows.
%% MCT "Scoring"
% tone_number (tone number from 1 to 25 max).
% probe_resp.keys (key pressed for probe intro screen)
% probe_resp.rt (time responded to probe intro screen relative to trial start)
% onoff_resp.keys (key pressed for on off question)
% onoff_resp.rt (time responded to on off question relative to trial start)
% aware_resp.keys (key pressed for aware question)
% aware_resp.rt (time responded to aware question relative to trial start)
% intent_response.keys (key pressed for intention question)
% intent_response.rt (time responded to intention question relative to trial start)
% probeloop1.thisRepN, probeloop1.thisTrialN, probeloop1.thisN, 
% probeloop1.thisIndex, probeloop1.ran (all dummies)
% one of the probe loop numbers should be probe number starting at 0
% however current example data only has one probe
%% MCT Excess
% MCTBeatResponse (doesn't actually store anything),

%% Create Separate Table for MCT

% MCT can select with tone, probe, onoff, aware, intent
% this leaves practiceloop but other tasks have this phrase in column names
% and I'm not sure how to make it look for practiceloop* exactly

ToneCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'tone'));
ProbeCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'probe'));
OnOffCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'onoff'));
AwareCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'aware'));
IntentCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'intent'));

% combine

MCTCols = ToneCols | ProbeCols | OnOffCols | AwareCols | IntentCols;
MCTAllData = rawdata(:,rawdata.Properties.VariableNames(MCTCols));

clear *Cols

% add extra columns
MCTAllData.("practiceloop.thisRepN") = rawdata.("practiceloop.thisRepN");
MCTAllData.("practiceloop.thisTrialN") = rawdata.("practiceloop.thisTrialN");
MCTAllData.("practiceloop.thisN") = rawdata.("practiceloop.thisN");
MCTAllData.("practiceloop.thisIndex") = rawdata.("practiceloop.thisIndex");
MCTAllData.("practiceloop.ran") = rawdata.("practiceloop.ran");

%% Separate practice from task for MCT and remove some extra columns and rows

MCTPToneRows = ~cellfun('isempty',MCTAllData.("practiceloop.ran"));
% but need to include the probe row too.
% and which columns are present depends on if they make an error during the
% practice
if isempty(find(strcmp("ifnoprobepracticeloop.ran",MCTAllData.Properties.VariableNames),1))
    % if there are no columns with this name
    MCTPProbeRow = ~cellfun('isempty',MCTAllData.("practiceprobeloop.ran"));
else
    MCTPProbeRow = ~cellfun('isempty',MCTAllData.("ifnoprobepracticeloop.ran"));
end
% could probably nest this to rename the practice probe columns, but that
% would break the pattern of organization here.

MCTPRows = MCTPToneRows | MCTPProbeRow;

MCTPData = MCTAllData(MCTPRows,:);


MCTPData(:,all(ismissing(MCTPData))) = [];
% clears all full empty columns so no extra columns in the practice.

clear MCTPRows MCTPProbeRow MCTPToneRows

% actual task
MCTToneRows = ~cellfun('isempty',MCTAllData.("toneloop1.ran"));
MCTProbeRows = ~cellfun('isempty',MCTAllData.("probeloop1.ran"));

MCTRows = MCTToneRows | MCTProbeRows;

% can't just clear all empty columns if the participant got no probes.
% can grab practice only columns with 'practice', 'resp_', 'response_'

PracticeCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'practice'));
PRespCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'resp_'));
PResponseCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'response_'));
ProbeLoopCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'probeloop1'));

ExtraMCTCols = PracticeCols | PRespCols | PResponseCols | ProbeLoopCols;

MCTData = MCTAllData(MCTRows,~ExtraMCTCols);

clear *Rows *Cols

% practice should have 29 columns, some of which need to be removed
% actual data should have 17 columns.

%% Rename columns for MCT

if isempty(find(strcmp("ifnoprobepracticeloop.ran",MCTPData.Properties.VariableNames),1))
    % if there are no columns with this name
    % then they had a probe during practice
    MCTPData = renamevars(MCTPData, ["probe_resp_practice.keys","probe_resp_practice.rt", ...
        "onoff_resp_2.keys","onoff_resp_2.rt","aware_resp_2.keys","aware_resp_2.rt", ...
        "intent_response_2.keys","intent_response_2.rt"], ...
    ["MCTPProbeIntroResp","MCTPProbeIntroRT","MCTPProbeOnOffResp","MCTPProbeOnOffRT", ...
    "MCTPProbeAwareResp","MCTPProbeAwareRT","MCTPProbeIntentResp","MCTPProbeIntentRT"]);
else
    MCTPData = renamevars(MCTPData, ["probe_resp_practice_2.keys","probe_resp_practice_2.rt", ...
        "onoff_resp_2.keys","onoff_resp_2.rt","aware_resp_2.keys","aware_resp_2.rt", ...
        "intent_response_3.keys","intent_response_3.rt"], ...
    ["MCTPProbeIntroResp","MCTPProbeIntroRT","MCTPProbeOnOffResp","MCTPProbeOnOffRT", ...
    "MCTPProbeAwareResp","MCTPProbeAwareRT","MCTPProbeIntentResp","MCTPProbeIntentRT"]);
end

MCTPData = renamevars(MCTPData, ["tone_number","tone_practicetrial_resp.keys", ...
    "tone_practicetrial_resp.rt","practiceloop.thisRepN","probetype","onoff_resp_instructions_2.keys", ...
    "onoff_resp_instructions_2.rt","aware_resp_instructions_2.keys","aware_resp_instructions_2.rt", ...
    "intent_response_instructions_2.keys", "intent_response_instructions_2.rt"], ...
    ["MCTPToneNum","MCTPResp","MCTPRT","MCTPTrial","MCTPProbeType","MCTInstProbeOnOffResp", ...
    "MCTInstProbeOnOffRT", "MCTInstProbeAwareResp","MCTInstProbeAwareRT", ...
    "MCTInstProbeIntentResp","MCTInstProbeIntentRT"]);

MCTData = renamevars(MCTData, ["tone_number","tone_trial_resp.keys","tone_trial_resp.rt","" + ...
    "toneloop1.thisRepN","probetype","probe_resp.keys","probe_resp.rt","onoff_resp.keys", ...
    "onoff_resp.rt","aware_resp.keys","aware_resp.rt","intent_response.keys","intent_response.rt"], ...
    ["MCTToneNum","MCTResp","MCTRT","MCTTrial","MCTProbeType","MCTProbeIntroResp", ...
    "MCTProbeIntroRT","MCTProbeOnOffResp","MCTProbeOnOffRT","MCTProbeAwareResp", ...
    "MCTProbeAwareRT","MCTProbeIntentResp","MCTProbeIntentRT"]);


%% Remove additional extra columns for MCT

% just removing anything with 'loop' still in the name

MCTPLoopCols = ~cellfun('isempty',regexp(MCTPData.Properties.VariableNames,'loop'));
MCTLoopCols = ~cellfun('isempty',regexp(MCTData.Properties.VariableNames,'loop'));

MCTPData = MCTPData(:,~MCTPLoopCols);
MCTData = MCTData(:,~MCTLoopCols);

clear *LoopCols

% Practice should have 19 columns
% Practice should have 13 columns

%% re-align trials with thought probes in practice

% could use tone_number to find the rows that need shifting up or down.
% when tone_number is empty, need to shift toneloop1 columns up to match
% the row above the  empty cell...
% for practice, should only do this when they hit a probe, and not do this
% for the practice probe for those that don't make errors.

% in practice data after clearing all extra rows and columns so far
% the probe is in the same row as the corresponding MCTPToneNum, MCTPResp,
% MCTPRT, and MCTProbeType
% but MCTPTrial is misaligned

% THIS LOOP ISN'T WORKING FOR SOME REASON, EVEN THOUGH THE
% PROBE TYPE IS 0 IT'S STILL MOVING THE VALUES OF TRIAL UP AND
% WRITING 'ERASE' IN 

%for MCTPRNum = 1:(height(MCTPData))
    % going through row by row
    % can't just do number of rows here though because that changes...
    %if ~(str2double(MCTPData.("MCTPProbeType")(MCTPRNum)) == 0)
        % ismember(MCTPData.("MCTPProbeType")(MCTPRNum), '0')
        % if it is a practice probe for those who don't make mistakes, move
        % on.
        % if they got a probe for making a mistake
        % move the next value of MCTPTrial up to the same row, and delete
        % the row that contained the MCTPTrial originally
        %test = 'true';
        %test1 = 'true';
        %test3.("MCTPTrial")(MCTPRNum) = MCTPData.("MCTPTrial")(MCTPRNum +1);
        %test3.("MCTPTrial")(MCTPRNum +1) = {'erase'};
    %else
        %test = 'false';
        %test1 = 'still false';
        %test3.("MCTPTrial")(MCTPRNum) = MCTPData.("MCTPTrial")(MCTPRNum);
    %end
%end

%clear MCTPRNum

% THIS LOOP SEEMS TO WORK FOR SOME REASON

if isempty(find((ismember(MCTPData.("MCTPProbeType"), '0')),1))
    % if there is no practice probe in the data
    MCTPProbeRows = find(~cellfun('isempty',MCTPData.("MCTPProbeType")));
    for MCTPProbeRIdx = 1:height(MCTPProbeRows)
        MCTPProbeRowNum = MCTProbeRows(MCTPProbeRIdx);
        % not sure if this will be 'height' or not
        MCTPData.("MCTPTrial")(MCTPProbeRowNum) = MCTPData.("MCTPTrial")(MCTPProbeRowNum +1);
        MCTPData.("MCTPTrial")(MCTPProbeRowNum +1) = {'erase'};
    end
end

clear MCTPProbeRows MCTPProbeRIdx MCTPProbeRowNum

% check if there are probes in the data
if ~isempty(MCTData.("MCTProbeType"))
    MCTProbeRows = find(~cellfun('isempty',MCTData.("MCTProbeType")));
    for MCTProbeRIdx = 1:height(MCTProbeRows)
        MCTProbeRowNum = MCTProbeRows(MCTProbeRIdx);
        MCTData.("MCTTrial")(MCTProbeRowNum) = MCTData.("MCTTrial")(MCTProbeRowNum + 1);
        MCTData.("MCTTrial")(MCTProbeRowNum + 1) = {'erase'};
    end

end

clear MCTProbeRows MCTProbeRIdx MCTProbeRowNum

%% Remove extra rows from trial number

MCTPEraseRows = strcmp('erase',MCTPData.("MCTPTrial"));
MCTPData = MCTPData(~MCTPEraseRows,:);

MCTEraseRows = strcmp('erase',MCTData.("MCTTrial"));
MCTData = MCTData(~MCTEraseRows,:);

clear MCTPEraseRows MCTEraseRows


%% Add to counters for MCT

MCTPData.("MCTPTrial") = str2double(MCTPData.("MCTPTrial")) + 1;
MCTData.("MCTTrial") = str2double(MCTData.("MCTTrial")) + 1;

%% Relabel Probe and Response Types

% the following didn't work
% test = strrep(MCTData.("MCTProbeType"),'1','miscount');
% strrep(str,old,new) 

% X.fruit = categorical(X.fruit);
% X.fruit = renamecats(X.fruit,{'apple','orange','grapes'},{'1','2','3'});

%test1 = MCTPData;
%test1.("MCTPProbeType") = categorical(MCTPData.("MCTPProbeType"));
%test1 = renamecats(test1.("MCTPProbeType"),{'0','1','2','3'},{'NoErrorP','Miscount','LostCount','Timeout'});
% get error where oldnames need to  be a subset of categories. makes blanks
% into 'undefined' category too

% looping works
for PProbeRowIdx = 1:height(MCTPData)
    if contains(MCTPData.("MCTPProbeType"){PProbeRowIdx},'0')
        MCTPData.("MCTPProbeType"){PProbeRowIdx} = 'NoErrorP';

        if contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'left') || contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'right')
            % if it was the no error probe, then their response should just
            % be 'continue' with 'left' or 'right', but in case they misread...
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Continue';
        else
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ContinuedWrongKey';
            % just so I can check if someone isn't reading or pressing
            % 'down' lingered for them
        end

    elseif contains(MCTPData.("MCTPProbeType"){PProbeRowIdx},'1')
        MCTPData.("MCTPProbeType"){PProbeRowIdx} = 'Miscount';

        % if they miscounted, left, right, and down are all options.
        if contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'left')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Accident';
            % accidental key press
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'right')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ThoughtCorrect';
            % thought they were counting correctly
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'down')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Continue';
        end


    elseif contains(MCTPData.("MCTPProbeType"){PProbeRowIdx},'2')
        MCTPData.("MCTPProbeType"){PProbeRowIdx} = 'LostCount';
        
        % if they lost count, left and down are the only options presented
        if contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'left')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Accident';
            % accidental key press
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'right')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ContinuedWrongKey';
            % thought they were counting correctly
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'down')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Continue';
        end

    elseif contains(MCTPData.("MCTPProbeType"){PProbeRowIdx},'3')
        MCTPData.("MCTPProbeType"){PProbeRowIdx} = 'Timeout';
        
        % if they timed out, right and down are the only options presented
        if contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'left')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ContinuedWrongKey';
            % accidental key press
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'right')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ThoughtCorrect';
            % thought they were counting correctly
        elseif contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'down')
            MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Continue';
        end
    end

    % regardless of the probe type the other responses are consistent
    if contains(MCTPData.("MCTPProbeOnOffResp"){PProbeRowIdx},'left')
        MCTPData.("MCTPProbeOnOffResp"){PProbeRowIdx} = 'OnTask';
    elseif contains(MCTPData.("MCTPProbeOnOffResp"){PProbeRowIdx},'right')
        MCTPData.("MCTPProbeOnOffResp"){PProbeRowIdx} = 'MW';
    end
    if contains(MCTPData.("MCTPProbeAwareResp"){PProbeRowIdx},'left')
        MCTPData.("MCTPProbeAwareResp"){PProbeRowIdx} = 'Unaware';
    elseif contains(MCTPData.("MCTPProbeAwareResp"){PProbeRowIdx},'right')
        MCTPData.("MCTPProbeAwareResp"){PProbeRowIdx} = 'Aware';
    end
    if contains(MCTPData.("MCTPProbeIntentResp"){PProbeRowIdx},'left')
        MCTPData.("MCTPProbeIntentResp"){PProbeRowIdx} = 'Intentional';
    elseif contains(MCTPData.("MCTPProbeIntentResp"){PProbeRowIdx},'right')
        MCTPData.("MCTPProbeIntentResp"){PProbeRowIdx} = 'Unintentional';
    end
end


for ProbeRowIdx = 1:height(MCTData)
    if contains(MCTData.("MCTProbeType"){ProbeRowIdx},'1')
        MCTData.("MCTProbeType"){ProbeRowIdx} = 'Miscount';

        % if they miscounted, left, right, and down are all options.
        if contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'left')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'Accident';
            % accidental key press
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'right')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'ThoughtCorrect';
            % thought they were counting correctly
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'down')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'Continue';
        end


    elseif contains(MCTData.("MCTProbeType"){ProbeRowIdx},'2')
        MCTData.("MCTProbeType"){ProbeRowIdx} = 'LostCount';
        
        % if they lost count, left and down are the only options presented
        if contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'left')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'Accident';
            % accidental key press
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'right')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'ContinuedWrongKey';
            % thought they were counting correctly
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'down')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'Continue';
        end

    elseif contains(MCTData.("MCTProbeType"){ProbeRowIdx},'3')
        MCTData.("MCTProbeType"){ProbeRowIdx} = 'Timeout';
        
        % if they timed out, right and down are the only options presented
        if contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'left')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'ContinuedWrongKey';
            % accidental key press
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'right')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'ThoughtCorrect';
            % thought they were counting correctly
        elseif contains(MCTData.("MCTProbeIntroResp"){ProbeRowIdx},'down')
            MCTData.("MCTProbeIntroResp"){ProbeRowIdx} = 'Continue';
        end
    end

    % regardless of the probe type the other responses are consistent
    if contains(MCTData.("MCTProbeOnOffResp"){ProbeRowIdx},'left')
        MCTData.("MCTProbeOnOffResp"){ProbeRowIdx} = 'OnTask';
    elseif contains(MCTData.("MCTProbeOnOffResp"){ProbeRowIdx},'right')
        MCTData.("MCTProbeOnOffResp"){ProbeRowIdx} = 'MW';
    end
    if contains(MCTData.("MCTProbeAwareResp"){ProbeRowIdx},'left')
        MCTData.("MCTProbeAwareResp"){ProbeRowIdx} = 'Unaware';
    elseif contains(MCTData.("MCTProbeAwareResp"){ProbeRowIdx},'right')
        MCTData.("MCTProbeAwareResp"){ProbeRowIdx} = 'Aware';
    end
    if contains(MCTData.("MCTProbeIntentResp"){ProbeRowIdx},'left')
        MCTData.("MCTProbeIntentResp"){ProbeRowIdx} = 'Intentional';
    elseif contains(MCTData.("MCTProbeIntentResp"){ProbeRowIdx},'right')
        MCTData.("MCTProbeIntentResp"){ProbeRowIdx} = 'Unintentional';
    end
end
% and then I found out if I used {} instead of () I wouldn't have gotten
% the error for using == with type 'cell'
% except there are still errors when the comparison value isn't a number in
% quotes I guess.

clear *Idx

%% Add reaction time relative to stimulus onset to MCT

MCTPData.("MCTPRTDiff") = str2double(MCTPData.("MCTPRT")) - 0.75;

MCTData.("MCTRTDiff") = str2double(MCTData.("MCTRT")) - 0.75;



%% Save output for checking
fprintf('Saving processed data\n')

% could just do scoring immediately, but just in case, I'm going to save
% the separate files for each task.
% FileID = strcat(ID, "_", Date, "_", expName);
% could loop this but not going to for now.

SARTFileID = strcat(ID,"_SART.csv");
SwitchFileID = strcat(ID,"_Switch.csv");
SymSpanFileID = strcat(ID,"_SymSpan.csv");
NBackFileID = strcat(ID,"_NBack.csv");
MCTFileID = strcat(ID,"_MCT.csv");

SARTPFileID = strcat(ID,"_SARTP.csv");
SwitchPFileID = strcat(ID,"_SwitchP.csv");
SymSpanPFileID = strcat(ID,"_SymSpanP.csv");
NBackPFileID = strcat(ID,"_NBackP.csv");
MCTPFileID = strcat(ID,"_MCTP.csv");

writetable(SARTData, strcat(cleaneddatadir,SARTFileID));
writetable(SwitchData,strcat(cleaneddatadir,SwitchFileID));
writetable(SymSpanData,strcat(cleaneddatadir,SymSpanFileID));
writetable(NBackData,strcat(cleaneddatadir,NBackFileID));
writetable(MCTData,strcat(cleaneddatadir,MCTFileID));

writetable(SARTPData, strcat(cleanedpdatadir,SARTPFileID));
writetable(SwitchPData, strcat(cleanedpdatadir,SwitchPFileID));
writetable(SymSpanPData, strcat(cleanedpdatadir,SymSpanPFileID));
writetable(NBackPData, strcat(cleanedpdatadir,NBackPFileID));
writetable(MCTPData, strcat(cleanedpdatadir,MCTPFileID));

clear *FileID *AllData

%% SCORING NOTES

% may want to 'score' practice and actual for later checking.
% the accuracy indicators from psychopy may not always be consistent.

%% Scoring SART
% difference between correct response to non-targets (hit) and falsely responding
% to 3 (false alarm)
% if hit rate or false alarm rate are 0 or 1, adjust by 0.01

% so need to find:
% number of trials (should be consistent across participants)
% number of correct responses to numbers other than 3
% number of incorrectly responding to number 3
% hit rate = correct responses to numbers other than 3 / total numbers
% other than 3
% false alarm rate = incorrect response to 3 / total 3s
% measure of interest (d prime) = correct to non targets - incorrect
% responses to 3

% some studies report mean accuracy rates

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

