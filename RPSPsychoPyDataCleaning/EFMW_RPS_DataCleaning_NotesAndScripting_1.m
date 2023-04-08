%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning Code

% Chelsie H.
% Started: November 8, 2022
% Last updated: March 28, 2023

% Purpose: Remove Irrelevant Data for Later Scoring

% to do:
% remove columns from "practice" parts - create a separate file for this?
% remove any rows that only have practice data
% remove columns for randomizer variables
% create a separate file for just practice stuff
% create a separate file to store task/system information for all
% participants
% create script for checking if psychopy scoring is correct

% Example file for raw data: ExampleRPSPsychoPyData.cxv
% Example file for what cleaned data should look like: ExampleRPSGoalCleanedData.xlsx
% separate sheets for each part of the data.
% File with column key and content information is
% PsychoPyData_ColumnKey.xlsx

% raw file names are usually in this format: PARTICIPANT_EFMW_Tasks_RPS_..
% followed by digits for YYYY-MM-DD_HHhMM.SS.MsMsMs (the h is 'h')

% THIS SCRIPT IS NOT FOR REMOVING TRIALS WHERE THERE WERE ISSUES DURING
% DATA COLLECTION OR DUMMY TRIALS

% Note that because the data is being created through a python program,
% automatic counters will always start at '0' for the first item.
% 1 will have to be added to all counters to make this more intuitive in
% cleaned data.

%% Notes
% could separate data into different matrices, then look for the first
% indicator of a trial and delete all blank before it, then look for the
% last trial and delete everything after, just to conserve any trials where
% they did not response and no data was recorded.

%% Output Files
% ParticipantID_psychopy_cleaned (for cleaned data of tasks only)
% ParticipantID_psychopy_practice
% These will be made within matlab for each participant
% RPS_PsychoPyTaskInfo (will be RAD instead of RPS for RAD data)
% RPS_PsychoPyTaskInfo will be made externally

%% Clear all and Select Directory

                            % EVENTUALLY THIS NEEDS TO LOOP THROUGH SEVERAL
                            % DATA FILES

clc
clear
% on laptop maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSPsychoPyDataCleaning/');
% on desktop 
maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSPsychoPyDataCleaning/');


%% Load in Data
rawdatadir = [maindir 'RawData/'];
cleaneddatadir = [maindir 'CleanedData/'];
addpath(genpath(maindir))


