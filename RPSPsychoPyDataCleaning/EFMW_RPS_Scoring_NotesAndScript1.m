%% Executive Functioning and Mind Wandering (RPS) Study - Task Scoring Code

% Chelsie H.
% Started: June 28, 2023
% Last updated: July 19, 2023
% Last tested: (once script is complete)

    % Purpose: 
% Take cleaned task data from data cleaning script and score each task and 
% practice task as outlined in the preregistration for this study
% Also, grabbing some descriptive statistics for checking the data

    % Input:
% .csv files from CleanedData and CleanedPracticeData folders
% raw file names are usually PARTICIPANTID_TASK.csv or
% PARTICIPANTID_TASKP.csv for practice

    % Current Output:
% all scores added to the RPS_Task_Scores.csv

    % Example data files:
% RPS003_demo...csv and Test_...csv
% RPS003_demo does not have reaction time for the symmetry span task as it
% is an older data file from before this issue was corrected.

%% Notes

    % To do's:
% add this all to the data cleaning script 

    % Future ideas:
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

% Laptop:
% Packages:


%% Clear all and Select Directory - REMOVE WHEN THIS IS ADDED TO CLEANING LOOP
% WHEN THIS IS ADDED TO DATA CLEANING LOOP Just use the data for each task

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

cleaneddatadir = [maindir 'CleanedData/'];
cleanedpdatadir = [maindir 'CleanedPracticeData/'];
addpath(genpath(maindir))

