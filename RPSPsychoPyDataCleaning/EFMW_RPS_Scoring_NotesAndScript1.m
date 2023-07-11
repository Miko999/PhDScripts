%% Executive Functioning and Mind Wandering (RPS) Study - Task Scoring Code

% Chelsie H.
% Started: June 28, 2023
% Last updated: July 10, 2023
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
% TBD - likely a single csv with desired scores and descriptives for all
% participants RPS_Task_Scores.csv

    % Example data files:
% RPS003_demo...csv and Test_...csv
% RPS003_demo does not have reaction time for the symmetry span task as it
% is an older data file from before this issue was corrected.

%% Notes

    % To do's:
% Make a basic output csv with columns defined
% import this with proper data types for each column

% Create basic skeleton for scripting with notes on how to approach each
% part
% Score each task excluding dummies
% Derive useful descriptive statistics for each task excluding dummies (e.g., mean, sd, min, max
% for reaction time to see if anyone had any odd trials).

% Add a check for non-responders to MCT
% Count the number of probes for MCT
% Count response types for MCT

% Do a re-check of accuracy in case psychopy accuracy is not correct

% add this all to the data cleaning script 
% add task info to the output file too

% save cleaned data after scoring so that the new 'accuracy' columns are
% included'

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
ID = "RPS003_Demo";

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
SARTPHitRate = SARTPHits / SARTPNonTargets;

% calculate false alarm rate
SARTPFARate = SARTPFAs / SARTPTargets;

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
SARTPDPrime = SARTPHitRate - SARTPFARate;

% average reaction time all trials
SARTPMeanRT = mean(SARTPData.SARTPRT,"omitnan");
SARTPSDRT = std(SARTPData.SARTPRT,"omitnan");

% average reaction time for correct trials and incorrect trials
% there is no reaction time for non-response
% since we only want correct trials we could nest this into the previous
% loop

SARTPMeanHitRT = mean(SARTPRTHit,"omitnan");
SARTPSDHitRT = std(SARTPRTHit,"omitnan");

SARTPMeanFART = mean(SARTPRTFA,"omitnan");
SARTPSDFART = std(SARTPRTFA,"omitnan");

% if they made no correct or incorrect key presses, the mean and SD will be
% NaN

%% Store SART Practice Scores

% clear SARTP*

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
SARTDPrime = SARTHitRate - SARTFARate;

% average reaction time all trials
SARTMeanRT = mean(SARTData.SARTRT,"omitnan");
SARTSDRT = std(SARTData.SARTRT,"omitnan");

% average reaction time for correct trials and incorrect trials
% there is no reaction time for non-response
% since we only want correct trials we could nest this into the previous
% loop

SARTMeanHitRT = mean(SARTRTHit,"omitnan");
SARTSDHitRT = std(SARTRTHit,"omitnan");

SARTMeanFART = mean(SARTRTFA,"omitnan");
SARTSDFART = std(SARTRTFA,"omitnan");

% if they made no correct or incorrect key presses, the mean and SD will be
% NaN

%% Store SART Scores

% clear SART*

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

% clear SwitchP*
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

% clear Switch*

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

% clear SymSpanP* SymPIdx

%% Scoring Actual SymSpan

% Counters
SymSpanTrials = 0;
SymSpanAccuracy = 0;

