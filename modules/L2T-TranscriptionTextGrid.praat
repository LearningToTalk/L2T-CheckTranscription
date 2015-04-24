procedure transcribed_textgrid
	# Import constants from the [session_parameters] namespace.
	.initials$ = session_parameters.initials$
	.workstation$ = session_parameters.workstation$
	.experimental_task$ = session_parameters.experimental_task$
	.testwave$ = session_parameters.testwave$
	.participant_number$ = session_parameters.participant_number$
	.activity$ = session_parameters.activity$
	.experiment_directory$ = session_parameters.experiment_directory$

	.checkedDir$ = .experiment_directory$ + "/" +
		... "Transcription" + "/" +
		... "TranscriptionTextGrids/"

	.checkedTG$ =   .experimental_task$ + "_" +
		... participant.id$ + "*" +
		... "trans.TextGrid"

	@filename_from_pattern: .checkedDir$ + .checkedTG$, "Transcription TextGrid"
	.checkedTG$ = filename_from_pattern.filename$

	.write_to$ = .checkedDir$ + .checkedTG$

	if .checkedTG$ <> ""
		# Read in the Trascription TextGrid.
		Read from file... '.write_to$'
		# Import the name of the [.praat_obj$].
		.checkedTG_praat_obj$ = selected$()

		# Print a message.
		printline Loading TextGrid '.checkedTG$' from '.checkedDir$'

		@checking_initials: .write_to$, .initials$

		if !fileReadable(.checkedDir$ + "TranscriptionTextGridsBeforeChecking/" + .checkedTG$)
			Save as text file: .checkedDir$ + "TranscriptionTextGridsBeforeChecking/" + .checkedTG$
		endif

		numTiers = Get number of tiers
		if numTiers == origTierNum
			Insert interval tier:  origTierNum + 1, "Word"
			Insert interval tier:  origTierNum + 1, "Trial"
		endif
	else
		@transcription_TG_error: .checkedDir$, .participant_number$
	endif
endproc

procedure transcription_log_is
	# Check whether the Transcription Log exists on the Praat Objects list.
	.on_objects_list = segmentation_log.praat_obj$ <> ""
	# Check whether the Transcription Log has unchecked trials.
	select 'transcriptionLog.praat_obj$'

	if session_parameters.experimental_task$ = "NonWordRep"
		.n_cvs  = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.cvs$'
		.n_cvschecked = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.cvs_transcribed$'
		.n_vcs  = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.vcs$'
		.n_vcschecked = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.vcs_transcribed$'
		.n_ccs = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.ccs$'
		.n_ccschecked = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.ccs_transcribed$'
		.has_unchecked_trials = .n_cvschecked < .n_cvs | .n_vcschecked < .n_vcs | .n_ccschecked < .n_ccs
	elif session_parameters.experimental_task$ = "GFTA"
		.n_trials  = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.trials$'
		.n_checked = Get value... 'transcriptionLog.row_on_transcription_log'
			... 'transcription_log_columns.transcribed_trials$'
		.has_unchecked_trials = .n_checked < .n_trials
	endif
	# Determine whether the Transcription Log is [.ready] for the Transcription
	# TextGrid to be loaded.
	.ready = .on_objects_list * .has_unchecked_trials
endproc

#### PROCEDURE to llow checking script to work with Transcription scripts.
procedure transcription_textgridd (.task$, .tgObject$)
	if .task$ = "NonWordRep"
		# Numeric and string constants for the NWR transcription textgrid
		.target1_seg = 1
		.target2_seg = 2
		.prosody = 3
		.notes = 4
		.trial = 5
		.word = 6

		.target1_seg$ = "Target1Seg"
		.target2_seg$ = "Target2Seg"
		.prosody$ = "ProsodyScore"
		.notes$ = "TransNotes"
		.trial$ = "Trial"
		.word$ = "Word"
		.level_names$ = "'.target1_seg$' '.target2_seg$' '.prosody$' '.notes$' '.trial$' '.word$'"
		.pointTiers$ = .notes$
	elif .task$ = "GFTA"
		# Numeric and string constants for the GFTA transcription textgrid
		.prosodicPos = 1
		.phonemic = 2
		.score = 3
		.notes = 4
		.trial = 5
		.word = 6

		.prosodicPos$ = "ProsodicPos"
		.phonemic$ = "Phonemic"
		.score$ = "Score"
		.notes$ = "TransNotes"
		.trial$ = "Trial"
		.word$ = "Word"

		.level_names$ = "'.prosodicPos$' '.phonemic$' '.score$' '.notes$' '.trial$' '.word$'"
		.pointTiers$ = "'.score$' '.notes$'"
	endif

	.praat_obj$ = .tgObject$
endproc

procedure transcription_TG_error: .directory$ 
                              ... .participant_number$
  printline
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline ERROR :: No Transcription TextGrid was loaded
  printline
  printline Make sure the following directory exists on your computer:
  printline '.directory$'
  printline 
  printline Also, make sure that directory contains a Transcription TextGrid
        ... file for participant '.participant_number$'.
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline 
endproc