#######################################################################
# Controls whether the @log_[...] procedures write to the InfoLines.
# debug_mode = 1
debug_mode = 0
abort = 0

origTierNum = 4
trialTier = 5
wordTier = 6

# Include the other files mentioned in change 7 of version 2.
include ../L2T-utilities/L2T-Utilities.praat
include ../L2T-Audio/L2T-Audio.praat
include ../L2T-StartupForm/L2T-StartupForm.praat
include ../L2T-WordList/L2T-WordList.praat
include ../L2T-SegmentationTextGrid/L2T-SegmentationTextGrid.praat
include ../L2T-Transcription/L2T-Transcription.praat
include ../GFTAtranscription/GFTAProcedures.praat
include ../NonWordTranscription/NWRProcedures.praat

include modules/check_version.praat
include modules/L2T-TranscriptionTextGrid.praat
include modules/L2T-TranscriptionLog.praat
include modules/checkGFTATranscription.praat
include modules/checkNWRTranscription.praat

# Set the session parameters.
defaultExpTask = 1
defaultTestwave = 1
defaultActivity = 9
@session_parameters: defaultExpTask, defaultTestwave, defaultActivity

# Load the audio file
@audio

# Load the WordList.
@wordlist

# Load the segmented TextGrid and transcribed TextGrid to be checked.
@segmentation_textgrid
@transcribed_textgrid
@transcriptionLog

# Set the transcription-specific parameters.
@transcription_parameters

# Must be called to allow checking script to work with Transcription scripts.
@transcription_textgrid("check", session_parameters.experimental_task$,  participant.id$, session_parameters.initials$, transcription_parameters.textGridDirectory$))

#Object names
audioBasename$ = audio.praat_obj$
segmentBasename$ = segmentation_textgrid.praat_obj$
segmentTableBasename$ = segmentation_textgrid.tablePraat_obj$
transBasename$ = transcribed_textgrid.checkedTG_praat_obj$
transLogBasename$ = transcriptionLog.praat_obj$

#don't need this, once the table is created.
select 'segmentBasename$'
Remove

if session_parameters.experimental_task$ == "GFTA"
	@checkGFTATranscription
elsif session_parameters.experimental_task$ == "NonWordRep"
	@checkNWRTranscription
endif

label abort
select all
Remove