for SymIdx = 1:size(SymSpanData,1)
    % add to counter
    SymSpanTrials = SymSpanTrials + 1;
    % all rows should have symmetry and recall stimuli
    % if they respond to symmetry correctly
    if strcmp(SymSpanData.SymSpanMixSymCResp(SymPIdx),SymSpanData.SymSpanMixSymResp(SymPIdx))
        SymSpanData.SymSpanMixSymAccuracyCheck(SymPIdx) = "correct";
    % if they don't respond    
    elseif strcmp('',SymSpanData.SymSpanMixSymResp(SymPIdx))
            
            % ASSUMING IF THEY DON'T RESPOND IT WILL JUST BE ''
            % will need to test this with other data as the examples both
            % have full responding.

        SymSpanData.SymSpanMixSymAccuracyCheck(SymPIdx) = "miss";

    else
        SymSpanData.SymSpanMixSymAccuracyCheck(SymPIdx) = "incorrect";
    end

    % check that SymSpanMixRecRespMatches
    if strcmp(SymSpanData.SymSpanMixRecStim(SymPIdx),SymSpanData.SymSpanMixRecResp(SymPIdx))
        % record correct, incorrect
        % recall does not allow misses.
        SymSpanData.SymSpanMixRecAccuracyCheck(SymPIdx) = "correct";
        % add to counter
        SymSpanAccuracy = SymSpanAccuracy + 1;
    else
        SymSpanData.SymSpanMixRecAccuracyCheck(SymPIdx) = "incorrect";
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

% clear Sym*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scoring NBack Notes
% d prime, difference between correct response (hit) and false alarm to incorrect
% stimuli

% separately and together for 1-back and 2-back, Some studies calculate an
% average across n-back loads...

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

        % HAVE TO DECIDE HOW 1-BACK AND 2-BACK WILL BE COMBINED OR IF WE
        % WANT TO CHECK CEILING BEFORE COMBINING.


%% Score Practice NBack

% Actual NBack has an indicator for which trials are targets but the
% practices do not.

% Store Reaction Time
NBack1PHitRT = [];
NBack1PFART = [];
NBack2PHitRT = [];
NBack2PFART = [];

% Counters for correct trials
NBack1PHits = 0;
NBack1PFAs = 0;
NBack2Hits = 0;
NBack2FAs = 0;

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
    elseif ~isnan(NBackPData.NBack2PTrial(NBackIdx))
        % check if the current trial is a target
        % Except for when NBack2PTrial = 1 or 2 (dummies)
        if NBackPData.NBack2PTrial(NBackIdx) ~= 1 && NBackPData.NBack2PTrial(NBackIdx) ~= 2
            % if NBackPStim matches the NBackPStim two trials back, it's
            % a target
            if strcmp(NBackPData.NBackPStim(NBackPIdx),NBackPData.NBackPStim(NBackPIdx - 2))
                % so if NBack2PResp is 'space' this is a hit
                if strcmp('space',NBackPData.NBack2PResp(NBackIdx))
                    % add to hit counter
                    NBack2Hits = NBack2Hits + 1;
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
                    NBack2FAs = NBack2FAs + 1;
                    % add to the false alarm RT storage
                    NBack2PFART = [NBack2PFART; NBackPData.NBack2PRT(NBackPIdx)];
                    % mark as incorrect
                    NBackPData.NBackPAccuracyCheck(NBackPIdx) = "incorrect";
                end
            end
        end
    end
end

% number of 1 back practice trials is the maximum of NBack1PTrial minus 1
% number of 2 back practice trials is the maximum of NBack2PTrial minus 2

% get average and SD for RT for 1-back hits and FAs, and 2-back hits and
% FAs

% hit rate = correct responses to target/ total number of targets
% false alarm rate = incorrect response to non-target / non-targets
% measure of interest (d prime) = correct to target - incorrect
% to non-target

% if hit rate or false alarm rate is 0
    % add 0.01
% if hit rate or false alarm rate is 1
    % subtract 0.01    


%% Store Practice NBack


%% Score Actual NBack


%% Store Actual NBack

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Scoring Working Memory Notes

% z-score transform and average symmetry span and n-back task scores
% this will have to happen when all data is gathered.

%% Scoring MCT Notes
% check accuracy
% proportion of probes where participant was MW
% proportion of probes where participant was MW and aware/unaware
% proportion of probes where participant was MW and had
% intentional/unintentional thoughts

% will want to get total probes for the record as well
% total probes of each type (miscount, lost count, time out)

% percentage of trials where the participant did not respond

%% OUTPUT
% will be like task info, loading in a file and adding all new information
% to it.

