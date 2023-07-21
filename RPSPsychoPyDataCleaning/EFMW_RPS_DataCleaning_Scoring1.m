%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning and Task Scoring Script

% Chelsie H.
% Started: July 19, 2023
% Last updated: July 21, 2023
% Last tested: July 21, 2023

    % Purpose: 
% Record task and participant information to a Task Info spreadsheet
% Remove irrelevant data from raw data, save this cleaned data,
% then take this cleaned data and score each task as outlined in the
% preregistration as well as calculate potentially useful descriptive
% statistics.

    % Input:
% .csv from psychopy data in RawData Folder (counters always start at 0 in raw data)
% Raw file names are usually in this format: PARTICIPANT_EFMW_Tasks_RPS_..
% followed by digits for YYYY-MM-DD_HHhMM.SS.MsMsMs (the h is 'h', Ms are millisecond digits)


    % Current Output:
% separate .csv files for each task and each practice task
% for each participant in the RawData Folder, saved in Cleaned Data and
% Cleaned Practice Data folders.
% new task info is added to the RPS_PsychoPyTaskInfo.csv
% task scores and descriptives are saved to the RPS_Task_Scores.csv

% File with column key and content information is
% PsychoPyData_ColumnKey.xlsx

% File used to determine which strings to use to select the most relevant
% columns is ExpressionSelectorForColumns.xlsx

    % Example data files:
% PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv (older data with slight
% differences in columns)
% PARTICIPANT_EFMW_Tasks_RPS_ExampleMCTErrors.csv

%% Notes
    % To do's:
% Edit text sent to command window to grab participant ID or file name
% Combine spreadsheet with scores with spreadsheet of questionnaire scores
% and demographics

    % Future ideas:
% Could add something such that if the participant ID matches files in the
% cleaned data, the script should stop.
% Remove trials where there were issues during data collection
% Only import variable names that are of use for data cleaning.
% Edit the task to have variable names and save variables in a way that
% makes indexing easier
% dummies may not have been necessary to keep, since correct response is
% included in the conditions for some tasks
% combine this with researcher notes 
% combine this with questionnaires scoring and demographics
% check for participants that may have responded too early or too late on
% some trials (only the final response is recorded)
% create a standardized scoring reference?
% get reaction times for all trials, correct trials, and incorrect trials
% for all
% SymSpan may need to exclude trials that are longer than M + SD
% Add in thresholds for practices
% SymSpan could add script for determining number of series with all
% correct recall
% eventually all scores will need to be combined and z-scored.
% CHECK WHETHER Z-TRANSFORMING DATA BEFORE CALCULTING d' MAKES A
% DIFFERENCE.
% may need to consider criteria for removing MCT thought probes if they come
% right after another one.

%% Versions and Packages

% Main PC: Matlab R2021b update 6
% Packages: Stats and machine learning toolbox version 12.2, simulink
% version 10.4, signal processing toolbox version 8.7, image processing
% toolbox version 11.4; FieldTrip 1.0.1.0

%% Clear all and Select Directory

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

rawdatadir = [maindir 'RawData/'];
cleaneddatadir = [maindir 'CleanedData/'];
cleanedpdatadir = [maindir 'CleanedPracticeData/'];
addpath(genpath(maindir))