opts = detectImportOptions([maindir 'RPS_PsychoPyTaskInfo.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskInfo = readtable([maindir 'RPS_PsychoPyTaskInfo.csv'],opts);
    
clear opts

%% Load in scoring storage file

%%  JUST USING FIRST DEMO DATA FOR TESTING THE SCRIPT
ID = "RPS003_demo"; %"Test"

% Just to check that opts are correct
% SARTDataFile = fullfile(cleaneddatadir, strcat(ID,"_SART.csv"));
% SwitchDataFile = fullfile(cleaneddatadir, strcat(ID,"_Switch.csv"));
% SymSpanDataFile = fullfile(cleaneddatadir, strcat(ID,"_SymSpan.csv"));
% NBackDataFile = fullfile(cleaneddatadir, strcat(ID,"_NBack.csv"));
% MCTDataFile = fullfile(cleaneddatadir, strcat(ID,"_MCT.csv"));

% opts = detectImportOptions(MCTDataFile);
% all importing seems to be fine except if the participant has no symspan
% reaction times, the columns may be imported as characters.

SARTData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SART.csv")));
SwitchData = readtable(fullfile(cleaneddatadir, strcat(ID,"_Switch.csv")));
SymSpanData = readtable(fullfile(cleaneddatadir, strcat(ID,"_SymSpan.csv")));
NBackData = readtable(fullfile(cleaneddatadir, strcat(ID,"_NBack.csv")));
MCTData = readtable(fullfile(cleaneddatadir, strcat(ID,"_MCT.csv")));

SARTPData = readtable(fullfile(cleanedpdatadir, strcat(ID,"_SARTP.csv")));
SwitchPData = readtable(fullfile(cleanedpdatadir, strcat(ID,"_SwitchP.csv")));
SymSpanPData = readtable(fullfile(cleanedpdatadir, strcat(ID,"_SymSpanP.csv")));
NBackPData = readtable(fullfile(cleanedpdatadir, strcat(ID,"_NBackP.csv")));
MCTPData = readtable(fullfile(cleanedpdatadir, strcat(ID,"_MCTP.csv")));

%% Record Participant and Task Info for storage

% remove the following once this is all part of the larger loop.

ID = {'RPS003_demo'};
Date = {'2022-10-31_13h07.10.649'};
TaskOrder = {'SASWscSYsrN'};

Scores = [ID Date TaskOrder];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring SART Notes
% difference between correct response to non-targets (hit) and falsely responding
% to 3 (false alarm)
% if hit rate or false alarm rate are 0 or 1, adjust by 0.01

% so need to find:
% number of trials (should be consistent across participants)
    % should also just be maximum of SARTTrial/SARPTrial
% number of correct responses to numbers other than 3
% number of incorrectly responding to number 3
% hit rate = correct responses to numbers other than 3 / total numbers
% other than 3
% false alarm rate = incorrect response to 3 / total 3s
% measure of interest (d prime) = correct to non targets - incorrect
% responses to 3
% or hit rate minus false alarm rate?
% some studies report mean accuracy rates

% could make a new column for accuracy and counters for nontargets,
% targets, hits, false alarms,

% for each row of the data
    % check the number in the SARTStim column
    % if the number is not a 3
        % add 1 to nontarget counter
        % check that SARTResp is "space"
        % if the response is a space
            % add 1 to hit counter
            % accuracy = correct
        % else if they did not respond
            % accuracy = miss
    % if the number is a 3
        % add 1 to target counter
        % check that SARTResp is empty (or not a 'space')
        % if the response is not empty (or is a 'space')
            % add 1 to the false alarm counter
            % accuracy = falsealarm
        % else
            % accuracy = correct

% accuracy may be useful later.

% calculate hit rate

% calculate false alarm rate

% if hit rate or false alarm rate is 0
    % add 0.01
% if hit rate or false alarm rate is 1
    % subtract 0.01

% calculate d'

% will also want reaction time and sd of reaction time for all trials, for
% correct trials, and for incorrect trials.

   
%% Scoring Practice SART

SARTPTrials = max(SARTPData.SARTPTrial);

% create counters
SARTPNonTargets = 0;
SARTPTargets = 0;
SARTPHits = 0;
SARTPFAs = 0;

% for each row of the data
% for SARTPIdx = 1:(size(SARTPData,1))
%    % if the number in the SARTStim column is not a 3
%    if SARTPData.SARTPStim(SARTPIdx) ~= 3
%        % add 1 to nontarget counter
%        SARTPHits = SARTPHits + 1;
%        % if SARTResp is "space"
%        if SARTPData.SARTPResp(SARTPIdx) == "space"
%            % add 1 to hit counter
%            SARTPHits = SARTPHits + 1;
%            % accuracy = correct
%            SARTPData.SARTPAccuracyCheck(SARTPIdx) = "correct";
%        % else 
%        elseif SARTPData.SARTPResp(SARTPIdx) == ""
%            % accuracy = incorrect
%            SARTPData.SARTPAccuracyCheck(SARTPIdx) = "miss";
%        end
%    % else if the number is a 3
%    elseif SARTPData.SARTPStim(SARTPIdx) == 3
%        % add 1 to target counter
%        SARTPTargets = SARTPTargets + 1;
%        % if SARTResp is a space
%        if SARTPData.SARTPResp(SARTPIdx) == "space"
%            % add 1 to the false alarm counter
%            SARTPFAs = SARTPFAs + 1;
%            % accuracy = incorrect
%            SARTPData.SARTPAccuracyCheck(SARTPIdx) = "falsealarm";
%        else
%            % accuracy = correct
%            SARTPData.SARTPAccuracyCheck(SARTPIdx) = "correct";
%        end
%    end
%end

% Second version for adding in grabbing descriptive stats for correct and
% incorrect trials
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

% average reaction time for correct trials and incorrect trials
% there is no reaction time for non-response
% since we only want correct trials we could nest this into the previous
% loop

SARTPHitMeanRT = mean(SARTPRTHit,"omitnan");
SARTPHitSDRT = std(SARTPRTHit,"omitnan");

SARTPFAMeanRT = mean(SARTPRTFA,"omitnan");
SARTPFASDRT = std(SARTPRTFA,"omitnan");

% if they made no correct or incorrect key presses, the mean and SD will be
% NaN

%% Store SART Practice Scores

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

% average reaction time for correct trials and incorrect trials
% there is no reaction time for non-response
% since we only want correct trials we could nest this into the previous
% loop

SARTHitMeanRT = mean(SARTRTHit,"omitnan");
SARTHitSDRT = std(SARTRTHit,"omitnan");

SARTFAMeanRT = mean(SARTRTFA,"omitnan");
SARTFASDRT = std(SARTRTFA,"omitnan");

% if they made no correct or incorrect key presses, the mean and SD will be
% NaN

%% Store SART Scores

Scores = [Scores SARTTrials SARTTargets SARTNonTargets SARTHits SARTFAs SARTHitRate SARTFARate SARTdPrime SARTMeanRT SARTSDRT SARTHitMeanRT SARTHitSDRT SARTFAMeanRT SARTFASDRT];

clear SART*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring Switch Notes

% check accuracy
% calculating switch cost for reaction time for correct trials
% average reaction time for switch - average reaction time for stay
% this is for TRIALS not subtasks, calculated within the mixed blocks.

% need to calculate:
% number of mixed block stay and switch trials (should be consitent across
% participants)
% average reaction time for mixed blocks switch trials
% average reaction time for mixed blocks stay trials
% these could all be done in a loop which extracts the data for trial types
% separately

% difference between these averages

% for additional information
% sds for reaction times
% average and sd reaction time for single task blocks
% number of non responses
% average and sd reaction time for correct trials only

%% Scoring Practice Switch

% check single task accuracy
% create counters for single tasks
SwitchPShapeTrials = 0;
SwitchPColourTrials = 0;

SwitchPShapeCorrRT = [];
SwitchPColourCorrRT = [];

% for rows containing single task correct response information
%for SwitchPSingleIdx = find(~cellfun('isempty',SwitchPData.SwitchPCRespSingle),1,'first'):find(~cellfun('isempty',SwitchPData.SwitchPCRespSingle),1,'last')
%    % if it is a shape trial (if shape trial information is not NaN)
%    if ~isnan(SwitchPData.SwitchPShapeAcc(SwitchPSingleIdx))
%        % add to shape counter
%        SwitchPShapeTrials = SwitchPShapeTrials + 1;
%        % if response is correct
%        if strcmp(SwitchPData.SwitchPShapeResp(SwitchPSingleIdx),SwitchPData.SwitchPCRespSingle(SwitchPSingleIdx))
%            % accuracy check value is correct
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "correct";
%            % add rt to the reaction time storage
%            SwitchPShapeCorrRT = [SwitchPShapeCorrRT; SwitchPData.SwitchPShapeRT(SwitchPSingleIdx)];
%        % if no response
%        elseif strcmp('',SwitchPData.SwitchPShapeResp(SwitchPSingleIdx))
%            % accuracy check value is miss
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "miss";
%        % otherwise
%        else
%            % accuracy check value is incorrect
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "incorrect";
%        end
%    % if it is a colour trial
%    elseif ~isnan(SwitchPData.SwitchPColourAcc(SwitchPSingleIdx))
%        % add to colour counter
%        % if response is correct
%                SwitchPColourTrials = SwitchPColourTrials + 1;
%        % if response is correct
%        if strcmp(SwitchPData.SwitchPColourResp(SwitchPSingleIdx),SwitchPData.SwitchPCRespSingle(SwitchPSingleIdx))
%            % accuracy check value is correct
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "correct";
%            % add rt to the reaction time storage
%            SwitchPColourCorrRT = [SwitchPColourCorrRT; SwitchPData.SwitchPColourRT(SwitchPSingleIdx)];
%        % if no response
%        elseif strcmp('',SwitchPData.SwitchPColourResp(SwitchPSingleIdx))
%            % accuracy check value is miss
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "miss";
%        % otherwise
%        else
%            % accuracy check value is incorrect
%            SwitchPData.SwitchPAccuracyCheck(SwitchPSingleIdx) = "incorrect";
%        end
%        
%    end
%end

% could just use this loop to go through all trials and get mixed trial
% information
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

Scores = [Scores SwitchPShapeTrials SwitchPColourTrials SwitchPTrials SwitchPSwitchTrials SwitchPStayTrials SwitchPShapeCorrMeanRT SwitchPShapeCorrSDRT SwitchPColourCorrMeanRT SwitchPColourCorrSDRT SwitchPSwitchCorrMeanRT SwitchPSwitchCorrSDRT SwitchPStayCorrMeanRT SwitchPStayCorrSDRT SwitchPCostRT];

clear SwitchP*

%% Scoring actual switch task

% check single task accuracy
% create counters for single tasks
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

Scores = [Scores SwitchShapeTrials SwitchColourTrials SwitchTrials SwitchSwitchTrials SwitchStayTrials SwitchShapeCorrMeanRT SwitchShapeCorrSDRT SwitchColourCorrMeanRT SwitchColourCorrSDRT SwitchSwitchCorrMeanRT SwitchSwitchCorrSDRT SwitchStayCorrMeanRT SwitchStayCorrSDRT SwitchCostRT];

clear Switch*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scoring SymSpan Notes

% check accuracy
% symspan without SymSpanMixSymRT and SymSpanMixRecRT data need to be set to
% double - RPS003_Demo data imports properly,
% so could check if these rows are empty, if empty just add data of
% interest as "NaN"

% partial score, total number of squares recalled in the correct serial
% position (regardless of if whole series was correct)

% need to find: total correct red squares

% for additional information can check accuracy on symmetry part
% some studies exclude trials where the symmetry responses take longer than
% mean + SD.

%% Scoring Sym Span Practice

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
if isnan(sum(SymSpanPSymOnlyRT))
    SymSpanPSymOnlyMeanRT = sum(SymSpanPSymOnlyRT);
    SymSpanPSymOnlySDRT = sum(SymSpanPSymOnlyRT);
    
    SymSpanPRecOnlyMeanRT = sum(SymSpanPSymOnlyRT);
    SymSpanPRecOnlySDRT = sum(SymSpanPSymOnlyRT);
    
    SymSpanPSymMixedMeanRT = sum(SymSpanPSymOnlyRT);
    SymSpanPSymMixedSDRT = sum(SymSpanPSymOnlyRT);
    
    SymSpanPRecMixedMeanRT = sum(SymSpanPSymOnlyRT);
    SymSpanPRecMixedSDRT = sum(SymSpanPSymOnlyRT);
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


% partial score, total number of squares recalled in the correct serial
% position (regardless of if whole series was correct)
% could just add this to the loop such that if there were symmetry and
% recall stimuli, add 1 to total trials, and if they were correct on
% recall, add 1 to total correct



%% Store Sym Span Practice

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

% if they do not have reaction time data
% SymSPanPSymRT and SymSpanMixRecRT will be NaN
% otherwise can grab mean and SD of rt for symmetry only, recall only, and
% mixed task
if isnan(sum(SymSpanData.SymSpanMixSymRT))
    SymSpanMixSymMeanRT = sum(SymSpanData.SymSpanMixSymRT);
    SymSpanMixSymSDRT = sum(SymSpanData.SymSpanMixSymRT);
    
    SymSpanMixRecMeanRT = sum(SymSpanData.SymSpanMixSymRT);
    SymSpanMixRecSDRT = sum(SymSpanData.SymSpanMixSymRT);
else
    SymSpanMixSymMeanRT = mean(SymSpanMixSymMixedRT,"omitnan");
    SymSpanMixSymSDRT = std(SymSpanMixSymMixedRT,"omitnan");
    
    SymSpanMixRecMeanRT = mean(SymSpanMixRecMixedRT,"omitnan");
    SymSpanMixRecSDRT = std(SymSpanMixRecMixedRT,"omitnan");
end



%% Store Actual SymSPan

Scores = [Scores SymSpanMixSymMeanRT SymSpanMixSymSDRT SymSpanMixRecMeanRT SymSpanMixRecSDRT SymSpanTrials SymSpanAccuracy];

clear Sym*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scoring NBack Notes
% d prime, difference between correct response (hit) and false alarm to incorrect
% stimuli

% separately and together for 1-back and 2-back, Some studies calculate an
% average across n-back loads.
% paper referenced in preregistration calculated d-prime for each n-level
% for the n-back and averaged across these. d-prime was also calculated
% using z-scores rather than raw data...

% need to calculate
% number of trials can be taken from the counters
    % minus 1 for 1back practice, and minus 2 for 2-back practice and
    % actual task dummies
% number of correct responses to target (hits) - which includes checking accuracy
% number of incorrectly responding to number non-target
% hit rate = correct responses to target/ total number of targets
% false alarm rate = incorrect response to non-target / non-targets
% measure of interest (d prime) = correct to target - incorrect
% to non-target

% some studies have also found a ceiling effect with the 1-back

% if hit rate or false alarm rate is 0
    % add 0.01
% if hit rate or false alarm rate is 1
    % subtract 0.01


%% Score Practice NBack

% Actual NBack has an indicator for which trials are targets but the
% practices do not. The practices are always the same sequence with the
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
        if NBackData.Target(NBackIdx) == 1
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
            if NBackData.Target(NBackIdx) == 0
                % add to non-target counter
                NBack1NonTargets = NBack1NonTargets + 1;
            end
        end
    % If it's a 2-back trial other than trials 1 and 2
    elseif ~isnan(NBackData.NBack2Trial(NBackIdx)) && NBackData.NBack2Trial(NBackIdx) ~= 1 && NBackData.NBack2Trial(NBackIdx) ~= 2
        % check if the current trial is a target
        if NBackData.Target(NBackIdx) == 1
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
            if NBackData.Target(NBackIdx) == 0
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

Scores = [Scores NBack1Hits NBack1FAs NBack1Targets NBack1NonTargets NBack1HitRate NBack1FARate NBack1DPrime NBack1HitMeanRT NBack1HitSDRT NBack1FAMeanRT NBack1FASDRT NBack2Hits NBack2FAs NBack2Targets NBack2NonTargets NBack2HitRate NBack2FARate NBack2DPrime NBack2HitMeanRT NBack2HitSDRT NBack2FAMeanRT NBack2FASDRT];

clear NBack*
%% Scoring Working Memory Notes

% z-score transform and average symmetry span and n-back task scores
% this will have to happen when all data is gathered.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring MCT Notes

% record thought type from instructions responses
% record if they made an error during the practice
% record thought probe response during practice, list them if there are
% multiple?

% check frequencies of
% correct 20th beats
% incorrect 20th beats
% lost counts (if they didn't press up or left on the 25th beat)
% timeouts
% 'thought I was counting correctly'
% 'hit the wrong key by accident'
% 'hit the wrong key to continue'

% proportion of probes where participant was MW
% proportion of probes where participant was MW and aware/unaware
% proportion of probes where participant was MW and had
% intentional/unintentional thoughts
% proportion of combined thought types?

% so need number of probes
% and number of responses of each type

% number of trials where the participant did not respond to the beat.

%% Score Practice MCT

% record thought type from instructions responses
% can just concatinate?
MCTPInstProbe = strcat(MCTPData.MCTInstProbeOnOffResp(1),MCTPData.MCTInstProbeAwareResp(1),MCTPData.MCTInstProbeIntentResp(1));

% record if they made an error during the practice
% this could be if the probe is the last row, or could be if they pressed
% left at the wrong time, if they pressed up, or if they did not press left
% at all...
% or if the probe type is 0.
% or just use the probe type text made in data cleaning e.g., contains('NoErrorP',MCTPData.MCTPProbeTypeText)

% record thought probe response during practice, list them if there are
% multiple?

% can't get time between probes but can get number of trials between
% probes? (mean, sd, min, max).
% just subtract row number of the previous probe from current probe and
% store row number of current probe to use for subtraction next probe.

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

% store row number for probe differences
% MCTPProbeTrialDiff = 0;
% store probe differences in another array
% MCTPProbeTrialDiffs = [];

    
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
            MCTPErrorType = MCTPData.MCTPProbeTypeText(MCTPIdx);
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

Scores = [Scores MCTPInstProbe MCTPProbeResp MCTPErrorType MCTPErrorResp MCTPProbes MCTPCorrect MCTPNoneResp];

clear MCTP*

%% Score Actual MCT

% instead of counters for some of the information we want, it's easier to
% just use find()

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

Scores = [Scores MCTCorrect MCTNonResp MCTProbeResps MCTProbes MCTMiscount MCTTimeout MCTLostCount MCTThoughtCorrect MCTAccident MCTContinuedWrongKey MCTContinued MCTMW MCTAware MCTIntentional MCTMWAware MCTMWUnaware MCTMWIntentional MCTMWUnintentional MCTMWAwareInt MCTMWAwareUnint MCTMWUnawareInt MCTMWUnawareUnint MCTProbeTrialDiffsMin MCTProbeTrialDiffsMax MCTProbeTrialDiffsMean MCTProbeTrialDiffsSD];

clear MCT*

%% Load in Scores Data
opts = detectImportOptions([maindir 'RPS_Task_Scores.csv']);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax
TaskScores = readtable([maindir 'RPS_Task_Scores.csv'],opts);
    
clear opts

%% Combine Scores Data and Save as csv

TaskScores = [TaskScores; Scores];
writetable(TaskScores, [maindir 'RPS_Task_Scores.csv']);