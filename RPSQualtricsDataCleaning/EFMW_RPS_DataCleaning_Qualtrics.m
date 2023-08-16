%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning and Scoring Script for Questionnaires

% Chelsie H.
% Started: July 24, 2023
% Last updated: August 16, 2023
% Last tested: August 16, 2023

    % Purpose: 
% Take raw data extracted from qualtrics (numeric and choice text), and use
% this to extract demographics and score questionnaires for each
% participant by participant ID.

    % Input:
% .csv of data exported from Qualtrics, both the numeric and choice text versions
% these should have been renamed as
% "EFMW_RPS_Testing_MonthDD_YYYY_" with "ChoiceText" or "Numeric"
% This script is not made for looping through repeated files

    % Current Output:
% .csv named by date with demographics and scores for questionnaires.

    % Example data files:
% EFMW_RPS_Testing_November3_2022_ChoiceText.csv
% EFMW_RPS_Testing_November3_2022_Numeric.csv

%% Notes

    % Future Ideas
% have the indexing by column name instead of numbers that depend on
% constant output format.
% find a way to loop through multiple files while matching Choice Text and
% Numeric sheets.

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
    maindir = ('C:/Users/chish/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSQualtricsDataCleaning/');

else
    % on laptop 
    maindir = ('C:/Users/chels/OneDrive - University of Calgary/1_PhD_Project/Scripting/RPSQualtricsDataCleaning/');
end

rawdatadir = [maindir 'RawData/'];
cleaneddatadir = [maindir 'CleanedData/'];

addpath(genpath(maindir))

%% Load in Data

fprintf('Loading raw data\n')

% define file pattern/name of interest
filepattern = fullfile(rawdatadir, 'EFMW_RPS_Testing_*');

% find files in directory with file pattern
filename = dir(filepattern); 
% creates an array with dimensions: number of files with matching filepattern, 
% details for each file
% convert this to a cell array to extract only the file name
filecell = struct2cell(filename);

% The file names should be found in alphabetically order, therefore the
% first should be the choice text and the second should be numeric.