% need to get it to find all raw files or the raw files of interest too
filepattern = fullfile(rawdatadir, 'PARTICIPANT_EFMW_Tasks_RPS_*');
% finds all file with the string in the beginning of the file name
filename = dir(filepattern); 
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

            % fprintf('\n******\nLoading in raw data file %d\n******\n\n', (whatever the looping variable is called);

opts = detectImportOptions([rawdatadir filenamestring]);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
rawdata = readtable([rawdatadir filenamestring],opts);
% creates a table where all variables are 'cell'

% T2 = convertvars(T1,vars,dataType) converts the specified variables to the specified data type. The input argument T1 can be a table or timetable.
% doesn't do cell to double

            % LATER USE str2double INSTEAD TO GET NUMBERS
            % string() CONVERTS CELL TO STRING; CELL WORDS FINE FOR e.g.,
            % strcmp THOUGH.

            % cell2mat TO DO STUFF WITH NUMERIC VARIABLES

clear filename filenamestring opts

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

ID = unique(rawdata.("Participant ID (informed by researcher)"));
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

% EFtasksrandomizerloop.thisIndex = 0 = EFTask3 = SymmSpan = SY
% (same as above)"" = 1 = EFTask1 = Switch = SW
% "" = 2 = EFTask2 = Nback = N
% "" = 3 = EFTask4 = SART = SA

% can add this to the file with system information etc.

%% and Variable for which subtask was first
% May include subtasks
% Colour Shape Subtasks:
% counterbalance_switch_shapecolour.thisIndex = 0 = subtask1 = colour = c
% "" = 1 = subtask2 = shape = s
% Symmetry Span Subtasks:
% symmspansubtasksloop.thisIndex = 0 = s (symmetry judgement)
% " = 1 = r (recall)

% within an if loop for index for task randomizer
% if index = # corresponding to SW
% if index = # corresponding to c
% then task and subtask order variable = SWc...
% concatonate things into a variable name e.g., NSWcsSYsrSAN

%% To get task order
% Create TaskOrder variable to hold letters
TaskOrder = [];
    % find EFtasksrandomizerloop.thisN
TaskRandCol = find(strcmp(rawdata.Properties.VariableNames,"EFtasksrandomizerloop.thisN"));
% for 'PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv' this should be 32
for TaskRandIdx = 0:3
    % for every value of this which should be 0 to 3
    % testing when this = 0
        % had trouble getting find/ismember working for this
        TaskRandRow = find(ismember(rawdata.("EFtasksrandomizerloop.thisN"),string(TaskRandIdx)));
        % for the example, this should be 416
 
    % take that row number and find the value for EFtasksrandomizerloop.thisIndex
        TaskRandIdxNum = rawdata.("EFtasksrandomizerloop.thisIndex")(TaskRandRow);
        % creates a 1 x 1 cell with the value (3, in the example)
        % TaskRandIdxNum = cell2mat(TaskRandIdxNum(1));
        % but this makes it a character
        TaskRandIdxNum = str2num(cell2mat(TaskRandIdxNum(1)));
        % now this makes it a double but with just the single number

    % if that value is 0
    if TaskRandIdxNum == 0
        % add SY to TaskOrder; TaskOrder = [TaskOrder 'SY']
        TaskOrder = [TaskOrder 'SY'];        % remember to use single quotes
        % find symmspansubtasksloop.thisN
        % SubTaskRandCol = find(strcmp(rawdata.Properties.VariableNames,"symmspansubtasksloop.thisN"));
            % find row where this is 0
        SymmSubTaskRandRow = find(ismember(rawdata.("symmspansubtasksloop.thisN"),'0'));
        SymmSubTaskRandIdxNum = rawdata.("symmspansubtasksloop.thisIndex")(SymmSubTaskRandRow);
        SymmSubTaskRandIdxNum = str2num(cell2mat(SymmSubTaskRandIdxNum(1)));
            % for that row
            % if symmspansubtasksloop.thisIndex = 0
            if SymmSubTaskRandIdxNum == 0
                % add 'sr' to task order
                TaskOrder = [TaskOrder 'sr'];
            % else if symmspansubtasksloop.thisIndex = 1
            elseif SymmSubTaskRandIdxNum == 1
                % add 'rs' to task order
                TaskOrder = [TaskOrder 'rs'];
            end
    % else if the value for the task randomizer index is 1
    elseif TaskRandIdxNum == 1
        % add SW to task order variable
        TaskOrder = [TaskOrder 'SW'];
        % find counterbalance_switch_shapecolour.thisN
        % find row where this is 0
        SwitchSubTaskRandRow = find(ismember(rawdata.("counterbalance_switch_shapecolour.thisN"),'0'));
        SwitchSubTaskRandIdxNum = rawdata.("counterbalance_switch_shapecolour.thisIndex")(SwitchSubTaskRandRow);
        SwitchSubTaskRandIdxNum = str2num(cell2mat(SwitchSubTaskRandIdxNum(1)));
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

clear TaskRandCol TaskRandIdx TaskRandIdxNum TaskRandRow SymmSubTaskRandRow 
clear SymmSubTaskRandIdxNum SwitchSubTaskRandRow SwitchSubTaskRandIdxNum
clear psychopyversion OS frameRate TaskOrder NewTaskInfo TaskInfo

        % WILL NEED ID DATE EXPNAME FOR NAMING THE OUTPUT FILES

%% Create a new table for practice data
    % except we can't just do this because some columns have a mix of
    % information from the practice and actual tasks

%% Create separate tables for tasks SART

% cannot just concatinate with rawdata.variables
% create an index?

%T(:,ismember(T.Properties.VariableNames, {""list of variables""})) this
% doesn't work with wild cards

SARTMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'SART'));
SARTAllData = rawdata(:,rawdata.Properties.VariableNames(SARTMatch));
% doesn't get us the extra column for number

SARTAllData.("number") = rawdata.("number");
SARTAllData.("correctkey") = rawdata.("correctkey");
% adds the extra column to the end.
            
