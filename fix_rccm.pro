FUNCTION fix_rccm, $
   misr_path, $
   misr_orbit, $
   misr_block, $
   rccm, $
   L1B2_FOLDER = l1b2_folder, $
   L1B2_VERSION = l1b2_version, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   LOG_IT = log_it, $
   LOG_FOLDER = log_folder, $
   SAVE_IT = save_it, $
   SAVE_FOLDER = save_folder, $
   MAP_IT = map_it, $
   MAP_FOLDER = map_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function generates a clean version of the MISR L1B2
   ;  Georectified Radiance Product (GRP) Radiometric Camera-by-camera
   ;  Cloud Mask (RCCM) data product with edge and obscured pixels duly
   ;  flagged and missing values replaced by reasonable estimates.
   ;
   ;  ALGORITHM: This function reads the 9 original MISR RCCM data product
   ;  files for the specified PATH, ORBIT and BLOCK, as well as the
   ;  corresponding 9 L1B2 Georectified Radiance Product (GRP) Terrain
   ;  projected Global Mode (GM) files, and replaces eventual missing
   ;  values by estimates based on the values of neighboring pixels within
   ;  a 3 × 3 (or a 5 × 5) pixel window.
   ;
   ;  SYNTAX: rc = fix_rccm(misr_path, misr_orbit, misr_block, $
   ;  rccm, L1B2_FOLDER = l1b2_folder, L1B2_VERSION = l1b2_version, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  SAVE_IT = save_it, SAVE_FOLDER = save_folder, $
   ;  MAP_IT = map_it, MAP_FOLDER = map_folder, $
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
   ;  *   rccm {BYTE array} [O]:  The cleaned RCCM product.
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
   ;  *   MAP_IT = map_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating maps of the numerical results.
   ;
   ;  *   MAP_FOLDER = map_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the maps.
   ;
   ;  *   VERBOSE = verbose {INT} [I] (Default value: 0): Flag to
   ;      enable (1) or skip (0) reporting progress on the console.
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
   ;      provided in the call. The output positional parameter rccm
   ;      contains a clean version of the MISR RCCM data product. The
   ;      meaning of pixel values is as follows:
   ;
   ;      -   0B: Missing.
   ;
   ;      -   1B: Cloud with high confidence.
   ;
   ;      -   2B: Cloud with low confidence.
   ;
   ;      -   3B: Clear with low confidence.
   ;
   ;      -   4B: Clear with high confidence.
   ;
   ;      -   253B: Obscured.
   ;
   ;      -   254B: Edge.
   ;
   ;      -   255B: Fill.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The output positional parameter rccm inexistent,
   ;      incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Warning 98: The current computer is unrecognized.
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: Input positional parameter misr_orbit is invalid.
   ;
   ;  *   Error 130: Input positional parameter misr_block is invalid.
   ;
   ;  *   Error 199: An exception condition occurred in the function
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in the function
   ;      path2str.pro.
   ;
   ;  *   Error 202: An exception condition occurred in the function
   ;      path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in the function
   ;      orbit2str.pro.
   ;
   ;  *   Error 212: An exception condition occurred in the function
   ;      orbit2str.pro.
   ;
   ;  *   Error 220: An exception condition occurred in the function
   ;      block2str.pro.
   ;
   ;  *   Error 230: An exception condition occurred in the function
   ;      orbit2date.pro.
   ;
   ;  *   Error 240: RCCM file for the current camera not found.
   ;
   ;  *   Error 250: Found multiple RCCM files for the current camera.
   ;
   ;  *   Error 299: The current computer is unrecognized and one or more
   ;      input or output folder(s) is not specified by keyword
   ;      parameters.
   ;
   ;  *   Error 300: The RCCM file exists but is unreadable.
   ;
   ;  *   Error 302: The L1B2 file exists but is unreadable.
   ;
   ;  *   Error 310: An exception condition occurred in the function
   ;      is_readable.pro.
   ;
   ;  *   Error 312: An exception condition occurred in the function
   ;      is_readable.pro.
   ;
   ;  *   Error 320: The RCCM file does not exist.
   ;
   ;  *   Error 322: The L1B2 file does not exist.
   ;
   ;  *   Error 330: An exception condition occurred in the function
   ;      mk_rccm_0.pro.
   ;
   ;  *   Error 340: An exception condition occurred in the function
   ;      mk_rccm_1.pro.
   ;
   ;  *   Error 350: An exception condition occurred in the function
   ;      mk_rccm_2.pro.
   ;
   ;  *   Error 360: An exception condition occurred in the function
   ;      mk_rccm_0.pro.
   ;
   ;  *   Error 400: L1B2 file for the current camera not found.
   ;
   ;  *   Error 410: Found multiple L1B2 files for the current camera.
   ;
   ;  *   Error 500: The output folder log_path is unwritable.
   ;
   ;  *   Error 510: An exception condition occurred in the function
   ;      is_writable.pro.
   ;
   ;  *   Error 520: The output folder map_path is unwritable.
   ;
   ;  *   Error 530: An exception condition occurred in the function
   ;      is_writable.pro.
   ;
   ;  *   Error 600: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_MAKE_FILENAME.
   ;
   ;  *   Error 610: An exception condition occurred in the MISR TOOLKIT
   ;      routine
   ;      MTK_MAKE_FILENAME.
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
   ;  *   get_host_info.pro
   ;
   ;  *   is_readable.pro
   ;
   ;  *   mk_rccm_0.pro
   ;
   ;  *   mk_rccm_1.pro
   ;
   ;  *   mk_rccm_2.pro
   ;
   ;  *   orbit2date.pro
   ;
   ;  *   orbit2str.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_misr_specs.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: If specified, the optional keyword parameters XXX_FOLDER
   ;      override the default addresses given in set_roots_vers.pro.
   ;
   ;  *   NOTE 2: If specified, the optional keyword parameters
   ;      XXX_VERSION override the default version identifiers given in
   ;      set_roots_vers.pro.
   ;
   ;  *   NOTE 3: If a flag XXX_IT controlling an output file is
   ;      specified, the corresponding folder must be reachable by default
   ;      or given through the associated keyword, and be writable.
   ;
   ;  *   NOTE 4: If maps are requested by setting the input keyword
   ;      parameter map_it, map legends are also saved as text files with
   ;      matching names to describe the contents of these maps.
   ;
   ;  *   NOTE 5: The MISR RCCM product is only available at the reduced
   ;      spatial resolution of 128 line by 512 samples per BLOCK.
   ;
   ;  *   NOTE 6: The MISR RCCM product is provided on a per-camera basis,
   ;      and the cloud masks for a given camera apply to all spectral
   ;      bands of that camera.
   ;
   ;  *   NOTE 7: By default, the output files generated by this function
   ;      are saved in a folder located under the Global Mode outcomes.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> misr_orbit = 68050
   ;      IDL> misr_block = 110
   ;      IDL> log_it = 1
   ;      IDL> save_it = 1
   ;      IDL> map_it = 1
   ;      IDL> debug = 1
   ;      IDL> rc = fix_rccm(misr_path, misr_orbit, misr_block, rccm, $
   ;         LOG_IT = log_it, SAVE_IT = save_it, MAP_IT = map_it, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, 'rc = ', rc
   ;      rc =            0
   ;
   ;  REFERENCES:
   ;
   ;  *   Bull, M., Matthews, J., McDonald, D., Menzies, A., Moroney, C.,
   ;      Mueller, K. Paradise, S. and Smyth, M. (2011) _Data Products
   ;      Specifications_, Technical Report JPL D-13963, REVISION S, Jet
   ;      Propulsion Laboratory, California Institute of Technology,
   ;      Pasadena, CA, USA.
   ;
   ;  *   Diner, D. J., Di Girolamo, L. and Clothiaux, E. E. (1999) _Level
   ;      1 Cloud Detection Algorithm Theoretical Basis_, Technical Report
   ;      JPL D-13397, REVISION B, Jet Propulsion Laboratory, California
   ;      Institute of Technology, Pasadena, CA, USA.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–08–08: Version 0.8 — Original routines to manipulate MISR
   ;      RCCM data products provided by Linda Hunt.
   ;
   ;  *   2018–12–23: Version 0.9 — Initial release: This function and
   ;      those it depends on supersede all previous routines dealing with
   ;      MISR RCCM data products.
   ;
   ;  *   2018–12–30: Version 1.0 — Initial public release.
   ;
   ;  *   2019–01–30: Version 1.1 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–02: Version 1.2 — Add further diagnostic information in
   ;      the log file, update the code and the documentation.
   ;
   ;  *   2019–02–05: Version 1.3 — Reorganize the MISR RCCM functions.
   ;
   ;  *   2019–02–07: Version 1.4 — Rename this function from get_rccm.pro
   ;      to
   ;      fix_rccm.pro.
   ;
   ;  *   2019–02–18: Version 2.00 — Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
   ;
   ;  *   2019–02–24: Version 2.01 — Documentation update.
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
   IF (KEYWORD_SET(sav_it)) THEN sav_it = 1 ELSE sav_it = 0
   IF (KEYWORD_SET(map_it)) THEN map_it = 1 ELSE map_it = 0
   IF (KEYWORD_SET(verbose)) THEN verbose = 1 ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   ;  Initialize the output positional parameter(s):
   rccm = BYTARR(9, 512, 128)

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 4
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_orbit, ' + $
            'misr_block, rccm.'
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
   ;  positional parameter 'misr_block' is invalid:
      rc = chk_misr_block(misr_block, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   cams = misr_specs.CameraNames

   ;  Identify the current operating system and computer name:
   rc = get_host_info(os_name, comp_name, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 98
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
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
   IF (~KEYWORD_SET(l1b2_version)) THEN l1b2_version = versions[2]
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

   ;  Generate the short string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_s, /NOHEADER, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 202
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Orbit number:
   rc = orbit2str(misr_orbit, misr_orbit_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the short string version of the MISR Orbit number:
   rc = orbit2str(misr_orbit, misr_orbit_s, /NOHEADER, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 212
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   mpob_str = 'GM-' + misr_path_str + '-' + $
      misr_orbit_str + '-' + misr_block_str

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
   ;  set_roots_vers.pro could not assign valid values to the array root_dirs
   ;  and the required MISR and MISR-HR root folders have not been initialized:
   IF (debug AND (rc_roots EQ 99)) THEN BEGIN
      IF (~KEYWORD_SET(l1b2_folder) OR $
         ~KEYWORD_SET(rccm_folder) OR $
         (log_it AND (~KEYWORD_SET(log_folder))) OR $
         (save_it AND (~KEYWORD_SET(save_folder))) OR $
         (map_it AND (~KEYWORD_SET(map_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond + ' And at least one of the optional ' + $
            'input keyword parameters l1b2_folder, rccm_folder, ' + $
            'log_folder, save_folder or map_folder is not set.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the input RCCM files
   ;  if it has not been set previously:
   IF (KEYWORD_SET(rccm_folder)) THEN BEGIN
      rccm_fpath = force_path_sep(rccm_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
   ENDIF ELSE BEGIN
      rccm_fpath = root_dirs[1] + misr_path_str + PATH_SEP() + 'L1_RC' + $
         PATH_SEP()
   ENDELSE

   ;  Set the specifications of the RCCM files:
   rccm_files = STRARR(n_cams)
   misr_product = 'GRP_RCCM_GM'

   ;  Process each camera in turn, in the natural MISR order:
   FOR cam = 0, n_cams - 1 DO BEGIN
      status = MTK_MAKE_FILENAME(rccm_fpath, misr_product, cams[cam], $
         misr_path_s, misr_orbit_s, rccm_version, filename)
      IF (debug AND (status NE 0)) THEN BEGIN
         error_code = 600
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Status from MTK_MAKE_FILENAME = ' + strstr(status)
         RETURN, error_code
      ENDIF

   ;  Remove any wild card characters:
      files = FILE_SEARCH(filename, COUNT = count)
      IF (debug AND (count EQ 0)) THEN BEGIN
         error_code = 240
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': RCCM file for camera ' + cams[cam] + ' not found.'
         RETURN, error_code
      ENDIF
      IF (debug AND (count GT 1)) THEN BEGIN
         error_code = 250
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Multiple RCCM files found for camera ' + cams[cam] + '.'
         RETURN, error_code
      ENDIF
      rccm_files[cam] = files[0]

   ;  Return to the calling routine with an error message if this RCCM
   ;  file does not exist or is unreadable:
      rc = is_readable(rccm_files[cam], DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         0: BEGIN
               error_code = 300
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The RCCM file ' + in_file + $
                  ' exists but is unreadable.'
               RETURN, error_code
            END
         -1: BEGIN
               IF (debug) THEN BEGIN
                  error_code = 310
                  excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                     rout_name + ': ' + excpt_cond
                  RETURN, error_code
               ENDIF
            END
         -2: BEGIN
               error_code = 320
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input file ' + in_file + ' does not exist.'
               RETURN, error_code
            END
         ELSE: BREAK
      ENDCASE
   ENDFOR

   ;  Start the log file if it is required:
   IF (log_it) THEN BEGIN
      IF (KEYWORD_SET(log_folder)) THEN BEGIN
         log_path = log_folder
         log_path = force_path_sep(log_path, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         log_path = root_dirs[3] + mpob_str + '/RCCM' + PATH_SEP()
      ENDELSE

   ;  Return to the calling routine with an error message if the output
   ;  directory 'log_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(log_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         0: BEGIN
               error_code = 500
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The output folder ' + log_path + $
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
               FILE_MKDIR, log_path
            END
         ELSE: BREAK
      ENDCASE

      log_name = 'Log_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
         date + '.txt'
      log_spec = log_path + log_name

      fmt1 = '(A30, A)'
      fmt2 = '(12A14)'
      fmt3 = '(A14, 11I14)'

      OPENW, log_unit, log_spec, /GET_LUN
      PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_spec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_spec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit

      PRINTF, log_unit, 'Content: ', 'Log on the updating and upgrading', $
         FORMAT = fmt1
      PRINTF, log_unit, '', '   of the standard MISR RCCM product.', $
         FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', strstr(misr_path), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Orbit: ', strstr(misr_orbit), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Block: ', strstr(misr_block), FORMAT = fmt1
      PRINTF, log_unit
   ENDIF

   ;  Retrieve the original MISR RCCM data in the array 'rccm_0':
   rc = mk_rccm_0(rccm_files, misr_path, misr_orbit, misr_block, rccm_0, $
      n_miss_0, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      error_code = 330
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   IF (verbose) THEN PRINT, 'Done with mk_rccm_0.'

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm_0: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
            'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Fill (255B)', $
            'Total', FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_0[cam, *, *] EQ 0B, count_0)
         idx_1 = WHERE(rccm_0[cam, *, *] EQ 1B, count_1)
         idx_2 = WHERE(rccm_0[cam, *, *] EQ 2B, count_2)
         idx_3 = WHERE(rccm_0[cam, *, *] EQ 3B, count_3)
         idx_4 = WHERE(rccm_0[cam, *, *] EQ 4B, count_4)
         idx_255 = WHERE(rccm_0[cam, *, *] EQ 255B, count_255)
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_255, totcnt, FORMAT = fmt3
      ENDFOR
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_0 product if required:
   IF (KEYWORD_SET(map_it)) THEN BEGIN
      IF (KEYWORD_SET(map_folder)) THEN BEGIN
         map_path = map_folder
         map_path = force_path_sep(map_path, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         map_path = root_dirs[3] + mpob_str + '/RCCM' + PATH_SEP()
      ENDELSE

   ;  Return to the calling routine with an error message if the output
   ;  directory 'map_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(map_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         0: BEGIN
               error_code = 500
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The output folder ' + map_path + $
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
               FILE_MKDIR, map_path
            END
         ELSE: BREAK
      ENDCASE

      good_vals = [0B, 1B, 2B, 3B, 4B, 255B]
      good_vals_cols = ['red', 'white', 'gray', 'aqua', 'blue', 'red']
      FOR cam = 0, n_cams - 1 DO BEGIN
         map_name = 'Map_RCCM_rccm_0_' + mpob_str + '_' + cams[cam] + '_' + $
            acquis_date + '_' + date + '.png'
         map_spec = map_path + map_name
         map = lr2hr(REFORM(rccm_0[cam, *, *]))
         rc = make_bytemap(map, good_vals, good_vals_cols, map_spec, $
            DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Also save the legend for this map in the same folder:
         map_legend_name = 'Legend-Map_RCCM_rccm_0_' + mpob_str + '_' + $
            cams[cam] + '_' + acquis_date + '_' + date + '.txt'
         map_legend_spec = map_path + map_legend_name
         map_legend_txt = 'Map of the standard MISR Radiometric ' + $
            'Camera-by-camera Cloud Mask (RCCM) for ' + $
            'Path ' + strstr(misr_path) + $
            ', Orbit ' + strstr(misr_orbit) + $
            ', Block ' + strstr(misr_block) + $
            ' and Camera ' + cams[cam] + $
            '. All RCCM products are generated at the spatial resolution ' + $
            'of 1100 m and provided as arrays of 512 by 128 pixels. This ' + $
            'map has been enlarged (4x in each direction) by duplication ' + $
            'for viewing convenience and to facilitate comparisons with ' + $
            'other maps. Color coding: ' + $
            good_vals_cols[0] + ': no retrieval or fill value; ' + $
            good_vals_cols[1] + ': cloud with high confidence; ' + $
            good_vals_cols[2] + ': cloud with low confidence; ' + $
            good_vals_cols[3] + ': clear with low confidence; ' + $
            good_vals_cols[4] + ': clear with high confidence.'
         OPENW, legend_unit, map_legend_spec, /GET_LUN
         PRINTF, legend_unit, 'Legend for the map with the same filename:'
         PRINTF, legend_unit, map_legend_txt
         CLOSE, legend_unit
         FREE_LUN, legend_unit
      ENDFOR
   ENDIF

   ;  Set the path to the L1B2 files:
   IF (KEYWORD_SET(l1b2_folder)) THEN $
      l1b2_path = l1b2_folder ELSE $
      l1b2_path = root_dirs[1] + misr_path_str + PATH_SEP() + 'L1_GM' + $
         PATH_SEP()

   ;  Set the specifications of the L1B2 GRP GM files:
   l1b2_files = STRARR(n_cams)
   misr_product = 'GRP_TERRAIN_GM'
   IF (~KEYWORD_SET(l1b2_version)) THEN l1b2_version = versions[2]

   FOR cam = 0, n_cams - 1 DO BEGIN
      status = MTK_MAKE_FILENAME(l1b2_path, misr_product, cams[cam], $
         misr_path_s, misr_orbit_s, l1b2_version, filename)
      IF (debug AND (status NE 0)) THEN BEGIN
         error_code = 610
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Status from MTK_MAKE_FILENAME = ' + strstr(status)
         RETURN, error_code
      ENDIF

   ;  Remove any wild card characters:
      files = FILE_SEARCH(filename, COUNT = count)
      IF (debug AND (count EQ 0)) THEN BEGIN
         error_code = 400
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': L1B2 file for camera ' + cams[cam] + ' not found.'
         RETURN, return_code
      ENDIF
      IF (debug AND (count GT 1)) THEN BEGIN
         error_code = 410
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Multiple L1B2 files found for camera ' + cams[cam] + '.'
         RETURN, error_code
      ENDIF
      l1b2_files[cam] = files[0]

   ;  Return to the calling routine with an error message if this L1B2
   ;  file does not exist or is unreadable:
      rc = is_readable(l1b2_files[cam], DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         0: BEGIN
               error_code = 302
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input file ' + in_file + $
                  ' exists but is unreadable.'
               RETURN, error_code
            END
         -1: BEGIN
               IF (debug) THEN BEGIN
                  error_code = 312
                  excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                     rout_name + ': ' + excpt_cond
                  RETURN, error_code
               ENDIF
            END
         -2: BEGIN
               error_code = 322
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The input file ' + in_file + ' does not exist.'
               RETURN, error_code
            END
         ELSE: BREAK
      ENDCASE
   ENDFOR

   ;  Update the original MISR RCCM data to flag edge and obscured pixels:
   rc = mk_rccm_1(rccm_0, l1b2_files, misr_path, misr_orbit, misr_block, $
      rccm_1, n_miss_1, VERBOSE = verbose, DEBUG = debug, $
      EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      error_code = 310
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   IF (verbose) THEN PRINT, 'Done with mk_rccm_1.'

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm_1: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_1[cam, *, *] EQ 0B, count_0)
         idx_1 = WHERE(rccm_1[cam, *, *] EQ 1B, count_1)
         idx_2 = WHERE(rccm_1[cam, *, *] EQ 2B, count_2)
         idx_3 = WHERE(rccm_1[cam, *, *] EQ 3B, count_3)
         idx_4 = WHERE(rccm_1[cam, *, *] EQ 4B, count_4)
         idx_253 = WHERE(rccm_1[cam, *, *] EQ 253B, count_253)
         idx_254 = WHERE(rccm_1[cam, *, *] EQ 254B, count_254)
         idx_255 = WHERE(rccm_1[cam, *, *] EQ 255B, count_255)
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, FORMAT = fmt3
      ENDFOR
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_1 product if required:
   IF (KEYWORD_SET(map_it)) THEN BEGIN
      IF (KEYWORD_SET(map_folder)) THEN BEGIN
         map_path = map_folder
         map_path = force_path_sep(map_path, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         map_path = root_dirs[3] + mpob_str + '/RCCM' + PATH_SEP()
      ENDELSE
      good_vals = [0B, 1B, 2B, 3B, 4B, 253B, 254B, 255B]
      good_vals_cols = ['red', 'white', 'gray', 'aqua', 'blue', 'gold', $
         'black', 'red']
      FOR cam = 0, n_cams - 1 DO BEGIN
         map_name = 'Map_RCCM_rccm_1_' + mpob_str + '_' + cams[cam] + '_' + $
            acquis_date + '_' + date + '.png'
         map_spec = map_path + map_name
         map = lr2hr(REFORM(rccm_1[cam, *, *]))
         rc = make_bytemap(map, good_vals, good_vals_cols, map_spec, $
            DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Also save the legend for this map in the same folder:
         map_legend_name = 'Legend-Map_RCCM_rccm_1_' + mpob_str + '_' + $
            cams[cam] + '_' + acquis_date + '_' + date + '.txt'
         map_legend_spec = map_path + map_legend_name
         map_legend_txt = 'Map of the updated MISR Radiometric ' + $
            'Camera-by-camera Cloud Mask (RCCM) for ' + $
            'Path ' + strstr(misr_path) + $
            ', Orbit ' + strstr(misr_orbit) + $
            ', Block ' + strstr(misr_block) + $
            ' and Camera ' + cams[cam] + $
            ', where edge and obscured pixels have been flagged with ' + $
            'specific values to distinguish them from missing values. ' + $
            'All RCCM products are generated at the spatial resolution ' + $
            'of 1100 m and provided as arrays of 512 by 128 pixels. This ' + $
            'map has been enlarged (4x in each direction) by duplication ' + $
            'for viewing convenience and to facilitate comparisons with ' + $
            'other maps. Color coding: ' + $
            good_vals_cols[0] + ': missing or fill value; ' + $
            good_vals_cols[1] + ': cloud with high confidence; ' + $
            good_vals_cols[2] + ': cloud with low confidence; ' + $
            good_vals_cols[3] + ': clear with low confidence; ' + $
            good_vals_cols[4] + ': clear with high confidence; ' + $
            good_vals_cols[5] + ': pixels obscured by topography; and ' + $
            good_vals_cols[6] + ': pixels in the edges of the instrument swath.'
         OPENW, legend_unit, map_legend_spec, /GET_LUN
         PRINTF, legend_unit, 'Legend for the map with the same filename:'
         PRINTF, legend_unit, map_legend_txt
         CLOSE, legend_unit
         FREE_LUN, legend_unit
      ENDFOR
   ENDIF

   ;  Call 'mk_rccm_2' if there are missing values in 'rccm_1':
   IF (MAX(n_miss_1) GT 0) THEN BEGIN
      rc = mk_rccm_2(rccm_1, misr_path, misr_orbit, misr_block, rccm_2, $
         n_miss_2, VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (rc NE 0) THEN BEGIN
         error_code = 320
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE BEGIN
      rccm = rccm_1
   ENDELSE
   IF (verbose) THEN PRINT, 'Done with mk_rccm_2.'

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm_2: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_2[cam, *, *] EQ 0B, count_0)
         idx_1 = WHERE(rccm_2[cam, *, *] EQ 1B, count_1)
         idx_2 = WHERE(rccm_2[cam, *, *] EQ 2B, count_2)
         idx_3 = WHERE(rccm_2[cam, *, *] EQ 3B, count_3)
         idx_4 = WHERE(rccm_2[cam, *, *] EQ 4B, count_4)
         idx_253 = WHERE(rccm_2[cam, *, *] EQ 253B, count_253)
         idx_254 = WHERE(rccm_2[cam, *, *] EQ 254B, count_254)
         idx_255 = WHERE(rccm_2[cam, *, *] EQ 255B, count_255)
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, FORMAT = fmt3
      ENDFOR
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_2 product if required:
   IF (KEYWORD_SET(map_it)) THEN BEGIN
      IF (KEYWORD_SET(map_folder)) THEN BEGIN
         map_path = map_folder
         map_path = force_path_sep(map_path, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         map_path = root_dirs[3] + mpob_str + '/RCCM' + PATH_SEP()
      ENDELSE
      good_vals = [0B, 1B, 2B, 3B, 4B, 253B, 254B, 255B]
      good_vals_cols = ['red', 'white', 'gray', 'aqua', 'blue', 'gold', $
         'black', 'red']
      FOR cam = 0, n_cams - 1 DO BEGIN
         map_name = 'Map_RCCM_rccm_2_' + mpob_str + '_' + cams[cam] + '_' + $
            acquis_date + '_' + date + '.png'
         map_spec = map_path + map_name
         map = lr2hr(REFORM(rccm_2[cam, *, *]))
         rc = make_bytemap(map, good_vals, good_vals_cols, map_spec, $
            DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Also save the legend for this map in the same folder:
         map_legend_name = 'Legend-Map_RCCM_rccm_2_' + mpob_str + '_' + $
            cams[cam] + '_' + acquis_date + '_' + date + '.txt'
         map_legend_spec = map_path + map_legend_name
         map_legend_txt = 'Map of the upgraded MISR Radiometric ' + $
            'Camera-by-camera Cloud Mask (RCCM) for ' + $
            'Path ' + strstr(misr_path) + $
            ', Orbit ' + strstr(misr_orbit) + $
            ', Block ' + strstr(misr_block) + $
            ' and Camera ' + cams[cam] + $
            ', where many missing pixels have been replaced by estimates ' + $
            'of the cloud or clear status of the observed areas, based ' + $
            'on the cloudiness level of neighboring pixels within a 3x3 ' + $
            'subwindow. All RCCM products are generated at the spatial ' + $
            'resolution of 1100 m and provided as arrays of 512 by 128 ' + $
            'pixels. This map has been enlarged (4x in each direction) ' + $
            'by duplication for viewing convenience and to facilitate ' + $
            'comparisons with other maps. Color coding: ' + $
            good_vals_cols[0] + ': missing or fill value; ' + $
            good_vals_cols[1] + ': cloud with high confidence; ' + $
            good_vals_cols[2] + ': cloud with low confidence; ' + $
            good_vals_cols[3] + ': clear with low confidence; ' + $
            good_vals_cols[4] + ': clear with high confidence; ' + $
            good_vals_cols[5] + ': pixels obscured by topography; and ' + $
            good_vals_cols[6] + ': pixels in the edges of the instrument swath.'
         OPENW, legend_unit, map_legend_spec, /GET_LUN
         PRINTF, legend_unit, 'Legend for the map with the same filename:'
         PRINTF, legend_unit, map_legend_txt
         CLOSE, legend_unit
         FREE_LUN, legend_unit
      ENDFOR
   ENDIF ELSE BEGIN
      rccm = rccm_2
   ENDELSE

   IF (log_it) THEN BEGIN
      IF (verbose) THEN PRINT, 'Saved ' + log_spec
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   RETURN, return_code

END
