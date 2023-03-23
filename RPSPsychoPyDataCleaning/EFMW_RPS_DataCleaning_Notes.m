%% Executive Functioning and Mind Wandering (RPS) Study - Data Cleaning Code

% Chelsie H.
% Started: November 8, 2022
% Last updated: February 16, 2023

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
% RPS_PsychoPyTaskInfo (will be RAD instead of RPS for RAD data)

%% Constant Data Columns
% Participant ID (informed by researcher)
% date
% expName
% psychopyVersion , OS , and frameRate

% all will be copied to a new row of the RPS_PsychoPyTaskInfo file.
% columns renamed to: ID, date(YYYY-MM-DD_HHhMM.SS.MsMsMs), experiment
% psychpyVersion, OS, and frameRate can stay the same

% Could remake date so that it isn't in YYYY-MM-DD-HHhMM.SS.MsMsMs

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

%% Will need to create some sort of variable for task order
% Likely with EFtasksrandomizerloop.thisIndex (which tells which column of
% the randomizer was used) and EFtasksrandomizerloop.thisN (which tells the
% times the loop has been referred to from 0 to 3)
% so when EFtasksrandomizerloop.thisN = 0, EFtasksrandomizerloop.thisIndex
% can be the first digit and so on to make a four digit identifier for
% randomizer task order.
% could also take EFtasksrandomizerloop.thisIndex and create a label with
% the task each row refers to.

% EFtasksrandomizerloop.thisIndex = 0 = EFTask3 = SymmSpan = SY
% (same as above)"" = EFTask1 = Switch = SW
% "" = EFTask2 = Nback = N
% "" = EFTask4 = SART = SA

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