%% Load in Task Info Data
% task info loaded, added to, and saved outside of the loop through the
% files to reduce how often its read and wrote to.
opts = detectImportOptions([maindir 'RPS_PsychoPyTaskInfo.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskInfo = readtable([maindir 'RPS_PsychoPyTaskInfo.csv'],opts);
    
clear opts

%% Load in Scores Data
opts = detectImportOptions([maindir 'RPS_Task_Scores.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskScores = readtable([maindir 'RPS_Task_Scores.csv'],opts);
    
clear opts

%% Find all files available for cleaning

fprintf('Collecting raw file names\n')

% define file pattern/name of interest
filepattern = fullfile(rawdatadir, 'PARTICIPANT_EFMW_Tasks_RPS_*');

% find files in directory with file pattern
filename = dir(filepattern); 
% creates an array with dimensions: number of files with matching filepattern, 
% details for each file
% convert this to a cell array to extract only the file name
filecell = struct2cell(filename);

% remove extra variables
clear filepattern filename


%% Start of data cleaning loop

% number of file names is the size of filecell's second dimension
for filesidx = 1:size(filecell,2)

    % for each file name indexed by filesidx
    % import as a matrix
    filematrix = cell2mat(filecell(1,filesidx));    
    
    % change filename to a string
    filenamestring = mat2str(filematrix); 
    
    %remove extra ' characters
    filenamestring = strrep(filenamestring,'''','');
    
%% Load in raw data
    
    fprintf('\n******\nLoading in raw data file: %s\n******\n\n', filenamestring);
    
    % detect the options for importing the raw data
    opts = detectImportOptions([rawdatadir filenamestring]);
    % preserve variable naming to match matlab syntax so the variable names
    % are consistent with the column key
    opts.VariableNamingRule = 'preserve'; 

    % for all variable names
    for optsidx = 1:(size(opts.VariableNames,2))
        % if the variable name contains or matches the following
        if contains(opts.VariableNames(optsidx),'keys') || contains(opts.VariableNames(optsidx),'condition') ||...
         contains(opts.VariableNames(optsidx),'letter')  || contains(opts.VariableNames(optsidx),'correct')  ||...
         contains(opts.VariableNames(optsidx),'presented') || contains(opts.VariableNames(optsidx),'.x') ||...
         contains(opts.VariableNames(optsidx),'.y') || contains(opts.VariableNames(optsidx),'clicked_name') ||...
         strcmp(opts.VariableNames(optsidx),'images') || strcmp(opts.VariableNames(optsidx),'loopnumber') || ...
         strcmp(opts.VariableNames(optsidx),'practicesymmresponse') || strcmp(opts.VariableNames(optsidx),'practicesymmaccuracy') ||...
         strcmp(opts.VariableNames(optsidx),'practicesquareresponse') || strcmp(opts.VariableNames(optsidx),'practicerecallaccuracy') ||...
         strcmp(opts.VariableNames(optsidx),'symmresponse') || strcmp(opts.VariableNames(optsidx),'symmaccuracy') || ...
         strcmp(opts.VariableNames(optsidx),'squareresponse') || strcmp(opts.VariableNames(optsidx),'recallaccuracy') || ...
         strcmp(opts.VariableNames(optsidx),'date') || ...
         strcmp(opts.VariableNames(optsidx),'expName') || strcmp(opts.VariableNames(optsidx),'psychopyVersion') || ...
         contains(opts.VariableNames(optsidx),'OS') || strcmp(opts.VariableNames(optsidx),'framerate')
        % these variables should be set to be characters
            opts = setvartype(opts,opts.VariableNames(optsidx),'char');
    
            % for some reason, setting ParticipantID to character
            % explicitly doesn't import things correctly, so maintain
            % whatever settings opts has for it.
        elseif ~contains(opts.VariableNames(optsidx),'ParticipantID')
            % note: this is "contains" because some files have "Participant
            % ID (informed by researcher)" while others hae "Participant
            % ID"

            % all other variables can be doubles, since we treat them as numbers 
            % and want the NaNs in there for the most part    
            opts = setvartype(opts,opts.VariableNames(optsidx),'double');
      
        end
    
    end
    
    % read in the raw data as a table given the new opts defined above
    rawdata = readtable([rawdatadir filenamestring],opts);
    
    % clear extra variables
    clear filenamestring opts*

    
%% Store values for task info and naming output
    
    % Check if this file has the longer version of the participant ID
    % variable name
    % Previously tried to change the variable name in opts, but this didn't
    % work.
    if ~isempty(find(strcmp('Participant ID (informed by researcher)',rawdata.Properties.VariableNames),1))
        % rename to shorter version
        rawdata = renamevars(rawdata,'Participant ID (informed by researcher)','Participant ID');
    end
    
    % unique should work for most since there should be one value for each
    % in every row of the raw data
    ID = unique(rawdata.("Participant ID"));
    Date = unique(rawdata.("date"));
    expName = unique(rawdata.("expName"));
    psychopyversion = unique(rawdata.("psychopyVersion"));
    OS = unique(rawdata.("OS"));

    % may be able to do this in one step
    frameRate = unique(rawdata.("frameRate"));
    frameRate = num2cell(frameRate);
          
%% Determine Task Order
    fprintf('Determining task order\n')

    % Create TaskOrder array to hold the letters to represent tasks and
    % substasks
    % All tasks and subtasks except for the MCT were randomized across
    % participants to reduce task order effects/counterbalance, so task order varies from
    % participant to participant with the only indicator being what index
    % (row of the excel spreadsheet for 'conditions' used in psychopy) was
    % used for the task randomizer.

    TaskOrder = [];
    
    % Find the column for the task randomizer loop
    TaskRandCol = find(strcmp(rawdata.Properties.VariableNames,"EFtasksrandomizerloop.thisN"));
    
% for 'PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv' this should be 32

    % for every possible task ranomizer value that isn't NaN (0, 1, 2, 3)
    for TaskRandIdx = 0:3
        % Find what row of the rawdata contains the value
            TaskRandRow = find(ismember(string(rawdata.("EFtasksrandomizerloop.thisN")),string(TaskRandIdx)));

% MAY BE ABLE TO JUST DO THIS WITH == INSTEAD OF IS MEMBER NOW

% TaskRandRow should be 416 for the fewerrors data when
% TaskRandIdx is 0
     
            % for that row, find what 'index' was used for the task
            % randomizer loop
            TaskRandIdxNum = rawdata.("EFtasksrandomizerloop.thisIndex")(TaskRandRow);
         
        % if index 0 was used for that row.
        if TaskRandIdxNum == 0
            % This indicates that the task was the Symmetry Span Task
            % add SY to TaskOrder
            TaskOrder = [TaskOrder 'SY'];       % remember to use single quotes
            % find symmspansubtasksloop.thisN
            % find the first row (containing 0) for the symmetry span subtasks loop information
            SymSubTaskRandRow = find(ismember(rawdata.("symmspansubtasksloop.thisN"),0));
            % In that row, find the index for the symm span subtask loop
            SymSubTaskRandIdxNum = rawdata.("symmspansubtasksloop.thisIndex")(SymSubTaskRandRow);
                
                % if the index is 0
                if SymSubTaskRandIdxNum == 0
                    % this indicates the symmetry subtask was ran before
                    % the recall subtask
                    % add 'sr' to task order
                    TaskOrder = [TaskOrder 'sr'];
                % otherwise, the index should be 1
                % No other index values should be possible
                elseif SymSubTaskRandIdxNum == 1
                    % indicating the recall subtask was ran before the
                    % symmetry span subtask
                    % add 'rs' to task order
                    TaskOrder = [TaskOrder 'rs'];
                end

        % if the value for the task randomizer index is 1
        elseif TaskRandIdxNum == 1
            % this means that the Switch task was presented
            % add SW to task order variable
            TaskOrder = [TaskOrder 'SW'];
            % find the first row of the symmetry span randomizer
            % (containing 0)
            SwitchSubTaskRandRow = find(ismember(rawdata.("counterbalance_switch_shapecolour.thisN"),0));
            % use that row to find out the index value
            SwitchSubTaskRandIdxNum = rawdata.("counterbalance_switch_shapecolour.thisIndex")(SwitchSubTaskRandRow);
            
            % if the subtask randomizer for the switch task has index 0
            if SwitchSubTaskRandIdxNum == 0
                % the colour subtast was presented before the shape
                % subtask
                % add 'cs' to task order
                TaskOrder = [TaskOrder 'cs'];
            % if the subtask randomizer index is 1 
            elseif SwitchSubTaskRandIdxNum == 1
                % the shape subtask was presented before the colour subtask
                % add 'sc' to task order
                TaskOrder = [TaskOrder 'sc'];
            end

        % if value for task randomizer index is 2
        elseif TaskRandIdxNum == 2
            % the n-back task was presented
            % add N to task order
            TaskOrder = [TaskOrder 'N'];
            % The 1-back and 2-back are not randomized and always presented
            % in order.

        % if value for task randomizer index is 3
        elseif TaskRandIdxNum == 3
            % the SART was presented
            % add SA to task order
            TaskOrder = [TaskOrder 'SA'];
        end
    end    

% for 'PARTICIPANT_EFMW_Tasks_RPS_ExampleFewErrors.csv' the
% TaskOrder should be SASWscSYsrN
    
%% Combining task information for raw data file

    fprintf('Combining task info\n')

    NewTaskInfo = [ID Date expName psychopyversion OS frameRate TaskOrder];

    % combine this with what wsa taken from TaskInfo, adding the new
    % information to the end of that table.
    TaskInfo = [TaskInfo; NewTaskInfo];
    % this will be saved outside of the loop, so should just extend for
    % ever raw data file processed
        
    clear TaskRandCol TaskRandIdx TaskRandIdxNum TaskRandRow SymSubTaskRandRow 
    clear SymSubTaskRandIdxNum SwitchSubTaskRandRow SwitchSubTaskRandIdxNum
    clear psychopyversion OS frameRate NewTaskInfo
    % cleaning out extra variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SART Data
    fprintf('Processing SART data\n')
    
    % Find the columns labeled 'SART'
    SARTCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'SART'));

    % grab only those columns
    SARTAllData = rawdata(:,rawdata.Properties.VariableNames(SARTCols));
    
    % add the extra columns that don't have 'SART' in the name
    SARTAllData.("number") = rawdata.("number");
    SARTAllData.("correctkey") = rawdata.("correctkey");
    % adds the extra column to the end.
    
%% Separating practice from task for SART
    
    % the practice columns for the SART only have data during the practice.
    % find the rows for those columns that are not NaN
    SARTPRows = ~isnan(SARTAllData.("SARTpracticeloop.ran"));
    % select only those rows
    SARTPData = SARTAllData(SARTPRows,:);

    % Store the columns for number and correct key separately as they do
    % not contain 'practice' in the variable name
    SARTPNum = SARTPData.("number");
    SARTPCKey = SARTPData.("correctkey");
    
    % Find the variables (columns) with 'practice' in the name
    SARTPCols = ~cellfun('isempty', regexp(SARTPData.Properties.VariableNames, 'practice'));
    
    % Select only the practice columns
    SARTPData = SARTPData(:,SARTPCols);
    % add back in the other columns
    SARTPData.("number") = SARTPNum;
    SARTPData.("correctkey") = SARTPCKey;
    
    % can use ~ to exclude the practice data and keep the actual data
    SARTData = SARTAllData(~SARTPRows,~SARTPCols);

% few errors SARTPData should have 10 columns at this point
% few errors SARTData should have 15 columns at this point
    
    % remove the extra columns for the SART loop
    SARTLoopCol = ~cellfun('isempty',regexp(SARTData.Properties.VariableNames,'SARTloop'));
    SARTRows = ~isnan(SARTData.("SARTblock1loop.ran"));

% few errors SARTData should have 10 columns at this point
    
    SARTData = SARTData(SARTRows,~SARTLoopCol);
    
%% Remove more extra columns for SART
    SARTPData = SARTPData(:,~ismember(SARTPData.Properties.VariableNames, ["SARTpracticeloop.thisRepN", ...
        "SARTpracticeloop.thisTrialN", "SARTpracticeloop.thisIndex", "SARTpracticeloop.ran"]));
    
    SARTData = SARTData(:,~ismember(SARTData.Properties.VariableNames,["SARTblock1loop.thisRepN", ...
        "SARTblock1loop.thisTrialN","SARTblock1loop.thisIndex","SARTblock1loop.ran"]));
    
% few errors 6 columns in practice and actual SART data at this point.
    
%% Add 1 to counters for SART
    
    % since psychopy has the first trial as '0' we add one to all of the
    % counters.
    SARTPData.("SARTpracticeloop.thisN") = SARTPData.("SARTpracticeloop.thisN") + 1;
    
    SARTData.("SARTblock1loop.thisN") = SARTData.("SARTblock1loop.thisN") + 1;
    
%% Rename SART columns

    % for the sake of making them intuitive and shorter
    SARTPData = renamevars(SARTPData,["SARTkey_resp_practice.keys", ...
        "SARTkey_resp_practice.corr", "SARTkey_resp_practice.rt",  ...
        "SARTpracticeloop.thisN","number","correctkey"], ...
        ["SARTPResp","SARTPAcc","SARTPRT","SARTPTrial","SARTPStim","SARTPCResp"]);
    
    SARTData = renamevars(SARTData,["SARTkey_resp_trials.keys","SARTkey_resp_trials.corr", ...
        "SARTkey_resp_trials.rt","SARTblock1loop.thisN","number","correctkey"], ...
        ["SARTResp","SARTAcc","SARTRT","SARTTrial","SARTStim","SARTCResp"]);
    
    
    clear SARTCols SARTPRows SARTPNum SARTPCKey SARTPCols SARTLoopCol
    clear SARTRows 
    clear SARTAllData 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Switch Data
    fprintf('Processing Switch data\n')
    
    % find the variables containing the terms which select for the most switch
    % columns
    ShapeCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'shape'));
    ColourCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'colour'));
    MixedCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'mix'));
    PracticeSwitchCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceswitch'));
    SwitchCondCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'switchcond'));
    
    % combine these into a single logical array
    SwitchAllCols = ShapeCols | ColourCols | MixedCols | PracticeSwitchCols | SwitchCondCols;

    % use the logical array to select the columns of interest
    SwitchAllData = rawdata(:,SwitchAllCols);
    
    % add extra columns that were missed in the logical array
    SwitchAllData.("dummystimuluspresented") = rawdata.("dummystimuluspresented");
    SwitchAllData.("stimuluscondition") = rawdata.("stimuluscondition");
    SwitchAllData.("dummystimuluscondition") = rawdata.("dummystimuluscondition");
    SwitchAllData.("stimuluspresented") = rawdata.("stimuluspresented");
    SwitchAllData.("images") = rawdata.("images");
    SwitchAllData.("correct") = rawdata.("correct");
    SwitchAllData.("correctresponse") = rawdata.("correctresponse");
    SwitchAllData.("dummycorrectresponse") = rawdata.("dummycorrectresponse");
    
    clear ShapeCols ColourCols PracticeSwitchmatch SwitchCondCols MixedCols 
    clear SwitchAllCols PracticeSwitchCols

%% Separating practice from task for Switch
    
    % Find columns which are related to the practice
    SwitchPCols1 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'practice'));
    SwitchPCols2 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pshape'));
    SwitchPCols3 = ~cellfun('isempty', regexp(SwitchAllData.Properties.VariableNames, 'pcolour'));
    
    % create logical for columns
    SwitchPCols = SwitchPCols1 | SwitchPCols2 | SwitchPCols3;
    
    % find rows with practice data; practice columns only contain data in
    % the practice rows
    ShapePRows = ~isnan(SwitchAllData.("practiceshapeloop.ran"));
    ColourPRows = ~isnan(SwitchAllData.("practicecolourloop.ran"));
    SwitchMixedPRows = ~isnan(SwitchAllData.("practicemixedloop.ran"));

    % create logical for rows
    SwitchPRows = ShapePRows | ColourPRows | SwitchMixedPRows;
    
    % Select only practice rows    
    SwitchPData = SwitchAllData(SwitchPRows,:);
    
    % store "images" and "correct" as they aren't included in the logical
    % for columns
    SwitchPImages = SwitchPData.("images");
    SwitchPCorrect = SwitchPData.("correct");
    
    % Select only the columns related to practice
    SwitchPData = SwitchPData(:,SwitchPCols);
    
    % Add back in the images and correct columns
    SwitchPData.("images") = SwitchPImages;
    SwitchPData.("correct") = SwitchPCorrect;
    
% for few errors, SwitchPData practice should have 37 columns at this point
    
    % find rows for actual task data
    ShapeRows = ~isnan(SwitchAllData.("shapetrialsloop.ran"));
    ColourRows = ~isnan(SwitchAllData.("colourtrialsloop.ran"));
    SwitchMixedRows = ~isnan(SwitchAllData.("mixedblock1.ran"));

    % create logical for rows
    SwitchRows = ShapeRows | ColourRows | SwitchMixedRows;
    
    % select only those rows and the columns not related to practice
    SwitchData = SwitchAllData(SwitchRows,~SwitchPCols);
    
    clear SwitchPRows SwitchPImages SwitchPCorrect SwitchPCols1 SwitchPCols2 
    clear SwitchPCols3 SwitchRows SwitchPCols ShapePRows ColourPRows SwitchMixedPRows
    clear ShapeRows ColourRows SwitchMixedRows

% for the few errors example, SwitchData should have 58 columns at this
% point
    
%% Remove extra columns from switch data

    % finding columns related to loops  
    SwitchLoopCol1 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'switch_shapetrials'));
    SwitchLoopCol2 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'counterbalance_switch_shapecolour'));
    SwitchLoopCol3 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'switch_colourtrials'));
    SwitchLoopCol4 = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'colour_shape_switch_task'));
    
    % creating logical for columns
    SwitchLoopCol = SwitchLoopCol1 | SwitchLoopCol2 | SwitchLoopCol3 | SwitchLoopCol4;
    
    % selecting all data that is not those loops
    SwitchData = SwitchData(:,~SwitchLoopCol);
    
    clear SwitchLoopCol*
    
%% Separate switch dummy
                 
    % find dummy columns for practice and actual task
    SwitchPDummyCols = ~cellfun('isempty',regexp(SwitchPData.Properties.VariableNames,'dummy'));
    SwitchDummyCols = ~cellfun('isempty',regexp(SwitchData.Properties.VariableNames,'dummy'));
    
    % separate the dummies from the rest of the data
    SwitchPDummyData = SwitchPData(:,SwitchPDummyCols);
    SwitchDummyData = SwitchData(:,SwitchDummyCols);
    
    SwitchPData = SwitchPData(:,~SwitchPDummyCols);
    SwitchData = SwitchData(:,~SwitchDummyCols);

    % remove empty rows from the dummy data
    SwitchPDummyData = rmmissing(SwitchPDummyData);
    SwitchDummyData = rmmissing(SwitchDummyData);
    
    clear SwitchDummyCols SwitchPDummyCols 
    
%% Remove more extra columns from Switch data
    
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
    
% for few errors example, the switch practice should have 18 columns and
% actual switch data should have 19 columns, at this point
    
%% Rename Switch Columns
   
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
    
%% Add 1 to counters for switch
    
    SwitchPData.("SwitchPShapeTrial") = SwitchPData.("SwitchPShapeTrial") + 1;
    SwitchPData.("SwitchPColourTrial") = SwitchPData.("SwitchPColourTrial") + 1;
    % adding 2 to the mixed trial column because the dummy is actually
    % trial 1.
    SwitchPData.("SwitchPTrial") = SwitchPData.("SwitchPTrial") + 2;
    
    SwitchData.("SwitchShapeTrial") = SwitchData.("SwitchShapeTrial") + 1;
    SwitchData.("SwitchColourTrial") = SwitchData.("SwitchColourTrial") + 1;
    % adding 2 to the mixed trial column because the dummy is actually
    % trial 1
    SwitchData.("SwitchTrial") = SwitchData.("SwitchTrial") + 2;
    
%% Add Dummies to switch data
    
    % create an array with the same columns as the SwitchPData
    PDummyRow = SwitchPData(height(SwitchPData),:);
    
    % fill in the dummy row with the information from the dummy data,
    % accounting for change in variable names
    PDummyRow.("SwitchPRule") = SwitchPDummyData.("dummypracticeswitchstimuluscondition");
    PDummyRow.("SwitchPCond") = SwitchPDummyData.("dummypracticeswitchcondition");
    PDummyRow.("SwitchPStimMixed") = SwitchPDummyData.("dummypracticeswitchstimuluspresented");
    PDummyRow.("SwitchPCRespMixed") = SwitchPDummyData.("dummypracticeswitchcorrectresponse");
    PDummyRow.("SwitchPResp") = SwitchPDummyData.("mixpracticedummyresp.keys");
    PDummyRow.("SwitchPAcc") = SwitchPDummyData.("mixpracticedummyresp.corr");
    PDummyRow.("SwitchPRT") = SwitchPDummyData.("mixpracticedummyresp.rt");
    PDummyRow.("SwitchPTrial") = 1;
    
    % Add the dummy row to the data
    SwitchPData = [SwitchPData ; PDummyRow];
    
    % create an array with the same columns as switch data
    DummyRow = SwitchData(height(SwitchData),:);
    
    % fill in the dummy row with the information from the dummy data,
    % accounting for change in variable names
    DummyRow.("SwitchRule") = SwitchDummyData.("dummystimuluscondition");
    DummyRow.("SwitchCond") = SwitchDummyData.("dummyswitchcondition");
    DummyRow.("SwitchStimMixed") = SwitchDummyData.("dummystimuluspresented");
    DummyRow.("SwitchCRespMixed") = SwitchDummyData.("dummycorrectresponse");
    DummyRow.("SwitchResp") = SwitchDummyData.("mixeddummyresp.keys");
    DummyRow.("SwitchAcc") = SwitchDummyData.("mixeddummyresp.corr");
    DummyRow.("SwitchRT") = SwitchDummyData.("mixeddummyresp.rt");
    DummyRow.("SwitchTrial") = 1;
    
    % add dummy row to the data
    SwitchData = [SwitchData; DummyRow];
    
    clear PDummyRow DummyRow SwitchDummyData SwitchPDummyData
    clear SwitchAllData

% Remember, the dummy rows are added to the END of the data tables.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% Symmetry Span Data
    fprintf('Processing SymSpan data\n')
   
    % find variables containing terms that are related to the symmetry span
    % data
    SymCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'symm'));
    SquareCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'square'));
    PRespCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'practiceresponse'));
    RecallLoopCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'recallloop.'));
    
    % creat logical for columns
    SymSpanAllCols = SymCols | SquareCols | PRespCols | RecallLoopCols;

    % select only those column for symmetry span
    SymSpanAllData = rawdata(:,SymSpanAllCols);
    
    % add extra columns that were not included in the logical
    SymSpanAllData.("practicerecallaccuracy") = rawdata.("practicerecallaccuracy");
    SymSpanAllData.("loopnumber") = rawdata.("loopnumber");
    SymSpanAllData.("memnumber") = rawdata.("memnumber");
    SymSpanAllData.("recallaccuracy") = rawdata.("recallaccuracy");
    
    clear SymCols SquareCols PRespCols RecallLoopCols SymSpanAllCols
    
%% Separating practice from task for SymSpan
    
    % find columns related to practice
    SymPracticeCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'practice'));
    RecalLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'recallloop'));
    SymetryLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'symmetryloop'));
    PLoopCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'ploop'));
    SquareRespPCols = ~cellfun('isempty', regexp(SymSpanAllData.Properties.VariableNames, 'square_resp_2'));
    
    % combine into logical
    SymSpanPCols = SymPracticeCols | RecalLoopCols | SymetryLoopCols | PLoopCols | SquareRespPCols;
    
    clear SymPracticeCols RecalLoopCols SymetryLoopCols PLoopCols SquareRespPCols
    
    % find the rows where the practice columns contain data; practie only has data
    % in the practice section, otherwise it's NaN
    SymPRows = ~isnan(SymSpanAllData.("symmpracticeloop.ran"));
    RecallPresPRows = ~isnan(SymSpanAllData.("symmpracticesquareloop.ran"));
    RecallRespPRows = ~isnan(SymSpanAllData.("symmpracticerecalloop.ran"));
    RecallPRows = ~isnan(SymSpanAllData.("symmmempracticeloop.ran"));
    MixSymPRows = ~isnan(SymSpanAllData.("symmspansymmploop.ran"));
    MixRecallPRows = ~isnan(SymSpanAllData.("symmspanrecallploop.ran"));
    SymSpanMixPRows = ~isnan(SymSpanAllData.("symmspanploop.ran"));
    
    % combine into logical
    SymSpanPRows = SymPRows | RecallPresPRows | RecallRespPRows | RecallPRows | MixSymPRows | MixRecallPRows | SymSpanMixPRows;
    
    % select only rows with practice data    
    SymSpanPData = SymSpanAllData(SymSpanPRows,:);
    
    % store the extra columns that aren't included in the logical for
    % columns
    SymSpanPSymetrical = SymSpanPData.("symmetrical");
    SymSpanPLoopNum = SymSpanPData.("loopnumber");
    SymSpanPMemNum = SymSpanPData.("memnumber");
    
    % select only those columns matching the logical
    SymSpanPData = SymSpanPData(:,SymSpanPCols);
    
    % add back in the extra columns
    SymSpanPData.("symmetrical") = SymSpanPSymetrical;
    SymSpanPData.("loopnumber") = SymSpanPLoopNum;
    SymSpanPData.("memnumber") = SymSpanPMemNum;
    
% few errors SymSpanPData should have 57 columns at this point
% many errors SymSpanPData should have 69 columns at this point
    
    % find rows containing data for the actual task    
    SymRows = ~isnan(SymSpanAllData.("symmspanblocksymmloop.ran"));
    RecallRows = ~isnan(SymSpanAllData.("symmspanrecallblocksloop.ran"));
    SymSpanMixedRows = ~isnan(SymSpanAllData.("symmspanblocksloop.ran"));
    
    % combine logical
    SymSpanRows = SymRows | RecallRows | SymSpanMixedRows;
    
    % select only those rows with data for the actual task and those
    % columns which are not related to the practice
    SymSpanData = SymSpanAllData(SymSpanRows,~SymSpanPCols);
    

    clear SymPRows RecallPresPRows RecallRespPRows RecallPRows MixSymPRows 
    clear MixRecallPRows SymSpanMixPRows SymSpanPSymetrical SymSpanPLoopNum 
    clear SymSpanPMemNum SymSpanPRows SymSpanMixedRows RecallRows SymRows
    clear SymSpanRows SymSpanPCols

% few errors SymSpanPData should have 39 columns at this point
% many errors SymSpanPData should have 51 columns at this point
    
%% Add extra columns for symspan
    
    % previously, the reaction time for the symmetry span was not being
    % recorded, so older data needs these extra columns to match with newer
    % data.
    
    % if there are no reaction/response time data
    if isempty(find(strcmp("practiceresponse.time",SymSpanPData.Properties.VariableNames),1))
        % add empty columns to match newer data        
        SymSpanPData.("practiceresponse.time") = strings(height(SymSpanPData),1);
        SymSpanPData.("square_resp_2.time") = strings(height(SymSpanPData),1);
    end
    
    if isempty(find(strcmp("symmresponseclick.time",SymSpanData.Properties.VariableNames),1))
        SymSpanData.("symmresponseclick.time") = strings(height(SymSpanData),1);
        SymSpanData.("square_resp.time") = strings(height(SymSpanData),1);
    end
    
% few errors SymSpanPData should have 59 columns at this point
% SymSpanData should have 41 columns 

%% Rename SymSpan Columns
    
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
    
%% Remove extra columns from SymSpan data
    
    % find variables with the names of interest
    SymSpanPCols = ~cellfun('isempty',regexp(SymSpanPData.Properties.VariableNames,'Sym*'));
    SymSpanCols = ~cellfun('isempty',regexp(SymSpanData.Properties.VariableNames,'Sym*'));
    
    % select the data for the columns of interest
    SymSpanPData = SymSpanPData(:,SymSpanPCols);
    SymSpanData = SymSpanData(:,SymSpanCols);
    
    clear SymSpanPCols SymSpanCols
    
% few errors SymSpanPData should have 16 columns at this point
% SymSpanData should have 13 columns 
    
%% Add 1 to counters for SymSpan
    
    SymSpanPData.("SymSpanPSymTrial") = SymSpanPData.("SymSpanPSymTrial") + 1;
    SymSpanPData.("SymSpanPRecTrialsPerSeries") = SymSpanPData.("SymSpanPRecTrialsPerSeries") + 1;
    SymSpanPData.("SymSpanPRecSeries") = SymSpanPData.("SymSpanPRecSeries") + 1;
    SymSpanPData.("SymSpanPMixPresTrialsPerSeries") = SymSpanPData.("SymSpanPMixPresTrialsPerSeries") + 1;
    SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries") = SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries") + 1;
    SymSpanPData.("SymSpanPMixRecRespSeries") = SymSpanPData.("SymSpanPMixRecRespSeries") + 1;
    
    SymSpanData.("SymSpanMixPresTrialsPerSeries") = SymSpanData.("SymSpanMixPresTrialsPerSeries") + 1;
    SymSpanData.("SymSpanMixRecTrialsPerSeries") = SymSpanData.("SymSpanMixRecTrialsPerSeries") + 1;
    SymSpanData.("SymSpanMixRecRespSeries") = SymSpanData.("SymSpanMixRecRespSeries") + 1;
    
%% Assign Series Numbers and Conditions to All related rows
    
    % find the minimum and maximum row number for the reccal series numbers
    MinPRecSeriesRow = find(~isnan(SymSpanPData.("SymSpanPRecTrialsPerSeries")),1,'first');
    MaxPRecSeriesRow = find(~isnan(SymSpanPData.("SymSpanPRecSeries")),1,'last');
    
    % fill in the missing data between min and maximum with the value in
    % the next row with data for recall series
    SymSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow) = fillmissing( ...
        SymSpanPData.("SymSpanPRecSeries")(MinPRecSeriesRow:MaxPRecSeriesRow),'next');
    
    % find the maximum row for the condition number
    MaxPCondRow = find(~isnan(SymSpanPData.("SymSpanPRecSeriesCond")),1,'last');
    
    % fill in the missing data between min and maximum with the value in
    % the next row with data for condition
    SymSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow) = fillmissing( ...
        SymSpanPData.("SymSpanPRecSeriesCond")(MinPRecSeriesRow:MaxPCondRow),'next');
    
    % find the maximum row for the recall response series
    MaxPMixSeriesRow = find(~isnan(SymSpanPData.("SymSpanPMixRecRespSeries")),1,'last');
    % this row may be the same as the maximum row for condition but 
    % doing this in case it isn't
    
    % fill in the missing data between the min and max rows with the value
    % in the next row with data for the recall response series
    SymSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow) = fillmissing( ...
        SymSpanPData.("SymSpanPMixRecRespSeries")(MaxPRecSeriesRow:MaxPMixSeriesRow),'next');
    
    % the actual task data doesn't have as many extra empty rows because
    % the actual task does not include the single symmetry and recall tasks
    SymSpanData.("SymSpanMixRecRespSeries") = fillmissing(SymSpanData.("SymSpanMixRecRespSeries"),'next');
    SymSpanData.("SymSpanMixSeriesCond") = fillmissing(SymSpanData.("SymSpanMixSeriesCond"),'next');
    
    clear MinPRecSeriesRow MaxPRecSeriesRow MaxPCondRow MaxPMixSeriesRow 

%% Reorganizing data so presentation and response information are in the same row for each trial

    % for rows that have response data
    for SymPRespRow = 1:height(SymSpanPData)
        % if there is information for recall response
        if ~cellfun('isempty',SymSpanPData.("SymSpanPRecResp")(SymPRespRow))
            
            % find the row with series data 
            PRowsUp = SymSpanPData.("SymSpanPRecSeriesCond")(SymPRespRow);

            % assign the recall response data to the row with the series
            % data 
            SymSpanPData.("SymSpanPRecResp")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPRecResp")(SymPRespRow);
            SymSpanPData.("SymSpanPRecAcc")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPRecAcc")(SymPRespRow);
            % also assign the number of responses required per series
            SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries")(SymPRespRow-PRowsUp) = SymSpanPData.("SymSpanPMixRecRespTrialsPerSeries")(SymPRespRow);
        end

    end
    
    % same thing for the actual data
    for SymRespRow = 1:height(SymSpanData)
        if ~cellfun('isempty',SymSpanData.("SymSpanMixRecResp")(SymRespRow))
            RowsUp = SymSpanData.("SymSpanMixSeriesCond")(SymRespRow);
            SymSpanData.("SymSpanMixRecResp")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecResp")(SymRespRow);
            SymSpanData.("SymSpanMixRecAcc")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecAcc")(SymRespRow);
            SymSpanData.("SymSpanMixRecTrialsPerSeries")(SymRespRow-RowsUp) = SymSpanData.("SymSpanMixRecTrialsPerSeries")(SymRespRow);
        end
    end
    
    clear SymPRespRow PRowsUp SymRespRow RowsUp
    
%% Remove extra rows for SymSpan
    
    % Find the rows with stimulus information
    PSymStimRows = ~cellfun('isempty',SymSpanPData.("SymSpanPSymStim"));
    PRecStimPRows = ~cellfun('isempty',SymSpanPData.("SymSpanPRecStim"));
    
    % combine into logical
    SymPRows = PSymStimRows | PRecStimPRows;
    
    % select only rows with stimulus information
    SymSpanPData = SymSpanPData(SymPRows,:);
    
    % Same for the actual data

    SymStimRows = ~cellfun('isempty',SymSpanData.("SymSpanMixSymStim"));
    RecStimRows = ~cellfun('isempty',SymSpanData.("SymSpanMixRecStim"));
    
    SymRows = SymStimRows | RecStimRows;
    
    SymSpanData = SymSpanData(SymRows,:);
      
    clear PSymStimRows PRecStimPRows SymPRows
    clear SymStimRows RecStimRows SymRows
    clear SymSpanAllData
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% N-Back
    fprintf('Processing NBack data\n')

    % see previous tasks for notes on selecting relevant data.
    NBackCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'back'));
    NBackAllData = rawdata(:,rawdata.Properties.VariableNames(NBackCols));
    
    NBackAllData.("letter") = rawdata.("letter");
    NBackAllData.("target") = rawdata.("target");
    
    clear NBackCols
    
%% Separating practice from task for NBack
     
    % the 'letter' variable is only used in the pracitce
    NBackPRows = ~cellfun('isempty',NBackAllData.("letter"));
    NBackPData = NBackAllData(NBackPRows,:);
    
    % clears empty columns which should not be relevant to the pracice
    NBackPData(:,all(ismissing(NBackPData))) = [];

    NBackPCols1 = ~cellfun('isempty', regexp(NBackAllData.Properties.VariableNames, 'practice'));
    NBackPCols2 = ~cellfun('isempty', regexp(NBackAllData.Properties.VariableNames, 'presp'));
    
    NBackPCols = NBackPCols1 | NBackPCols2;
    
    NBackDummy1Rows = ~isnan(NBackAllData.("dummy1backloop.ran"));
    NBackDummy2Rows = ~isnan(NBackAllData.("dummy2backloop.ran"));
    NBackTargetRows = ~isnan(NBackAllData.("target"));
    
    NBackRows = NBackDummy1Rows | NBackDummy2Rows | NBackTargetRows;
    
    NBackData = NBackAllData(NBackRows,~NBackPCols);
    
    % Can't just remove all empty variables because they should not respond to
    % the dummys but might
    
% for few errors example, NBackPData should have 17 columns and NBackData
% should have 41 columns at this point
    
    clear NBackPRows
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
    
% for few errors example, NBackPData should have 9 columns and NBackData
% should have 20 columns at this point

%% Add to counters for NBack
    
    NBackPData.("practice1backloop.thisTrialN") = NBackPData.("practice1backloop.thisTrialN") + 1;
    NBackPData.("practice2backloop.thisTrialN") = NBackPData.("practice2backloop.thisTrialN") + 1;
    
    NBackData.("dummy1backloop.thisRepN") = NBackData.("dummy1backloop.thisRepN") + 1;
    NBackData.("dummy2backloop.thisRepN") = NBackData.("dummy2backloop.thisRepN") + 1;
    
    % for the actual 1-back and 2-back there are two dummy trials so the
    % counters must add 3
    NBackData.("trials_1backloop.thisTrialN") = NBackData.("trials_1backloop.thisTrialN") + 3;
    NBackData.("trials_2backloop.thisTrialN") = NBackData.("trials_2backloop.thisTrialN") + 3;
    
%% Separate NBack dummy trials
               
    % for the n-back there are no dummy trials in the practice
    % find where the dummy rows have data.
    NBackDummyRows1 = ~isnan(NBackData.("dummy1backloop.thisRepN"));
    NBackDummyRows2 = ~isnan(NBackData.("dummy2backloop.thisRepN"));
    
    NBackDummyRows = NBackDummyRows1 | NBackDummyRows2;
    
    % find the columns for dummies
    NBackDummyCols = ~cellfun('isempty',regexp(NBackData.Properties.VariableNames,'dummy'));
    
    % create separate arrays for the 1-back and 2-back dummies
    NBackDummy1Data = NBackData(NBackDummyRows1,:);
    NBackDummy2Data = NBackData(NBackDummyRows2,:);
    
    % select the non-dummmy data separately.
    NBackData = NBackData(~NBackDummyRows,~NBackDummyCols);
    
    % combine the dummy arrays.
    NBackDummyData = [NBackDummy1Data; NBackDummy2Data];

    % select only the dummy columns
    NBackDummyData = NBackDummyData(:,NBackDummyCols);
    
    clear NBackDummyRows1 NBackDummyRows2 NBackDummyCols NBackDummyRows NBackDummy1Data NBackDummy2Data
    
% for few errors, the dummy nback data should have 8 columns and actual 
% data should have 11 at this point
    
%% Rename NBack Columns
    
    NBackPData = renamevars(NBackPData, ["presp_1back.keys","presp_1back.corr","practice1backloop.thisTrialN", ...
        "letter","presp_1back.rt","presp_2back.keys","presp_2back.corr","practice2backloop.thisTrialN","presp_2back.rt"], ...
        ["NBack1PResp","NBack1PAcc","NBack1PTrial","NBackPStim","NBack1PRT","NBack2PResp","NBack2PAcc","NBack2PTrial","NBack2PRT"]);
    
    NBackData = renamevars(NBackData, ["trialletter1back","resp_1back.keys","resp_1back.corr","resp_1back.rt", ...
        "trials_1backloop.thisTrialN","trialletter2back","resp_2back.keys","resp_2back.corr","trials_2backloop.thisTrialN", ...
        "resp_2back.rt","target"], ...
        ["NBack1Stim","NBack1Resp","NBack1Acc","NBack1RT","NBack1Trial","NBack2Stim","NBack2Resp","NBack2Acc","NBack2Trial", ...
        "NBack2RT","Target"]);
    
%% Add Dummies to nback data
    
    % as with the switch practice, create empty 'rows' for the dummy data,
    % fill them in, and add them to the actual data

    NBackDummyRow = NBackData(1:4,:);
    
    NBackDummyRow.("NBack1Stim") = NBackDummyData.("dummyletter1back");
    NBackDummyRow.("NBack1Resp") = NBackDummyData.("resp_dummy1back.keys");
    NBackDummyRow.("NBack1Acc") = NBackDummyData.("resp_dummy1back.corr");
    NBackDummyRow.("NBack1RT") = NaN(4,1);
    NBackDummyRow.("NBack1Trial") = NBackDummyData.("dummy1backloop.thisRepN");
    
    NBackDummyRow.("NBack2Stim") = NBackDummyData.("dummyletter2back");
    NBackDummyRow.("NBack2Resp") = NBackDummyData.("resp_dummy2back.keys");
    NBackDummyRow.("NBack2Acc") = NBackDummyData.("resp_dummy2back.corr");
    NBackDummyRow.("NBack2RT") = NaN(4,1);
    NBackDummyRow.("NBack2Trial") = NBackDummyData.("dummy2backloop.thisRepN");
    NBackDummyRow.("Target") = ["D";"D";"D";"D"];
    
    NBackData = [NBackData ; NBackDummyRow];
    
% NBACK DUMMYS MAY BE SCORED AS 0 (INCORRECT) DESPITE BEING
% CORRECT
% REMEMBER - WITH DUMMY ROWS AT THE BOTTOM OF THE TABLE, ANY
% SCORING CONDITIONAL ON DUMMYS OR ON PREVIOUS TRIALS MUST
% REFER TO TRIAL NUMBER, NOT JUST TO THE PREVIOUS ROW
    
    clear NBackDummyRow NBackDummyData      
    
%% Centering n-back practice reaction times
    
    % for n-back prctices, the response is available at the start of the routine
    % (time 0); however the stimulus iof interest isn't presented until 0.5
    % seconds.
    % to determine response time relative to stimulus onset need to subtact
    % rt - 0.5; if there result is negative, it was an anticipatory response
    % if result is positive, they responded after the stimulus was presented
    
    NBackPData.("NBack1PRT") = NBackPData.("NBack1PRT") - 0.5;
    NBackPData.("NBack2PRT") = NBackPData.("NBack2PRT") - 0.5;
    
    % During the actual n-back, stimulus and response are available
    % from the start of the routine so no correction needed.

    % This would mean that if there were any anticipatory responses they would
    % technically be from the trial before, as only the final response in
    % the trial is recorded
    
    
    clear NBackAllData
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metronome Counting Task
    fprintf('Processing MCT data\n')

    % similar process for separating data from other tasks
    
    ToneCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'tone'));
    ProbeCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'probe'));
    OnOffCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'onoff'));
    AwareCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'aware'));
    IntentCols = ~cellfun('isempty', regexp(rawdata.Properties.VariableNames, 'intent'));
        
    MCTCols = ToneCols | ProbeCols | OnOffCols | AwareCols | IntentCols;
    MCTAllData = rawdata(:,rawdata.Properties.VariableNames(MCTCols));
    
    clear *Cols
    
    MCTAllData.("practiceloop.thisRepN") = rawdata.("practiceloop.thisRepN");
    MCTAllData.("practiceloop.thisTrialN") = rawdata.("practiceloop.thisTrialN");
    MCTAllData.("practiceloop.thisN") = rawdata.("practiceloop.thisN");
    MCTAllData.("practiceloop.thisIndex") = rawdata.("practiceloop.thisIndex");
    MCTAllData.("practiceloop.ran") = rawdata.("practiceloop.ran");
    
%% Separate practice from task for MCT and remove some extra columns and rows
    
    MCTPToneRows = ~isnan(MCTAllData.("practiceloop.ran"));

    % the practice probe variable names depend on if the participants made
    % an error during the practice section or not.

    % if they made an error the following should be empty
    if isempty(find(strcmp("ifnoprobepracticeloop.ran",MCTAllData.Properties.VariableNames),1))
        % so the probe row would have a different name
        MCTPProbeRow = ~isnan(MCTAllData.("practiceprobeloop.ran"));
    else
        MCTPProbeRow = ~isnan(MCTAllData.("ifnoprobepracticeloop.ran"));
    end
    
    % could probably nest this to rename the practice probe columns, but that
    % would break the pattern of organization here.
    
    MCTPRows = MCTPToneRows | MCTPProbeRow;
    
    MCTPData = MCTAllData(MCTPRows,:);
    
    MCTPData(:,all(ismissing(MCTPData))) = [];
    
    % actual task
    MCTToneRows = ~isnan(MCTAllData.("toneloop1.ran"));
    MCTProbeRows = ~isnan(MCTAllData.("probeloop1.ran"));
    
    MCTRows = MCTToneRows | MCTProbeRows;
    
    % We cannot clear all empty columns for the actual data, as this would
    % remove probe columns if the participant did not see any probes
    
    PracticeCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'practice'));
    PRespCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'resp_'));
    PResponseCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'response_'));
    ProbeLoopCols = ~cellfun('isempty',regexp(MCTAllData.Properties.VariableNames,'probeloop1'));
    
    ExtraMCTCols = PracticeCols | PRespCols | PResponseCols | ProbeLoopCols;
    
    MCTData = MCTAllData(MCTRows,~ExtraMCTCols);
    
    clear MCTPProbeRow *Rows *Cols
    
% for few errors example, MCTPData should have 29 columns, MCTData should 
% have 17 columns at this point
    
%% Rename columns for MCT
    
    % conditional on whether they made an error during the practice.
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
    
  
    MCTPLoopCols = ~cellfun('isempty',regexp(MCTPData.Properties.VariableNames,'loop'));
    MCTLoopCols = ~cellfun('isempty',regexp(MCTData.Properties.VariableNames,'loop'));
    
    MCTPData = MCTPData(:,~MCTPLoopCols);
    MCTData = MCTData(:,~MCTLoopCols);
    
    clear *LoopCols
    
% For few errors example, MCTPData should have 19 columns, MCTData should
% have 13 columns, at this point
    
%% re-align trials with thought probes in practice MCT
    
    % the trials with probes are spread across two rows with some
    % information including probe information in the first row and the
    % remainder in the second row

    % if there is a probe
    if ~isempty(MCTPData.("MCTPProbeType"))
        % if they have made a mistake during the practice 
        % (if they did not make a mistake, this would not be empty)
        if isempty(find((ismember(MCTPData.("MCTPProbeType"), 0)),1))

            % take the probe row
            MCTPProbeRows = find(~isnan(MCTPData.("MCTPProbeType")));
            
            % for each probe row
            for MCTPProbeRIdx = 1:height(MCTPProbeRows)
                % take that row number
                MCTPProbeRowNum = MCTPProbeRows(MCTPProbeRIdx);
                % add the trial for the next row to this row
                MCTPData.("MCTPTrial")(MCTPProbeRowNum) = MCTPData.("MCTPTrial")(MCTPProbeRowNum +1);
                % change the next row's trial number to NaN
                MCTPData.("MCTPTrial")(MCTPProbeRowNum +1) = NaN;
            end

            % remove all rows with NaN
            MCTPEraseRows = isnan(MCTPData.("MCTPTrial"));
            MCTPData = MCTPData(~MCTPEraseRows,:);

            % if they did not make a mistake, the practice probe would be 
            % at the very end of the practice data and cannot be assigned a
            % trial number, so removing NaNs only occurs when they make an
            % error
        end
    end
   
    % similar with actual data
    if ~isempty(MCTData.("MCTProbeType"))

        MCTProbeRows = find(~isnan(MCTData.("MCTProbeType")));

        for MCTProbeRIdx = 1:height(MCTProbeRows)

            MCTProbeRowNum = MCTProbeRows(MCTProbeRIdx);
            
            MCTData.("MCTTrial")(MCTProbeRowNum) = MCTData.("MCTTrial")(MCTProbeRowNum + 1);
            MCTData.("MCTTrial")(MCTProbeRowNum + 1) = NaN;

            % The probe will never be in the final row in the actual data
            % so we don't have to worry about an NaN being subbed into
            % MCTTrial when there is a probe

        end
    
    end

    MCTEraseRows = isnan(MCTData.("MCTTrial"));
    MCTData = MCTData(~MCTEraseRows,:);
    
    clear MCTPEraseRows MCTEraseRows
    clear MCTPProbeRows MCTPProbeRIdx MCTPProbeRowNum
    clear MCTProbeRows MCTProbeRIdx MCTProbeRowNum
    
%% Add to counters for MCT
    
    MCTPData.("MCTPTrial") = MCTPData.("MCTPTrial") + 1;
    MCTData.("MCTTrial") = MCTData.("MCTTrial") + 1;
    
%% Add probe and response lables
    
    % making new columns for the name for probe type and corresponding
    % responses

    MCTPData.("MCTPProbeTypeText")(:) = "";
    MCTData.("MCTProbeTypeText")(:) = "";

    for PProbeRowIdx = 1:height(MCTPData)
        
        % the probe type is only 0 if they did not make an error during the
        % practice
        if MCTPData.("MCTPProbeType")(PProbeRowIdx)== 0
            % label to reflect this
            MCTPData.("MCTPProbeTypeText"){PProbeRowIdx} = 'NoErrorP';
    
            % if they made no mistake, they are instructed to press left or
            % right to continue
            if contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'left') || contains(MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx},'right')
                MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'Continue';
            else
                % if they hit the wrong key to continue (down), this
                % suggests their lingering on that response from the trials
                MCTPData.("MCTPProbeIntroResp"){PProbeRowIdx} = 'ContinuedWrongKey';
            end
        
        % similar looping for the other trial types
        elseif MCTPData.("MCTPProbeType")(PProbeRowIdx)== 1
            MCTPData.("MCTPProbeTypeText"){PProbeRowIdx} = 'Miscount';
    
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
    
    
        elseif MCTPData.("MCTPProbeType")(PProbeRowIdx)== 2
            MCTPData.("MCTPProbeTypeText"){PProbeRowIdx} = 'LostCount';
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
    
        elseif MCTPData.("MCTPProbeType")(PProbeRowIdx)== 3
            MCTPData.("MCTPProbeTypeText"){PProbeRowIdx} = 'Timeout';
           
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
    
        % regardless of the probe type the responses to the other questions
        % are consistent
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
    
    
    % similar looping for actual trials, where probe type 0 is not an
    % option
    for ProbeRowIdx = 1:height(MCTData)
        if MCTData.("MCTProbeType")(ProbeRowIdx)== 1
            MCTData.("MCTProbeTypeText"){ProbeRowIdx} = 'Miscount';
    
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
    
    
        elseif MCTData.("MCTProbeType")(ProbeRowIdx)== 2
            MCTData.("MCTProbeTypeText"){ProbeRowIdx} = 'LostCount';
            
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
    
        elseif MCTData.("MCTProbeType")(ProbeRowIdx)== 3
            MCTData.("MCTProbeTypeText"){ProbeRowIdx} = 'Timeout';
            
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
    
    clear *Idx

% recode the instruction probe response as well.
if contains(MCTPData.("MCTInstProbeOnOffResp"){1},'left')
    MCTPData.("MCTInstProbeOnOffResp"){1} = 'OnTask';
elseif contains(MCTPData.("MCTInstProbeOnOffResp"){1},'right')
    MCTPData.("MCTInstProbeOnOffResp"){1} = 'MW';
end

if contains(MCTPData.("MCTInstProbeAwareResp"){1},'left')
    MCTPData.("MCTInstProbeAwareResp"){1} = 'Unaware';
elseif contains(MCTPData.("MCTInstProbeAwareResp"){1},'right')
    MCTPData.("MCTInstProbeAwareResp"){1} = 'Aware';
end

if contains(MCTPData.("MCTInstProbeIntentResp"){1},'left')
    MCTPData.("MCTInstProbeIntentResp"){1} = 'Intentional';
elseif contains(MCTPData.("MCTInstProbeIntentResp"){1},'right')
    MCTPData.("MCTInstProbeIntentResp"){1} = 'Unintentional';
end
    
%% Add reaction time relative to stimulus onset to MCT
    
    % sound starts at 0.75 seconds relative to the start of the routine and
    % lasts for 0.075 seconds

    MCTPData.("MCTPRTDiff") = MCTPData.("MCTPRT") - 0.75;
    
    MCTData.("MCTRTDiff") = MCTData.("MCTRT") - 0.75;
    
    
    clear *AllData
    
%% Save cleaned data for checking
    
    % this part of the script was used prior to creating scoring script.
    % new versions of the cleaned data will be saved with the score checks
    % instead

    %fprintf('Saving processed data\n')
    
    % could have made a loop for file names but hardcoding for now.

    %SARTFileID = strcat(ID,"_SART.csv");
    %SwitchFileID = strcat(ID,"_Switch.csv");
    %SymSpanFileID = strcat(ID,"_SymSpan.csv");
    %NBackFileID = strcat(ID,"_NBack.csv");
    %MCTFileID = strcat(ID,"_MCT.csv");
    
    %SARTPFileID = strcat(ID,"_SARTP.csv");
    %SwitchPFileID = strcat(ID,"_SwitchP.csv");
    %SymSpanPFileID = strcat(ID,"_SymSpanP.csv");
    %NBackPFileID = strcat(ID,"_NBackP.csv");
    %MCTPFileID = strcat(ID,"_MCTP.csv");
    
    %writetable(SARTData, strcat(cleaneddatadir,SARTFileID));
    %writetable(SwitchData,strcat(cleaneddatadir,SwitchFileID));
    %writetable(SymSpanData,strcat(cleaneddatadir,SymSpanFileID));
    %writetable(NBackData,strcat(cleaneddatadir,NBackFileID));
    %writetable(MCTData,strcat(cleaneddatadir,MCTFileID));
    
    %writetable(SARTPData, strcat(cleanedpdatadir,SARTPFileID));
    %writetable(SwitchPData, strcat(cleanedpdatadir,SwitchPFileID));
    %writetable(SymSpanPData, strcat(cleanedpdatadir,SymSpanPFileID));
    %writetable(NBackPData, strcat(cleanedpdatadir,NBackPFileID));
    %writetable(MCTPData, strcat(cleanedpdatadir,MCTPFileID));
    
    %clear *FileID *AllData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring
    fprintf('Scoring tasks\n')

    % store info for scores
    Scores = [ID Date TaskOrder];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring Practice SART
    fprintf('Scoring SART\n')

    SARTPTrials = max(SARTPData.SARTPTrial);
    
    % create counters
    SARTPNonTargets = 0;
    SARTPTargets = 0;
    SARTPHits = 0;
    SARTPFAs = 0;

    % Need to store RT for correct and incorrect
    SARTPRTHit = [];
    SARTPRTFA = [];

    % for each row of the data
    for SARTPIdx = 1:(size(SARTPData,1))
        % if the number in the SARTStim column is not a 3
        if SARTPData.SARTPStim(SARTPIdx) ~= 3
            % add 1 to nontarget counter
            SARTPNonTargets = SARTPNonTargets + 1;
            % if SARTResp is "space"
            if SARTPData.SARTPResp(SARTPIdx) == "space"
                % add 1 to hit counter
                SARTPHits = SARTPHits + 1;
                % accuracy = correct
                SARTPData.SARTPAccuracyCheck(SARTPIdx) = "correct";
                % add the RT to the vector for correct RT
                SARTPRTHit(SARTPHits,1) = SARTPData.SARTPRT(SARTPIdx);
            % else 
            elseif SARTPData.SARTPResp(SARTPIdx) == ""
                % accuracy = incorrect
                SARTPData.SARTPAccuracyCheck(SARTPIdx) = "miss";
                % no response so no RT to record
            end
        % else if the number is a 3
        elseif SARTPData.SARTPStim(SARTPIdx) == 3
            % add 1 to target counter
            SARTPTargets = SARTPTargets + 1;
            % if SARTResp is a space
            if SARTPData.SARTPResp(SARTPIdx) == "space"
                % add 1 to the false alarm counter
                SARTPFAs = SARTPFAs + 1;
                % accuracy = incorrect
                SARTPData.SARTPAccuracyCheck(SARTPIdx) = "falsealarm";
                % add the RT for the vector for incorrect RT
                SARTPRTFA(SARTPFAs,1) = SARTPData.SARTPRT(SARTPIdx);
            else
                % accuracy = correct
                SARTPData.SARTPAccuracyCheck(SARTPIdx) = "correct";
                % do not need to add to correct times here since it's an
                % omission
            end
        end
    end
    
    
    % calculate hit rate
    SARTPHitRate = SARTPHits / SARTPNonTargets; % because they should respond to non-targets
    
    % calculate false alarm rate
    SARTPFARate = SARTPFAs / SARTPTargets; % because they should not respond to targets
    
    % if hit rate or false alarm rate is 0
    if SARTPHitRate == 0
        % add 0.01
        SARTPHitRate = 0.01;
    % if hit rate or false alarm rate is 1
    elseif SARTPHitRate == 1
        % subtract 0.01
        SARTPHitRate = 0.99;
    end
    
    if SARTPFARate == 0
        SARTPFARate = 0.01;
    elseif SARTPFARate == 1
        SARTPFARate = 0.99;
    end
    
    % calculate d'
    SARTPdPrime = SARTPHitRate - SARTPFARate;
    
    % average reaction time all trials
    SARTPMeanRT = mean(SARTPData.SARTPRT,"omitnan");
    SARTPSDRT = std(SARTPData.SARTPRT,"omitnan");

    SARTPHitMeanRT = mean(SARTPRTHit,"omitnan");
    SARTPHitSDRT = std(SARTPRTHit,"omitnan");
    
    SARTPFAMeanRT = mean(SARTPRTFA,"omitnan");
    SARTPFASDRT = std(SARTPRTFA,"omitnan");

%% Store SART Practice Scores
    
    SARTPFileID = strcat(ID,"_SARTP.csv");
    writetable(SARTPData, strcat(cleanedpdatadir,SARTPFileID));
    
    Scores = [Scores SARTPTrials SARTPTargets SARTPNonTargets SARTPHits SARTPFAs SARTPHitRate SARTPFARate SARTPdPrime SARTPMeanRT SARTPSDRT SARTPHitMeanRT SARTPHitSDRT SARTPFAMeanRT SARTPFASDRT];
    
    clear SARTP*

%% Scoring Actual SART

    % Same as practice
    
    SARTTrials = max(SARTData.SARTTrial);
    
    SARTNonTargets = 0;
    SARTTargets = 0;
    SARTHits = 0;
    SARTFAs = 0;
    
    SARTRTHit = [];
    SARTRTFA = [];
    
    % for each row of the data
    for SARTIdx = 1:(size(SARTData,1))
        % if the number in the SARTStim column is not a 3
        if SARTData.SARTStim(SARTIdx) ~= 3
            % add 1 to nontarget counter
            SARTNonTargets = SARTNonTargets + 1;
            % if SARTResp is "space"
            if SARTData.SARTResp(SARTIdx) == "space"
                % add 1 to hit counter
                SARTHits = SARTHits + 1;
                % accuracy = correct
                SARTData.SARTAccuracyCheck(SARTIdx) = "correct";
                % add the RT to the vector for correct RT
                SARTRTHit(SARTHits,1) = SARTData.SARTRT(SARTIdx);
            % else 
            elseif SARTData.SARTResp(SARTIdx) == ""
                % accuracy = incorrect
                SARTData.SARTAccuracyCheck(SARTIdx) = "miss";
                % no response so no RT to record
            end
        % else if the number is a 3
        elseif SARTData.SARTStim(SARTIdx) == 3
            % add 1 to target counter
            SARTTargets = SARTTargets + 1;
            % if SARTResp is a space
            if SARTData.SARTResp(SARTIdx) == "space"
                % add 1 to the false alarm counter
                SARTFAs = SARTFAs + 1;
                % accuracy = incorrect
                SARTData.SARTAccuracyCheck(SARTIdx) = "falsealarm";
                % add the RT for the vector for incorrect RT
                SARTRTFA(SARTFAs,1) = SARTData.SARTRT(SARTIdx);
            else
                % accuracy = correct
                SARTData.SARTAccuracyCheck(SARTIdx) = "correct";
                % do not need to add to correct times here since it's an
                % omission
            end
        end
    end
    
    
    % calculate hit rate
    SARTHitRate = SARTHits / SARTNonTargets;
    
    % calculate false alarm rate
    SARTFARate = SARTFAs / SARTTargets;
    
    % if hit rate or false alarm rate is 0
    if SARTHitRate == 0
        % add 0.01
        SARTHitRate = 0.01;
    % if hit rate or false alarm rate is 1
    elseif SARTHitRate == 1
        % subtract 0.01
        SARTHitRate = 0.99;
    end
    
    if SARTFARate == 0
        SARTFARate = 0.01;
    elseif SARTFARate == 1
        SARTFARate = 0.99;
    end
    
    % calculate d'
    SARTdPrime = SARTHitRate - SARTFARate;
    
    % average reaction time all trials
    SARTMeanRT = mean(SARTData.SARTRT,"omitnan");
    SARTSDRT = std(SARTData.SARTRT,"omitnan");

    SARTHitMeanRT = mean(SARTRTHit,"omitnan");
    SARTHitSDRT = std(SARTRTHit,"omitnan");
    
    SARTFAMeanRT = mean(SARTRTFA,"omitnan");
    SARTFASDRT = std(SARTRTFA,"omitnan");

%% Store SART Scores

    SARTFileID = strcat(ID,"_SART.csv");
    writetable(SARTData, strcat(cleaneddatadir,SARTFileID));

    Scores = [Scores SARTTrials SARTTargets SARTNonTargets SARTHits SARTFAs SARTHitRate SARTFARate SARTdPrime SARTMeanRT SARTSDRT SARTHitMeanRT SARTHitSDRT SARTFAMeanRT SARTFASDRT];
    
    clear SART*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scoring Practice Switch
    
    fprintf('Scoring Switch Task\n')

    % check single task accuracy
    % create counters for single tasks
    SwitchPShapeTrials = 0;
    SwitchPColourTrials = 0;
    
    SwitchPShapeCorrRT = [];
    SwitchPColourCorrRT = [];
    
    SwitchPTrials = 0;
    SwitchPSwitchTrials = 0;
    SwitchPStayTrials = 0;
    
    SwitchPSwitchCorrRT = [];
    SwitchPStayCorrRT = [];
    
    for SwitchPIdx = 1:size(SwitchPData,1)
        % if it is a shape trial (if shape trial information is not NaN)
        if ~isnan(SwitchPData.SwitchPShapeAcc(SwitchPIdx))
            % add to shape counter
            SwitchPShapeTrials = SwitchPShapeTrials + 1;
            % if response is correct
            if strcmp(SwitchPData.SwitchPShapeResp(SwitchPIdx),SwitchPData.SwitchPCRespSingle(SwitchPIdx))
                % accuracy check value is correct
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "correct";
                % add rt to the reaction time storage
                SwitchPShapeCorrRT = [SwitchPShapeCorrRT; SwitchPData.SwitchPShapeRT(SwitchPIdx)];
            % if no response
            elseif strcmp('',SwitchPData.SwitchPShapeResp(SwitchPIdx))
                % accuracy check value is miss
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "miss";
            % otherwise
            else
                % accuracy check value is incorrect
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "incorrect";
            end
        % if it is a colour trial
        elseif ~isnan(SwitchPData.SwitchPColourAcc(SwitchPIdx))
            % add to colour counter
            SwitchPColourTrials = SwitchPColourTrials + 1;
            % if response is correct
            if strcmp(SwitchPData.SwitchPColourResp(SwitchPIdx),SwitchPData.SwitchPCRespSingle(SwitchPIdx))
                % accuracy check value is correct
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "correct";
                % add rt to the reaction time storage
                SwitchPColourCorrRT = [SwitchPColourCorrRT; SwitchPData.SwitchPColourRT(SwitchPIdx)];
            % if no response
            elseif strcmp('',SwitchPData.SwitchPColourResp(SwitchPIdx))
                % accuracy check value is miss
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "miss";
            % otherwise
            else
                % accuracy check value is incorrect
                SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "incorrect";
            end
            
            % if it is a mixed trial
        elseif ~isnan(SwitchPData.SwitchPAcc(SwitchPIdx))
            % add to the counter
            SwitchPTrials = SwitchPTrials + 1;
            % if it is the dummy, don't do anything
            % if it is the stay condition
            if strcmp('stay',SwitchPData.SwitchPCond(SwitchPIdx))
                % add to the stay counter
                SwitchPStayTrials = SwitchPStayTrials + 1;
    
                % if they responded correctly
                if strcmp(SwitchPData.SwitchPResp(SwitchPIdx),SwitchPData.SwitchPCRespMixed(SwitchPIdx))
                    % accuracy check value is correct
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "correct";
                    % add rt to the reaction time storage
                    SwitchPStayCorrRT = [SwitchPStayCorrRT; SwitchPData.SwitchPRT(SwitchPIdx)];
                % if no response
                elseif strcmp('',SwitchPData.SwitchPResp(SwitchPIdx))
                    % accuracy check value is miss
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "miss";
                % otherwise
                else
                    % accuracy check value is incorrect
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "incorrect";
                end
                
            % if it is a switch condition
            elseif strcmp('switch',SwitchPData.SwitchPCond(SwitchPIdx))
                % add to the switch counter
                SwitchPSwitchTrials = SwitchPSwitchTrials + 1;
    
                % if they responded correctly
                if strcmp(SwitchPData.SwitchPResp(SwitchPIdx),SwitchPData.SwitchPCRespMixed(SwitchPIdx))
                    % accuracy check value is correct
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "correct";
                    % add rt to the reaction time storage
                    SwitchPSwitchCorrRT = [SwitchPSwitchCorrRT; SwitchPData.SwitchPRT(SwitchPIdx)];
                % if no response
                elseif strcmp('',SwitchPData.SwitchPResp(SwitchPIdx))
                    % accuracy check value is miss
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "miss";
                % otherwise
                else
                    % accuracy check value is incorrect
                    SwitchPData.SwitchPAccuracyCheck(SwitchPIdx) = "incorrect";
                end
            
            end
    
        end
    end
    
    % reaction time descriptives for correct trials
    SwitchPShapeCorrMeanRT = mean(SwitchPShapeCorrRT,"omitnan");
    SwitchPShapeCorrSDRT = std(SwitchPShapeCorrRT,"omitnan");
    
    SwitchPColourCorrMeanRT = mean(SwitchPColourCorrRT,"omitnan");
    SwitchPColourCorrSDRT = std(SwitchPColourCorrRT,"omitnan");
    
    SwitchPSwitchCorrMeanRT = mean(SwitchPSwitchCorrRT,"omitnan");
    SwitchPSwitchCorrSDRT = std(SwitchPSwitchCorrRT,"omitnan");
    
    SwitchPStayCorrMeanRT = mean(SwitchPStayCorrRT,"omitnan");
    SwitchPStayCorrSDRT = std(SwitchPStayCorrRT,"omitnan");
    
    % switch cost is mean rt switch - mean rt stay (for correct trials only)
    SwitchPCostRT = SwitchPSwitchCorrMeanRT - SwitchPStayCorrMeanRT;


%% Storing practice switch scoring

    SwitchPFileID = strcat(ID,"_SwitchP.csv");
    writetable(SwitchPData, strcat(cleanedpdatadir,SwitchPFileID));

    Scores = [Scores SwitchPShapeTrials SwitchPColourTrials SwitchPTrials SwitchPSwitchTrials SwitchPStayTrials SwitchPShapeCorrMeanRT SwitchPShapeCorrSDRT SwitchPColourCorrMeanRT SwitchPColourCorrSDRT SwitchPSwitchCorrMeanRT SwitchPSwitchCorrSDRT SwitchPStayCorrMeanRT SwitchPStayCorrSDRT SwitchPCostRT];
    
    clear SwitchP*

%% Scoring actual switch task

    SwitchShapeTrials = 0;
    SwitchColourTrials = 0;
    
    SwitchShapeCorrRT = [];
    SwitchColourCorrRT = [];
    
    SwitchTrials = 0;
    SwitchSwitchTrials = 0;
    SwitchStayTrials = 0;
    
    SwitchSwitchCorrRT = [];
    SwitchStayCorrRT = [];
    
    for SwitchIdx = 1:size(SwitchData,1)
        % if it is a shape trial (if shape trial information is not NaN)
        if ~isnan(SwitchData.SwitchShapeAcc(SwitchIdx))
            % add to shape counter
            SwitchShapeTrials = SwitchShapeTrials + 1;
            % if response is correct
            if strcmp(SwitchData.SwitchShapeResp(SwitchIdx),SwitchData.SwitchCRespSingle(SwitchIdx))
                % accuracy check value is correct
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "correct";
                % add rt to the reaction time storage
                SwitchShapeCorrRT = [SwitchShapeCorrRT; SwitchData.SwitchShapeRT(SwitchIdx)];
            % if no response
            elseif strcmp('',SwitchData.SwitchShapeResp(SwitchIdx))
                % accuracy check value is miss
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "miss";
            % otherwise
            else
                % accuracy check value is incorrect
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "incorrect";
            end
        % if it is a colour trial
        elseif ~isnan(SwitchData.SwitchColourAcc(SwitchIdx))
            % add to colour counter
            SwitchColourTrials = SwitchColourTrials + 1;
            % if response is correct
            if strcmp(SwitchData.SwitchColourResp(SwitchIdx),SwitchData.SwitchCRespSingle(SwitchIdx))
                % accuracy check value is correct
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "correct";
                % add rt to the reaction time storage
                SwitchColourCorrRT = [SwitchColourCorrRT; SwitchData.SwitchColourRT(SwitchIdx)];
            % if no response
            elseif strcmp('',SwitchData.SwitchColourResp(SwitchIdx))
                % accuracy check value is miss
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "miss";
            % otherwise
            else
                % accuracy check value is incorrect
                SwitchData.SwitchAccuracyCheck(SwitchIdx) = "incorrect";
            end
            
            % if it is a mixed trial
        elseif ~isnan(SwitchData.SwitchAcc(SwitchIdx))
            % add to the counter
            SwitchTrials = SwitchTrials + 1;
            % if it is the dummy, don't do anything
            % if it is the stay condition
            if strcmp('stay',SwitchData.SwitchCond(SwitchIdx))
                % add to the stay counter
                SwitchStayTrials = SwitchStayTrials + 1;
    
                % if they responded correctly
                if strcmp(SwitchData.SwitchResp(SwitchIdx),SwitchData.SwitchCRespMixed(SwitchIdx))
                    % accuracy check value is correct
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "correct";
                    % add rt to the reaction time storage
                    SwitchStayCorrRT = [SwitchStayCorrRT; SwitchData.SwitchRT(SwitchIdx)];
                % if no response
                elseif strcmp('',SwitchData.SwitchResp(SwitchIdx))
                    % accuracy check value is miss
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "miss";
                % otherwise
                else
                    % accuracy check value is incorrect
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "incorrect";
                end
                
            % if it is a switch condition
            elseif strcmp('switch',SwitchData.SwitchCond(SwitchIdx))
                % add to the switch counter
                SwitchSwitchTrials = SwitchSwitchTrials + 1;
    
                % if they responded correctly
                if strcmp(SwitchData.SwitchResp(SwitchIdx),SwitchData.SwitchCRespMixed(SwitchIdx))
                    % accuracy check value is correct
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "correct";
                    % add rt to the reaction time storage
                    SwitchSwitchCorrRT = [SwitchSwitchCorrRT; SwitchData.SwitchRT(SwitchIdx)];
                % if no response
                elseif strcmp('',SwitchData.SwitchResp(SwitchIdx))
                    % accuracy check value is miss
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "miss";
                % otherwise
                else
                    % accuracy check value is incorrect
                    SwitchData.SwitchAccuracyCheck(SwitchIdx) = "incorrect";
                end
            
            end
    
        end
    end
    
    % reaction time descriptives for correct trials
    SwitchShapeCorrMeanRT = mean(SwitchShapeCorrRT,"omitnan");
    SwitchShapeCorrSDRT = std(SwitchShapeCorrRT,"omitnan");
    
    SwitchColourCorrMeanRT = mean(SwitchColourCorrRT,"omitnan");
    SwitchColourCorrSDRT = std(SwitchColourCorrRT,"omitnan");
    
    SwitchSwitchCorrMeanRT = mean(SwitchSwitchCorrRT,"omitnan");
    SwitchSwitchCorrSDRT = std(SwitchSwitchCorrRT,"omitnan");
    
    SwitchStayCorrMeanRT = mean(SwitchStayCorrRT,"omitnan");
    SwitchStayCorrSDRT = std(SwitchStayCorrRT,"omitnan");
    
    % switch cost is mean rt switch - mean rt stay (for correct trials only)
    SwitchCostRT = SwitchSwitchCorrMeanRT - SwitchStayCorrMeanRT;
    
%% Storing actual switch scores

    SwitchFileID = strcat(ID,"_Switch.csv");
    writetable(SwitchData,strcat(cleaneddatadir,SwitchFileID));
    
    Scores = [Scores SwitchShapeTrials SwitchColourTrials SwitchTrials SwitchSwitchTrials SwitchStayTrials SwitchShapeCorrMeanRT SwitchShapeCorrSDRT SwitchColourCorrMeanRT SwitchColourCorrSDRT SwitchSwitchCorrMeanRT SwitchSwitchCorrSDRT SwitchStayCorrMeanRT SwitchStayCorrSDRT SwitchCostRT];
    
    clear Switch*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scoring Sym Span Practice

    fprintf('Scoring Symmetry Span Task\n')

    % Store reaction time for single and mixed tasks
    SymSpanPSymOnlyRT = [];
    SymSpanPRecOnlyRT = [];
    SymSpanPSymMixedRT = [];
    SymSpanPRecMixedRT = [];
    
    % Counters
    SymSpanPMixedTrials = 0;
    SymSpanPMixedAccuracy = 0;
    
    % to check accuracy
    % for each row
    % This loop could be simplified but I just built on checking accuracy to
    % get rt information.
    for SymPIdx = 1:size(SymSpanPData,1)
    
        % find where SymSpanPSymCResp has information
        if ~strcmp('',SymSpanPData.SymSpanPSymCResp(SymPIdx))
            % check that SymSpanPSymResp matches
            if strcmp(SymSpanPData.SymSpanPSymCResp(SymPIdx),SymSpanPData.SymSpanPSymResp(SymPIdx))
                % record correct, incorrect, miss
                SymSpanPData.SymSpanPSymAccuracyCheck(SymPIdx) = "correct";
            elseif strcmp('',SymSpanPData.SymSpanPSymResp(SymPIdx))
                SymSpanPData.SymSpanPSymAccuracyCheck(SymPIdx) = "miss";
            else
                SymSpanPData.SymSpanPSymAccuracyCheck(SymPIdx) = "incorrect";
            end
            
            % if there is no recall stimulus
            if strcmp('',SymSpanPData.SymSpanPRecStim(SymPIdx))
                % add reaction time to the symmetry only storage
                SymSpanPSymOnlyRT = [SymSpanPSymOnlyRT; SymSpanPData.SymSpanPSymRT(SymPIdx)];
            % if there is a recall stimulus
            elseif ~strcmp('',SymSpanPData.SymSpanPRecStim(SymPIdx))
                % add reaction time to symmetry mixed storage
                SymSpanPSymMixedRT = [SymSpanPSymMixedRT; SymSpanPData.SymSpanPSymRT(SymPIdx)];
            end
    
        end
    
        % find where there is a recall stimulus
        if ~strcmp('',SymSpanPData.SymSpanPRecStim(SymPIdx))
            % check that SymSpanPRecRespMatches
            if strcmp(SymSpanPData.SymSpanPRecStim(SymPIdx),SymSpanPData.SymSpanPRecResp(SymPIdx))
                % record correct, incorrect
                % recall does not allow misses.
                SymSpanPData.SymSpanPRecAccuracyCheck(SymPIdx) = "correct";
            else
                SymSpanPData.SymSpanPRecAccuracyCheck(SymPIdx) = "incorrect";
            end
    
            % check if there is no symmetry stimulus
            if strcmp('',SymSpanPData.SymSpanPSymCResp(SymPIdx))
                % add reaction time to recall only storage
                SymSpanPRecOnlyRT = [SymSpanPRecOnlyRT; SymSpanPData.SymSpanPRecRT(SymPIdx)];
            % if there is a symmetry stimulus
            elseif ~strcmp('',SymSpanPData.SymSpanPSymCResp(SymPIdx))
                % add reaction time to recall mixed storage
                SymSpanPRecMixedRT = [SymSpanPRecMixedRT; SymSpanPData.SymSpanPRecRT(SymPIdx)];
            end
        end
        
        % just adding it as a new loop
        % if there are stimuli for both symmetry and recall
        if ~strcmp('',SymSpanPData.SymSpanPSymCResp(SymPIdx)) && ~strcmp('',SymSpanPData.SymSpanPRecStim(SymPIdx))
            % add to the mixed trials counter
            SymSpanPMixedTrials = SymSpanPMixedTrials + 1;
            
            % if they also responded to the recall correctly
            if strcmp("correct",SymSpanPData.SymSpanPRecAccuracyCheck(SymPIdx))
                % add to the accuracy counter
                SymSpanPMixedAccuracy = SymSpanPMixedAccuracy + 1;
            end
        end
    
    end
    
    % if they do not have reaction time data
    % SymSPanPSymRT and SymSpanPRecRT will be NaN
    % otherwise can grab mean and SD of rt for symmetry only, recall only, and
    % mixed task
    if isnan(sum(str2double(SymSpanPSymOnlyRT)))
        SymSpanPSymOnlyMeanRT = sum(str2double(SymSpanPSymOnlyRT));
        SymSpanPSymOnlySDRT = sum(str2double(SymSpanPSymOnlyRT));
        
        SymSpanPRecOnlyMeanRT = sum(str2double(SymSpanPSymOnlyRT));
        SymSpanPRecOnlySDRT = sum(str2double(SymSpanPSymOnlyRT));
        
        SymSpanPSymMixedMeanRT = sum(str2double(SymSpanPSymOnlyRT));
        SymSpanPSymMixedSDRT = sum(str2double(SymSpanPSymOnlyRT));
        
        SymSpanPRecMixedMeanRT = sum(str2double(SymSpanPSymOnlyRT));
        SymSpanPRecMixedSDRT = sum(str2double(SymSpanPSymOnlyRT));
    else
        SymSpanPSymOnlyMeanRT = mean(SymSpanPSymOnlyRT,"omitnan");
        SymSpanPSymOnlySDRT = std(SymSpanPSymOnlyRT,"omitnan");
        
        SymSpanPRecOnlyMeanRT = mean(SymSpanPRecOnlyRT,"omitnan");
        SymSpanPRecOnlySDRT = std(SymSpanPRecOnlyRT,"omitnan");
        
        SymSpanPSymMixedMeanRT = mean(SymSpanPSymMixedRT,"omitnan");
        SymSpanPSymMixedSDRT = std(SymSpanPSymMixedRT,"omitnan");
        
        SymSpanPRecMixedMeanRT = mean(SymSpanPRecMixedRT,"omitnan");
        SymSpanPRecMixedSDRT = std(SymSpanPRecMixedRT,"omitnan");
    end

%% Store Sym Span Practice

    SymSpanPFileID = strcat(ID,"_SymSpanP.csv");
    writetable(SymSpanPData, strcat(cleanedpdatadir,SymSpanPFileID));

    Scores = [Scores SymSpanPSymOnlyMeanRT SymSpanPSymOnlySDRT SymSpanPRecOnlyMeanRT SymSpanPRecOnlySDRT SymSpanPSymMixedMeanRT SymSpanPSymMixedSDRT SymSpanPRecMixedMeanRT SymSpanPRecMixedSDRT SymSpanPMixedTrials SymSpanPMixedAccuracy];
    
    clear SymSpanP* SymPIdx

%% Scoring Actual SymSpan

    % Counters
    SymSpanTrials = 0;
    SymSpanAccuracy = 0;
    
    for SymIdx = 1:size(SymSpanData,1)
        % add to counter
        SymSpanTrials = SymSpanTrials + 1;
        % all rows should have symmetry and recall stimuli
        % if they respond to symmetry correctly
        if strcmp(SymSpanData.SymSpanMixSymCResp(SymIdx),SymSpanData.SymSpanMixSymResp(SymIdx))
            SymSpanData.SymSpanMixSymAccuracyCheck(SymIdx) = "correct";
        % if they don't respond    
        elseif strcmp('',SymSpanData.SymSpanMixSymResp(SymIdx))
                
                % ASSUMING IF THEY DON'T RESPOND IT WILL JUST BE ''
                % will need to test this with other data as the examples both
                % have full responding.
    
            SymSpanData.SymSpanMixSymAccuracyCheck(SymIdx) = "miss";
    
        else
            SymSpanData.SymSpanMixSymAccuracyCheck(SymIdx) = "incorrect";
        end
    
        % check that SymSpanMixRecRespMatches
        if strcmp(SymSpanData.SymSpanMixRecStim(SymIdx),SymSpanData.SymSpanMixRecResp(SymIdx))
            % record correct, incorrect
            % recall does not allow misses.
            SymSpanData.SymSpanMixRecAccuracyCheck(SymIdx) = "correct";
            % add to counter
            SymSpanAccuracy = SymSpanAccuracy + 1;
        else
            SymSpanData.SymSpanMixRecAccuracyCheck(SymIdx) = "incorrect";
        end
    
    end
    
    if isnan(sum(str2double(SymSpanData.SymSpanMixSymRT)))
        SymSpanMixSymMeanRT = sum(str2double(SymSpanData.SymSpanMixSymRT));
        SymSpanMixSymSDRT = sum(str2double(SymSpanData.SymSpanMixSymRT));
        
        SymSpanMixRecMeanRT = sum(str2double(SymSpanData.SymSpanMixSymRT));
        SymSpanMixRecSDRT = sum(str2double(SymSpanData.SymSpanMixSymRT));
    else
        SymSpanMixSymMeanRT = mean(SymSpanMixSymMixedRT,"omitnan");
        SymSpanMixSymSDRT = std(SymSpanMixSymMixedRT,"omitnan");
        
        SymSpanMixRecMeanRT = mean(SymSpanMixRecMixedRT,"omitnan");
        SymSpanMixRecSDRT = std(SymSpanMixRecMixedRT,"omitnan");
    end



%% Store Actual SymSPan

    SymSpanFileID = strcat(ID,"_SymSpan.csv");
    writetable(SymSpanData,strcat(cleaneddatadir,SymSpanFileID));

    Scores = [Scores SymSpanMixSymMeanRT SymSpanMixSymSDRT SymSpanMixRecMeanRT SymSpanMixRecSDRT SymSpanTrials SymSpanAccuracy];
    
    clear Sym*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Score Practice NBack

    fprintf('Scoring N-Back Task \n')

    % The practices are always the same sequence with the
    % same number of targets.
    
    % Store Reaction Time
    NBack1PHitRT = [];
    NBack1PFART = [];
    NBack2PHitRT = [];
    NBack2PFART = [];
    
    % Counters for correct trials
    NBack1PHits = 0;
    NBack1PFAs = 0;
    NBack2PHits = 0;
    NBack2PFAs = 0;
    
    % This is just going to be a mess of if loops for now
    
    % For each row
    for NBackPIdx = 1:size(NBackPData,1)
        % If it's a 1-back trial
        if ~isnan(NBackPData.NBack1PTrial(NBackPIdx))
            % check if the current trial is a target
            % except for when NBack1PTrial = 1
            if NBackPData.NBack1PTrial(NBackPIdx) ~= 1
                % If the NBackPStim matches the previous NBackPStim, it's a target
                if strcmp(NBackPData.NBackPStim(NBackPIdx),NBackPData.NBackPStim(NBackPIdx - 1))
                    % so if NBack1PResp is 'space' this is a correct response - hit
                    if strcmp('space',NBackPData.NBack1PResp(NBackPIdx))
                        % add to hit counter
                        NBack1PHits = NBack1PHits + 1;
                        % add to hit RT storage
                        NBack1PHitRT = [NBack1PHitRT; NBackPData.NBack1PRT(NBackPIdx)];
                        % mark as correct
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "correct";
                    else
                        % otherwise it's a miss
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "miss";
                    end
                % if the stimuli do not match
                elseif ~strcmp(NBackPData.NBackPStim(NBackPIdx),NBackPData.NBackPStim(NBackPIdx - 1))
                    % and they pressed 'space' this is a false alarm
                    if strcmp('space',NBackPData.NBack1PResp(NBackPIdx))
                        % add to the false alarm counter
                        NBack1PFAs = NBack1PFAs + 1;
                        % add to the false alarm RT storage
                        NBack1PFART = [NBack1PFART; NBackPData.NBackP1RT(NBackPIdx)];
                        % mark as incorrect
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "incorrect";
                    end
                end
            end
    
        % If it's a 2-back trial
        elseif ~isnan(NBackPData.NBack2PTrial(NBackPIdx))
            % check if the current trial is a target
            % Except for when NBack2PTrial = 1 or 2 (dummies)
            if NBackPData.NBack2PTrial(NBackPIdx) ~= 1 && NBackPData.NBack2PTrial(NBackPIdx) ~= 2
                % if NBackPStim matches the NBackPStim two trials back, it's
                % a target
                if strcmp(NBackPData.NBackPStim(NBackPIdx),NBackPData.NBackPStim(NBackPIdx - 2))
                    % so if NBack2PResp is 'space' this is a hit
                    if strcmp('space',NBackPData.NBack2PResp(NBackPIdx))
                        % add to hit counter
                        NBack2PHits = NBack2PHits + 1;
                        % add to hit RT storage
                        NBack2PHitRT = [NBack2PHitRT; NBackPData.NBack2PRT(NBackPIdx)];
                        % mark as correct
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "correct";
                    % otherwise it's a miss
                    else
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "miss";
                    end
                % if the stimuli do not match
                elseif ~strcmp(NBackPData.NBackPStim(NBackPIdx),NBackPData.NBackPStim(NBackPIdx - 2))
                    % and they pressed 'space' it's a false alarm
                    if strcmp('space',NBackPData.NBack2PResp(NBackPIdx))
                        % add to the false alarm counter
                        NBack2PFAs = NBack2PFAs + 1;
                        % add to the false alarm RT storage
                        NBack2PFART = [NBack2PFART; NBackPData.NBack2PRT(NBackPIdx)];
                        % mark as incorrect
                        NBackPData.NBackPAccuracyCheck(NBackPIdx) = "incorrect";
                    end
                end
            end
        end
    end
    
    % number of practice targets (for hits); and nontargets (for false alarms)
    NBack1PTargets = 2;
    NBack2PTargets = 3;
    NBack1PNonTargets = 8;
    NBack2PNonTargets = 7;
    
    % hit rate = correct responses to target/ total number of targets
    NBack1PHitRate = NBack1PHits/NBack1PTargets;
    NBack2PHitRate = NBack2PHits/NBack2PTargets;
    
    % false alarm rate = incorrect response to non-target / non-targets
    NBack1PFARate = NBack1PFAs/NBack1PNonTargets;
    NBack2PFARate = NBack2PFAs/NBack2PNonTargets;
    
    % could combine the following loops since we should be able to assume that
    % if Hit rate is 0; false alarm rate is 1; and vice versa, but just in case
    % I'm leaving them separate.
    
    % if hit rate or false alarm rate is 0
    if NBack1PHitRate == 0
        % add 0.01
        NBack1PHitRate = 0.01;
    % if hit rate or false alarm rate is 1
    elseif NBack1PHitRate == 1
        % subtract 0.01    
        NBack1PHitRate = 0.99;
    end
    
    if NBack2PHitRate == 0
        NBack2PHitRate = 0.01;
    elseif NBack2PHitRate == 1
        NBack2PHitRate = 0.99;
    end
    
    if NBack1PFARate == 0
        NBack1PFARate = 0.01;
    elseif NBack1PFARate == 1  
        NBack1PFARate = 0.99;
    end
    
    if NBack2PFARate == 0
        NBack2PFARate = 0.01;
    elseif NBack2PFARate == 1
        NBack2PFARate = 0.99;
    end
    
    % measure of interest (d prime) = hit rate - false alarm rate
    
    NBack1PDPrime = NBack1PHitRate - NBack1PFARate;
    NBack2PDPrime = NBack2PHitRate - NBack2PFARate;
    
    % get average and SD for RT for 1-back hits and FAs, and 2-back hits and
    % FAs
    NBack1PHitMeanRT = mean(NBack1PHitRT,"omitnan");
    NBack1PHitSDRT = std(NBack1PHitRT,"omitnan");
    NBack1PFAMeanRT = mean(NBack1PFART,"omitnan");
    NBack1PFASDRT = std(NBack1PFART,"omitnan");
    
    NBack2PHitMeanRT = mean(NBack2PHitRT,"omitnan");
    NBack2PHitSDRT = std(NBack2PHitRT,"omitnan");
    NBack2PFAMeanRT = mean(NBack2PFART,"omitnan");
    NBack2PFASDRT = std(NBack2PFART,"omitnan");
    
%% Store Practice NBack

    NBackPFileID = strcat(ID,"_NBackP.csv");
    writetable(NBackPData, strcat(cleanedpdatadir,NBackPFileID));
    
    Scores = [Scores NBack1PHits NBack1PFAs NBack1PTargets NBack1PNonTargets NBack1PHitRate NBack1PFARate NBack1PDPrime NBack1PHitMeanRT NBack1PHitSDRT NBack1PFAMeanRT NBack1PFASDRT NBack2PHits NBack2PFAs NBack2PTargets NBack2PNonTargets NBack2PHitRate NBack2PFARate NBack2PDPrime NBack2PHitMeanRT NBack2PHitSDRT NBack2PFAMeanRT NBack2PFASDRT];
    
    clear NBack1P* NBack2P*

%% Score Actual NBack

    % Store Reaction Time
    NBack1HitRT = [];
    NBack1FART = [];
    NBack2HitRT = [];
    NBack2FART = [];
    
    % Counters for correct trials
    NBack1Hits = 0;
    NBack1FAs = 0;
    NBack2Hits = 0;
    NBack2FAs = 0;
    
    NBack1Targets = 0;
    NBack1NonTargets = 0;
    NBack2Targets = 0;
    NBack2NonTargets = 0;
    
    % dummies are never marked as targets.
    % Loop to find hits, false alarms, and corresponding reaction times
    for NBackIdx = 1:size(NBackData,1)
        % If it's a 1-back trial other than trials 1 and 2
        if ~isnan(NBackData.NBack1Trial(NBackIdx)) && NBackData.NBack1Trial(NBackIdx) ~= 1 && NBackData.NBack1Trial(NBackIdx) ~= 2
            % check if the current trial is a target
            % if it is a target
            if strcmp('1',NBackData.Target(NBackIdx))
                % add to target counter
                NBack1Targets = NBack1Targets + 1;
                % and they responded
                if strcmp('space',NBackData.NBack1Resp(NBackIdx))
                    % add to hit counter
                    NBack1Hits = NBack1Hits + 1;
                    % add to RT storage
                    NBack1HitRT = [NBack1HitRT; NBackData.NBack1RT(NBackIdx)];
                    % mark as correct
                    NBackData.NBackAccuracyCheck(NBackIdx) = "correct";
                % and they did not respond
                else
                    % it's a miss
                    NBackData.NBackAccuracyCheck(NBackIdx) = "miss";
                end
            % if it is not a target
            else
                % and they responded
                if strcmp('space',NBackData.NBack1Resp(NBackIdx))
                    % add to FA counter
                    NBack1FAs = NBack1FAs + 1;
                    % add to RT storage
                    NBack1FART = [NBack1FART; NBackData.NBack1RT(NBackIdx)];
                    % mark as incorrect
                    NBackData.NBackAccuracyCheck(NBackIdx) = "incorrect";
                end
                % if it is not a target or a dummy
                if strcmp('0',NBackData.Target(NBackIdx))
                    % add to non-target counter
                    NBack1NonTargets = NBack1NonTargets + 1;
                end
            end
        % If it's a 2-back trial other than trials 1 and 2
        elseif ~isnan(NBackData.NBack2Trial(NBackIdx)) && NBackData.NBack2Trial(NBackIdx) ~= 1 && NBackData.NBack2Trial(NBackIdx) ~= 2
            % check if the current trial is a target
            if strcmp('1',NBackData.Target(NBackIdx))
                % add to target counter
                NBack2Targets = NBack2Targets + 1;
                % and they responded
                if strcmp('space',NBackData.NBack2Resp(NBackIdx))
                    % add to hit counter
                    NBack2Hits = NBack2Hits + 1;
                    % add to RT storage
                    NBack2HitRT = [NBack2HitRT; NBackData.NBack2RT(NBackIdx)];
                    % mark as correct
                    NBackData.NBackAccuracyCheck(NBackIdx) = "correct";
                % and they did not respond
                else
                    % it's a miss
                    NBackData.NBackAccuracyCheck(NBackIdx) = "miss";
                end
            % if it is not a target
            else
                % and they responded
                if strcmp('space',NBackData.NBack2Resp(NBackIdx))
                    % add to FA counter
                    NBack2FAs = NBack2FAs + 1;
                    % add to RT storage
                    NBack2FART = [NBack2FART; NBackData.NBack2RT(NBackIdx)];
                    % mark as incorrect
                    NBackData.NBackAccuracyCheck(NBackIdx) = "incorrect";
                end
                % if it is not a target or a dummy
                if strcmp('0',NBackData.Target(NBackIdx))
                    % add to non-target counter
                    NBack2NonTargets = NBack2NonTargets + 1;
                end
            end
        end
    end
    
    % hit rate = correct responses to target/ total number of targets
    NBack1HitRate = NBack1Hits/NBack1Targets;
    NBack2HitRate = NBack2Hits/NBack2Targets;
    
    % false alarm rate = incorrect response to non-target / non-targets
    NBack1FARate = NBack1FAs/NBack1NonTargets;
    NBack2FARate = NBack2FAs/NBack2NonTargets;
    
    % if hit rate or false alarm rate is 0
    if NBack1HitRate == 0
        % add 0.01
        NBack1HitRate = 0.01;
    % if hit rate or false alarm rate is 1
    elseif NBack1HitRate == 1
        % subtract 0.01    
        NBack1HitRate = 0.99;
    end
    
    if NBack2HitRate == 0
        NBack2HitRate = 0.01;
    elseif NBack2HitRate == 1
        NBack2HitRate = 0.99;
    end
    
    if NBack1FARate == 0
        NBack1FARate = 0.01;
    elseif NBack1FARate == 1  
        NBack1FARate = 0.99;
    end
    
    if NBack2FARate == 0
        NBack2FARate = 0.01;
    elseif NBack2FARate == 1
        NBack2FARate = 0.99;
    end
    
    % measure of interest (d prime) = hit rate - false alarm rate
    
    NBack1DPrime = NBack1HitRate - NBack1FARate;
    NBack2DPrime = NBack2HitRate - NBack2FARate;
    
    % get average and SD for RT for 1-back hits and FAs, and 2-back hits and
    % FAs
    NBack1HitMeanRT = mean(NBack1HitRT,"omitnan");
    NBack1HitSDRT = std(NBack1HitRT,"omitnan");
    NBack1FAMeanRT = mean(NBack1FART,"omitnan");
    NBack1FASDRT = std(NBack1FART,"omitnan");
    
    NBack2HitMeanRT = mean(NBack2HitRT,"omitnan");
    NBack2HitSDRT = std(NBack2HitRT,"omitnan");
    NBack2FAMeanRT = mean(NBack2FART,"omitnan");
    NBack2FASDRT = std(NBack2FART,"omitnan");


%% Store Actual NBack

    NBackFileID = strcat(ID,"_NBack.csv");
    writetable(NBackData,strcat(cleaneddatadir,NBackFileID));

    Scores = [Scores NBack1Hits NBack1FAs NBack1Targets NBack1NonTargets NBack1HitRate NBack1FARate NBack1DPrime NBack1HitMeanRT NBack1HitSDRT NBack1FAMeanRT NBack1FASDRT NBack2Hits NBack2FAs NBack2Targets NBack2NonTargets NBack2HitRate NBack2FARate NBack2DPrime NBack2HitMeanRT NBack2HitSDRT NBack2FAMeanRT NBack2FASDRT];
    
    clear NBack*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Score Practice MCT

    fprintf('Scoring MCT\n')

    % record thought type from instructions responses
    % can just concatinate?
    MCTPInstProbe = strcat(MCTPData.MCTInstProbeOnOffResp(1),MCTPData.MCTInstProbeAwareResp(1),MCTPData.MCTInstProbeIntentResp(1));

    % make an array for storing probe responses
    MCTPProbeResps = [];
    MCTPErrorType = []; % for a general list of errors during the practice, for the actual task will
    %  get a counter for each type of error
    MCTPErrorResp = []; % for a list of responses to the error, actual task use a counter
    
    % make counters for errors/probes (use counter for probe types for actual data)
    MCTPProbes = 0;
    % MCTPTrials = 0; number of practice trials is always 25.
    MCTPCorrect = 0;
    MCTPNoneResp = 0;

    for MCTPIdx = 1:(size(MCTPData,1))
        
        % if the probe type is 0, they did not make any error
        if MCTPData.MCTPProbeType(MCTPIdx) == 0
            % record that they did not make an error during the practice
            MCTPErrorType = {'NONE'};
            % record practice probe response
            MCTPProbeResp = strcat(MCTPData.MCTPProbeOnOffResp(MCTPIdx), MCTPData.MCTPProbeAwareResp(MCTPIdx), MCTPData.MCTPProbeIntentResp(MCTPIdx));
    
        % if probe type is any other probe type
        elseif MCTPData.MCTPProbeType(MCTPIdx) == 1 || MCTPData.MCTPProbeType(MCTPIdx) == 2 || MCTPData.MCTPProbeType(MCTPIdx) == 3
            % record the type of error they made, if multiple, add the errors
            % to a list.
            if isempty(MCTPErrorType)
                MCTPErrorType = {MCTPData.MCTPProbeTypeText(MCTPIdx)};
            else
                MCTPErrorType = strcat(MCTPErrorType,',',MCTPData.MCTPProbeTypeText(MCTPIdx));
            end
            % add to the error counter
            MCTPProbes = MCTPProbes + 1;
            % Record practice probe response
            MCTPProbeResp = strcat(MCTPData.MCTPProbeOnOffResp(MCTPIdx), MCTPData.MCTPProbeAwareResp(MCTPIdx), MCTPData.MCTPProbeIntentResp(MCTPIdx));
            % store it in the array, added to the end if there was a previous
            % probe
            if isempty(MCTPProbeResps)
                MCTPProbeResps = [MCTPProbeResp];
            else
                MCTPProbeResps = strcat(MCTPProbeResps,',',MCTPProbeResp);
            end
    
            % record responses to the thought probe intro, just in case
            if isempty(MCTPErrorResp)
                MCTPErrorResp = MCTPData.MCTPProbeIntroResp(MCTPIdx);
            else
                MCTPErrorResp = strcat(MCTPErrorResp,',',MCTPData.MCTPProbeIntroResp(MCTPIdx));
            end
    
            % Add the trial number difference of this probe and the most recent
            % probe
            % MCTPProbeTrialDiffs = [MCTPProbeTrialDiffs; (MCTPIdx - MCTPProbeTrialDiff)];
            % store the trial number of the current probe to calculate the
            % trial number difference between the next probe and the current
            % probe
            % MCTPProbeTrialDiff = MCTPIdx;
            % the above should not be important for the practice MCT
    
        % otherwise probe type will be NaN for the trials.
        elseif isnan(MCTPData.MCTPProbeType(MCTPIdx))
            % if the trial number is 20 and the response is left
            if MCTPData.MCTPToneNum(MCTPIdx) == 20 && strcmp('left',MCTPData.MCTPResp(MCTPIdx))
                % add to the 'correct' counter
                MCTPCorrect = MCTPCorrect + 1;
            end
    
        end
        % regardless of probe type, if the response is empty, it's a none
        % response
        % in the practice, this is except when trial number is NaN
        if ~isnan(MCTPData.MCTPToneNum(MCTPIdx)) && isempty(MCTPData.MCTPResp(MCTPIdx))
            % add to the non-response counter
            MCTPNoneResp = MCTPNoneResp + 1;
        end
    end
    
    % if they made no errors, there will be no error response so no information
    % will be added to the scores
    if isempty(MCTPErrorResp)
        MCTPErrorResp = {'NoErrors'};
    end


%% Store Practice MCT

    MCTPFileID = strcat(ID,"_MCTP.csv");
    writetable(MCTPData, strcat(cleanedpdatadir,MCTPFileID));

    Scores = [Scores MCTPInstProbe MCTPProbeResp MCTPErrorType MCTPErrorResp MCTPProbes MCTPCorrect MCTPNoneResp];
    
    clear MCTP

%% Score Actual MCT

    MCTMW = size(find(strcmp('MW',MCTData.MCTProbeOnOffResp)),1);
    % vs MCTOnTask = 0;
    MCTAware = size(find(strcmp('Aware',MCTData.MCTProbeAwareResp)),1);
    % vs MCTUnaware = 0;
    MCTIntentional = size(find(strcmp('Intentional',MCTData.MCTProbeIntentResp)),1);
    % vs MCTUnintentional = 0;
    
    MCTProbes = size(find(~isnan(MCTData.MCTProbeType)),1);
    
    % number of error types
    MCTMiscount = size(find(strcmp('Miscount',MCTData.MCTProbeTypeText)),1);
    MCTTimeout = size(find(strcmp('Timeout',MCTData.MCTProbeTypeText)),1);
    MCTLostCount = size(find(strcmp('LostCount',MCTData.MCTProbeTypeText)),1);
    % number of probe intro responses
    MCTThoughtCorrect = size(find(strcmp('ThoughtCorrect',MCTData.MCTProbeIntroResp)),1);
    MCTContinued = size(find(strcmp('Continue',MCTData.MCTProbeIntroResp)),1);
    MCTContinuedWrongKey = size(find(strcmp('ContinuedWrongKey',MCTData.MCTProbeIntroResp)),1);
    MCTAccident = size(find(strcmp('Accident',MCTData.MCTProbeIntroResp)),1);
    
    % for the combined types of thought probe responses and other things, we
    % will need to loop
    
    % make an array for storing probe responses
    MCTProbeResps = [];
    MCTProbeRespsArray = [];
    % may not need this but just in case
    
    MCTNonResp = 0;
    MCTCorrect = 0;
    % MCTTrials = 0; % trials should always be 825 unless a participant
    % withdraws early.
    
    % store row number for probe differences
    MCTProbeTrialDiff = 0;
    % store probe differences in another array
    MCTProbeTrialDiffs = [];
    
    % for each row
    for MCTIdx = 1:size(MCTData,1)
        % if there is a probe
        if ~isnan(MCTData.MCTProbeType(MCTIdx))
            % record probe response
            MCTProbeResp = strcat(MCTData.MCTProbeOnOffResp(MCTIdx), MCTData.MCTProbeAwareResp(MCTIdx), MCTData.MCTProbeIntentResp(MCTIdx));
            if isempty(MCTProbeResps)
                MCTProbeResps = [MCTProbeResp];
            else
                MCTProbeResps = strcat(MCTProbeResps,',',MCTProbeResp);
                MCTProbeRespsArray = [MCTProbeRespsArray,MCTProbeResp];
            end
            % could loop through each response type and put each type into a
            % counter
            % or just count them up at the end by going into MCTProbeResp
            % also record trial differences between probes
    
            % Add the trial number difference of this probe and the most recent
            % probe
            MCTProbeTrialDiffs = [MCTProbeTrialDiffs; (MCTIdx - MCTProbeTrialDiff)];
            % store the trial number of the current probe to calculate the
            % trial number difference between the next probe and the current
            % probe
            MCTProbeTrialDiff = MCTIdx;
     
        % else if there is no probe
        elseif isnan(MCTData.MCTProbeType(MCTIdx))
            % if response is 'left' and MCTTrial is 20
            if MCTData.MCTToneNum(MCTIdx) == 20 && strcmp('left',MCTData.MCTResp(MCTIdx))
                %add to the 'correct' counter'
                MCTCorrect = MCTCorrect + 1;
            end
    
            % if they did not respond
            if strcmp('',MCTData.MCTResp(MCTIdx))
                MCTNonResp = MCTNonResp + 1;
            end
        end
    end
    
    MCTMWAwareInt = size(find(strcmp('MWAwareIntentional',MCTProbeRespsArray)),2);
    MCTMWAwareUnint = size(find(strcmp('MWAwareUnintentional',MCTProbeRespsArray)),2);
    MCTMWUnawareInt = size(find(strcmp('MWUnawareIntentional',MCTProbeRespsArray)),2);
    MCTMWUnawareUnint = size(find(strcmp('MWUnawareUnintentional',MCTProbeRespsArray)),2);
    
    MCTMWAware = MCTMWAwareInt + MCTMWAwareUnint;
    MCTMWUnaware = MCTMWUnawareInt + MCTMWUnawareUnint;
    MCTMWIntentional = MCTMWAwareInt + MCTMWUnawareInt;
    MCTMWUnintentional = MCTMWAwareUnint + MCTMWUnawareUnint;
    
    MCTProbeTrialDiffsMin = min(MCTProbeTrialDiffs);
    MCTProbeTrialDiffsMax = max(MCTProbeTrialDiffs);
    MCTProbeTrialDiffsMean = mean(MCTProbeTrialDiffs);
    MCTProbeTrialDiffsSD = std(MCTProbeTrialDiffs);
    
    if isempty(MCTProbeResps)
        MCTProbeResps = {'NoProbes'};
    end

%% Store Actual MCT

    MCTFileID = strcat(ID,"_MCT.csv");
    writetable(MCTData,strcat(cleaneddatadir,MCTFileID));

    Scores = [Scores MCTCorrect MCTNonResp MCTProbeResps MCTProbes MCTMiscount MCTTimeout MCTLostCount MCTThoughtCorrect MCTAccident MCTContinuedWrongKey MCTContinued MCTMW MCTAware MCTIntentional MCTMWAware MCTMWUnaware MCTMWIntentional MCTMWUnintentional MCTMWAwareInt MCTMWAwareUnint MCTMWUnawareInt MCTMWUnawareUnint MCTProbeTrialDiffsMin MCTProbeTrialDiffsMax MCTProbeTrialDiffsMean MCTProbeTrialDiffsSD];
    
    clear MCT*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Combine Scoring Table

    fprintf('Storing Scores \n')

    TaskScores = [TaskScores; Scores];
    clear Scores

end

%% Save arrays for task info and scores

    fprintf('Saving Additions to Task Info and Scoring.\n')

% outside of the loop so with all new information added at once
% write to file
writetable(TaskInfo, [maindir 'RPS_PsychoPyTaskInfo.csv']);
writetable(TaskScores, [maindir 'RPS_Task_Scores.csv']);