%% SART Practice:
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

%% Separating practice from task for SART

% for the practice columns, there is data only during the practice while
% the rest is NaN
% so if I select only those rows where the practice section is not NaN I
% can keep just the rows that matter from the 'numbers' column

SARTPRows = ~isnan(SARTAllData.("SARTpracticeloop.ran"));
SARTPData = SARTAllData(SARTPRows,:);
% but this leaves us with extra columns.
SARTPNum = SARTPData.("number");
SARTPCKey = SARTPData.("correctkey");

SARTPMatch = ~cellfun('isempty', regexp(SARTPData.Properties.VariableNames, 'practice'));
% using 'practice' won't work in some of the other tasks.

        % FUTURE VERSIONS OF THE TASKS NEED STANDARDIZED VARIABLE NAMING TO
        % MAKE THIS SEPARATION EASIER
        % OTHER VARIABLES SHOULD ALSO INCLUDE THE TASK LABEL AND BE
        % SEPARATED FOR PRACTICE AND ACTUAL TASKS

SARTPData = SARTPData(:,SARTPMatch);
SARTPData.("number") = SARTPNum;
SARTPData.("correctkey") = SARTPCKey;

% data should have 10 columns in practice

% can use ~ to get the task data only.
SARTData = SARTAllData(~SARTPRows,~SARTPMatch);

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

clear SARTMatch SARTPRows SARTPNum SARTPCKey SARTPMatch SARTLoopCol
clear SARTRows


% For now, this puts the SART practice and SART data of use into separate
% tables with new labels and counters set to start at 1.

                    % eventually need to see if the practice and actual data can be put into
                    % one file somehow
                    % they'll probably have a different number of rows though
                    % so maybe they'll need to be saved into separate files per task

%% Switch Practice:
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

ShapeMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'shape'));
ShapeData = rawdata(:,rawdata.Properties.VariableNames(ShapeMatch));

ColourMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'colour'));
ColourData = rawdata(:,rawdata.Properties.VariableNames(ColourMatch));

MixedMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'mix'));
MixedData = rawdata(:,rawdata.Properties.VariableNames(MixedMatch));

PracticeSwitchMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceswitch'));
PracticeSwitchData = rawdata(:,rawdata.Properties.VariableNames(PracticeSwitchMatch));

%then add switchcond, dummyswitchcondition, switchcondition,
%dummystimuluspresented, stimuluscondition, dummystimuluscondition, 
% stimuluspresented, images, correct - separately

% some of these can grouped maybe to reduce single calls?
SwitchCondMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'switchcond'));
SwitchCondData = rawdata(:,rawdata.Properties.VariableNames(SwitchCondMatch));

% but 'colour_shape_switch_task...' columns will overlap

% combine data
% error because duplicate table variable name

OverLapMatch = ~cellfun('isempty', regexp(ShapeData.Properties.VariableNames, 'colour'));
ShapeData = ShapeData(:,ShapeData.Properties.VariableNames(~OverLapMatch));
OverLapMatch2 = ~cellfun('isempty', regexp(SwitchCondData.Properties.VariableNames, 'practiceswitch'));
SwitchCondData = SwitchCondData(:,SwitchCondData.Properties.VariableNames(~OverLapMatch2));

% duplicate dummypracticeswitchcondition

SwitchAllData = [ShapeData ColourData MixedData PracticeSwitchData SwitchCondData];

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

clear ShapeMatch ShapeData ColourMatch ColourData PracticeSwitchmatch PracticeSwitchData
clear SwitchCondMatch SwitchCondData OverLapMatch OverLapMatch2
clear MixedMatch MixedData PracticeSwitchMatch PracticeSwitchData
%% Separating practice from task for Switch

% for the practice columns, there is data only during the practice while
% the rest is NaN
% so if I select only those rows where the practice section is not NaN I
% can keep just the rows that matter from the 'numbers' column

% but colour, shape, and switch (mixed) have separate practice sections
% so...

%isnan doesn't work here because the empty parts aren't NAN for some
%reason.

SwitchPMatch1 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'practice'));
SwitchPMatch2 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pshape'));
SwitchPMatch3 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pcolour'));

