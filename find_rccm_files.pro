FUNCTION find_rccm_files, $
   misr_path, $
   misr_orbit, $
   rccm_files, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function provides the file specifications (path +
   ;  names) of the 9 MISR L1 Radiometric Camera-by-camera Cloud Mask
   ;  (RCCM) files corresponding to the given misr_path and misr_orbit, if
   ;  they are available in the expected folder.
   ;
   ;  ALGORITHM: This function reports the file specifications (path +
   ;  names) of the 9 MISR L1 RCCM files for the specified MISR PATH and
   ;  ORBIT in the expected folder and verifies that they are readable.
   ;
   ;  SYNTAX: rc = find_rccm_files(misr_path, misr_orbit, rccm_files, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INT} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_orbit {LONG} [I]: The selected MISR ORBIT number.
   ;
   ;  *   rccm_files {STRING array} [O]: The file specifications (path and
   ;      filenames) of the 9 MISR L1 RCCM files for the specified
   ;      misr_path and misr_orbit.
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
   ;      a null string, if the optional input keyword parameter DEBUG was
   ;      set and if the optional output keyword parameter EXCPT_COND was
   ;      provided in the call. The output positional parameter rccm_files
   ;      contains the specifications of the 9 MISR RCCM files for the
   ;      specified PATH and ORBIT.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG was
   ;      set and if the optional output keyword parameter EXCPT_COND was
   ;      provided. The output positional parameter rccm_files may be
   ;      inexistent, incomplete or incorrect.
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
   ;  *   Error 199: An exception condition occurred in
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: An exception condition occurred in function
   ;      path2str.pro.
   ;
   ;  *   Error 210: An exception condition occurred in function
   ;      orbit2str.pro.
   ;
   ;  *   Error 300: The input folder rccm_path exists but is unreadable.
   ;
   ;  *   Error 310: An exception condition occurred in function
   ;      is_readable.pro.
   ;
   ;  *   Error 320: The input folder rccm_path does not exist.
   ;
   ;  *   Error 400: The input folder rccm_path does not contain any L1
   ;      RCCM files for selected MISR PATH and ORBIT.
   ;
   ;  *   Error 410: The input folder rccm_path contains fewer than 9 L1
   ;      RCCM files for selected MISR PATH and ORBIT.
   ;
   ;  *   Error 420: The input folder rccm_path contains more than 9 L1
   ;      RCCM files for selected MISR PATH and ORBIT.
   ;
   ;  *   Error 430: At least one of the MISR L1 RCCM files in the input
   ;      folder rccm_path is not readable.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   chk_misr_orbit.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   is_frompath.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_readable.pro
   ;
   ;  *   orbit2str.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_roots_vers.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: This function assumes that the folder rccm_path, defined
   ;      either by default or by the input keyword parameter l1b2_folder,
   ;      contains full ORBITs, i.e., that files contain data for all
   ;      BLOCKs. Exception condition 420 may be triggered by the presence
   ;      of multiple subsetted files for the same MISR PATH and ORBIT.
   ;
   ;  *   NOTE 2: The RCCM file specifications are provided in the native
   ;      MISR camera order, i.e., from DF to DA.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> misr_orbit = 68050
   ;      IDL> rccm_folder = ''
   ;      IDL> rccm_version = ''
   ;      IDL> debug = 1
   ;      IDL> rc = find_rccm_files(misr_path, misr_orbit, $
   ;         rccm_files, RCCM_FOLDER = rccm_folder, $
   ;         RCCM_VERSION = rccm_version, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, rccm_files
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_DF_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_CF_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_BF_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_AF_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_AN_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_AA_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_BA_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_CA_F04_0025.hdf
   ;      /Volumes/.../MISR_AM1_GRP_RCCM_GM_P168_O068050_DA_F04_0025.hdf
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2018–12–30: Version 1.0 — Initial public release.
   ;
   ;  *   2019–01–30: Version 1.1 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–02: Version 1.2 — Delete unused variable pob_str.
   ;
   ;  *   2019–02–05: Version 1.3 — Reorganize the MISR RCCM functions.
   ;
   ;  *   2019–02–18: Version 2.00 — Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
   ;
   ;  *   2019–02–24: Version 2.01 — Documentation update.
   ;
   ;  *   2019–03–28: Version 2.10 — Sort the RCCM files in the native
   ;      MISR order on output; update the handling of the optional input
   ;      keyword parameter VERBOSE and generate the software version
   ;      consistent with the published documentation.
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
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Initialize the output positional parameter(s):
   rccm_files = ['']

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 3
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameters: misr_path, misr_orbit, rccm_files.'
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
   ENDIF

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   misr_cams = misr_specs.CameraNames

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

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Generate the long string version of the MISR Orbit number:
   rc = orbit2str(misr_orbit, misr_orbit_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF ((debug) AND (rc NE 0)) THEN BEGIN
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the directory address of the folder containing RCCM files:
   IF (KEYWORD_SET(rccm_folder)) THEN BEGIN
      rccm_path = force_path_sep(rccm_folder, DEBUG = debug, $
         EXCPT_COND = excpt_cond)
   ENDIF ELSE BEGIN
      rccm_path = root_dirs[1] + misr_path_str + PATH_SEP() + $
         'L1_RC' + PATH_SEP()
   ENDELSE

   ;  Return to the calling routine with an error message if the input
   ;  directory 'rccm_path' does not exist or is unreadable:
   rc = is_readable(rccm_path, DEBUG = debug, EXCPT_COND = excpt_cond)
   CASE rc OF
      0: BEGIN
            error_code = 300
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The input folder ' + rccm_path + $
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
               rout_name + ': The input folder ' + rccm_path + $
               ' does not exist.'
            RETURN, error_code
         END
      ELSE: BREAK
   ENDCASE

   ;  Search for the 9 L1 RCCM files implied by the given MISR Path and
   ;  Orbit input parameters:
   rccm_prefix = 'MISR_AM1_GRP_RCCM_GM_'
   rccm_fname = rccm_prefix + misr_path_str + '_' + $
      misr_orbit_str + '_*_' + rccm_version + '.hdf'
   rccm_files = FILE_SEARCH(rccm_path, rccm_fname, COUNT = num_files)

   IF (debug) THEN BEGIN

   ;  Manage exception conditions:
      IF (num_files EQ 0) THEN BEGIN
         error_code = 400
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Directory ' + rccm_path + $
            ' does not contain any RCCM files for MISR Path ' + $
            misr_path_str + ' and Orbit ' + misr_orbit_str + '.'
         RETURN, error_code
      ENDIF

      IF (num_files LT 9) THEN BEGIN
         error_code = 410
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Directory ' + rccm_path + ' contains fewer than 9 RCCM ' + $
            'files for MISR Path ' + misr_path_str + ' and Orbit ' + $
            misr_orbit_str + '.'
         RETURN, error_code
      ENDIF
      IF (num_files GT 9) THEN BEGIN
         error_code = 420
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Directory ' + rccm_path + 'contains more than 9 RCCM ' + $
            'files for MISR Path ' + misr_path_str + ' and Orbit ' + $
            misr_orbit_str + '.'
         RETURN, error_code
      ENDIF

   ;  Check that each of these files is readable:
      FOR i = 0, num_files - 1 DO BEGIN
         IF (is_readable(rccm_files[i], DEBUG = debug, $
            EXCPT_COND = excpt_cond) NE 1) THEN BEGIN
            error_code = 430
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
               ': RCCM file ' + rccm_files[i] + ' is unreadable.'
            RETURN, error_code
         ENDIF
      ENDFOR
   ENDIF

   ;  Sort those files in the native MISR order:
   temp = STRARR(9)
   FOR cam = 0, n_cams - 1 DO BEGIN
      pattern = '_' + misr_cams[cam] + '_'
      idx = WHERE(STRPOS(rccm_files, pattern) GT 0, count)
      temp[cam] = rccm_files[idx[0]]
   ENDFOR
   rccm_files = temp

   IF (verbose GT 1) THEN BEGIN
      FOR cam = 0, n_cams - 1 DO PRINT, 'rccm_files[' + strstr(cam) + $
         '] = ' + rccm_files[cam]
   ENDIF
   IF (verbose GT 0) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
