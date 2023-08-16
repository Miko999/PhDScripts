%% Executive Functioning and Mind Wandering (RPS) Study - Combining Cleaned Data
% Chelsie H.
% Started: July 28, 2023
% Last updated: July 28, 2023
% Last tested: August 16, 2023

    % Purpose: 
% Combined cleaned data from PsychoPy and Qualtrics for running analyses
% ensuring data are combined by participant ID

    % Input:
% RPS_Task_Scores.csv created from EFMW_RPS_DataCleaning_Scoring matlab
% script and most recent CleanedQualtricsData .csv file from
% EFMW_RPS_DataCleaning_Qualtrics.m file.

    % Current Output:
% .csv with all scores called RPSData.csv in main scripting folder. This
% was made using examples to create the appropriate number of columns.

%% Notes

    % TO DO:
% add extra variables from participant tracker. (use
% RPSDataCleaningTrackerNotes)

    % Future Ideas
% combine with other scripts to make one huge script.


%% Versions and Packages

% Main PC: Matlab R2021b update 6
% Packages: Stats and machine learning toolbox version 12.2, simulink
% version 10.4, signal processing toolbox version 8.7, image processing
% toolbox version 11.4; FieldTrip 1.0.1.0

%% Set Directories
clc
clear

% Request for which device to set directory
LaptopOrDesktop = input('Which device are you using? (1 for Desktop, 2 for Laptop):');

fprintf('Setting directories\n')

if LaptopOrDesktop == 1
    % on desktop 
    maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/');

else
    % on laptop 
    maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/');
end

% qualtrics data location
QDataDir = [maindir 'RPSQualtricsDataCleaning/CleanedData/'];

addpath(genpath(maindir))

%% Load in Data

fprintf('Loading in cleaned data\n')

% PsychoPyData

PPData = readtable([maindir 'RPSPsychoPyDataCleaning/RPS_Task_Scores.csv']);

% Qualtrics Data
% may need to find a way for it to load the most recent file.

% this grabs all of the files in a directory
QFiles = dir([maindir 'RPSQualtricsDataCleaning/CleanedData/']);

% then we clear out the unnamed files
QFiles = QFiles(~[QFiles.isdir]);

% and get the order for the dimension of interest
[DateNumber,DateOrder] = sort([QFiles.datenum],'descend');
% descending order since most recent would be the greater number - based on
% trying to test this out in the command window

QFiles = QFiles(DateOrder);

% Select the most recent file
FileName = QFiles.name;
% doesn't allow numeric indexing but this just takes the first value.

opts = detectImportOptions([maindir 'RPSQualtricsDataCleaning/CleanedData/' FileName]);
opts.VariableNamingRule = 'preserve';
 
QData = readtable([maindir 'RPSQualtricsDataCleaning/CleanedData/' FileName],opts);

clear DateOrder FileName opts

%% Load in previously combined data

opts = detectImportOptions([maindir 'RPSCombinedData.csv']);
opts.VariableNamingRule = 'preserve';
FullDataFile = readtable([maindir 'RPSCombinedData.csv'],opts);

clear opts

%% Combining Data

% Have to look at if QData.PID and PDate.ParticipantID are equal

% if they are not equal, add these as separate rows with blanks for the
% data that is not available.

% if they are equal put them in the same row.

% doing it the following way means looping through QData and not PPData so
% can't find where PPData has extra participants without QData though....

% loop through each row of QData
FullData = table();

DataRowCounter = 0;

StopFlag = 0;

for Idx = 1:size(QData,1)
    % first check whether the data has already been added to the file
    % if there is no match, the comparison of PIDs should come up empty.
    % if it is not empty, there is a match and the loop should just move on
    if isempty(find(strcmp(QData.PID(Idx),FullDataFile.PID),1))
        % find the row where PPData has the same ID
        if ~isempty(find(strcmp(QData.PID(Idx),PPData.ParticipantID),1))
            
            PPRow = find(strcmp(QData.PID(Idx),PPData.ParticipantID),1);
    
            DataRowCounter = DataRowCounter + 1;
    
            FullData(DataRowCounter,:) = [QData(Idx,:),PPData(PPRow,(2:end))];
    
        else
    
            fprintf('\nThere is no PsychoPyData for Participant: %s\n', string(QData.PID(Idx)));
    
            ContinueLoop = input('Continue? (Y or N)','s');
            if strcmp('N',ContinueLoop)
               StopFlag = 1;
            end
    
        end
    
        if StopFlag == 1
            StopFlag = 0;
            break
        end
    end
end

%% Add New Data to Existing Full Data

% if the full data is not empty
if ~isempty(FullData)
    FullDataFile = [FullDataFile;FullData];
    writetable(FullData, strcat(maindir,'RPSCombinedData.csv'));
else
    fprintf('\nNo new combined psychopy and qualtrics data.\n')
end