SwitchPMatch = SwitchPMatch1 | SwitchPMatch2 | SwitchPMatch3;

clear SwitchPMatch1 SwitchPMatch2 SwitchPMatch3

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

SwitchPData = SwitchPData(:,SwitchPMatch);

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

SwitchData = SwitchAllData(SwitchRows,~SwitchPMatch);

clear SwitchRows SwitchPMatch

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

PDummyRow = SwitchPData(nrows(SwitchPData),:);

PDummyRow.("SwitchPRule") = SwitchPDummyData.("dummypracticeswitchstimuluscondition");
PDummyRow.("SwitchPCond") = SwitchPDummyData.("dummypracticeswitchcondition");
PDummyRow.("SwitchPStimMixed") = SwitchPDummyData.("dummypracticeswitchstimuluspresented");
PDummyRow.("SwitchPCRespMixed") = SwitchPDummyData.("dummypracticeswitchcorrectresponse");
PDummyRow.("SwitchPResp") = SwitchPDummyData.("mixpracticedummyresp.keys");
PDummyRow.("SwitchPAcc") = SwitchPDummyData.("mixpracticedummyresp.corr");
PDummyRow.("SwitchPRT") = SwitchPDummyData.("mixpracticedummyresp.rt");
PDummyRow.("SwitchPTrial") = 1;

SwitchPData = [SwitchPData ; PDummyRow];

DummyRow = SwitchData(nrows(SwitchData),:);

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

%% Symmetry Span Practice
% Symm
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
% Symmetry
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
% Symm
% symmetryloop.thisRepN, symmetryloop.thisTrialN, symmetryloop.thisN, symmetryloop.thisIndex, 
% symmetryloop.ran
% Recall
% recallloop.thisRepN, recallloop.thisTrialN, recallloop.thisN, recallloop.thisIndex, 
% recallloop.ran
% Task
% symmspanendkey.keys, symmspanendkey.rt, symmspantaskloop.thisRepN, symmspantaskloop.thisTrialN, 
% symmspantaskloop.thisN, symmspantaskloop.thisIndex, symmspantaskloop.ran

%% Create separate tables for SymmSpan

                % REMEMBER THAT OLDER DATA ARE MISSING THE ".time" COLUMNS
                % having timing also added other columns related to
                % mousec click

% most symmspan columns have "symm" or "square" in them
% creates overlap with "symmpracticesquareloop..." columns
% can also include "practiceresponse" items
% and "recallloop." items (period is needed to reduce overlap)
% and requires adding: practicerecallaccuracy, loopnumber, memnumber, recallaccuracy

SymmMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'symm'));
SymmData = rawdata(:,rawdata.Properties.VariableNames(SymmMatch));

SquareMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'square'));
SquareData = rawdata(:,rawdata.Properties.VariableNames(SquareMatch));

PRespMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceresponse'));
PRespData = rawdata(:,rawdata.Properties.VariableNames(PRespMatch));

RecallLoopMatch = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'recallloop.'));
RecallLoopData = rawdata(:,rawdata.Properties.VariableNames(RecallLoopMatch));

OverLapMatch3 = ~cellfun('isempty', regexp(SquareData.Properties.VariableNames, 'symmpracticesquareloop'));
SquareData = SquareData(:,SquareData.Properties.VariableNames(~OverLapMatch3));

% combine

SymmSpanAllData = [SymmData SquareData PRespData RecallLoopData];

% add extra columns
SymmSpanAllData.("practicerecallaccuracy") = rawdata.("practicerecallaccuracy");
SymmSpanAllData.("loopnumber") = rawdata.("loopnumber");
SymmSpanAllData.("memnumber") = rawdata.("memnumber");
SymmSpanAllData.("recallaccuracy") = rawdata.("recallaccuracy");

clear SymmMatch SymmData SquareMatch SquareData PRespMatch PRespData RecallLoopMatch RecallLoopData OverLapMatch3

%% Separating practice from task for SymmSpan

% symmetry, recall, and the full combined task have practice sections.

