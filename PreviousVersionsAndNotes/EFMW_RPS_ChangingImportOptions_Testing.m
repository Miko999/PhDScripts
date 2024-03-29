
% DATA IMPORT IS NOT CONSISTENT ACROSS FILES. Sometimes files are imported
% with some variables as cells, other times they are doubles
        % need to find a way to have things import as desired.


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


%% Find file names and import options
rawdatadir = [maindir 'RawData/'];
cleaneddatadir = [maindir 'CleanedData/'];
cleanedpdatadir = [maindir 'CleanedPracticeData/'];
addpath(genpath(maindir))

fprintf('Collecting raw file names\n')

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

filenamestring = mat2str(filematrix); 
% change filename to string
filenamestring = strrep(filenamestring,'''','');
%remove extra ' characters

% load in data file

% seems like files are inconsistent in terms of how many columns they
% contain due to differences in mistakes etc.
% so may have to go variable by variable and change settings..

opts = detectImportOptions([rawdatadir filenamestring]);
opts.VariableNamingRule = 'preserve'; % need to set to preserve or it changes variable names ot match matlab syntax

%% Change import options

% opts.SelectedVariableNames = {'Smoker','Diastolic','Systolic'}; lets you
% select what variables you want to import, could save some time on
% cleaning them out later...

% opts = setvaropts(opts,Name,Value)
% opts = setvaropts(opts,{'Diastolic','Systolic'},'FillValue',0);

% but this depends on what variables are present
% set variables we want as 'double' to 'double
% opts = setvaropts(opts,{'EFtasksrandomizerloop.thisRepN','EFtasksrandomizerloop.thisTrialN' ...
%    ,'EFtasksrandomizerloop.thisN','EFtasksrandomizerloop.thisIndex','EFtasksrandomizerloop.ran' ...
%    ,'EFTask1','EFTask2','EFTask3','EFTask4','subtask1','subtask2','SARTkey_resp_practice.corr' ...
%    ,'SARTkey_resp_practice.rt','SARTpracticeloop.thisRepN','SARTpracticeloop.thisTrialN' ...
%    ,'SARTpracticeloop.thisN','SARTpracticeloop.thisIndex','SARTpracticeloop.ran','number' ...
%    ,'SARTkey_resp_trials.corr','SARTkey_resp_trials.rt','SARTblock1loop.thisRepN' ...
%    ,'SARTblock1loop.thisTrialN','SARTblock1loop.thisN','SARTblock1loop.thisIndex' ...
%    ,'SARTblock1loop.ran','SARTloop.thisRepN','SARTloop.thisTrialN','SARTloop.thisN' ...
%    ,'SARTloop.thisIndex','SARTloop.ran','pshape_resp.corr','pshape_resp.rt' ...
%    ,'practiceshapeloop.thisRepN','practiceshapeloop.thisTrialN','practiceshapeloop.thisN' ...
%    ,'practiceshapeloop.thisIndex','shapetrialsresp.corr','shapetrialsresp.rt' ...
%    ,'shapetrialsloop.thisRepN','shapetrialsloop.thisTrialN','shapetrialsloop.thisN' ...
%    ,'shapetrialsloop.thisIndex','shapetrialsloop.ran','switch_shapetrials.thisRepN' ...
%    ,'switch_shapetrials.thisTrialN','switch_shapetrials.thisN','switch_shapetrials.thisIndex' ...
%    ,'switch_shapetrials.ran','counterbalance_switch_shapecolour.thisRepN' ...
%    ,'counterbalance_switch_shapecolour.thisTrialN','counterbalance_switch_shapecolour.thisN' ...
%    ,'counterbalance_switch_shapecolour.thisIndex','counterbalance_switch_shapecolour.ran' ...
%    ,'pcolour_resp.corr','pcolour_resp.rt','practicecolourloop.thisRepN','practicecolourloop.thisTrialN' ...
%    ,'practicecolourloop.thisN','practicecolourloop.thisIndex','practicecolourloop.ran' ...
%    ,'colourtrialresp.corr','colourtrialresp.rt','colourtrialsloop.thisRepN','colourtrialsloop.thisTrialN' ...
%    ,'colourtrialsloop.thisN','colourtrialsloop.thisIndex','colourtrialsloop.ran' ...
%    ,'switch_colourtrials.thisRepN','switch_colourtrials.thisTrialN','switch_colourtrials.thisN' ...
%    ,'switch_colourtrials.thisIndex','switch_colourtrials.ran','mixpracticedummyresp.corr' ...
%    ,'mixpracticedummyresp.rt','mixpracticeresp.corr','mixpracticeresp.rt' ...
%    ,'practicemixedloop.thisRepN','practicemixedloop.thisTrialN','practicemixedloop.thisN' ...
%    ,'practicemixedloop.thisIndex','practicemixedloop.ran','switchcond','mixeddummyresp.corr' ...
%    ,'mixeddummyresp.rt','mixedtrialsresp.corr','mixedtrialsresp.rt','mixedblock1.thisRepN' ...
%    ,'mixedblock1.thisTrialN','mixedblock1.thisN','mixedblock1.thisIndex','mixedblock1.ran' ...
%    ,'colour_shape_switch_task.thisRepN','colour_shape_switch_task.thisTrialN' ...
%    ,'colour_shape_switch_task.thisN','colour_shape_switch_task.thisIndex' ...
%    ,'colour_shape_switch_task.ran','symmpracticeloop.thisRepN','symmpracticeloop.thisTrialN' ...
%    ,'symmpracticeloop.thisN','symmpracticeloop.thisIndex','symmpracticeloop.ran' ...
%    ,'symmetrical','symmetryloop.thisRepN','symmetryloop.thisTrialN','symmetryloop.thisN' ...
%    ,'symmetryloop.thisIndex','symmetryloop.ran','symmspansubtasksloop.thisRepN' ...
%    ,'symmspansubtasksloop.thisTrialN','symmspansubtasksloop.thisN','symmspansubtasksloop.thisIndex' ...
%    ,'symmspansubtasksloop.ran','symmpracticesquareloop.thisRepN','symmpracticesquareloop.thisTrialN' ...
%    ,'symmpracticesquareloop.thisN','symmpracticesquareloop.thisIndex','symmpracticesquareloop.ran' ...
%    ,'symmpracticerecalloop.thisRepN','symmpracticerecalloop.thisTrialN','symmpracticerecalloop.thisN' ...
%    ,'symmpracticerecalloop.thisIndex','symmpracticerecalloop.ran','symmmempracticeloop.thisRepN' ...
%    ,'symmmempracticeloop.thisTrialN','symmmempracticeloop.thisN','symmmempracticeloop.thisIndex' ...
%    ,'symmmempracticeloop.ran','memnumber','recallloop.thisRepN','recallloop.thisTrialN' ...
%    ,'recallloop.thisN','recallloop.thisIndex','recallloop.ran','symmspansymmploop.thisRepN' ...
%    ,'symmspansymmploop.thisTrialN','symmspansymmploop.thisN','symmspansymmploop.thisIndex' ...
%    ,'symmspansymmploop.ran','symmspanrecallploop.thisRepN','symmspanrecallploop.thisTrialN' ...
%    ,'symmspanrecallploop.thisN','symmspanrecallploop.thisIndex','symmspanrecallploop.ran' ...
%    ,'symmspanploop.thisRepN','symmspanploop.thisTrialN','symmspanploop.thisN' ...
%    ,'symmspanploop.thisIndex','symmspanploop.ran','symmspanblocksymmloop.thisRepN' ...
%    ,'symmspanblocksymmloop.thisTrialN','symmspanblocksymmloop.thisN','symmspanblocksymmloop.thisIndex' ...
%    ,'symmspanblocksymmloop.ran','symmspanrecallblocksloop.thisRepN','symmspanrecallblocksloop.thisTrialN' ...
%    ,'symmspanrecallblocksloop.thisN','symmspanrecallblocksloop.thisIndex','symmspanrecallblocksloop.ran' ...
%    ,'symmspanblocksloop.thisRepN','symmspanblocksloop.thisTrialN','symmspanblocksloop.thisN' ...
%    ,'symmspanblocksloop.thisIndex','symmspanblocksloop.ran','symmspanendkey.rt' ...
%    ,'symmspantaskloop.thisRepN','symmspantaskloop.thisTrialN','symmspantaskloop.thisN' ...
%    ,'symmspantaskloop.thisIndex','symmspantaskloop.ran','presp_1back.corr' ...
%    ,'practice1backloop.thisRepN','practice1backloop.thisTrialN','practice1backloop.thisN' ...
%    ,'practice1backloop.thisIndex','practice1backloop.ran','presp_1back.rt' ...
%    ,'resp_dummy1back.corr','dummy1backloop.thisRepN','dummy1backloop.thisTrialN' ...
%    ,'dummy1backloop.thisN','dummy1backloop.thisIndex','dummy1backloop.ran','resp_1back.corr' ...
 %   ,'resp_1back.rt','trials_1backloop.thisRepN','trials_1backloop.thisTrialN' ...
  %  ,'trials_1backloop.thisN','trials_1backloop.thisIndex','trials_1backloop.ran' ...
%    ,'target','presp_2back.corr','practice2backloop.thisRepN','practice2backloop.thisTrialN' ...
%    ,'practice2backloop.thisN','practice2backloop.thisIndex','practice2backloop.ran' ...
%    ,'presp_2back.rt','resp_dummy2back.corr','dummy2backloop.thisRepN','dummy2backloop.thisTrialN' ...
%    ,'dummy2backloop.thisN','dummy2backloop.thisIndex','dummy2backloop.ran','resp_2back.corr' ...
 %   ,'trials_2backloop.thisRepN','trials_2backloop.thisTrialN','trials_2backloop.thisN' ...
 %   ,'trials_2backloop.thisIndex','trials_2backloop.ran','resp_2back.rt','nbacktask.thisRepN' ...
 %   ,'nbacktask.thisTrialN','nbacktask.thisN','nbacktask.thisIndex','nbacktask.ran' ...
 %   ,'onoff_resp_instructions_2.rt','aware_resp_instructions_2.rt','intent_response_instructions_2.rt' ...
 %   ,'tone_number','tone_practicetrial_resp.rt','practiceloop.thisRepN','practiceloop.thisTrialN' ...
 %   ,'practiceloop.thisN','practiceloop.thisIndex','practiceloop.ran','probetype' ...
 %   ,'practiceprobeloop.thisRepN','practiceprobeloop.thisTrialN','practiceprobeloop.thisN' ...
 %   ,'practiceprobeloop.thisIndex','practiceprobeloop.ran','onoff_resp_2.rt','aware_resp_2.rt' ...
 %   ,'ifnoprobepracticeloop.thisRepN','ifnoprobepracticeloop.thisTrialN','ifnoprobepracticeloop.thisN' ...
 %   ,'ifnoprobepracticeloop.thisIndex','ifnoprobepracticeloop.ran','tone_trial_resp.rt' ...
 %   ,'toneloop1.thisRepN','toneloop1.thisTrialN','toneloop1.thisN','toneloop1.thisIndex' ...
 %   ,'toneloop1.ran','probe_resp.rt','onoff_resp.rt','aware_resp.rt','intent_response.rt' ...
 %   ,'probeloop1.thisRepN','probeloop1.thisTrialN','probeloop1.thisN','probeloop1.thisIndex' ...
 %   ,'probeloop1.ran'},'double');


% listing out the variables with just single quotes in one set of {}, with
% double quotes and one set of {}, and with single quotes and each within
% {} within a larger {} leads to the following error
% Expected a string scalar or character vector for the parameter name.

% opts = setvartype(opts,"SARTkey_resp_practice_corr",'string');
% with single quotes in {} we get 'unknown variable name'
% double quotes in {} give us 'selection must be a string array, character
% vector, or cell array of character vectors
% rounded quotes gives an error
% double quotes within single quotes doesn't work
% no quotes gives 'unable to resolve name)
% issue was the variable name didn't exist
% running with existing variable, the above works.

% opts = setvartype(opts,{'SARTkey_resp_practice_corr','SARTkey_resp_practice_rt'},'string');
% this also works


% maybe better to loop through all of the variable names and set
% accordingly?



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
%% Import
rawdata = readtable([rawdatadir filenamestring],opts);
% creates a table where all variables are 'cell'


clear filename filenamestring %opts