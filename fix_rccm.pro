FUNCTION fix_rccm, $
   misr_ptr, $
   radrd_ptr, $
   rccm, $
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
   ;  ALGORITHM: This function replaces missing values in the MISR L1B2
   ;  Radiometric Camera-by-camera Cloud Mask (RCCM) data product by
   ;  reasonable estimates. Metadata on the MISR PATH, ORBIT and BLOCK to
   ;  process, and L1B2 Georectified Radiance Product (GRP) data are
   ;  obtained through pointers to the heap variables misr_ptr and
   ;  radrd_ptr, respectively. The RCCM products are read from the input
   ;  positional parameter rccm_files. For each of the 9 cameras, this
   ;  replacement process is executed in 4 steps:
   ;
   ;  *   Function mk_rccm0.pro reads the standard RCCM data from files,
   ;
   ;  *   Function mk_rccm1.pro flags unobservable (obscured and edge)
   ;      pixels by importing that information from the associated
   ;      Radiance product,
   ;
   ;  *   Function mk_rccm2.pro replaces missing values by cloudiness
   ;      estimates derived from the 2 closest neighboring cameras
   ;      wherever they record identical conditions, and
   ;
   ;  *   Function mk_rccm3.pro replaces any remaining missing values on
   ;      the basis of cloudiness conditions in their immediate
   ;      neighborhood.
   ;
   ;  SYNTAX: rc = fix_rccm(misr_ptr, radrd_ptr, rccm_files, rccm, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;  SAVE_IT = save_it, SAVE_FOLDER = save_folder, $
   ;  MAP_IT = map_it, MAP_FOLDER = map_folder, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_ptr {POINTER} [I]: The pointer to a STRING array containing
   ;      metadata on the MISR MODE, PATH, ORBIT and BLOCK to be
   ;      processed.
   ;
   ;  *   radrd_ptr {POINTER array} [I]: The array of 36 (9 cameras by 4
   ;      spectral bands) pointers to the data buffers containing the UINT
   ;      L1B2 Georectified Radiance Product (GRP) scaled radiance values
   ;      (with the RDQI attached), in the native order (DF to DA and Blue
   ;      to NIR).
   ;
   ;  *   rccm {BYTE array} [O]: The cleaned RCCM product.
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
   ;  *   MAP_IT = map_it {INT} [I] (Default value: 0): Flag to activate
   ;      (1) or skip (0) generating maps of the numerical results.
   ;
   ;  *   MAP_FOLDER = map_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the output folder
   ;      containing the maps.
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
   ;      provided. The output positional parameter rccm may be undefined,
   ;      incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Warning 98: The current computer is unrecognized.
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_ptr is not a
   ;      pointer.
   ;
   ;  *   Error 120: The input positional parameter radrd_ptr is not a
   ;      pointer array.
   ;
   ;  *   Error 199: An exception condition occurred in the function
   ;      set_roots_vers.pro.
   ;
   ;  *   Error 200: Access to MISR L1B2 Radiance data must be provided in
   ;      Global Mode.
   ;
   ;  *   Error 210: An exception condition occurred in the function
   ;      path2str.pro.
   ;
   ;  *   Error 220: An exception condition occurred in the function
   ;      orbit2str.pro.
   ;
   ;  *   Error 230: An exception condition occurred in the function
   ;      orbit2date.pro.
   ;
   ;  *   Error 299: The computer is not recognized and at least one of
   ;      the optional input keyword parameters rccm_folder, log_folder,
   ;      save_folder, map_folder is not specified.
   ;
   ;  *   Error 300: An exception condition occurred in the function
   ;      find_rccm_files.pro.
   ;
   ;  *   Error 400: An exception condition occurred in the function
   ;      mk_rccm_0.pro.
   ;
   ;  *   Error 410: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_0.
   ;
   ;  *   Error 420: An exception condition occurred in the function
   ;      mk_rccm_1.pro.
   ;
   ;  *   Error 430: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_1.
   ;
   ;  *   Error 440: An exception condition occurred in the function
   ;      mk_rccm_2.pro.
   ;
   ;  *   Error 450: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_2.
   ;
   ;  *   Error 460: An exception condition occurred in the function
   ;      mk_rccm_3.pro.
   ;
   ;  *   Error 470: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_3.
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
   ;  *   Error 540: The output folder map_path is unwritable.
   ;
   ;  *   Error 550: An exception condition occurred in the function
   ;      is_writable.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   get_host_info.pro
   ;
   ;  *   is_array.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_pointer.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   make_bytemap.pro
   ;
   ;  *   mk_rccm0.pro
   ;
   ;  *   mk_rccm1.pro
   ;
   ;  *   mk_rccm2.pro
   ;
   ;  *   mk_rccm3.pro
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
   ;  *   str2block.pro
   ;
   ;  *   str2orbit.pro
   ;
   ;  *   str2path.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: If maps are requested by setting the input keyword
   ;      parameter map_it, map legends are also saved as text files with
   ;      matching names to describe the contents of these maps.
   ;
   ;  *   NOTE 2: The MISR RCCM product is only available at the reduced
   ;      spatial resolution of 128 line by 512 samples per BLOCK, for all
   ;      9 cameras.
   ;
   ;  *   NOTE 3: The MISR RCCM product is provided on a per-camera basis,
   ;      and the cloud mask for a given camera applies to all 4 spectral
   ;      bands of that camera.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_mode = 'GM'
   ;      IDL> misr_path = 168
   ;      IDL> misr_orbit = 68050
   ;      IDL> verbose = 0
   ;      IDL> debug = 1
   ;      IDL> rc = find_l1b2_files(misr_mode, misr_path, $
   ;         misr_orbit, l1b2_files, $
   ;         L1B2_FOLDER = l1b2_folder, L1B2_VERSION = l1b2_version, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> misr_block = 110
   ;      IDL> rc = heap_l1b2_block(l1b2_files, misr_block, $
   ;         misr_ptr, radrd_ptr, brf_ptr, rdqi_ptr, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> log_it = 1
   ;      IDL> save_it = 1
   ;      IDL> map_it = 1
   ;      IDL> rc = fix_rccm(misr_ptr, radrd_ptr, rccm, $
   ;         RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;         LOG_IT = log_it, LOG_FOLDER = log_folder, $
   ;         SAVE_IT = save_it, SAVE_FOLDER = save_folder, $
   ;         MAP_IT = map_it, MAP_FOLDER = map_folder, $
   ;         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
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
   ;  *   2019–02–18: Version 2.00 —– Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
   ;
   ;  *   2019–02–24: Version 2.01 –— Documentation update.
   ;
   ;  *   2019–02–27: Version 2.02 — Implement an improved algorithm,
   ;      capable of effectively dealing with cases where most values are
   ;      missing within a BLOCK, as long as values are not missing in
   ;      neighboring cameras, take advantage of the new functions
   ;      find_rccm_files.pro and map_rccm_block.pro, and update the
   ;      documentation.
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
   IF (KEYWORD_SET(map_it)) THEN map_it = 1 ELSE map_it = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Initialize the output positional parameter(s):
   rccm = BYTARR(9, 512, 128)

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 3
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_ptr, radrd_ptr, rccm.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'misr_ptr' is not a pointer:
      IF (is_pointer(misr_ptr) NE 1) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The input positional parameter misr_ptr is not a pointer.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'radrd_ptr' is not a pointer array:
      IF ((is_pointer(radrd_ptr) NE 1) OR (is_array(radrd_ptr) NE 1)) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The input positional parameter radrd_ptr is not a ' + $
            'pointer array.'
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
   IF (~KEYWORD_SET(rccm_version)) THEN rccm_version = versions[5]

   ;  Get today's date:
   date = today(FMT = 'ymd')

   ;  Get today's date and time:
   date_time = today(FMT = 'nice')

   ;  Retrieve the MISR Mode, Path, Orbit, Block and Version identifiers:
   temp = *misr_ptr
   misr_mode = temp[0]
   misr_path_str = temp[1]
   misr_orbit_str = temp[2]
   misr_block_str = temp[3]
   misr_version = temp[4]

   ;  Return to the calling routine with an error message if 'misr_mode' is
   ;  not 'GM', as all RCCM products are only available at the reduced
   ;  spatial resolution:
   IF (debug AND (misr_mode NE 'GM')) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Access to MISR L1B2 Radiance data must be provided in Global Mode.'
      RETURN, error_code
   ENDIF

   mpob_str = misr_mode + '-' + misr_path_str + '-' + $
      misr_orbit_str + '-' + misr_block_str

   ;  Generate the MISR Path and Orbit numbers:
   rc = str2path(misr_path_str, misr_path, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   rc = str2orbit(misr_orbit_str, misr_orbit, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   rc = str2block(misr_block_str, misr_block, $
      DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Generate the short string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_s, /NOHEADER, $
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
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

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
      IF (~KEYWORD_SET(rccm_folder) OR $
         (log_it AND (~KEYWORD_SET(log_folder))) OR $
         (save_it AND (~KEYWORD_SET(save_folder))) OR $
         (map_it AND (~KEYWORD_SET(map_folder)))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond + ' And at least one of the optional ' + $
            'input keyword parameters log_folder, save_folder ' + $
            'or map_folder is not set.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Retrieve the specifications (path + filename) of the 9 RCCM files, in
   ;  the native order: DF, CF, ..., AN, ..., CA, DA:
   rc = find_rccm_files(misr_path, misr_orbit, rccm_files, $
      RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 300
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

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

   ;  === Step 0: Get the original data =======================================
   ;  Retrieve the original MISR RCCM data and store it in the array 'rccm_0':
   rc = mk_rccm0(rccm_files, misr_block, rccm_0, n_miss_0, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm0: ', '', FORMAT = fmt1
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

   ;  Set the expected RCCM values and the colors in which they should be
   ;  mapped:
   good_vals = [0B, 1B, 2B, 3B, 4B, 253B, 254B, 255B]
   good_vals_cols = ['red', 'white', 'gray', 'aqua', 'blue', 'gold', $
      'black', 'red']

   ;  Map the rccm_0 product if required:
   IF (map_it) THEN BEGIN
      rccm_logo = 'rccm0'
      rccm_lgnd = ''
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_0, rccm_logo, rccm_lgnd, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 410
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  === Step 1: Flag the obscured and edge pixels ===========================
   ;  Update the original MISR RCCM data to flag edge and obscured pixels:
   rc = mk_rccm1(rccm_0, misr_ptr, radrd_ptr, rccm_1, n_miss_1, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 420
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm1: ', '', FORMAT = fmt1
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
   IF (map_it) THEN BEGIN
      rccm_logo = 'rccm1'
      rccm_lgnd = ' Obscured and edge have been flagged with ' + $
      'specific values to distinguish them from missing values. '
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_1, rccm_logo, rccm_lgnd, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 430
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Return to the calling routine if there are no missing values:
   IF (TOTAL(n_miss_1) EQ 0) THEN BEGIN
      rccm = rccm_1
      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'End of processing: rccm1 does not contain ' + $
            'any missing values.'
         CLOSE, log_unit
         FREE_LUN, log_unit
      ENDIF
   ENDIF

   ;  === Step 2: Replace missing values based on neighboring cameras =========
   ;  Call 'mk_rccm2' if there are missing values in 'rccm_1':
   IF (MAX(n_miss_1) GT 0) THEN BEGIN
      rc = mk_rccm2(rccm_1, n_miss_1, rccm_2, n_miss_2, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 440
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE BEGIN
      rccm = rccm_1
   ENDELSE

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm2: ', '', FORMAT = fmt1
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
   IF (map_it) THEN BEGIN
      rccm_logo = 'rccm2'
      rccm_lgnd = ' Missing pixels have been replaced by estimates ' + $
      'of the cloud or clear status of the observed areas, based ' + $
      'on the cloudiness level of the 2 neighboring cameras, wherever ' + $
      'they report identical values.'
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_2, rccm_logo, rccm_lgnd, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 450
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Return to the calling routine if there are no missing values:
   IF (TOTAL(n_miss_2) EQ 0) THEN BEGIN
      rccm = rccm_2
      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'End of processing: rccm2 does not contain ' + $
            'any missing values.'
         CLOSE, log_unit
         FREE_LUN, log_unit
      ENDIF
   ENDIF

   ;  === Step 3: Replace missing values based on neighboring pixels ==========
   ;  Call 'mk_rccm3' if there are missing values in 'rccm_2':
   IF (MAX(n_miss_2) GT 0) THEN BEGIN
      rc = mk_rccm3(rccm_2, rccm_3, n_miss_3, VERBOSE = verbose, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 460
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
      rccm = rccm_3
   ENDIF ELSE BEGIN
      rccm = rccm_2
   ENDELSE

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Outcome of mk_rccm3: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_3[cam, *, *] EQ 0B, count_0)
         idx_1 = WHERE(rccm_3[cam, *, *] EQ 1B, count_1)
         idx_2 = WHERE(rccm_3[cam, *, *] EQ 2B, count_2)
         idx_3 = WHERE(rccm_3[cam, *, *] EQ 3B, count_3)
         idx_4 = WHERE(rccm_3[cam, *, *] EQ 4B, count_4)
         idx_253 = WHERE(rccm_3[cam, *, *] EQ 253B, count_253)
         idx_254 = WHERE(rccm_3[cam, *, *] EQ 254B, count_254)
         idx_255 = WHERE(rccm_3[cam, *, *] EQ 255B, count_255)
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, FORMAT = fmt3
      ENDFOR
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_3 product if required:
   IF (map_it) THEN BEGIN
      rccm_logo = 'rccm3'
      rccm_lgnd = ' Missing pixels have been replaced by estimates ' + $
      'of the cloud or clear status of the observed areas, based ' + $
      'on the cloudiness level of neighboring pixels within small ' + $
      'sub-windows of the target camera.'
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_3, rccm_logo, rccm_lgnd, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 470
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Save the final result in an IDL SAVE file if requested:
   IF (save_it) THEN BEGIN

      IF (KEYWORD_SET(save_folder)) THEN BEGIN
         save_path = save_folder
         save_path = force_path_sep(save_path, DEBUG = debug, $
            EXCPT_COND = excpt_cond)
      ENDIF ELSE BEGIN
         save_path = root_dirs[3] + mpob_str + '/RCCM' + PATH_SEP()
      ENDELSE

   ;  Return to the calling routine with an error message if the output
   ;  directory 'save_path' is not writable, and create it if it does not
   ;  exist:
      rc = is_writable(save_path, DEBUG = debug, EXCPT_COND = excpt_cond)
      CASE rc OF
         0: BEGIN
               error_code = 540
               excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                  rout_name + ': The output folder ' + save_path + $
                  ' is unwritable.'
               RETURN, error_code
            END
         -1: BEGIN
               IF (debug) THEN BEGIN
                  error_code = 550
                  excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
                     rout_name + ': ' + excpt_cond
                  RETURN, error_code
               ENDIF
            END
         -2: BEGIN
               FILE_MKDIR, save_path
            END
         ELSE: BREAK
      ENDCASE

      save_fname = 'Save_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
         date + '.sav'
      save_fspec = save_path + save_fname
      SAVE, rccm, FILENAME = save_fspec

      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'Final RCCM data saved in'
         PRINTF, log_unit, save_fspec
      ENDIF
   ENDIF

   IF (log_it) THEN BEGIN
      PRINTF, log_unit, 'Saved ' + log_spec
      PRINTF, log_unit, 'Saved ' + save_fspec
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   IF (log_it AND (verbose GT 1)) THEN PRINT, 'Saved ' + log_spec
   IF (save_it AND (verbose GT 1)) THEN PRINT, 'Saved ' + save_fspec

   IF (verbose GT 0) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