SymmPracticeMatch = ~cellfun('isempty', regexp(SymmSpanAllData.Properties.VariableNames, 'practice'));
RecalLoopMatch = ~cellfun('isempty', regexp(SymmSpanAllData.Properties.VariableNames, 'recallloop'));
SymmetryLoopMatch = ~cellfun('isempty', regexp(SymmSpanAllData.Properties.VariableNames, 'symmetryloop'));
PLoopMatch = ~cellfun('isempty', regexp(SymmSpanAllData.Properties.VariableNames, 'ploop'));
SquareRespPMatch = ~cellfun('isempty', regexp(SymmSpanAllData.Properties.VariableNames, 'square_resp_2'));

SymmSpanPMatch = SymmPracticeMatch | RecalLoopMatch | SymmetryLoopMatch | PLoopMatch | SquareRespPMatch;

clear SymmPracticeMatch RecalLoopMatch SymmetryLoopMatch PLoopMatch SquareRespPMatch

% for the practice columns, there is data only during the practice while
% the rest is empty cells, so rows can be eliminated this way
% there are, however, many rows that are separate for each loop within a
% loop

        % MAY NEED TO RECOMBINE THINGS TO REDUCE EXTRA COLUMNS AND ROWS

SymmPRows = ~cellfun('isempty',SymmSpanAllData.("symmpracticeloop.ran"));
RecallPresPRows = ~cellfun('isempty',SymmSpanAllData.("symmpracticesquareloop.ran"));
RecallRespPRows = ~cellfun('isempty',SymmSpanAllData.("symmpracticerecalloop.ran"));
RecallPRows = ~cellfun('isempty',SymmSpanAllData.("symmmempracticeloop.ran"));
MixSymmPRows = ~cellfun('isempty',SymmSpanAllData.("symmspansymmploop.ran"));
MixRecallPRows = ~cellfun('isempty',SymmSpanAllData.("symmspanrecallploop.ran"));
SymmSpanMixPRows = ~cellfun('isempty',SymmSpanAllData.("symmspanploop.ran"));

SymmSpanPRows = SymmPRows | RecallPresPRows | RecallRespPRows | RecallPRows | MixSymmPRows | MixRecallPRows | SymmSpanMixPRows;

clear SymmPRows RecallPresPRows RecallRespPRows RecallPRows MixSymmPRows MixRecallPRows SymmSpanMixPRows

SymmSpanPData = SymmSpanAllData(SymmSpanPRows,:);

% need to add 'symmetrical', 'loopnumber', 'memnumber'

SymmSpanPSymmetrical = SymmSpanPData.("symmetrical");
SymmSpanPLoopNum = SymmSpanPData.("loopnumber");
SymmSpanPMemNum = SymmSpanPData.("memnumber");

SymmSpanPData = SymmSpanPData(:,SymmSpanPMatch);

SymmSpanPData.("symmetrical") = SymmSpanPSymmetrical;
SymmSpanPData.("loopnumber") = SymmSpanPLoopNum;
SymmSpanPData.("memnumber") = SymmSpanPMemNum;

clear SymmSpanPSymmetrical SymmSpanPLoopNum SymmSpanPMemNum SymmSpanPRows

% older data should have 57 columns in practice
% newer data should have 69 columns in practice

% can use ~ to get the task data only.

SymmRows = ~cellfun('isempty',SymmSpanAllData.("symmspanblocksymmloop.ran"));
RecallRows = ~cellfun('isempty',SymmSpanAllData.("symmspanrecallblocksloop.ran"));
SymmSpanMixedRows = ~cellfun('isempty',SymmSpanAllData.("symmspanblocksloop.ran"));

SymmSpanRows = SymmRows | RecallRows | SymmSpanMixedRows;

clear SymmSpanMixedRows RecallRows SymmRows

SymmSpanData = SymmSpanAllData(SymmSpanRows,~SymmSpanPMatch);

clear SymmSpanRows SymmSpanPMatch

% older data should have 39 columns
% newer data should have 51 columns

%% For older data only, add in columns we need.

% could try to do a check for if the variable exists
% on it's own, strcmp isn't great because it makes a logical array checking
% every variable name.

if isempty(find(strcmp("practiceresponse.time",SymmSpanPData.Properties.VariableNames)))
    % if there are no columns with this name
    
    SymmSpanPData.("practiceresponse.time") = strings(nrows(SymmSpanPData),1);
    SymmSpanPData.("square_resp_2.time") = strings(nrows(SymmSpanPData),1);
    % create that column
