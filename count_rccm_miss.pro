FUNCTION count_rccm_miss, $
   misr_path, $
   misr_block, $
   L1B2_FOLDER = l1b2_folder, $
   L1B2_VERSION = l1b2_version, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   OUT_FOLDER = out_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function counts the number of missing RCCM pixel
   ;  values found in each of the 9 cameras of all available ORBITS for
   ;  the specified MISR PATH and BLOCK, and saves the results in a plain
   ;  ASCII text file.
   ;
   ;  ALGORITHM: This function relies on the IDL functions rccm_0 and
   ;  rccm_1 to read the RCCM files for each of the available ORBITS and
   ;  to distinguish genuinely missing values from swath edge and obscured
   ;  values. This requires loading the corresponding MISR L1B2 Radiance
   ;  files to locate those edge and obscured values.
   ;
   ;  SYNTAX: rc = count_rccm_miss(misr_path, misr_block, $
   ;  L1B2_FOLDER = l1b2_folder, L1B2_VERSION = l1b2_version, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  OUT_FOLDER = out_folder, VERBOSE = verbose, $
   ;  DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_block {INT} [I]: The selected MISR BLOCK number.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   L1B2_FOLDER = l1b2_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the MISR L1B2 files, if they are not located in the
   ;      default location.
   ;
   ;  *   L1B2_VERSION = l1b2_version {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The L1B2 version identifier to use instead
   ;      of the default value.
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
   ;  *   OUT_FOLDER = out_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the output file(s).
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
   ;      provided in the call. The output file containing the statistics
   ;      on the number of missing values in each RCCM file is saved in
   ;      the default or designated folder.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output file may be inexistent, incomplete or
   ;      incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: The input positional parameter misr_block is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      block2str.pro.
   ;
   ;  *   Error 299: The computer is not recognized and at least one of
   ;      the optional input keyword parameters l1b2_folder, rccm_folder,
   ;      out_folder is not specified.
   ;
   ;  *   Error 300: The input folder l1b2_path is not found, not a
   ;      directory or not readable.
   ;
   ;  *   Error 310: The input folder rccm_path is not found, not a
   ;      directory or not readable.
   ;
   ;  *   Error 400: The output folder out_fpath is not writable.
   ;
   ;  *   Error 500: The gm_orbits and rc_orbits arrays have no ORBIT
   ;      number in common.
   ;
   ;  *   Error 510: An exception condition occurred in function
   ;      heap_l1b2_block.pro.
   ;
   ;  *   Error 600: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_SETREGION_BY_PATH_BLOCKRANGE.
   ;
   ;  *   Error 610: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_MAKE_FILENAME.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   cgSetIntersection (David W. Fanning, Coyote Library)
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_misr_block.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   find_rccm_files.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   heap_l1b2_block.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_readable_dir.pro
   ;
   ;  *   is_writable_dir.pro
   ;
   ;  *   mk_rccm0.pro
   ;
   ;  *   mk_rccm1.pro
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
   ;  *   NOTE 1: Because the MISR L1B2 files need to be read to process
   ;      the RCCM files, this function is very time consuming: it can
   ;      take over an hour to generate the statistics for a single BLOCK
   ;      over the entire mission period. Set the optional input keyword
   ;      parameter VERBOSE to 2 to generate an intermediary progress
   ;      report on the console each time 50 ORBITS have been processed.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 167
   ;      IDL> misr_block = 100
   ;      IDL> rc = count_rccm_miss(misr_path, misr_block)
   ;      IDL> PRINT, rc
   ;             0
   ;
   ;  REFERENCES:
   ;
   ;  *   Michel M. Verstraete, Linda A. Hunt, Hugo De Lemos and Larry Di
   ;      Girolamo (2019) Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product,
   ;      _Earth System Science Data Discussions_, Vol. 2019, p. 1–18,
   ;      available from
   ;      https://www.earth-syst-sci-data-discuss.net/essd-2019-77/ (DOI:
   ;      10.5194/essd-2019-77).
   ;
   ;  *   Michel M. Verstraete, Linda A. Hunt, Hugo De Lemos and Larry Di
   ;      Girolamo (2020) Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product,
   ;      _Earth System Science Data_, Vol. 12, p. 611–628, available from
   ;      https://www.earth-syst-sci-data.net/12/611/2020/essd-12-611-2020.html
   ;      (DOI: 10.5194/essd-12-611-2020).
   ;
   ;  VERSIONING:
   ;
   ;  *   2019–04–30: Version 1.0 — Initial release.
   ;
   ;  *   2019–05–01: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–05–04: Version 2.01 — Update the code to report the
   ;      specific error message of MTK routines.
   ;
   ;  *   2019–05–07: Version 2.15 — Software version described in the
   ;      preprint published in _ESSD Discussions_ mentioned above.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the use of
   ;      verbose and the assignment of numeric return codes), and switch
   ;      to 3-parts version identifiers.
   ;
   ;  *   2020–02–18: Version 2.1.1 — Update the code to use the current
   ;      version of the function heap_l1b2_block.pro.
   ;
   ;  *   2020–03–19: Version 2.2.0 — Software version described in the
   ;      peer-reviewed paper published in _ESSD_ referenced above.
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
      n_reqs = 2
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_block.'
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
   ;  positional parameter 'misr_block' is invalid:
      rc = chk_misr_block(misr_block, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
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
   IF (~KEYWORD_SET(l1b2_version)) THEN l1b2_version = versions[2]
   IF (~KEYWORD_SET(rccm_version)) THEN rccm_version = versions[5]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Return to the calling routine with an error message if the routine
   ;  'set_roots_vers.pro' could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF(~KEYWORD_SET(l1b2_folder) OR $
         ~KEYWORD_SET(rccm_folder) OR $
         ~KEYWORD_SET(out_folder)) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Computer is unrecognized, function set_roots_vers.pro did ' + $
            'not assign default folder values, and at least one of the ' + $
            'optional keyword parameters l1b2_folder, rccm_folder, ' + $
            'out_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the input L1B2 files
   ;  if it has not been set previously, and verify that it exists:
   IF (KEYWORD_SET(l1b2_folder)) THEN BEGIN
      rc = force_path_sep(l1b2_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
      l1b2_fpath = l1b2_folder
   ENDIF ELSE BEGIN
      l1b2_fpath = root_dirs[1] + misr_path_str + PATH_SEP() + $
         'L1_GM' + PATH_SEP()
   ENDELSE
   IF (debug) THEN BEGIN
      res = is_readable_dir(l1b2_fpath)
      IF (res NE 1) THEN BEGIN
         error_code = 300
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Folder l1b2_fpath does not exist or is unreadable.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the input RCCM files
   ;  if it has not been set previously, and verify that it exists:
   IF (KEYWORD_SET(rccm_folder)) THEN BEGIN
      rc = force_path_sep(rccm_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
      rccm_fpath = rccm_folder
   ENDIF ELSE BEGIN
      rccm_fpath = root_dirs[1] + misr_path_str + PATH_SEP() + $
         'L1_RC' + PATH_SEP()
   ENDELSE
   IF (debug) THEN BEGIN
      res = is_readable_dir(rccm_fpath)
      IF (res NE 1) THEN BEGIN
         error_code = 310
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Folder rccm_fpath does not exist or is unreadable.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Retrieve and count the names of all locally available MISR L1B2 Radiance
   ;  files for the specified Path:
   in_gm_files = FILE_SEARCH(l1b2_fpath + 'MISR*_GM_*.hdf', $
      COUNT = n_gm_files)
   tst = n_gm_files MOD 9
   n_gm_orbits = n_gm_files / 9
   IF (debug AND (verbose GT 2)) THEN BEGIN
      PRINT, 'Found ' + strstr(n_gm_files) + ' L1B2 GRP GM files.'
      IF (tst NE 0) THEN PRINT, 'This is not a multiple of 9, so at least ' + $
         'one of the Orbits does not feature 9 input GRP GM files.'
   ENDIF

   ;  Generate a STRING array of unique MISR L1B2 Orbit numbers:
   pos = STRPOS(in_gm_files[0], '_O')
   gm_orbits = STRMID(in_gm_files, pos + 2, 6)
   gm_orbits = gm_orbits[UNIQ(gm_orbits)]

   ;  Set the directory address of the folder containing the outputs
   ;  if it has not been set previously:
   IF (KEYWORD_SET(out_folder)) THEN BEGIN
      rc = force_path_sep(out_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
      out_fpath = out_folder
   ENDIF ELSE BEGIN
      out_fpath = root_dirs[3] + 'GM-' + misr_path_str + '-' + $
         misr_block_str + PATH_SEP()
   ENDELSE

   ;  Create the output directory 'out_fpath' if it does not exist:
   res = is_writable_dir(out_fpath, /CREATE)
   IF (debug AND (res NE 1)) THEN BEGIN
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
         rout_name + ': The variable out_fpath is unwritable.'
      RETURN, error_code
   ENDIF

   ;  Retrieve and count the names of all locally available MISR RCCM files
   ;  for the specified Path:
   in_rc_files = FILE_SEARCH(rccm_fpath + 'MISR*_RCCM_*.hdf', $
      COUNT = n_rc_files)
   tst = n_rc_files MOD 9
   n_rc_orbits = n_rc_files / 9
   IF (debug AND (verbose GT 2)) THEN BEGIN
      PRINT, 'Found ' + strstr(n_rc_files) + ' L1B2 RCCM files.'
      IF (tst NE 0) THEN PRINT, 'This is not a multiple of 9, so at least ' + $
         'one of the Orbits does not feature 9 input RCCM files.'
   ENDIF

   ;  Generate a STRING array of unique MISR RCCM Orbit numbers:
   pos = STRPOS(in_rc_files[0], '_O')
   rc_orbits = STRMID(in_rc_files, pos + 2, 6)
   rc_orbits = rc_orbits[UNIQ(rc_orbits)]

   ;  Identify the set of MISR Orbits for which both the 9 L1B2 and the
   ;  9 RCCM files are available:
   idx_com_orbits = cgSetIntersection(LONG(gm_orbits), LONG(rc_orbits), $
      COUNT = n_com_orbits, INDICES_A = indices_a, INDICES_B = indices_b, $
      NORESULT = noresult, POSITIONS = positions, SUCCESS = success)
   IF (debug AND (success EQ 0)) THEN BEGIN
      error_code = 500
      excpt_cond = 'Error ' + strstr(error_code) + ' in cgSetIntersection' + $
         ': The gm_orbits and rc_orbits arrays have no Orbit number in common.'
      RETURN, error_code
   ENDIF
   com_orbits = strstr(idx_com_orbits)

   ;  Define the arrays that will contain the results:
   com_dat = STRARR(n_com_orbits)
   com_jul = DBLARR(n_com_orbits)
   n_miss_pts = LONARR(n_com_orbits, 9)

   ;  Define the (1-Block) region of interest to be the specified Block:
   status = MTK_SETREGION_BY_PATH_BLOCKRANGE(misr_path, $
      misr_block, misr_block, region)
   IF (debug AND (status NE 0)) THEN BEGIN
      error_code = 600
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Error message from MTK_SETREGION_BY_PATH_BLOCKRANGE: ' + $
         MTK_ERROR_MESSAGE(status)
      RETURN, error_code
   ENDIF

   IF (verbose GT 0) THEN BEGIN
      PRINT, 'Ready to process ' + strstr(n_com_orbits) + ' Orbits.'
   ENDIF

   misr_mode = 'GM'

   ;  Loop over all available Orbits for which the L1B2 and the RCCM files
   ;  are both available:
   FOR i_com_orbit = 0, n_com_orbits - 1 DO BEGIN
      com_orbit = com_orbits[i_com_orbit]
      misr_orbit = LONG(com_orbit)

   ;  Get the date and the Julian date of acquisition of the current Orbit:
      res = orbit2date(LONG(com_orbit))
      com_dat[i_com_orbit] = res
      res = orbit2date(LONG(com_orbit), /JULIAN)
      com_jul[i_com_orbit] = res

   ;  Load the 36 L1B2 data channels for the current Orbit on the heap:
      rc = heap_l1b2_block(misr_mode, misr_path, misr_orbit, misr_block, $
         misr_ptr, radrd_ptr, rad_ptr, brf_ptr, rdqi_ptr, scalf_ptr, $
         convf_ptr, L1B2GM_FOLDER = l1b2gm_folder, $
         L1B2GM_VERSION = l1b2gm_version, $
         L1B2LM_FOLDER = l1b2lm_folder, L1B2LM_VERSION = l1b2lm_version, $
         MISR_SITE = misr_site, TEST_ID = test_id, $
         FIRST_LINE = first_line, LAST_LINE = last_line, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)

      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 510
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF

   ;  Locate the corresponding RCCM files for the current Orbit:
      rc = find_rccm_files(misr_path, misr_orbit, rccm_files, $
         RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
         DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Read the 9 standard MISR RCCM files for the current Orbit:
      rc = mk_rccm0(rccm_files, misr_block, rccm_0, n_miss_0, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Update the original MISR RCCM data to flag edge and obscured pixels:
      rc = mk_rccm1(rccm_0, misr_ptr, radrd_ptr, rccm_1, n_miss_1, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Record the number of missing RCCM values in the 9 cameras of the
   ;  current Orbit:
      n_miss_pts[i_com_orbit, *] = n_miss_1

   ;  Clear the heap memory for the next Orbit:
      PTR_FREE, misr_ptr, radrd_ptr, rad_ptr, brf_ptr, rdqi_ptr, $
         scalf_ptr, convf_ptr

      IF ((verbose GT 0) AND $
         ((i_com_orbit MOD 25) EQ 0) AND $
         (i_com_orbit GT 0)) THEN BEGIN
         PRINT, 'Processed ' + strstr(i_com_orbit) + ' Orbits.'
      ENDIF
   ENDFOR

   ;  Generate the name of the output file to contain the results:
   out_fname = 'Num_RCCM_miss_' + misr_path_str + '-' + misr_block_str + $
      '_' + com_dat[0] + '_' + com_dat[n_com_orbits - 1] + '.txt'
   out_fspec = out_fpath + out_fname

   ;  Open the output file:
   OPENW, out_unit, out_fspec, /GET_LUN

   fmt1 = '(A4, 2X, A6, 2X, A12, 2X, A12, 9(2X, A8), 2X, A10)'
   fmt2 = '(I4, 2X, I6, 2X, A12, 2X, F12.2, 9(2X, I8), 2X, I10)'

   ;  Write the header:
   PRINTF, out_unit, 'Statistics on the number of missing RCCM values by ' + $
      'Orbit and Camera for Path ' + strstr(misr_path) + ' and Block ' + $
      strstr(misr_block)
   PRINTF, out_unit, '#', 'Orbit', 'Cal date', 'Julian date', 'DF', 'CF', $
      'BF', 'AF', 'AN', 'AA', 'BA', 'CA', 'DA', 'Total', FORMAT = fmt1
   PRINTF, out_unit, strrepeat("=", 142)

   ;  Write the results:
   FOR i_orbit = 0, n_com_orbits - 1 DO BEGIN
      PRINTF, out_unit, i_orbit, com_orbits[i_orbit], $
         com_dat[i_orbit], com_jul[i_orbit], n_miss_pts [i_orbit, *], $
         TOTAL(n_miss_pts [i_orbit, *]), FORMAT = fmt2
   ENDFOR

   ;  Close the output file:
   FREE_LUN, out_unit

   IF (verbose GT 0) THEN BEGIN
      PRINT, 'The results have been saved in the output file'
      PRINT, out_fspec
   ENDIF
   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

END
