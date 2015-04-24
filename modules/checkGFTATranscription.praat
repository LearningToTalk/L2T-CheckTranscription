procedure checkGFTATranscription
	# Numeric and string constants for the Word List Table.
	wordListBasename$ = wordlist.praat_obj$
	wordListOrthography$ = wordlist_columns.orthography$
	wordListWord$ = wordlist_columns.word$
	wordListWorldBet$ = wordlist_columns.worldBet$
	wordListTargetC1$ = wordlist_columns.targetC1$
	wordListTargetC2$ = wordlist_columns.targetC2$
	wordListTargetC3$ = wordlist_columns.targetC3$
	wordListprosPos1$ = wordlist_columns.prosPos1$
	wordListprosPos2$ = wordlist_columns.prosPos2$
	wordListprosPos3$ = wordlist_columns.prosPos3$

	# Count the trials of structure type
	@count_GFTA_wordlist_structures(wordListBasename$)
	nTrials = count_GFTA_wordlist_structures.nTrials

	# These are column names
	transLogTrials$ = transcription_log_columns.trials$
	transLogTrialsTranscribed$ = transcription_log_columns.trials_transcribed$
	transLogEndTime$ = transcription_log_columns.end$
	transLogScore$ = transcription_log_columns.score$
	transLogTranscribeableTokens$ = transcription_log_columns.transcribeable$

###############################################################################
#                             Code for Transcription                          #
###############################################################################

	# Open a separate Editor window with the transcription textgrid object and audio file.
	selectObject(transBasename$)
	plusObject(audioBasename$)
	Edit
	# Set the Spectrogram settings, etc., here.

	#Count remaining trials

	## does this log file increment for each session?  if so, this "1" should be changed to numRows
	## in the log file.

	@count_remaining_trials(transLogBasename$, 2, "NumberOfTrials", "NumberOfTrialsTranscribed")
	n_trials = count_remaining_trials.n_trials
	n_transcribed = count_remaining_trials.n_transcribed
	n_remaining = count_remaining_trials.n_remaining

	# If there are still trials to transcribe, ask the transcriber if she would like to transcribe them.
	n_transcribed < n_trials
	beginPause("Transcribe GFTA Trials")
		comment("There are 'n_remaining' trials to transcribe.")
		comment("Would you like to transcribe them?")
	button = endPause("No", "Yes", 2, 1)

	# If the user chooses no, skip the transcription loop and break out of this loop.
	if button == 1
		goto abort
	endif

	selectObject(segmentTableBasename$)
	Extract rows where column (text): "tier", "is equal to", "Trial"
	Rename: "TierTimes"

	.currentTrial = n_transcribed + 1

	# Loop through the trials of the current type
	while (.currentTrial <= n_trials)
		# Determine the target word and target segments. 
		selectObject(wordListBasename$)
		.word$ = Get value: .currentTrial, wordListWord$
		.targetWord$ = Get value: .currentTrial, wordListWorldBet$
		.targetWordOrtho$ = Get value: .currentTrial, wordListOrthography$
		.targetC1$ = Get value: .currentTrial, wordListTargetC1$
		.targetC2$ = Get value: .currentTrial, wordListTargetC2$
		.targetC3$ = Get value: .currentTrial, wordListTargetC3$
		.prosPos1$ = Get value: .currentTrial, wordListprosPos1$
		.prosPos2$ = Get value: .currentTrial, wordListprosPos2$
		.prosPos3$ = Get value: .currentTrial, wordListprosPos3$

		# Look up trial number in segmentation table. Compute trial midpoint from table.
		selectObject(segmentTableBasename$)
		.segTableRow = Search column: "text", .targetWordOrtho$

		@get_xbounds_from_table(segmentTableBasename$, .segTableRow)

		# Find bounds of the textgrid interval containing the transcription for the current trial
		selectObject(transBasename$)
		.currentInterval = Get high interval at time: 1, get_xbounds_from_table.xmin + 0.1

		Insert boundary: trialTier, get_xbounds_from_table.xmin
		Insert boundary: trialTier, get_xbounds_from_table.xmax
		Insert boundary: wordTier, get_xbounds_from_table.xmin
		Insert boundary: wordTier, get_xbounds_from_table.xmax

		.segmentInterval = Get low interval at time: 5, get_xbounds_from_table.xmax - 0.1

		Set interval text: trialTier, .segmentInterval, .word$
		Set interval text: wordTier, .segmentInterval, .targetWordOrtho$

		Extract part: get_xbounds_from_table.xmin, get_xbounds_from_table.xmax, "yes"
		.originalScore$ = "OriginalTranscription_" + .word$
		Rename: .originalScore$
		Down to Table: "no", 6, "yes", "no"

		selectObject(transBasename$)
		editor 'transBasename$'
			Zoom: get_xbounds_from_table.xmin - 0.25, get_xbounds_from_table.xmax + 0.25
		endeditor

		if .targetC1$ != "" & .targetC1$ != "?" & button != 3
			select Table '.originalScore$'
			.segmentRow = Search column: "text", .targetC1$
			.segmentLowerBoundary = Get value: .segmentRow, "tmin"

			selectObject(transBasename$)
			.pointInterval = Get high index from time: 3, .segmentLowerBoundary
			@CheckSegment(.targetC1$, .pointInterval, 1, .targetWord$, .prosPos1$)
		endif
		if .targetC2$ != "" & .targetC2$ != "?" & button != 3
			select Table '.originalScore$'
			.segmentRow = Search column: "text", .targetC2$
			.segmentLowerBoundary = Get value: .segmentRow, "tmin"

			selectObject(transBasename$)
			.pointInterval = Get high index from time: 3, .segmentLowerBoundary
			@CheckSegment(.targetC2$, .pointInterval, 2, .targetWord$, .prosPos2$)
		endif
		if .targetC3$ != "" & .targetC3$ != "?" & button != 3
			select Table '.originalScore$'
			.segmentRow = Search column: "text", .targetC3$
			.segmentLowerBoundary = Get value: .segmentRow, "tmin"

			selectObject(transBasename$)
			.pointInterval = Get high index from time: 3, .segmentLowerBoundary
			@CheckSegment(.targetC3$, ..pointInterval, 3, .targetWord$, .prosPos3$)
		endif

		if button != 3
			#do a save of log and TG
			selectObject(transBasename$)
			Save as text file: transcribed_textgrid.write_to$

			# Update the number of CV-trials that have been transcribed.
			selectObject(transLogBasename$)
			Set numeric value: 2, "NumberOfTrialsTranscribed", .currentTrial
			Save as tab-separated file: transcriptionLog.write_to$

			select TextGrid '.originalScore$'
			plus Table '.originalScore$'
			Remove

			.currentTrial = .currentTrial + 1
		endif
	endwhile