end

if isempty(find(strcmp("symmresponseclick.time",SymmSpanData.Properties.VariableNames)))
    % if there are no columns with this name
    
    SymmSpanData.("symmresponseclick.time") = strings(nrows(SymmSpanData),1);
    SymmSpanData.("square_resp.time") = strings(nrows(SymmSpanData),1);
    % create that column
end

% older practice data should now have 59 columns, data should have 41

%% Rename SymmSpan Columns

% next can rename columns for SymmSpan data, than add in corresponding dummy
% data to a new row piece by piece, so column order will not be a problem

SymmSpanPData = renamevars(SymmSpanPData, ["practicepresentedsymmstim","practicesymmcorrectresponse", "practicesymmaccuracy", ...
    "practiceresponse.time","practiceresponse.clicked_name","symmpracticeloop.thisN","practicesquarecorrectresponse", ...
    "symmpracticesquareloop.thisN","practicerecallaccuracy","square_resp_2.time","square_resp_2.clicked_name","symmmempracticeloop.thisN", ...
    "memnumber","symmspansymmploop.thisN","symmspanrecallploop.thisN","symmspanploop.thisN",], ...
    ["SymSpanPSymStim","SymSpanPSymCResp","SymSpanPSymAcc","SymSpanPSymRT","SymSpanPSymResp","SymSpanPSymTrial","SymSpanPRecStim", ...
    "SymSpanPRecTrialsPerSeries", "SymSpanPRecAcc","SymSpanPRecRT","SymSpanPRecResp","SymSpanPRecSeries","SymSpanPRecSeriesCond", ...
    "SymSpanPMixSymRecPresTrialsPerSeries","SymSpanPMixRecRespTrialsPerSeries","SymSpanPMixRecRespSeries",]);

SymmSpanData = renamevars(SymmSpanData, ["memnumber","presentedsymmstim","symmcorrectresponse","symmresponse","symmaccuracy", ...
    "symmresponseclick.time","squarecorrectresponse","symmspanblocksymmloop.thisTrialN","recallaccuracy","square_resp.time", ...
    "square_resp.clicked_name","symmspanrecallblocksloop.thisN","symmspanblocksloop.thisN"], ...
    ["SymSpanMixSeriesCond ","SymSpanMixSymStim","SymSpanMixSymCResp","SymSpanMixSymResp","SymSpanMixSymAcc","SymSpanMixSymRT", ...
    "SymmSpanMixRecStim","SymmSpanMixSymRecPresTrialsPerSeries","SymSpanMixRecAcc","SymSpanMixRecRT","SymSpanMixRecResp", ...
    "SymSpanMixRecTrialsPerSeries","SymSpanMixRecRespSeries"]);

        % SINGLE AND MIXED PRACTICE SECTIONS SHARE SOME COLUMNS

%% Remove extra columns from SymmSpan data
% loops must be removed after renaming since some extra loop columns are
% also counters

% all the data we care about starts with "Sym*"

SymmSpanPCols = ~cellfun('isempty',regexp(SymmSpanPData.Properties.VariableNames,'Sym*'));

SymmSpanCols = ~cellfun('isempty',regexp(SymmSpanData.Properties.VariableNames,'Sym*'));

SymmSpanPData = SymmSpanPData(:,SymmSpanPCols);
SymmSpanData = SymmSpanData(:,SymmSpanCols);

clear SymmSpanPCols SymmSpanCols

% practice data should have 16 columns
% data should have 13 columns

%% Add 1 to counters for SymmSpan

SymmSpanPData.("SymSpanPSymTrial") = str2double(SymmSpanPData.("SymSpanPSymTrial")) + 1;
SymmSpanPData.("SymSpanPRecTrialsPerSeries") = str2double(SymmSpanPData.("SymSpanPRecTrialsPerSeries")) + 1;
SymmSpanPData.("SymSpanPRecSeries") = str2double(SymmSpanPData.("SymSpanPRecSeries")) + 1;
SymmSpanPData.("SymSpanPMixSymRecPresTrialsPerSeries") = str2double(SymmSpanPData.("SymSpanPMixSymRecPresTrialsPerSeries")) + 1;
SymmSpanPData.("SymSpanPMixRecRespTrialsPerSeries") = str2double(SymmSpanPData.("SymSpanPMixRecRespTrialsPerSeries")) + 1;
SymmSpanPData.("SymSpanPMixRecRespSeries") = str2double(SymmSpanPData.("SymSpanPMixRecRespSeries")) + 1;

