FUNCTION diag_rccm, $
   misr_path, $
   misr_orbit, $
   misr_block, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   LOG_IT = log_it, $
   LOG_FOLDER = log_folder, $
   SAVE_IT = save_it, $
   SAVE_FOLDER = save_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function collects metadata and basic statistics about
   ;  the contents of a single MISR BLOCK within each of the 9 MISR RCCM
   ;  files for the specified PATH, ORBIT, and BLOCK, and saves these
   ;  results into 9 text files and 9 corresponding IDL SAVE files.
   ;
   ;  ALGORITHM: This function inspects the contents of the 9 MISR RCCM
   ;  files and reports on the numbers of high-confidence cloud,
   ;  low-confidence cloud, low confidence clear and high-confidence clear
   ;  pixels, as well as on the number of glitter-contaminated pixels and
   ;  on the tests used to derive those cloudiness levels.
   ;
   ;  SYNTAX: rc = diag_rccm(misr_path, misr_orbit, misr_block, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  SAVE_IT = save_it, SAVE_FOLDER = save_folder, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INTEGER} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_orbit {LONG} [I]: The selected MISR ORBIT number.
   ;
   ;  *   misr_block {INTEGER} [I]: The selected MISR BLOCK number.
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
   ;      set_roots_vers.pro): The MISR RCCM version identifier to use
   ;      instead of the default value.
   ;
   ;  *   LOG_IT = log_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating a log file.
   ;
   ;  *   LOG_FOLDER = log_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the processing log.
   ;
   ;  *   SAVE_IT = save_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) saving the results in a savefile.
   ;
   ;  *   SAVE_FOLDER = save_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the savefile.
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
   ;      provided in the call. The output log and save files are saved in
   ;      the designated or default folders.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output log and save files may be inexistent,
   ;      incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input argument misr_path is invalid.
   ;
   ;  *   Error 120: Input argument misr_orbit is invalid.
   ;
   ;  *   Error 122: The input positional parameter misr_orbit is
   ;      inconsistent with the input positional parameter misr_path.
   ;
   ;  *   Error 124: An exception condition occurred in is_frompath.pro.
   ;
   ;  *   Error 130: Input argument misr_block is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      orbit2str.pro.
   ;
   ;  *   Error 220: An exception condition occurred in function
   ;      block2str.pro.
   ;
   ;  *   Error 230: An exception condition occurred in function
   ;      orbit2date.pro.
   ;
   ;  *   Error 299: The computer is not recognized and at least one of
   ;      the optional input keyword parameters rccm_folder, log_folder,
   ;      save_folder is not specified.
   ;
   ;  *   Error 300: An exception condition occurred in function
   ;      find_rccm_files.
   ;
   ;  *   Error 500: The output folder log_fpath is unwritable.
   ;
   ;  *   Error 510: An exception condition occurred in function
   ;      is_writable.
   ;
   ;  *   Error 520: The output folder save_fpath is unwritable.
   ;
   ;  *   Error 530: An exception condition occurred in function
   ;      is_writable.
   ;
   ;  *   Error 600: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 610: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_FILE_TO_GRIDLIST.
   ;
   ;  *   Error 620: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_FILE_GRID_TO_FIELDLIST.
   ;
   ;  *   Error 630: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_READDATA.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_misr_block.pro
   ;
   ;  *   chk_misr_orbit.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   find_rccm_files.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   get_host_info.pro
   ;
   ;  *   is_frompath.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   orbit2date.pro
   ;
   ;  *   orbit2str.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   today.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: The input keyword parameters log_it and save_it are
   ;      provided to generate the desired outputs selectively.
   ;      Deselecting some of them may accelerate the processing, but if
   ;      none of them are set, then no output will be saved either.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> misr_path = 168
   ;      IDL> misr_orbit = 65487
   ;      IDL> misr_block = 111
   ;      IDL> log_it = 1
   ;      IDL> save_it = 1
   ;      IDL> verbose = 2
   ;      IDL> debug = 1
   ;      IDL> rc = diag_rccm(misr_path, misr_orbit, misr_block, $
   ;         LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;         SAVE_IT = save_it, SAVE_FOLDER = save_folder, $
   ;         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      Saved ~/MISR_HR/Outcomes/GM-P168-O065487-B111/RCCM/
   ;         Save_RCCM_diag_GM-P168-O065487-B111-AA_2012-04-10_2019-02-19.sav
   ;      Saved ~/MISR_HR/Outcomes/GM-P168-O065487-B111/RCCM/
   ;         Log_RCCM_diag_GM-P168-O065487-B111-AA_2012-04-10_2019-02-19.txt
   ;      ...
   ;      Saved ~/MISR_HR/Outcomes/GM-P168-O065487-B111/RCCM/
   ;         Save_RCCM_diag_GM-P168-O065487-B111-DF_2012-04-10_2019-02-19.sav
   ;      Saved ~/MISR_HR/Outcomes/GM-P168-O065487-B111/RCCM/
   ;         Log_RCCM_diag_GM-P168-O065487-B111-DF_2012-04-10_2019-02-19.txt
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2019–02–05: Version 1.0 — Initial release.
   ;
   ;  *   2019–02–06: Version 1.1 — Initial public release, following the
   ;      stricter coding and documentation standards.
   ;
   ;  *   2019–02–18: Version 2.00 — Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
   ;
   ;  *   2019–02–28: Version 2.01 — Documentation update.
   ;
   ;  *   2019–03–28: Version 2.10 — Update the handling of the optional
   ;      input keyword parameter VERBOSE and generate the software
   ;      version consistent with the published documentation.
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
   IF (KEYWORD_SET(save_it)) THEN save_it = 1 ELSE save_it = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 3
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_orbit, misr_block.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_path' is invalid:
      rc = chk_misr_path(misr_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_orbit' is invalid:
      rc = chk_misr_orbit(misr_orbit, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_orbit' is inconsistent with the input
   ;  positional parameter 'misr_path':
      res = is_frompath(misr_path, misr_orbit, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (res NE 1) THEN BEGIN
         CASE 1 OF
            (res EQ 0): BEGIN
               error_code = 122
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input positional parameter ' + $
                  'misr_orbit is inconsistent with the input positional ' + $
                  'parameter misr_path.'
               RETURN, error_code
            END
            (res EQ -1): BEGIN
               error_code = 124
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': ' + excpt_cond
               RETURN, error_code
            END
         ENDCASE
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_block' is invalid:
      rc = chk_misr_block(misr_block, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 130
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
   IF (~KEYWORD_SET(rccm_version)) THEN rccm_version = versions[5]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Orbit number:
   rc = orbit2str(misr_orbit, misr_orbit_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   mpob_str = 'GM-' + misr_path_str + '-' + misr_orbit_str + '-' + misr_block_str

   ;  Get the date of acquisition of this MISR Orbit:
   acquis_date = orbit2date(LONG(misr_orbit), DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (debug AND (excpt_cond NE '')) THEN BEGIN
      error_code = 230
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Return to the calling routine with an error message if the routine
   ;  'set_roots_vers.pro' could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF (~KEYWORD_SET(rccm_folder) OR $
         (log_it AND (~KEYWORD_SET(log_folder))) OR $
         (save_it AND (~KEYWORD_SET(save_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
            rout_name + ': ' + excpt_cond + $
            ' And at least one of the optional input keyword ' + $
            'parameters rccm_folder, log_folder, save_folder, ' + $
            'is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Get the file specifications of the 9 L1 RCCM files corresponding to the
   ;  inputs above:
   rc = find_rccm_files(misr_path, misr_orbit, rccm_files, $
      RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   n_files = N_ELEMENTS(rccm_files)

   ;  Set the directory address of the folder containing the output log file
   ;  if it has not been set previously:
   IF (KEYWORD_SET(log_folder)) THEN BEGIN
      log_fpath = force_path_sep(log_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
   ENDIF ELSE BEGIN
      log_fpath = root_dirs[3] + mpob_str + PATH_SEP() + 'RCCM' + PATH_SEP()
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

   ;  Set the directory address of the folder containing the output save file
   ;  if it has not been set previously:
   IF (KEYWORD_SET(save_folder)) THEN BEGIN
      save_fpath = force_path_sep(save_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
   ENDIF ELSE BEGIN
      save_fpath = root_dirs[3] + mpob_str + PATH_SEP() + 'RCCM' + PATH_SEP()
   ENDELSE

   ;  Return to the calling routine with an error message if the output
   ;  directory 'save_fpath' is not writable, and create it if it does not
   ;  exist:
   rc = is_writable(save_fpath, DEBUG = debug, EXCPT_COND = excpt_cond)
   CASE rc OF
      1: BREAK
      0: BEGIN
            error_code = 520
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The output folder ' + save_fpath + $
               ' is unwritable.'
            RETURN, error_code
         END
      -1: BEGIN
            IF (debug) THEN BEGIN
               error_code = 530
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': ' + excpt_cond
               RETURN, error_code
            ENDIF
         END
      -2: BEGIN
            FILE_MKDIR, save_fpath
         END
      ELSE: BREAK
   ENDCASE

   i_cams = STRARR(n_files)
   i_vers = STRARR(n_files)
   log_fspecs = STRARR(n_files)
   fmt1 = '(A30, A)'

   FOR i = 0, n_files - 1 DO BEGIN

   ;  Get the camera name and the MISR version number from the input filename:
      parts = STRSPLIT(FILE_BASENAME(rccm_files[i], '.hdf'), '_', $
         COUNT = n_parts, /EXTRACT)
      i_cams[i] = parts[7]
      status = MTK_FILE_VERSION(rccm_files[0], misr_version)
      i_vers[i] = misr_version

      IF (log_it) THEN BEGIN
         log_fname = 'Log_RCCM_diag_' + mpob_str + '-' + i_cams[i] + '_' + $
            acquis_date + '_' + date + '.txt'
         log_fspecs[i] = log_fpath + log_fname

   ;  Save the outcome in a separate diagnostic file for each camera:
         OPENW, log_unit, log_fspecs[i], /GET_LUN
         PRINTF, log_unit, 'File name: ', log_fname, FORMAT = fmt1
         PRINTF, log_unit, 'Folder name: ', log_fpath, FORMAT = fmt1
         PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
         PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
         PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
         PRINTF, log_unit

         PRINTF, log_unit, 'Content: ', 'Metadata for a single Block ' + $
            'of a single', FORMAT = fmt1
         PRINTF, log_unit, '', 'MISR RCCM Terrain-projected Global Mode ' + $
            '(camera) file.', FORMAT = fmt1
         PRINTF, log_unit
         PRINTF, log_unit, 'MISR Path: ', strstr(misr_path), FORMAT = fmt1
         PRINTF, log_unit, 'MISR Orbit: ', strstr(misr_orbit), FORMAT = fmt1
         PRINTF, log_unit, 'MISR Block: ', strstr(misr_block), FORMAT = fmt1
         PRINTF, log_unit, 'MISR Camera: ', i_cams[i], FORMAT = fmt1
         PRINTF, log_unit, 'Date of MISR acquisition: ', acquis_date, $
            FORMAT = fmt1
         PRINTF, log_unit
      ENDIF

   ;  Create the output meta_data structure:
      meta_data = CREATE_STRUCT('Title', $
         'Metadata for a single Block of a single MISR RCCM file')
      meta_data = CREATE_STRUCT(meta_data, 'OS_Path', $
         FILE_DIRNAME(rccm_files[i]))
      meta_data = CREATE_STRUCT(meta_data, 'OS_File', $
         FILE_BASENAME(rccm_files[i]))
      meta_data = CREATE_STRUCT(meta_data, 'MISR_Path', misr_path)
      meta_data = CREATE_STRUCT(meta_data, 'MISR_Orbit', misr_orbit)
      meta_data = CREATE_STRUCT(meta_data, 'MISR_Block', misr_block)
      meta_data = CREATE_STRUCT(meta_data, 'MISR_Camera', i_cams[i])
      meta_data = CREATE_STRUCT(meta_data, 'MISR_RCCM_Version', rccm_version)

   ;  Define the (1-Block) region of interest:
      status = MTK_SETREGION_BY_PATH_BLOCKRANGE(misr_path, $
         misr_block, misr_block, region)
      IF (debug AND (status NE 0)) THEN BEGIN
         error_code = 600
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': status from MTK_SETREGION_BY_PATH_BLOCKRANGE = ' + strstr(status)
         RETURN, error_code
      ENDIF

   ;  Retrieve the names of the first grid:
      status = MTK_FILE_TO_GRIDLIST(rccm_files[i], ngrids, grids)
      IF (debug AND (status NE 0)) THEN BEGIN
         error_code = 610
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': status from MTK_FILE_TO_GRIDLIST = ' + strstr(status)
         RETURN, error_code
      ENDIF
      meta_data = CREATE_STRUCT(meta_data, 'Ngrids', ngrids)

   ;  For this grid, record its name:
      FOR j = 0, 0 DO BEGIN
         tagg = 'Grid_' + strstr(j)
         valg = grids[j]
         meta_data = CREATE_STRUCT(meta_data, tagg, valg)

   ;  Retrieve the names of the fields in this grid:
         status = MTK_FILE_GRID_TO_FIELDLIST(rccm_files[i], grids[j], $
            nfields, fields)
         IF (debug AND (status NE 0)) THEN BEGIN
            error_code = 620
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': status from MTK_FILE_GRID_TO_FIELDLIST = '+ strstr(status)
            RETURN, error_code
         ENDIF

         tagnf = tagg + '_Nfields'
         valnf = nfields
         meta_data = CREATE_STRUCT(meta_data, tagnf, valnf)

   ;  For each of the first 3 fields, record its name:
         FOR k = 0, 2 DO BEGIN
            tagfn = tagg + '_Field_' + strstr(k)
            valfn = fields[k]
            meta_data = CREATE_STRUCT(meta_data, tagfn, valfn)

   ;  Read the data for that grid and field:
            status = MTK_READDATA(rccm_files[i], grids[j], fields[k], $
               region, databuf, mapinfo)
            IF (status NE 0) THEN BEGIN
               error_code = 630
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': status from MTK_READDATA = ' + strstr(status)
               RETURN, error_code
            ENDIF

   ;  Count the total number of pixels in that field:
            npixels = N_ELEMENTS(databuf)
            tagnp = tagfn + '_Npixels'
            valnp = npixels
            meta_data = CREATE_STRUCT(meta_data, tagnp, valnp)

   ;  Report on the field data type:
            type = SIZE(databuf, /TYPE)
            tagty = tagfn + '_IDLType'
            valty = type
            meta_data = CREATE_STRUCT(meta_data, tagty, valty)

   ;  Field-specific processing:
   ;  Process the Cloud field:
            IF (STRPOS(fields[k], 'Cloud') GE 0) THEN BEGIN

   ;  Count the number of non-retrieved values:
               idx_nnocld = WHERE(databuf EQ 0B, nnocld)
               tagnnocld = tagfn + '_Nnocld'
               valnnocld = nnocld
               meta_data = CREATE_STRUCT(meta_data, tagnnocld, valnnocld)

   ;  Count the number of high-confidence cloud pixels in that field:
               idx_nhicld = WHERE(databuf EQ 1B, nhicld)
               tagnhicld = tagfn + '_Nhicld'
               valnhicld = nhicld
               meta_data = CREATE_STRUCT(meta_data, tagnhicld, valnhicld)

   ;  Count the number of low-confidence cloud pixels in that field:
               idx_nlocld = WHERE(databuf EQ 2B, nlocld)
               tagnlocld = tagfn + '_Nlocld'
               valnlocld = nlocld
               meta_data = CREATE_STRUCT(meta_data, tagnlocld, valnlocld)

   ;  Count the number of low-confidence clear pixels in that field:
               idx_nloclr = WHERE(databuf EQ 3B, nloclr)
               tagnloclr = tagfn + '_Nloclr'
               valnloclr = nloclr
               meta_data = CREATE_STRUCT(meta_data, tagnloclr, valnloclr)

   ;  Count the number of high-confidence clear pixels in that field:
               idx_nhiclr = WHERE(databuf EQ 4B, nhiclr)
               tagnhiclr = tagfn + '_Nhiclr'
               valnhiclr = nhiclr
               meta_data = CREATE_STRUCT(meta_data, tagnhiclr, valnhiclr)

   ;  Count the number of fill values in the Cloud field:
               idx_cldfill = WHERE(databuf EQ 255B, ncldfill)
               tagncldfill = tagfn + '_Ncldfill'
               valncldfill = ncldfill
               meta_data = CREATE_STRUCT(meta_data, tagncldfill, valncldfill)
            ENDIF

   ;  Process the Glitter field:
            IF (STRPOS(fields[k], 'Glitter') GE 0) THEN BEGIN

   ;  Count the number of pixels not contaminated by glitter:
               idx_nnoglt = WHERE(databuf EQ 0B, nnoglt)
               tagnnoglt = tagfn + 'Nnoglt'
               valnnoglt = nnoglt
               meta_data = CREATE_STRUCT(meta_data, tagnnoglt, valnnoglt)

   ;  Count the number of pixels contaminated by glitter:
               idx_nglt = WHERE(databuf EQ 1B, nglt)
               tagnglt = tagfn + 'Nglt'
               valnglt = nglt
               meta_data = CREATE_STRUCT(meta_data, tagnglt, valnglt)

   ;  Count the number of fill values in the Glitter field:
               idx_gltfill = WHERE(databuf EQ 255B, ngltfill)
               tagngltfill = tagfn + '_Ngltfill'
               valngltfill = ngltfill
               meta_data = CREATE_STRUCT(meta_data, tagngltfill, valngltfill)
            ENDIF

   ;  Process the Quality field:
            IF (STRPOS(fields[k], 'Quality') GE 0) THEN BEGIN

   ;  Count the number of non-retrieved values:
               idx_nnoqual = WHERE(databuf EQ 255B, nnoqual)
               tagnnoqual = tagfn + '_Nnoqual'
               valnnoqual = nnoqual
               meta_data = CREATE_STRUCT(meta_data, tagnnoqual, valnnoqual)

    ;  Count the number of pixels where only the secondary test was used:
               idx_n2tst = WHERE(databuf EQ 1B, n2tst)
               tagn2tst = tagfn + '_N2tst'
               valn2tst = n2tst
               meta_data = CREATE_STRUCT(meta_data, tagn2tst, valn2tst)

   ;  Count the number of pixels where only the primary test was used:
               idx_n1tst = WHERE(databuf EQ 2B, n1tst)
               tagn1tst = tagfn + '_N1tst'
               valn1tst = n1tst
               meta_data = CREATE_STRUCT(meta_data, tagn1tst, valn1tst)

   ;  Count the number of pixels where both tests were used:
               idx_n12tst = WHERE(databuf EQ 3B, n12tst)
               tagn12tst = tagfn + '_N12tst'
               valn12tst = n12tst
               meta_data = CREATE_STRUCT(meta_data, tagn12tst, valn12tst)

   ;  Count the number of fill values in the Quality field:
               idx_qualfill = WHERE(databuf EQ 255B, nqualfill)
               tagnqualfill = tagfn + '_Nqualfill'
               valnqualfill = nqualfill
               meta_data = CREATE_STRUCT(meta_data, tagnqualfill, valnqualfill)
            ENDIF
         ENDFOR   ;  End of loop on fields
      ENDFOR   ;  End of loop on grids

   ;  Save the alphanumeric results contained in the structure 'meta_data' in
   ;  a camera-specific '.sav' file:
      IF (save_it) THEN BEGIN
         save_fname = 'Save_RCCM_diag_' + mpob_str + '-' + i_cams[i] + '_' + $
            acquis_date + '_' + date + '.sav'
         save_fspec = save_fpath + save_fname
         SAVE, meta_data, FILENAME = save_fspec
         IF (log_it) THEN BEGIN
            PRINTF, log_unit, 'Saved ' + FILE_BASENAME(save_fspec)
            PRINTF, log_unit
         ENDIF
      ENDIF

   ;  Print each diagnostic structure tag and its value in the diagnostic log
   ;  file:
      IF (log_it) THEN BEGIN
         ntags = N_TAGS(meta_data)
         tagnames = TAG_NAMES(meta_data)
         nd = oom(ntags, BASE = 10.0, DEBUG = debug, $
            EXCPT_COND = excpt_cond) + 1
         fmt2 = '(I' + strstr(nd) + ', A' + strstr(29 - nd) + ', 1X, A)'

   ;  Generic HDF file information:
         FOR itag = 0, 7 DO BEGIN
            PRINTF, log_unit, FORMAT = fmt2, $
               itag, tagnames[itag], strstr(meta_data.(itag))
         ENDFOR
         PRINTF, log_unit

   ;  Number of Grids in this HDF file:
         PRINTF, log_unit, FORMAT = fmt2, $
            8, tagnames[8], strstr(meta_data.(8))

   ;  Print the rest of the structure:
         FOR itag = 9, ntags - 1 DO BEGIN
            IF (STRPOS(strstr(meta_data.(itag)), 'Band') GT 0) THEN $
               PRINTF, log_unit
               PRINTF, log_unit, FORMAT = fmt2, $
                  itag, tagnames[itag], strstr(meta_data.(itag))
         ENDFOR

         IF (log_it) THEN BEGIN
            FREE_LUN, log_unit
            CLOSE, log_unit
         ENDIF

         IF ((verbose GT 1) AND save_it) THEN PRINT, 'Saved ' + save_fspec
         IF ((verbose GT 1) AND log_it) THEN PRINT, 'Saved ' + log_fspecs[i]
      ENDIF
   ENDFOR   ;  End of loop on RCCM files

   IF (verbose GT 0) THEN PRINT, 'Exiting ' + rout_name + '.'

END