endproc

procedure CheckSegment(.target$, .whichPoint, .whichSegment, .word$, .pros$)
	selectObject(transBasename$)

	beginPause("Target'.whichSegment' Transcription for '.word$'")
		comment("Is /'.target$'/ scored correctly?")
	button = endPause("Yes", "NO", "Quit", 1)

	if button == 2
		.originalPointTime = Get time of point: 3, .whichPoint
		Remove point: 3, .whichPoint

		# [RETRANSCRIBE Target]
		@RetranscribeSegment(.whichSegment, .originalPointTime, .target$, .word$, .pros$)

	elsif button == 3
		goto abort
	endif
endproc

procedure RetranscribeSegment(.whichSegment, .originalPointTime, .target$, .word$, .pros$)
# Prompt the user to rate production.
	beginPause ("Rate the production of consonant #'.whichSegment'.")
		comment ("Next sound to transcribe: '.target$' at '.pros$' in '.word$'")
		comment ("Choose a phonemic transcription.")
		choice ("Rating", 1)
		option ("Correct")
		option ("Incorrect")
		option ("Untranscribeable")
	endPause ("Ruin everything", "Rate Production", 2, 1)
 
	if rating$ != "Untranscribeable"
		if rating$ = "Correct"
			.segmentScore = 1
		else
			.segmentScore = 0
		endif
		# Update the GFTA score.
		selectObject(transLogBasename$)

		.score = Get value: 2, transLogScore$
		.score = .score + .segmentScore
		Set numeric value: 2, transLogScore$, .score

		selectObject(transBasename$)
		Insert point... transcription_textgrid.score '.originalPointTime' '.segmentScore'
	else
		# Update number of GFTA transcribeable segments.
		selectObject(transLogBasename$)

		.numTrabscribeable = Get value: 2, transLogTranscribeableTokens$
		.numTrabscribeable = .numTrabscribeable - 1
		Set numeric value: 2, transLogTranscribeableTokens$, .numTrabscribeable

		selectObject(transBasename$)
		Insert point... transcription_textgrid.score '.originalPointTime' Not Transcribeable
	endif
endproc
