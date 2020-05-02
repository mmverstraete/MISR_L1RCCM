FUNCTION cld_cov_ts, $
   misr_path, $
   misr_block, $
   FROM_DATE = from_date, $
   UNTIL_DATE = until_date, $
   L1B2GM_FOLDER = l1b2gm_folder, $
   L1B2GM_VERSION = l1b2gm_version, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   LOG_IT = log_it, $
   LOG_FOLDER = log_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function generates a time series of cloud cover
   ;  statistics derived from the MISR RCCM data between the indicated
   ;  dates.
   ;
   ;  ALGORITHM: This function reads the standard MISR RCCM data product
   ;  for the specified BLOCK of all ORBITS belonging to the specified
   ;  PATH and acquired between the from_date and the until_date,
   ;  inclusive, replaces missing values if they are any, and reports on
   ;  the prevalence of cloudy and clear pixels, as well as the fractional
   ;  cloud cover for the BLOCK.
   ;
   ;  SYNTAX: rc = cld_cov_ts(misr_path, misr_block, $
   ;  FROM_DATE = from_date, UNTIL_DATE = until_date, $
   ;  L1B2GM_FOLDER = l1b2gm_folder, L1B2GM_VERSION = l1b2gm_version, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_block {INT} [I]: The selected MISR BLOCK number.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   FROM_DATE = from_date {STRING} [I]: The date of the start of the
   ;      period to be processed.
   ;
   ;  *   UNTIL_DATE = until_date {STRING} [I]: The date of the end of the
   ;      period to be processed.
   ;
   ;  *   L1B2GM_FOLDER = l1b2gm_folder {STRING} [I] (Default value: Set
   ;      by function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the MISR L1B2 GM files, if they are not located in
   ;      the default location.
   ;
   ;  *   L1B2GM_VERSION = l1b2gm_version {STRING} [I] (Default value: Set
   ;      by function
   ;      set_roots_vers.pro): The L1B2 GM version identifier to use
   ;      instead of the default value.
   ;
   ;  *   RCCM_FOLDER = rccm_folder {STRING} [I]: The directory address of
   ;      the folder containing the MISR RCCM files, if different from the
   ;      default value set by function set_roots_vers.pro).
   ;
   ;  *   RCCM_VERSION = rccm_version {STRING} [I]: The RCCM version
   ;      identifier, if different from the default value set by function
   ;      set_roots_vers.pro).
   ;
   ;  *   LOG_IT = log_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating a log file.
   ;
   ;  *   LOG_FOLDER = log_folder {STRING} [I]: The directory address of
   ;      the output folder containing the processing log, if different
   ;      from the value implied by the default set by function
   ;      set_roots_vers.pro) and the routine arguments.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to enable
   ;      (> 0) or skip (0) outputting messages on the console:
   ;
   ;      -   If verbose > 0, messages inform the user about progress in
   ;          the execution of time-consuming routines, or the location of
   ;          output files (e.g., log, map, plot, etc.);
   ;
   ;      -   If verbose > 1, messages record entering and exiting the
   ;          routine; and
   ;
   ;      -   If verbose > 2, messages provide additional information
   ;          about intermediary results.
   ;
   ;  *   DEBUG = debug {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) debugging tests.
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: INT.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns 0, and the output keyword parameter excpt_cond is set to
   ;      a null string, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided in the call. The output Log file contains the desired
   ;      information.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output Log file may be inexistent, incomplete or
   ;      incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Warning 98: The computer has not been recognized by the function
   ;      get_host_info.pro.
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: One of the input positional parameters is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      chk_ymddate.pro.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      chk_ymddate.pro.
   ;
   ;  *   Error 220: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 230: An exception condition occurred in function
   ;      block2str.pro.
   ;
   ;  *   Error 299: The computer is not recognized and at least one of
   ;      the optional input keyword parameters l1b2_folder, rccm_folder,
   ;      log_folder is not specified.
   ;
   ;  *   Error 400: The output folder log_fpath is unwritable.
   ;
   ;  *   Error 410: No directory corresponds to the specification
   ;      log_fpath.
   ;
   ;  *   Error 420: Multiple directories correspond to the specification
   ;      log_fpath.
   ;
   ;  *   Error 500: An exception condition occurred in function
   ;      find_orbits_paths_dates.pro.
   ;
   ;  *   Error 510: An exception condition occurred in function
   ;      orbit2date.pro.
   ;
   ;  *   Error 520: An exception condition occurred in function
   ;      orbit2date.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_mpobcbr.pro
   ;
   ;  *   chk_ymddate.pro
   ;
   ;  *   find_orbits_paths_dates.pro
   ;
   ;  *   fix_rccm.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   get_host_info.pro
   ;
   ;  *   heap_l1b2_block.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_writable_dir.pro
   ;
   ;  *   orbit2date.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: Executing this function over a long period (e.g., the
   ;      mission duration) can be time consuming, as the MISR RCCM and
   ;      L1B2 GRP data both need to be read from the files for the
   ;      purpose of replacing missing values, before estimating the
   ;      fractional cloud cover.
   ;
   ;  *   NOTE 2: None of the log, save of map files optionally generated
   ;      by the function fix_rccm.pro are generated or saved in this
   ;      process: only the final results are reported in the Log file of
   ;      this function.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 169
   ;      IDL> misr_block = 110
   ;      IDL> from_date = ''
   ;      IDL> until_date = ''
   ;      IDL> l1b2gm_folder = ''
   ;      IDL> l1b2gm_version = ''
   ;      IDL> rccm_folder = ''
   ;      IDL> rccm_version = ''
   ;      IDL> log_it = 1
   ;      IDL> log_folder = ''
   ;      IDL> verbose = 1
   ;      IDL> debug = 1
   ;      IDL> rc = cld_cov_ts(misr_path, misr_block, $
   ;      IDL>    FROM_DATE = from_date, UNTIL_DATE = until_date, $
   ;      IDL>    L1B2GM_FOLDER = l1b2gm_folder, $
   ;      IDL>    L1B2GM_VERSION = l1b2gm_version, $
   ;      IDL>    RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;      IDL>    LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;      IDL>    VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      Ready to process 461 Orbits...
   ;      Done processing 20 Orbits.
   ;      Done processing 40 Orbits.
   ;      ...
   ;      Done processing 400 Orbits.
   ;      Done processing 420 Orbits.
   ;      Log file Log_CloudCover_P169-B110_2020-05-02.txt
   ;      has been saved in ~/MISR_HR/Outcomes/P169-B110/
   ;
   ;  REFERENCES:
   ;
   ;  *   Michel M. Verstraete, Linda A. Hunt, Hugo De Lemos and Larry Di
   ;      Girolamo (2019) Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product,
   ;      _Earth System Science Data Discussions (ESSDD)_, Vol. 2019, p.
   ;      1–18, available from
   ;      https://www.earth-syst-sci-data-discuss.net/essd-2019-77/ (DOI:
   ;      10.5194/essd-2019-77).
   ;
   ;  *   Michel M. Verstraete, Linda A. Hunt, Hugo De Lemos and Larry Di
   ;      Girolamo (2020) Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product,
   ;      _Earth System Science Data (ESSD)_, Vol. 12, p. 611–628,
   ;      available from
   ;      https://www.earth-syst-sci-data.net/12/611/2020/essd-12-611-2020.html
   ;      (DOI: 10.5194/essd-12-611-2020).
   ;
   ;  VERSIONING:
   ;
   ;  *   2020–04–16: Version 1.0 — Initial public release.
   ;
   ;  *   2020–04–18: Version 2.2.0 — Software version brought to the same
   ;      level as the other functions described in the peer-reviewed
   ;      paper published in _ESSD_ referenced above.
   ;
   ;  *   2020–05–02: Version 2.2.1 — Update the code to free all heap
   ;      variables after each ORBIT is processed.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2020 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following three
   ;      conditions:
   ;
   ;      1. The above copyright notice and this permission notice shall
   ;      be included in their entirety in all copies or substantial
   ;      portions of the Software.
   ;
   ;      2. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
   ;      KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
   ;      WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
   ;      AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;      3. The current version of this Software is freely available from
   ;
   ;      https://github.com/mmverstraete.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com
   ;Sec-Cod

   COMPILE_OPT idl2, HIDDEN

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Initialize the default return code:
   return_code = 0

   ;  Set the default values of flags and essential keyword parameters:
   IF (KEYWORD_SET(log_it)) THEN log_it = 1 ELSE log_it = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Set the MISR Mode (the RCCM data product is only available in Global
   ;  Mode) and select the AN camera:
   misr_mode = 'GM'
   misr_camera = 'AN'

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 2
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_block.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if one of the
   ;  input positional parameters 'misr_mode', 'misr_path', 'misr_orbit',
   ;  'misr_block', 'misr_camera', 'misr_band', 'misr_resol' is invalid:
      rc = chk_mpobcbr(MISR_MODE = misr_mode, MISR_PATH = misr_path, $
         MISR_ORBIT = misr_orbit, MISR_BLOCK = misr_block, $
         MISR_CAMERA = misr_camera, MISR_BAND = misr_band, $
         MISR_RESOL = misr_resol, VERBOSE = verbose, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ENDIF

   ;  Identify the current operating system and computer name:
   rc = get_host_info(os_name, comp_name, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 98
      excpt_cond = 'Warning ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      PRINT, excpt_cond
   ENDIF

   ;  Set the default folders and version identifiers of the MISR and
   ;  MISR-HR files on this computer, and return to the calling routine if
   ;  there is an internal error, but not if the computer is unrecognized, as
   ;  root addresses can be overridden by input keyword parameters:
   rc_roots = set_roots_vers(root_dirs, versions, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc_roots GE 100)) THEN BEGIN
      error_code = 199
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the MISR and MISR-HR version numbers if they have not been specified
   ;  explicitly:
   IF (~KEYWORD_SET(l1b2gm_version)) THEN l1b2gm_version = versions[2]
   IF (~KEYWORD_SET(rccm_version)) THEN rccm_version = versions[5]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Check or set the date range to inspect:
   IF (KEYWORD_SET(from_date)) THEN BEGIN
      rc = chk_ymddate(from_date, year, month, day, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 200
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE from_date = '2000-02-24'

   IF (KEYWORD_SET(until_date)) THEN BEGIN
      rc = chk_ymddate(until_date, year, month, day, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 210
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE until_date = date

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 230
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   pb_str_d = strcat([misr_path_str, misr_block_str], '-')

   ;  Return to the calling routine with an error message if the routine
   ;  'set_roots_vers.pro' could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF (~KEYWORD_SET(l1b2gm_folder) OR $
         ~KEYWORD_SET(rccm_folder) OR $
         (log_it AND (~KEYWORD_SET(log_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Computer is unrecognized, function set_roots_vers.pro did ' + $
            'not assign default folder values, and at least one of the ' + $
            'optional keyword parameters l1b2gm_folder, rccm_folder, ' + $
            'log_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Generate the list of Orbits acquired along the specified Path between the
   ;  indicated dates:
   rc = find_orbits_paths_dates(misr_path, misr_path, $
      from_date, until_date, misr_orbits_struct, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 500
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   misr_orbits = misr_orbits_struct.MISR_PATH_0_ORBITS

   ;  Start the Log file:
   IF (log_it) THEN BEGIN

   ;  Set the directory address of the folder containing the Log file:
      IF (KEYWORD_SET(log_folder)) THEN BEGIN
         log_fpath = log_folder
      ENDIF ELSE BEGIN
         log_fpath = root_dirs[3] + pb_str_d
      ENDELSE
      rc = force_path_sep(log_fpath, DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Create the output directory 'log_fpath' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable:
      res = is_writable_dir(log_fpath, /CREATE)
      IF (debug AND (res NE 1)) THEN BEGIN
         error_code = 400
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
            rout_name + ': The directory log_fpath is unwritable.'
         RETURN, error_code
      ENDIF

   ;  Verify that the file specification of a single directory does not contain
   ;  wildcard characters such as * or ?):
      dirs = FILE_SEARCH(log_fpath, COUNT = n_dirs, /MARK_DIRECTORY)
      IF (debug) THEN BEGIN
         IF (n_dirs EQ 0) THEN BEGIN
            error_code = 410
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': No directory corresponds to the specification log_fpath.'
            RETURN, error_code
         ENDIF
         IF (n_dirs GT 1) THEN BEGIN
            error_code = 420
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': Multiple directories correspond to the ' + $
               'specification log_fpath.'
            RETURN, error_code
         ENDIF
      ENDIF
      log_fpath = dirs[0]
      log_fname = 'Log_CloudCover_' + pb_str_d + '_' + date + '.txt'
      log_fspec = log_fpath + log_fname

   ;  Start the Log file:
      fmt1 = '(A30, A)'
      fmt2 = '(A8, 2X, A12, 2X, A12, 4(2X, A8), 2X, A8)'
      fmt3 = '(I8, 2X, A12, 2X, I12, 4(2X, I8), 2X, F8.4)'

      OPENW, log_unit, log_fspec, /GET_LUN
      PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_fspec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_fspec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit

      PRINTF, log_unit, 'Content: ', 'Time series of cloud cover statistics', $
         FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'MISR Mode: ', misr_mode, FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', strstr(misr_path), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Block: ', strstr(misr_block), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Camera: ', misr_camera, FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'Orbit', 'Date', 'Julian date', $
         'n_cld_hi', 'n_cld_lo', 'n_clr_lo', 'n_clr_hi', 'cld_frac', $
         FORMAT = fmt2
      PRINTF, log_unit, strrepeat('-', 86)
   ENDIF

   n_orbits = N_ELEMENTS(misr_orbits)
   IF (verbose GT 0) THEN PRINT, 'Ready to process ' + strstr(n_orbits) + $
      ' Orbits...'

   ;  Loop over the array of MISR Orbits:
   FOR i = 0, n_orbits - 1 DO BEGIN
      misr_orbit = misr_orbits[i]

   ;  Get the date of acquisition of this MISR Orbit as a STRING:
      datapool = 0
      julian = 0
      acquis_date_ymd = orbit2date(LONG(misr_orbit), DATAPOOL = datapool, $
         JULIAN = julian, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (excpt_cond NE '')) THEN BEGIN
         error_code = 510
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Get the date of acquisition of this MISR Orbit as a LONG:
      julian = 1
      acquis_date_jul = orbit2date(LONG(misr_orbit), DATAPOOL = datapool, $
         JULIAN = julian, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (excpt_cond NE '')) THEN BEGIN
         error_code = 520
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Load the L1B2 data for that Orbit on the heap:
      rc = heap_l1b2_block(misr_mode, misr_path, misr_orbit, misr_block, $
         misr_ptr, radrd_ptr, rad_ptr, brf_ptr, rdqi_ptr, $
         scalf_ptr, convf_ptr, $
         L1B2GM_FOLDER = l1b2gm_folder, L1B2GM_VERSION = l1b2gm_version, $
         L1B2LM_FOLDER = l1b2lm_folder, L1B2LM_VERSION = l1b2lm_version, $
         MISR_SITE = misr_site, TEST_ID = test_id, $
         FIRST_LINE = first_line, LAST_LINE = last_line, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  If one (or more) of the MISR L1B2 GRP data files is missing, skip
   ;  this Orbit and proceed to the next one:
      IF (rc NE 0) THEN CONTINUE

   ;  Fix the RCCM data (replace missing values), without generating the log,
   ;  save file or maps for each Orbit:
      rc = fix_rccm(misr_ptr, radrd_ptr, rccm, $
         RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
         EDGE = edge, TEST_ID = test_id, $
         FIRST_LINE = first_line, LAST_LINE = last_line, $
         LOG_IT = 0,  LOG_FOLDER = log_folder, $
         SAVE_IT = 0, SAVE_FOLDER = save_folder, $
         MAP_IT = 0, MAP_FOLDER = map_folder, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Release the memory associated with the heap pointers:
      PTR_FREE, misr_ptr, radrd_ptr, rad_ptr, brf_ptr, rdqi_ptr, $
         scalf_ptr, convf_ptr

   ;  Extract the desired information for the AN camera and generate the TS
   ;  data:
      cld_cov_an = REFORM(rccm[4, *, *])
      idx_cld_hi = WHERE(cld_cov_an EQ 1B, n_cld_hi)
      idx_cld_lo = WHERE(cld_cov_an EQ 2B, n_cld_lo)
      idx_clr_lo = WHERE(cld_cov_an EQ 3B, n_clr_lo)
      idx_clr_hi = WHERE(cld_cov_an EQ 4B, n_clr_hi)
      n_cld_clr_val = n_cld_hi + n_cld_lo + n_clr_lo + n_clr_hi
      IF (n_cld_clr_val GT 0) THEN BEGIN
         cld_frac = (FLOAT(n_cld_hi) + FLOAT(n_cld_lo)) / FLOAT(n_cld_clr_val)

   ;  Save the results in the output file:
         PRINTF, log_unit, misr_orbit, acquis_date_ymd, acquis_date_jul, $
            n_cld_hi, n_cld_lo, n_clr_lo, n_clr_hi, cld_frac, FORMAT = fmt3
      ENDIF

      IF ((verbose GT 0) AND (i GT 0) AND ((i MOD 20) EQ 0)) THEN BEGIN
         PRINT, 'Done processing ' + strstr(i) + ' Orbits.'
      ENDIF

   ENDFOR   ;  End loop over Orbits

   CLOSE, log_unit

   IF ((verbose GT 0) AND log_it) THEN BEGIN
      PRINT, 'Log file ' + log_fname
      PRINT, 'has been saved in ' + log_fpath
   ENDIF

   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
