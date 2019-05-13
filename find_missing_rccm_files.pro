FUNCTION find_missing_rccm_files, $
   misr_mode, $
   misr_path, $
   n_missing_rccm_files, $
   FROM_DATE = from_date, $
   UNTIL_DATE = until_date, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   LOG_IT = log_it, $
   LOG_FOLDER = log_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function inspects the available MISR RCCM files for
   ;  the specified PATH between the indicated dates, and reports on
   ;  missing ORBITS within that period.
   ;
   ;  ALGORITHM: This function relies on the MISR Toolkit to generate a
   ;  list of missing RCCM ORBITS for the specified PATH that occur
   ;  between the from_date and the until_date dates, inclusive. If the
   ;  optional input keyword parameter log_it is set, it generates a log
   ;  file indicating the ORBITS for which the requested products and
   ;  versions are missing, and saves it in the specified or default
   ;  folder.
   ;
   ;  SYNTAX:
   ;  rc = find_missing_rccm_files(misr_mode, misr_path, n_missing_rccm_files, $
   ;  FROM_DATE = from_date, UNTIL_DATE = until_date, n_missing_rccm_files $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_mode {STRING} [I]: The selected MISR MODE.
   ;
   ;  *   misr_path {INT} [I]: The selected MISR PATH number.
   ;
   ;  *   n_missing_rccm_files {LONG} [O]: The number of missing MISR
   ;      Global Mode RCCM files.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   RCCM_FOLDER = rccm_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the MISR RCCM files, if they are not located in the
   ;      default location.
   ;
   ;  *   RCCM_VERSION = rccm_version {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The RCCM version identifier to use instead
   ;      of the default value.
   ;
   ;  *   LOG_IT = log_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating a log file.
   ;
   ;  *   LOG_FOLDER = log_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the processing log.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to enable
   ;      (> 0) or skip (0) reporting progress on the console: 1 only
   ;      reports exiting the routine; 2 reports entering and exiting the
   ;      routine, as well as key milestones; 3 reports entering and
   ;      exiting the routine, and provides detailed information on the
   ;      intermediary results.
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
   ;      provided in the call. The output positional parameter
   ;      n_missing_rccm_files reports on the number of missing files in
   ;      the designated or default folder, between the specified dates. A
   ;      log file is saved if the input keyword parameter LOG_IT is set.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output positional parameter n_missing_rccm_files
   ;      may be undefined, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_mode is invalid.
   ;
   ;  *   Error 120: The input positional parameter misr_path is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      chk_ymddate.pro.
   ;
   ;  *   Error 220: An exception condition occurred in function
   ;      chk_ymddate.pro.
   ;
   ;  *   Error 299: The computer is not recognized and at least one of
   ;      the optional input keyword parameters rccm_folder, log_folder is
   ;      not specified.
   ;
   ;  *   Error 300: An exception condition occurred in function
   ;      set_rccm_folder.pro.
   ;
   ;  *   Error 400: An exception condition occurred in function
   ;      find_orbits_paths_dates.pro.
   ;
   ;  *   Error 500: The output folder log_fpath exists but is unwritable.
   ;
   ;  *   Error 510: An exception condition occurred in function
   ;      is_writable.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   chk_misr_mode.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   chk_ymddate.pro
   ;
   ;  *   find_orbits_paths_dates.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   get_host_info.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   match2.pro [from IDL AstroLib]
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_rccm_folder.pro
   ;
   ;  *   set_misr_specs.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_mode = 'GM'
   ;      IDL> misr_path = 168
   ;      IDL> from_date = ''
   ;      IDL> until_date = '2018-12-31'
   ;      IDL> log_it = 1
   ;      IDL> verbose = 1
   ;      IDL> debug = 1
   ;      IDL> rc = find_missing_rccm_files(misr_mode, $
   ;         misr_path, n_missing_rccm_files, $
   ;         FROM_DATE = from_date, UNTIL_DATE = until_date, $
   ;         RCCM_FOLDER = rccm_folder, $
   ;         RCCM_VERSION = rccm_version, LOG_IT = log_it, $
   ;         LOG_FOLDER = log_folder, VERBOSE = verbose, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, rc
   ;            0
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2016–06–13: Version 0.9 — Initial release.
   ;
   ;  *   2017–11–10: Version 1.0 — Initial public release.
   ;
   ;  *   2018–01–30: Version 1.1 — Implement optional debugging.
   ;
   ;  *   2018–06–01: Version 1.5 — Implement new coding standards.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–03–20: Version 2.10 — Update the handling of the optional
   ;      input keyword parameter VERBOSE and generate the software
   ;      version consistent with the published documentation.
   ;
   ;  *   2019–05–04: Version 2.11 — Update the code to report the
   ;      specific error message of MTK routines.
   ;
   ;  *   2019–05–06: Version 2.12 — Update the code to report the RCCM
   ;      version number used.
   ;
   ;  *   2019–05–07: Version 2.15 — Software version described in the
   ;      paper entitled _Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product_.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2019 Michel M. Verstraete.
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
   ;      be included in its entirety in all copies or substantial
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

   ;  Set the default values of flags and essential output keyword parameters:
   IF (KEYWORD_SET(log_it)) THEN log_it = 1 ELSE log_it = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Initialize the output positional parameter(s):
   n_missing_rccm_files = 0L

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 3
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_mode, misr_path, ' + $
            'n_missing_rccm_files.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_mode' is invalid:
      rc = chk_misr_mode(misr_mode, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_path' is invalid:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   misr_cams = misr_specs.CameraNames
   n_bnds = misr_specs.NBands
   misr_bnds = misr_specs.BandNames

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
   IF (~KEYWORD_SET(rccm_version)) THEN rccm_version = versions[5]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   mp_str = misr_mode + '-' + misr_path_str

   ;  Set the date range to inspect:
   IF (KEYWORD_SET(from_date)) THEN BEGIN
      rc = chk_ymddate(from_date, year, month, day, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 210
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE from_date = '2000-02-24'

   IF (KEYWORD_SET(until_date)) THEN BEGIN
      rc = chk_ymddate(until_date, year, month, day, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 220
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE until_date = date

   ;  Return to the calling routine with an error message if the routine
   ;  'set_roots_vers.pro' could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF ((rccm AND (~KEYWORD_SET(rccm_folder))) OR $
         (log_it AND (~KEYWORD_SET(log_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond + '. And at least one of the optional input ' + $
            'keyword parameters rccm_folder, log_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the MISR RCCM files:
   rc = set_rccm_folder(misr_path, rccm_fpath, n_rccm_files, $
      RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the list of expected MISR files between the from_date and the
   ;  until_date for the specified Path, and reset n_rccm_files to the number
   ;  of Orbits concerned:
   rc = find_orbits_paths_dates(misr_path, misr_path, $
      from_date, until_date, misr_orbits, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND rc NE 0) THEN BEGIN
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   n_orbits = misr_orbits.misr_path_0_norbits
   orbits = misr_orbits.misr_path_0_orbits

   IF (log_it) THEN BEGIN

   ;  Set the directory address of the folder containing the log file:
      IF (KEYWORD_SET(log_folder)) THEN BEGIN
         log_fpath = force_path_sep(log_folder, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         log_fpath = root_dirs[3] + mp_str + PATH_SEP()
      ENDELSE

   ;  Return to the calling routine with an error message if the output
   ;  directory 'log_fpath' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(log_fpath, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         1: BREAK
         0: BEGIN
               error_code = 500
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The output folder ' + log_fpath + $
                  ' is unwritable.'
               RETURN, error_code
            END
         -1: BEGIN
               IF (debug) THEN BEGIN
                  error_code = 510
                  excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                     rout_name + ': ' + excpt_cond
                  RETURN, error_code
               ENDIF
            END
         -2: BEGIN
               FILE_MKDIR, log_fpath
            END
         ELSE: BREAK
      ENDCASE

   ;  Generate the specification of the log file:
      log_fname = 'Missing_RCCM_Orbits_' + date + '.txt'
      log_fspec = log_fpath + log_fname

   ;  Open and initiate the output log file:
      fmt1 = '(A30, A)'

      OPENW, log_unit, log_fspec, /GET_LUN
      PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_fspec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_fspec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit

      PRINTF, log_unit, 'Content: ', 'Information on missing RCCM files', $
         FORMAT = fmt1
      PRINTF, log_unit, 'RCCM path: ', rccm_fpath, FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, 'MISR Mode: ', misr_mode, FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', strstr(misr_path), FORMAT = fmt1
      PRINTF, log_unit, 'From: ', from_date, FORMAT = fmt1
      PRINTF, log_unit, 'Until: ', until_date, FORMAT = fmt1
      PRINTF, log_unit
      PRINTF, log_unit, '# Orbits accomplished: ', strstr(n_orbits), $
         FORMAT = fmt1
   ENDIF

   ;  Generate the array containing the actually available RCCM files of the
   ;  specified Version:
   pattern = rccm_fpath + 'MISR_AM1_GRP_RCCM_GM*' + rccm_version + '.hdf'
   avail_rccm_files = FILE_SEARCH(pattern, COUNT = avail_files)

   ;  Generate the array of unique available Orbits:
   avail_orbits = LONG(avail_rccm_files.Extract('[0-9]{6}'))
   avail_unique_orbits = avail_orbits[UNIQ(avail_orbits, SORT(avail_orbits))]
   n_avail_unique_orbits = N_ELEMENTS(avail_unique_orbits)

   ;  Generate the array of missing Orbits, using the IDL Astro library program
   ;  'match2', which returns an index -1 when no match is found:
   match2, orbits, avail_orbits, suba, subb
   idx_miss = WHERE(suba EQ -1, n_missing_orbits)
   missing_orbits = orbits[idx_miss]
   n_missing_rccm_files = n_missing_orbits * 9

   ;  Record the results in the log file:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, '# Orbits missing: ', strstr(n_missing_orbits), $
         FORMAT = fmt1
      FOR i = 0, n_missing_orbits - 1 DO BEGIN
         orbit = missing_orbits[i]
         acquis_date = orbit2date(orbit, DEBUG = debug, EXCPT_COND = excpt_cond)
         IF (excpt_cond NE '') THEN STOP
         PRINTF, log_unit, strstr(orbit) + ': ', acquis_date, FORMAT = fmt1
      ENDFOR
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   IF (verbose GT 0) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