filematrixtext = cell2mat(filecell(1,1));    
% change filename to a string
filenamestringtext = mat2str(filematrixtext); 
%remove extra ' characters
filenamestringtext = strrep(filenamestringtext,'''','');

filematrixnum = cell2mat(filecell(1,2));    
filenamestringnum = mat2str(filematrixnum); 
filenamestringnum = strrep(filenamestringnum,'''','');

textopts = detectImportOptions([rawdatadir filenamestringtext]);
textopts.VariableNamingRule = 'preserve';
RawDataText = readtable([rawdatadir filenamestringtext],textopts);  

numericopts = detectImportOptions([rawdatadir filenamestringnum]);
numericopts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax

for numoptsidx = 1:(size(numericopts.VariableNames,2))
    % if the variable name contains or matches the following
    if contains(numericopts.VariableNames(numoptsidx),'Race') && ~contains(numericopts.VariableNames(numoptsidx),'TEXT')
    % these variables should be set to be doubles
        numericopts = setvartype(numericopts,numericopts.VariableNames(numoptsidx),'double');
    end

end
    
RawDataNum = readtable([rawdatadir filenamestringnum],numericopts);

clear numericopts textopts file*

%% Loop to go through each participant

% for each participant ID
for PIdx = 1:size(RawDataText)

    % Check that PIDs match across text and numeric version
    if ~strcmp(RawDataText.PID(PIdx),RawDataNum.PID(PIdx))
        fprintf('\n******\nThe choice text row for %s and the corresponding row in the numeric data do not match. \n******\n\n', string(RawDataText.PID(PIdx)));
        break
    end

%% Extract Demographics for Output

    % adding demographics before race/ethnicity
    QData = RawDataText(PIdx,18:28);
    
    % for Race/Ethnicity need to remove the (e.g.*) part and combine these into
    % one row.
    % for multiple Race/Ethnicity, may also need to create a mixed category.

    % otherwise would have to do one big 'if' loop for each race and
    % combinations.

    % just hard coding the column numbers for now
    
    if sum(RawDataNum{PIdx,29:38},2,"omitnan") > 1
        QData.RaceEthnicity = 'Mixed Race';
    else
        RaceEthnicity = strtrim(join(strcat(string(RawDataText{PIdx,29:39}))));
        RaceEthnicity = eraseBetween(RaceEthnicity,"(",")");
        RaceEthnicity = char(RaceEthnicity);
        RaceEthnicity = RaceEthnicity(1:end-3);
        % there must be a better way to do this but I don't know how.
    
        QData.RaceEthnicity = string(RaceEthnicity);
    end
    
    % add in other demographics
    % omitting diagnosis age and only grabbing if they are on medication
   
    QData = [QData, RawDataText(PIdx,[40:46,48,51:53,56,57])];

    clear RaceEthnicity

%% Score ASRS

    % according to the Novo Psych site subscales identified by Stanton et
    % al., 2018 are:

    % Inattentive Subscale, items 1,2,3,4,7,8,9,10,11
    QData.ASRSIn = sum(RawDataNum{PIdx,[60:63,66:70]},2,"omitnan");

    % Hyperactive Impulsive Motor Subscale, items 5, 6, 12, 13, 14
    QData.ASRSHIM = sum(RawDataNum{PIdx,[64,65,71:73]},2,"omitnan");

    % Hyperactive Impulsive Verbal Subscale, items 15, 16, 17, 18
    QData.ASRSHIV = sum(RawDataNum{PIdx,[74:77]},2,"omitnan");

    % sometimes studies combine the HI subscales


    % part A are the short-form high load questions
    QData.ASRSA = sum(RawDataNum{PIdx,[60:65]},2,"omitnan");

    % and total
    QData.ASRSTotal = sum(RawDataNum{PIdx,60:77},2,"omitnan");


%% Score BDEFS

    % Section Totals
    % Section 1 - Self-Management to Time, columns 78 to 98
    QData.BDEFS_SelfManagementToTime = sum(RawDataNum{PIdx,[78:98]},2,"omitnan");
    % Section 2 - Self-Organization/Problem Solving, columns 99 to 122
    QData.BDEFS_SelfOrganizationProblemSolving = sum(RawDataNum{PIdx,[99:122]},2,"omitnan");
    % Section 3 - Self-Restraint, columns 123 to 141
    QData.BDEFS_SelfRestaint = sum(RawDataNum{PIdx,[123:141]},2,"omitnan");
    % Section 4 - Self-Motivation, columns 142 to 153
    QData.BDEFS_SelfMotivation = sum(RawDataNum{PIdx,[142:153]},2,"omitnan");
    % Section 5 - Self-Regulation of Emotion, columns 154 to 166
    QData.BDEFS_SelfRegulationOfEmotion = sum(RawDataNum{PIdx,[154:166]},2,"omitnan");
    
    % Totaly EF Summary Score (sum all sections
    QData.TotalBDEFS= sum(RawDataNum{PIdx,[78:166]},2,"omitnan");

    % EF Symptom Count = number of 3s or 4s

    BDEFSSymptomCount = 0;

    for BIdx = 78:166

        if table2array(RawDataNum(PIdx,BIdx)) == 3 || table2array(RawDataNum(PIdx,BIdx)) == 4
            % == does not work with arrays

            BDEFSSymptomCount = BDEFSSymptomCount + 1;
        end
        
    end

    QData.BDEFSSymptomCount = BDEFSSymptomCount;

    % ADHD-EF Index Scoresum 1, 6, 14, 16, 24, 49, 50, 55, 60, 65, 69
    % columns 78, 83, 91, 93, 101, 126, 127, 132, 137, 142, 146

    ADHDEFCols = [78, 83, 91, 93, 101, 126, 127, 132, 137, 142, 146];

    QData.ADHDEFIndex = sum(RawDataNum{PIdx,ADHDEFCols},2,"omitnan");

    clear BDEFSSymptomCount BIdx

%% Score MEWS

    % total score columns 167 to 178

    QData.TotalMews = sum(RawDataNum{PIdx,[167:178]},2,"omitnan");

    QDataAll(PIdx,:) = QData;

    clear QData

end

%% Rename Variables

QDataAll = renamevars(QDataAll,["D1_Age","D2_Hand","D3_Sex","D3_Sex_99_TEXT", ...
    "D4_Gender","D4_Gender_99_TEXT","D5_Transgender","D5_Transgender_99_TEXT", ...
    "D6_SexualOrientation","D6_SexualOrientation_99_TEXT","D8_Education","D9_Income", ...
    "D9_Income_99_TEXT","D10_Rhythm","D11_TBI","D12_Stroke","D13.1_ADHDDiagnosis", ...
    "D13.3_ADHDMedication","D14.1_Diagnoses","D14.2_DiagSpecific","D14.3_DiagMedication", ...
    "D15.1_NonMed","D15.2_NonMedName"], ...
    ["Age","Hand","Sex","Sex_Input", ...
    "Gender","Gender_Input","Transgender","Transgender_Input", ...
    "SexualOrientation","SexualOrientation_Input","Education","Income", ...
    "Income_Input","Rhythm","TBI","Stroke","ADHDDiagnosis", ...
    "ADHDMedication","Diagnoses","DiagSpecific","DiagMedication", ...
    "NonMed","NonMedName"]);

%% Export Scores

Date = input('What is today''s date? (MonDD_YYYY):','s');

writetable(QDataAll, strcat(cleaneddatadir,'CleanedQualtricsData_',Date,'.csv'));