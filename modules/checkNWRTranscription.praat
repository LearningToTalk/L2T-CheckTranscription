# Values for .result_node$
node_quit$ = "quit"
node_next$ = "next"
node_back$ = "back"

procedure checkNWRTranscription
	# Numeric and string constants for the Word List Table.
	wordListBasename$ = wordlist.praat_obj$
	wordListTrialNumber$ = wordlist_columns.trial_number$
	wordListWorldBet$ = wordlist_columns.worldbet$
	wordListOrthography$ = wordlist_columns.orthography$
	wordListTarget1$ = wordlist_columns.target1$
	wordListTarget2$ = wordlist_columns.target2$
	wordListTargetStructure$ = wordlist_columns.target_structure$

	# Count the trials of structure type
	@count_nwr_wordlist_structures(wordListBasename$, wordListTargetStructure$)
	nTrialsCV = count_nwr_wordlist_structures.nTrialsCV
	nTrialsVC = count_nwr_wordlist_structures.nTrialsVC
	nTrialsCC = count_nwr_wordlist_structures.nTrialsCC

	# Column numbers from the segmented textgrid
	segTextGridTrial = segmentation_textgrid_tiers.trial
	segTextGridContext = segmentation_textgrid_tiers.context

	# These are column names
	select 'transLogBasename$'
	transLogCVs$ = transcription_log_columns.cvs$
	transLogCVsTranscribed$ = transcription_log_columns.cvs_transcribed$
	transLogVCs$ = transcription_log_columns.vcs$
	transLogVCsTranscribed$ = transcription_log_columns.vcs_transcribed$
	transLogCCs$ = transcription_log_columns.ccs$
	transLogCCsTranscribed$ = transcription_log_columns.ccs_transcribed$

	#######################################################################
	# Open an Edit window with the segmentation textgrid, so that the transcriber can examine
	# the larger segmentation context to recoup from infelicitous segmenting of false starts
	# and the like. 
	selectObject(transBasename$)
	plusObject(audioBasename$)
	Edit
	#######################################################################
	# Loop through the trial types
	trial_type1$ = "CV"
	trial_type2$ = "VC"
	trial_type3$ = "CC"
	current_type = 1
	current_type_limit = 4

	# [TRIAL TYPE LOOP]
	while current_type < current_type_limit
		trial_type$ = trial_type'current_type'$

		# Check if there are any trials to transcribe for this trial type.
		trials_col$ = transLog'trial_type$'s$
		done_col$ = transLog'trial_type$'sTranscribed$

		@count_remaining_trials(transLogBasename$, 2, trials_col$, done_col$)
		n_trials = count_remaining_trials.n_trials
		n_checked = count_remaining_trials.n_transcribed
		n_remaining = count_remaining_trials.n_remaining

		# Jump to next type if there are no remaining trials to transcribe
		if n_remaining == 0
			current_type = current_type + 1
		# If there are still trials to check, ask the checker whether or not to continue.
		elsif n_checked < n_trials
			beginPause("Transcribe 'trial_type$'-trials")
				comment("There are 'n_remaining' 'trial_type$'-trials to check.")
				comment("Would you like to check them?")
			button = endPause("No", "Yes", 2, 1)	

			# Trial numbers here refer to rows in the Word List table
			trial = n_checked + 1

			# If the user chooses no, skip the transcription loop and break out of this loop.
			if button == 1
				goto abort
			endif

			# Loop through the trials of the current type
			while trial <= n_trials
				# Determine the target word and target segments. 
				selectObject(wordListBasename$ + "_" + trial_type$)
				targetNonword$ = Get value: trial, wordListWorldBet$
				trial$ = Get value: trial, wordListTrialNumber$
				word$ = Get value: trial, wordListOrthography$
				target1$ = Get value: trial, wordListTarget1$
				target2$ = Get value: trial, wordListTarget2$

				# Get the Trial Number (a string value) of the current trial.
				selectObject(wordListBasename$ + "_" + trial_type$)
				trialNumber$ = Get value: trial, wordListTrialNumber$

				# Look up trial number in segmentation table. Compute trial midpoint from table.
				selectObject(segmentTableBasename$)
				segTableRow = Search column: "text", trialNumber$

				@get_xbounds_from_table(segmentTableBasename$, segTableRow)

				# Find bounds of the textgrid interval containing the transcription for the current trial
				selectObject(transBasename$)
				currentInterval = Get low interval at time: 1, get_xbounds_from_table.xmax - 0.1
				segmentXMin = Get start point: 1, currentInterval
				segmentXMax = Get end point: 1, currentInterval
				segmentXMid = segmentXMin + ((segmentXMax - segmentXMin) / 2)

				Insert boundary: trialTier, segmentXMin
				Insert boundary: trialTier, segmentXMax
				Insert boundary: wordTier, segmentXMin
				Insert boundary: wordTier, segmentXMax

				segmentInterval = Get low interval at time: 5, get_xbounds_from_table.xmax - 0.1

				Set interval text: trialTier, segmentInterval, trial$
				Set interval text: wordTier, segmentInterval, word$

				Extract part: segmentXMin, segmentXMax, "yes"
				Rename: "OriginalTranscription_" + word$

				selectObject(transBasename$)
				editor 'transBasename$'
					Zoom: segmentXMin - 0.25, segmentXMax + 0.25
				endeditor

				@checkTarget: 1
				transcription1$ = checkTarget.transcription$

				@checkTarget: 2
				transcription2$ = checkTarget.transcription$

				@checkProsody

				#do a save of log and TG
				selectObject(transBasename$)
				Save as text file: transcribed_textgrid.write_to$

				# Update the number of CV-trials that have been transcribed.
				selectObject(transLogBasename$)
				log_col$ = transLog'trial_type$'sTranscribed$
				Set numeric value: 2, log_col$, trial
				Save as tab-separated file: transcriptionLog.write_to$

				select TextGrid OriginalTranscription_'word$'
				Remove
				trial = trial + 1
			endwhile
		endif
		current_type = current_type + 1
	endwhile