SymmSpanData.("SymmSpanMixSymRecPresTrialsPerSeries") = str2double(SymmSpanData.("SymmSpanMixSymRecPresTrialsPerSeries")) + 1;
SymmSpanData.("SymSpanMixRecTrialsPerSeries") = str2double(SymmSpanData.("SymSpanMixRecTrialsPerSeries")) + 1;
SymmSpanData.("SymSpanMixRecRespSeries") = str2double(SymmSpanData.("SymSpanMixRecRespSeries")) + 1;

        % looking at the data at this point, it would be good to shift the
        % reponses up for the squares so that they're in the same rows.
        % it also may be good to assign series number and condition to every row just to
        % reduce the NaNs, but how?
        % for practice, could just shift SymSpanPRecResp, SymSpanPRecAcc,
        % and SymSpanPMixRecRespTrialsPerSeries up 2 rows
        % this makes the trials per series for stimulus presentatino and
        % response redundant but that would be good for checking things
        % later.

% test1 = SymmSpanPData;
% test1.("SymSpanPRecResp") = circshift(test1.("SymSpanPRecResp"),[-2 0]);
% this works but doesn't account for the extra columns between responses
% from SymSpanPRecSeries

%% Assign Series Numbers and Conditions to All related rows

        % STILL NEED TO DO THIS FOR NON-PRACTICE DATA

% need to identify the currently filled rows that are otherwise empty for
% removal later
% SymSpanPRecSeriesCond applies to all practices
SymPSeriesRows = cellfun('isempty',SymmSpanPData.("SymSpanPRecSeriesCond"));

% for all NaN rows for SymSpanPRecSeries (except the first ten rows from
% the symmetry practice).
% Assign the first encountered number down the rows to all previous rows...

% except this column is for the recall practice only, so need to stop this
% after the last number of SymSpanPRecSeries

% for precseriesidx = 11:(find(~isnan(SymmSpanPData.("SymSpanPRecSeries")),1,'last'))
    % for those rows that are part of recall series
   % if isnan(SymmSpanPData.("SymSpanPRecSeries")(precseriesidx))
        % if there is no number
        % find the next number in SymSpanPRecSeries
        
  %  end
%end

% test.("SymSpanPRecSeries") = fillmissing(test.("SymSpanPRecSeries"),'nearest');
% this works, just need to leave the non-series rows NaN

% can't use fill missing on one row at a time in a loop
MinPRecSeriesRow = find(~isnan(SymmSpanPData.("SymSpanPRecSeries")),1,'first');
MaxPRecSeriesRow = find(~isnan(SymmSpanPData.("SymSpanPRecSeries")),1,'last');

SymmSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow) = fillmissing( ...
    SymmSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow),'next');

% same thing for SymSpanPRecSeriesCond
MaxPCondRow = find(~cellfun('isempty',SymmSpanPData.("SymSpanPRecSeriesCond")),1,'last');

SymmSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow) = fillmissing( ...
    SymmSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow),'next');

% same thing for SymSpanPMixRecRespSeries
MaxPMixSeriesRow = find(~isnan(SymmSpanPData.("SymSpanPMixRecRespSeries")),1,'last');
% may be the same as max p cond row but doing this just in case

SymmSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow) = fillmissing( ...
    SymmSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow),'next');



%% Redefine Condition Number to Move Presentation and Response Data Into the Same Rows
% still can't just move other columns up because spacing differs between
% stimulus and response. Could use series condition number to find out how
% many rows to move up some values
% but need to convert these to numbers

test.("SymSpanPRecSeriesCond") = str2double(test.("SymSpanPRecSeriesCond"));

        % START HERE NEXT TIME

%% N-Back Practice
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

%% MCT Instructions
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
% tone_number (tome number from 1 to 25 max).
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
