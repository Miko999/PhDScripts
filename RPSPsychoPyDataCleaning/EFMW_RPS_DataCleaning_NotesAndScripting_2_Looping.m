%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning Code

% Chelsie H.
% Started: November 8, 2022
% Last updated: June 21, 2023
% Last tested: June 28, 2023

    % Purpose: 
% Record task and participant information to a Task Info spreadsheet
% Remove irrelevant data from raw data, save this cleaned data,
% Eventually calculate scores or variables of interest, save the scores.

    % Input: .csv from psychopy data in RawData Folder (counters always start at 0 in raw data)
% Raw file names are usually in this format: PARTICIPANT_EFMW_Tasks_RPS_..
% followed by digits for YYYY-MM-DD_HHhMM.SS.MsMsMs (the h is 'h', Ms are millisecond digits)

    % Current Output: separate .csv files for each task and each practice task
% for each participant in the RawData Folder, saved in Cleaned Data and
% Cleaned Practice Data folders.

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
% Create script to score tasks (dummy trials needed for scoring but
% should not themselves contribute to scoring)
% Combine spreadsheet with scores with spreadsheet of questionnaire scores
% and demographics
% scoring for the MCT may include looking for non-responders or excessive
% failure
% Check if accuracy data from psychopy is actually correct.

    % Future ideas:
% Could add something such that if the participant ID matches files in the
% cleaned data, the script should stop.
% Remove trials where there were issues during data collection
% Only import variable names that are of use for data cleaning.
% Edit the task to have variable names and save variables in a way that
% makes indexing easier

%% Versions and Packages

% Main PC: Matlab R2021b update 6
% Packages: Stats and machine learning toolbox version 12.2, simulink
% version 10.4, signal processing toolbox version 8.7, image processing
% toolbox version 11.4; FieldTrip 1.0.1.0

% Laptop:
% Packages:
% Surfacebook: Matlab R2021b update 6
% Packages: Stats and Machine Learning Toolbox 10.4,
% Simulink 10.4, Signal Processing Toolbox 8.7, Image Procesisng Toolbax 11.4, Images
% Acquision Toolbox 6.5

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
    
%% Combinging task information for raw data file

    fprintf('Combining task info\n')

    NewTaskInfo = [ID Date expName psychopyversion OS frameRate TaskOrder];

    % combine this with what wsa taken from TaskInfo, adding the new
    % information to the end of that table.
    TaskInfo = [TaskInfo; NewTaskInfo];
    % this will be saved outside of the loop, so should just extend for
    % ever raw data file processed
        
    clear TaskRandCol TaskRandIdx TaskRandIdxNum TaskRandRow SymSubTaskRandRow 
    clear SymSubTaskRandIdxNum SwitchSubTaskRandRow SwitchSubTaskRandIdxNum
    clear psychopyversion OS frameRate TaskOrder NewTaskInfo
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
                MCTPProbeRowNum = MCTProbeRows(MCTPProbeRIdx);
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
    
%% Add reaction time relative to stimulus onset to MCT
    
    % sound starts at 0.75 seconds relative to the start of the routine and
    % lasts for 0.075 seconds

    MCTPData.("MCTPRTDiff") = MCTPData.("MCTPRT") - 0.75;
    
    MCTData.("MCTRTDiff") = MCTData.("MCTRT") - 0.75;
    
    
    
%% Save cleaned data for checking

    fprintf('Saving processed data\n')
    
    % could have made a loop for file names but hardcoding for now.

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

end

%% Save the task info array

% outside of the loop so with all new information added at once
% write to file
writetable(TaskInfo, [maindir 'RPS_PsychoPyTaskInfo.csv']);