endproc

procedure checkTarget(.targetNum)
	selectObject(transBasename$)
	.targetScore$ = Get label of interval: .targetNum, currentInterval
	.transcriptionEndpoint = index (.targetScore$, ";")
	.transcription$ = left$ (.targetScore$, .transcriptionEndpoint - 1)
	.target$ = target'.targetNum'$

	beginPause("Target'.targetNum' Transcription for 'targetNonword$'")
		comment("Is /'.target$'/ transcribed correctly as ['.transcription$']?")
 	button = endPause("Yes", "NO", "Quit", 1)

	if button == 2
		Set interval text: .targetNum, currentInterval, ""
		# [RETRANSCRIBE Target]
		@transcribe_segment(trialNumber$, targetNonword$, target1$, target2$, .targetNum)

		# [SCORE Target]
		selectObject(transBasename$)
		segmentInterval = Get interval at time: transcription_textgrid.target'.targetNum'_seg, segmentXMid
		Set interval text: transcription_textgrid.target'.targetNum'_seg, segmentInterval, transcribe_segment.transcription$
	elsif button == 3
		goto abort
	endif
endproc

procedure checkProsody
	selectObject(transBasename$)
	beginPause("Prosody Transcription for 'targetNonword$'")
		comment("Is the prosody transcribed correctly?")
 	button = endPause("Yes", "NO", "Quit", 1)

	if button == 2
		Set interval text: 3, currentInterval, ""

		# [SCORE Prosody]
		@transcribe_prosody(targetNonword$, target1$, transcription1$, target2$, transcription2$)
		prosodyInterval = Get interval at time: transcription_textgrid.prosody, segmentXMid
		@check_worldBet(targetNonword$, transcribe_prosody.target1_correct$, transcribe_prosody.target2_correct$, transcribe_prosody.frame_not_shortened)
		Set interval text: transcription_textgrid.prosody, prosodyInterval, check_worldBet.text$
	elsif button == 3
		goto abort
	endif
endproc