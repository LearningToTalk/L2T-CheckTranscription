procedure transcriptionLog
	# Import constants from [@session_parameters] namespace.
	# Note: As currently written, [transcriptionLog] assumes that 
	# @session_parameters has been called prior to the @transcriptionLog 
	# call.  If you want to generalize [transcriptionLog] so that this 
	# assumption is not made, then all of the constants in the following 
	# block of code need to be made arguments to the [transcriptionLog] 
	# function.
	.activity$ = session_parameters.activity$
	.experiment_directory$ = session_parameters.experiment_directory$
	.initials$ = session_parameters.initials$
	.experimental_task$ = session_parameters.experimental_task$
	.participant_number$ = session_parameters.participant_number$

	# Set the [.row_on_transcription_log] that is used when checking a	# Transcribed TextGrid.
	.row_on_transcription_log = 2

	# Set up the [transcription_log_columns] namespace.
	@transcription_log_columns

	# Only do something if the [.experiment_directory$] is set up.
	if .experiment_directory$ <> ""
		# Set up the path to the [.directory$] of Checked Transcription Logs.
		.checkedDir$ = .experiment_directory$ + "/" +
			... "Transcription" + "/" +
			... "TranscriptionLogs/"

		.checkedLog$ = .experimental_task$ + "_" +
			... participant.id$ + "_" + checking_initials.initials$ +
			... "transLog.txt"

		.write_to$ = .checkedDir$ + .checkedLog$

		if fileReadable (.write_to$)
			# Read in the Trascription Log.
			@read_transcription_log
			# Import the name of the [.praat_obj$].
			.praat_obj$ = read_transcription_log.praat_obj$
			# If the user is checking a transcribed TextGrid, then check if this is
			# her first session by checking the number of rows on Transcription Log
			# Table.
			# Just update the EndDate column.
			@timestamp
			select '.praat_obj$'
			Set string value: .row_on_transcription_log,
				... transcription_log_columns.end$,
				... timestamp.time$
		else
			@transcribers_initials: transcribed_textgrid.write_to$

			.origLog$ = .experimental_task$ + "_" +
				... participant.id$ + "_" + transcribers_initials.initials$ +
				... "transLog.txt"

			.write_to$ =  .checkedDir$ +.origLog$

			@read_transcription_log
			.praat_obj$ = read_transcription_log.praat_obj$
			@populateRows: .row_on_transcription_log
         		.write_to$ = .checkedDir$ + .experimental_task$ + "_" +
				... participant.id$ + "_" +
				... checking_initials.initials$ + "transLog.txt"
		endif
	else
		# If the [.experiment_directory$] is not set up, then set all of the 
		# string constants to empty strings.
		.read_from$ = ""
		.write_to$  = ""
		.praat_obj$ = ""
		# Print a message to let the user know that no Transcription Log was loaded.
		printline No Transcription Log was loaded because the current workstation
			... is not recognized.
	endif
endproc

procedure populateRows .row_on_transcription_log
	# Add a row and populate it.
	select 'transcriptionLog.praat_obj$'
	Append row
	# The initials of the checker.
	Set string value: .row_on_transcription_log,
		... transcription_log_columns.transcriber$,
		... session_parameters.initials$
	# The start time.
	@timestamp
	Set string value: .row_on_transcription_log,
		... transcription_log_columns.start$,
		... timestamp.time$
	# The end time.
	@timestamp
	Set string value: .row_on_transcription_log,
		... transcription_log_columns.end$,
		... timestamp.time$

	if session_parameters.experimental_task$ = "NonWordRep"
		# The number of cvs.
		.n_cvs = Get value... 1 'transcription_log_columns.cvs$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.cvs$, .n_cvs
		# The number of cvs transcribed (= 0).
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.cvs_transcribed$, 0

		.n_vcs = Get value... 1 'transcription_log_columns.vcs$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.vcs$, .n_vcs
		# The number of vcs transcribed (= 0).
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.vcs_transcribed$,0

     		.n_ccs = Get value... 1 'transcription_log_columns.ccs$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.ccs$, .n_ccs
		# The number of ccs transcribed (= 0).
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.ccs_transcribed$, 0

	elif session_parameters.experimental_task$ = "GFTA"
		# The number of trials.
		.n_trials = Get value... 1 'transcription_log_columns.trials$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.trials$, .n_trials
		# The number of trials transcribed (= 0).
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.trials_transcribed$, 0

		.score = Get value... 1 'transcription_log_columns.score$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.score$, 0

		.transcribeable = Get value... 1 'transcription_log_columns.transcribeable$'
		Set numeric value: .row_on_transcription_log,
			... transcription_log_columns.transcribeable$, 77
	endif
endproc

# A procedure that functions as a constant for the column numbers and column
# names of the various columns in a TranscriptionLog.
procedure transcription_log_columns
	if session_parameters.experimental_task$ = "NonWordRep"
		.transcriber = 1
		.transcriber$ = "NonwordTranscriber"
		.start = 2
		.start$ = "StartTime"
		.end = 3
		.end$ = "EndTime"
		.cvs = 4
		.cvs$ = "NumberOfCVs"
		.cvs_transcribed = 5
		.cvs_transcribed$ = "NumberOfCVsTranscribed"
		.vcs = 6
		.vcs$ = "NumberOfVCs"
		.vcs_transcribed = 7
		.vcs_transcribed$ = "NumberOfVCsTranscribed"
		.ccs = 8
		.ccs$ = "NumberOfCCs"
		.ccs_transcribed = 9
		.ccs_transcribed$ = "NumberOfCCsTranscribed"

		.length = 9

	elif session_parameters.experimental_task$ = "GFTA"
		.transcriber = 1
		.transcriber$ = "GFTATranscriber"
		.start = 2
		.start$ = "StartTime"
		.end = 3
		.end$ = "EndTime"
		.trials = 4
		.trials$ = "NumberOfTrials"
		.trials_transcribed = 5
		.trials_transcribed$ = "NumberOfTrialsTranscribed"
		.score = 6
		.score$ = "Score"
		.transcribeable = 7
		.transcribeable$ = "TranscribeableTokens"

		.length = 7
	endif
endproc

procedure transcribers_initials: .transcription_log_filepath$
  @parse_filepath: .transcription_log_filepath$
  .initials$ = mid$(parse_filepath.filename$,
                ... rindex(parse_filepath.filename$, "_") + 1,
                ... 2)
endproc

# A procedure for determining the checking initials from a filepath and the
# checker's initials.
procedure checking_initials: .filepath$, .checkers_initials$
	@transcribers_initials: .filepath$
	.initials$ = transcribers_initials.initials$ + .checkers_initials$
endproc

# A procedure for determining how the length of the initials sequence in
# a filename.
# Note: .filename$ must end in transLog.txt
procedure initials_sequence: .filename$
	.length = length(.filename$)
	.left_index = rindex(.filename$, "_") + 1
	.suffix$ = mid$(.filename$, .left_index, .length - .left_index + 1)
	.initials$ = replace$(.suffix$, "transLog.txt", "", 1)
	.n_char = length(.initials$)
endproc

procedure read_transcription_log
		# Read in the Transcription Log from the filesystem.
		Read Table from tab-separated file... 'transcriptionLog.write_to$'
		# Rename the Transcription Log Table object.
		@participant: transcriptionLog.write_to$, 
			... session_parameters.participant_number$
		.table_obj$ = participant.id$ + "_Log" + checking_initials.initials$
		Rename... '.table_obj$'
		# Store the name of the Transcription Log Table object.
		.praat_obj$ = selected$()
	endif
endproc