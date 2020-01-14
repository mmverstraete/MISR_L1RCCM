FUNCTION fix_rccm, $
   misr_ptr, $
   radrd_ptr, $
   rccm, $
   RCCM_FOLDER = rccm_folder, $
   RCCM_VERSION = rccm_version, $
   EDGE = edge, $
   TEST_ID = test_id, $
   FIRST_LINE = first_line, $
   LAST_LINE = last_line, $
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
   ;  flagged and missing values replaced by reasonable estimates. It also
   ;  optionally permits to document the performance of the process.
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
   ;  This function also allows the user to artificially introduce missing
   ;  data for the purpose of documenting the performance of the
   ;  replacement process.
   ;
   ;  SYNTAX: rc = fix_rccm(misr_ptr, radrd_ptr, rccm_files, rccm, $
   ;  RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
   ;  EDGE = edge, TEST_ID = test_id, $
   ;  FIRST_LINE = first_line, LAST_LINE = last_line, $
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
   ;  *   EDGE = edge {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) copying the cloud mask of the neighboring camera
   ;      with the wider swath outside of the region where it overlaps
   ;      with the cloud mask of the neighboring camera with the narrower
   ;      swath.
   ;
   ;  *   TEST_ID = test_id {STRING} [I] (Default value: ”): Flag to
   ;      activate (non-empty STRING) or skip (empty STRING) artificially
   ;      introducing missing data in the RCCM data buffer; if set, this
   ;      keyword is used in output file names to label experiments.
   ;
   ;  *   FIRST_LINE = first_line {INT array of 9 elements} [I] (Default value: 9 elements set to -1):
   ;      The index (between 0 and 127) of the first line to be replaced
   ;      by missing data, in each of the 9 cameras. Values outside that
   ;      range are ignored.
   ;
   ;  *   LAST_LINE = last_line {INT array of 9 elements} [I] (Default value: 9 elements set to -1):
   ;      The index (between 0 and 127) of the last line to be replaced by
   ;      missing data, in each of the 9 cameras. Values outside that
   ;      range are ignored.
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
   ;      If the optional input keyword parameter TEST_ID is set to a
   ;      non-empty string, missing data are artificially introduced in
   ;      the RCCM data between line first_line and last_line (inclusive),
   ;      and a confusion matrix is assembled to document how the
   ;      reconstructed values compare with the original data. The string
   ;      test_id is used to label the results, as well as the output
   ;      paths and file names.
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
   ;  *   Error 130: The optional keyword parameter test_id is not of type
   ;      STRING.
   ;
   ;  *   Error 140: The optional input keyword parameter test_id is set
   ;      but the keyword parameter first_line is not set or invalid.
   ;
   ;  *   Error 150: The optional input keyword parameter test_id is set
   ;      but the keyword parameter last_line is not set or invalid.
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
   ;  *   Error 400: The output folder log_path is unwritable.
   ;
   ;  *   Error 410: The output folder save_path is unwritable.
   ;
   ;  *   Error 500: An exception condition occurred in the function
   ;      mk_rccm_0.pro.
   ;
   ;  *   Error 510: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map the original rccm_0
   ;      data.
   ;
   ;  *   Error 512: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map the artificially
   ;      modified rccm_0 data.
   ;
   ;  *   Error 520: An exception condition occurred in the function
   ;      mk_rccm_1.pro.
   ;
   ;  *   Error 530: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_1.
   ;
   ;  *   Error 540: An exception condition occurred in the function
   ;      mk_rccm_2.pro.
   ;
   ;  *   Error 550: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_2.
   ;
   ;  *   Error 560: An exception condition occurred in the function
   ;      mk_rccm_3.pro.
   ;
   ;  *   Error 570: An exception condition occurred in the function
   ;      map_rccm_block.pro while attempting to map rccm_3.
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
   ;  *   is_writable_dir.pro
   ;
   ;  *   make_bytemap.pro
   ;
   ;  *   map_rccm_block.pro
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
   ;  *   strcat.pro
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
   ;      IDL> rc = find_l1b2gm_files(misr_path, misr_orbit, l1b2gm_files, $
   ;         L1B2GM_FOLDER = l1b2gm_folder, L1B2GM_VERSION = l1b2gm_version, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> misr_block = 110
   ;      IDL> rc = heap_l1b2_block(l1b2gm_files, misr_block, $
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
   ;  *   Mike Bull, Jason Matthews, Duncan McDonald, Alexander Menzies,
   ;      Catherine Moroney, Kevin Mueller, Susan Paradise, Mike
   ;      Smyth (2011) _MISR Data Products Specifications_, JPL D-13963,
   ;      REVISION S, Jet Propulsion Laboratory, California Institute of
   ;      Technology, Pasadena, CA, USA.
   ;
   ;  *   Diner, D. J., Di Girolamo, L. and Clothiaux, E. E. (1999) _Level
   ;      1 Cloud Detection Algorithm Theoretical Basis_, Technical Report
   ;      JPL D-13397, REVISION B, Jet Propulsion Laboratory, California
   ;      Institute of Technology, Pasadena, CA, USA.
   ;
   ;  *   Michel Verstraete, Linda Hunt, Hugo De Lemos and Larry Di
   ;      Girolamo (2019) _Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product_,
   ;      Earth System Science Data Discussions, Vol. 2019, p. 1–18,
   ;      available from
   ;      https://www.earth-syst-sci-data-discuss.net/essd-2019-77/ (DOI:
   ;      10.5194/essd-2019-77).
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
   ;
   ;  *   2019–04–08: Version 2.11 — Bug fix: Add IF statement on
   ;      line 943.
   ;
   ;  *   2019–05–07: Version 2.15 — Software version described in the
   ;      preprint published in ESSD Discussions mentioned above.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the use of
   ;      verbose and the assignment of numeric return codes), and switch
   ;      to 3-parts version identifiers.
   ;
   ;  *   2019–09–10: Version 2.1.1 — Add arguments and code to
   ;      artificially insert missing data in the RCCM data buffer, and
   ;      build a confusion matrix to document the performance of the
   ;      replacement algorithm.
   ;
   ;  *   2019–09–24: Version 2.1.2 — Update the code (1) to map the
   ;      original RCCM data before artificially inserting additional
   ;      missing data, (2) to record the confusion matrices after
   ;      mk_rccm2 and mk_rccm3 in the log file, and (3) to modify the
   ;      default map output directory.
   ;
   ;  *   2020–01–10: Version 2.1.3 — Add version information and
   ;      percentage of cloudiness statistics in the log file; fix bug in
   ;      the computation of totcnt for rccm2; update the name of maps for
   ;      tests involving artifically missing data; add the optional
   ;      keyword parameter EDGE to match the latest version of mk_rccm2
   ;      and update the directory name for the corresponding outputs to
   ;      reflect its eventual use; and update the documentation.
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
   IF (~KEYWORD_SET(edge)) THEN edge = 0 ELSE edge = 1
   IF (~KEYWORD_SET(test_id)) THEN BEGIN
      test_id = ''
      IF (test_id EQ '') THEN BEGIN
         first_line = MAKE_ARRAY(9, 4, /INTEGER, VALUE = -1)
         last_line = MAKE_ARRAY(9, 4, /INTEGER, VALUE = -1)
      ENDIF
   ENDIF
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

   ;  Return to the calling routine with an error message if the optional input
   ;  keyword parameter 'test_id' is set but not as a STRING:
      IF (KEYWORD_SET(test_id) AND (is_string(test_id) NE 1)) THEN BEGIN
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The optional keyword parameter test_id is not of type STRING.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the optional input
   ;  keyword parameter 'test_id' is set and the keyword parameter 'first_line'
   ;  is not set, or not an INT array of 9 elements:
      IF ((test_id NE '') AND $
         ((is_integer(first_line) NE 1) OR $
         (is_array(first_line) NE 1) OR $
         (N_ELEMENTS(first_line) NE 9))) THEN BEGIN
         error_code = 140
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The optional input keyword parameter test_id is set but ' + $
            'the keyword parameter first_line is not set or invalid.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the optional input
   ;  keyword parameter 'test_id' is set and the keyword parameter 'last_line'
   ;  is not set, or not an INT array of 9 elements:
      IF ((test_id NE '') AND $
         ((is_integer(last_line) NE 1) OR $
         (is_array(last_line) NE 1) OR $
         (N_ELEMENTS(last_line) NE 9))) THEN BEGIN
         error_code = 150
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The optional input keyword parameter test_id is set but ' + $
            'the keyword parameter last_line is not set or invalid.'
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

   ;  Retrieve the MISR Mode, Path, Orbit, Block and Version identifiers from
   ;  the input positional parameter 'misr_ptr':
   misr_meta = *misr_ptr
   misr_mode = misr_meta[0]
   misr_path_str = misr_meta[1]
   misr_orbit_str = misr_meta[2]
   misr_block_str = misr_meta[3]
   misr_version = misr_meta[4]

   ;  Return to the calling routine with an error message if 'misr_mode' is
   ;  not 'GM', as all RCCM products are only available at the reduced
   ;  spatial resolution:
   IF (debug AND (misr_mode NE 'GM')) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Access to MISR L1B2 Radiance data must be provided in Global Mode.'
      RETURN, error_code
   ENDIF

   pob_str = strcat([misr_path_str, misr_orbit_str, misr_block_str], '-')
   mpob_str = strcat([misr_mode, pob_str], '-')

   ;  Generate the MISR Path, Orbit and Block numbers:
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
            ': Computer is unrecognized, function set_roots_vers.pro did ' + $
            'not assign default folder values, and at least one of the ' + $
            'optional keyword parameters log_folder, save_folder, ' + $
            'map_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Retrieve the specifications (path + filename) of the 9 RCCM files, in
   ;  the native order: DF, CF, ..., AN, ..., CA, DA:
   rc = find_rccm_files(misr_path, misr_orbit, rccm_files, $
      RCCM_FOLDER = rccm_folder, RCCM_VERSION = rccm_version, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
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
      ENDIF ELSE BEGIN
         log_path = root_dirs[3] + pob_str + PATH_SEP() + $
            'GM' + PATH_SEP() + 'RCCM'

   ;  Update the log path if this is a test run:
         IF (test_id NE '') THEN log_path = log_path + '_' + test_id
      ENDELSE
      rc = remove_path_sep(log_path)
      IF (edge) THEN log_path = log_path + '_edge'
      rc = force_path_sep(log_path)

   ;  Create the output directory 'log_path' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable:
      res = is_writable_dir(log_path, /CREATE)
      IF (debug AND (res NE 1)) THEN BEGIN
         error_code = 400
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
            rout_name + ': The directory log_path is unwritable.'
         RETURN, error_code
      ENDIF

      IF (test_id EQ '') THEN BEGIN
         log_name = 'Log_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
            date + '.txt'
      ENDIF ELSE BEGIN
         log_name = 'Log_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
            date + '_' + test_id + '.txt'
      ENDELSE
      log_spec = log_path + log_name

      fmt1 = '(A30, A)'
      fmt2 = '(16A14)'
      fmt3 = '(A14, 9I14, 4F14.2)'

      OPENW, log_unit, log_spec, /GET_LUN
      PRINTF, log_unit, 'File name: ', FILE_BASENAME(log_spec), $
         FORMAT = fmt1
      PRINTF, log_unit, 'Folder name: ', FILE_DIRNAME(log_spec, $
         /MARK_DIRECTORY), FORMAT = fmt1
      PRINTF, log_unit, 'Generated by: ', rout_name, FORMAT = fmt1
      PRINTF, log_unit, 'Generated on: ', comp_name, FORMAT = fmt1
      PRINTF, log_unit, 'Saved on: ', date_time, FORMAT = fmt1
      PRINTF, log_unit

      PRINTF, log_unit, 'Content: ', 'Log on the updating and upgrading ' + $
         'of the standard MISR RCCM product.', FORMAT = fmt1
      PRINTF, log_unit, 'MISR Path: ', strstr(misr_path), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Orbit: ', strstr(misr_orbit), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Block: ', strstr(misr_block), FORMAT = fmt1
      PRINTF, log_unit, 'MISR RCCM Version: ', rccm_version, FORMAT = fmt1
      PRINTF, log_unit, 'Edge option: ', strstr(edge), FORMAT = fmt1
      PRINTF, log_unit, 'MISR Toolkit version: ', MTK_VERSION(), FORMAT = fmt1
      PRINTF, log_unit
   ENDIF

   ;  === Step 0a: Get the original data ======================================
   ;  Retrieve the original MISR RCCM data and store it in the array 'rccm_0':
   rc = mk_rccm0(rccm_files, misr_block, rccm_0, n_miss_0, $
      VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 500
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Map the original rccm_0 product if required:
   IF (map_it) THEN BEGIN
      rccm_logo = 'rccm0'
      rccm_lgnd = ''
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_0, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 510
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  === Step 0b: Optionally add missing data for testing purposes ===========
   IF (test_id NE '') THEN BEGIN

   ;  Set aside the original version of the data to allow comparison with the
   ;  reconstructed version later:
      ori_data = rccm_0

   ;  Loop over the cameras that must be artificially contaminated with
   ;  missing values:
      FOR cam = 0, n_cams - 1 DO BEGIN

   ;  Skip the current camera if either 'first_line' or 'last_line' lie outside
   ;  the range [0, 127] (the number of lines in a Block of RCCM data):
         IF ((first_line[cam] LT 0) OR (first_line[cam] GT 127) OR $
            (last_line[cam] LT 0) OR (last_line[cam] GT 127)) $
            THEN CONTINUE

   ;  Skip the current camera if 'first_line' exceeds 'last_line':
         IF (first_line[cam] GT last_line[cam]) THEN CONTINUE

   ;  Insert missing data in the current data buffer:
         FOR line = first_line[cam], last_line[cam] DO BEGIN
            rccm_0[cam, *, line] = 0B
         ENDFOR

   ;  Recalculate the number of missing values in the current camera:
         idx = WHERE(rccm_0 EQ 0B, cnt)
         n_miss_0[cam] = cnt
      ENDFOR

      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'TEST_ID: ', test_id, FORMAT = fmt1
         PRINTF, log_unit, '', 'Missing data have been ' + $
            'artificially added as follows:', FORMAT = fmt1
         fl = strcat(strstr(first_line), ', ')
         PRINTF, log_unit, 'First_line: ', fl, FORMAT = fmt1
         ll = strcat(strstr(last_line), ', ')
         PRINTF, log_unit, 'Last_line: ', ll, FORMAT = fmt1
         PRINTF, log_unit
      ENDIF
   ENDIF

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN

   ;  Define category accumulators:
      tot_miss = 0L
      tot_cld_hi = 0L
      tot_cld_lo = 0L
      tot_clr_lo = 0L
      tot_clr_hi = 0L
      tot_fill = 0L
      tot_tot = 0L

      PRINTF, log_unit, 'Outcome of mk_rccm0: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Fill (255B)', $
         'Total', FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_0[cam, *, *] EQ 0B, count_0)
         IF (count_0 EQ -1) THEN count_0 = 0L
         idx_1 = WHERE(rccm_0[cam, *, *] EQ 1B, count_1)
         IF (count_1 EQ -1) THEN count_1 = 0L
         idx_2 = WHERE(rccm_0[cam, *, *] EQ 2B, count_2)
         IF (count_2 EQ -1) THEN count_2 = 0L
         idx_3 = WHERE(rccm_0[cam, *, *] EQ 3B, count_3)
         IF (count_3 EQ -1) THEN count_3 = 0L
         idx_4 = WHERE(rccm_0[cam, *, *] EQ 4B, count_4)
         IF (count_4 EQ -1) THEN count_4 = 0L
         idx_255 = WHERE(rccm_0[cam, *, *] EQ 255B, count_255)
         IF (count_255 EQ -1) THEN count_255 = 0L
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_255, totcnt, FORMAT = fmt3

   ;  Update the individual accumulators:
         tot_miss = tot_miss + count_0
         tot_cld_hi = tot_cld_hi + count_1
         tot_cld_lo = tot_cld_lo + count_2
         tot_clr_lo = tot_clr_lo + count_3
         tot_clr_hi = tot_clr_hi + count_4
         tot_fill = tot_fill + count_255
         tot_tot = tot_tot + count_0 + count_1 + count_2 + $
            count_3 + count_4 + count_255
      ENDFOR
      PRINTF, log_unit, 'Totals', tot_miss, tot_cld_hi, tot_cld_lo, $
         tot_clr_lo, tot_clr_hi, tot_fill, tot_tot, FORMAT = fmt3
      PRINTF, log_unit
   ENDIF

   ;  Map the modified rccm_0 product if required:
   IF (map_it AND (test_id NE '')) THEN BEGIN
      rccm_logo = 'rccm0_test'
      rccm_lgnd = ' Additional missing values have been artificially ' + $
         'introduced for testing purposes. '
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_0, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 512
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
      error_code = 520
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN

   ;  Define category accumulators:
      tot_miss = 0L
      tot_cld_hi = 0L
      tot_cld_lo = 0L
      tot_clr_lo = 0L
      tot_clr_hi = 0L
      tot_obsc = 0L
      tot_edge = 0L
      tot_fill = 0L
      tot_tot = 0L

      PRINTF, log_unit, 'Outcome of mk_rccm1: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', $
         'Cld-Hi (%)', 'Cld-Lo (%)', 'Clr-Lo (%)', 'Clr-Hi (%)', $
         FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_1[cam, *, *] EQ 0B, count_0)
         IF (count_0 EQ -1) THEN count_0 = 0L
         idx_1 = WHERE(rccm_1[cam, *, *] EQ 1B, count_1)
         IF (count_1 EQ -1) THEN count_1 = 0L
         idx_2 = WHERE(rccm_1[cam, *, *] EQ 2B, count_2)
         IF (count_2 EQ -1) THEN count_2 = 0L
         idx_3 = WHERE(rccm_1[cam, *, *] EQ 3B, count_3)
         IF (count_3 EQ -1) THEN count_3 = 0L
         idx_4 = WHERE(rccm_1[cam, *, *] EQ 4B, count_4)
         IF (count_4 EQ -1) THEN count_4 = 0L
         idx_253 = WHERE(rccm_1[cam, *, *] EQ 253B, count_253)
         IF (count_253 EQ -1) THEN count_253 = 0L
         idx_254 = WHERE(rccm_1[cam, *, *] EQ 254B, count_254)
         IF (count_254 EQ -1) THEN count_254 = 0L
         idx_255 = WHERE(rccm_1[cam, *, *] EQ 255B, count_255)
         IF (count_255 EQ -1) THEN count_255 = 0L
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         totval = totcnt - count_253 - count_254 - count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, $
            (FLOAT(count_1) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_2) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_3) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_4) / FLOAT(totval)) * 100.0, $
            FORMAT = fmt3

   ;  Update the individual accumulators:
         tot_miss = tot_miss + count_0
         tot_cld_hi = tot_cld_hi + count_1
         tot_cld_lo = tot_cld_lo + count_2
         tot_clr_lo = tot_clr_lo + count_3
         tot_clr_hi = tot_clr_hi + count_4
         tot_obsc = tot_obsc + count_253
         tot_edge = tot_edge + count_254
         tot_fill = tot_fill + count_255
         tot_tot = tot_tot + count_0 + count_1 + count_2 + $
            count_3 + count_4 + count_253 + count_254 + count_255
      ENDFOR
      PRINTF, log_unit, 'Totals', tot_miss, tot_cld_hi, tot_cld_lo, $
         tot_clr_lo, tot_clr_hi, tot_obsc, tot_edge, tot_fill, tot_tot, $
         FORMAT = fmt3
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_1 product if required:
   IF (map_it) THEN BEGIN
      IF (test_id NE '') THEN rccm_logo = 'rccm1_test' ELSE rccm_logo = 'rccm1'
      rccm_lgnd = ' Obscured and edge have been flagged with ' + $
      'specific values to distinguish them from missing values. '
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_1, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 530
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
         IF (verbose GT 0) THEN PRINT, 'Saved ' + log_spec
         RETURN, return_code
      ENDIF
   ENDIF

   ;  === Step 2a: Replace missing values based on neighboring cameras ========
   ;  Call 'mk_rccm2' if there are missing values in 'rccm_1':
   IF (MAX(n_miss_1) GT 0) THEN BEGIN
      rc = mk_rccm2(rccm_1, n_miss_1, rccm_2, n_miss_2, EDGE = edge, $
         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 540
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF ELSE BEGIN
      rccm = rccm_1
   ENDELSE

   ;  Record the outcome in the log if required:
   IF (log_it) THEN BEGIN

   ;  Define category accumulators:
      tot_miss = 0L
      tot_cld_hi = 0L
      tot_cld_lo = 0L
      tot_clr_lo = 0L
      tot_clr_hi = 0L
      tot_obsc = 0L
      tot_edge = 0L
      tot_fill = 0L
      tot_tot = 0L

      PRINTF, log_unit, 'Outcome of mk_rccm2: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', $
         'Cld-Hi (%)', 'Cld-Lo (%)', 'Clr-Lo (%)', 'Clr-Hi (%)', $
         FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_2[cam, *, *] EQ 0B, count_0)
         IF (count_0 EQ -1) THEN count_0 = 0L
         idx_1 = WHERE(rccm_2[cam, *, *] EQ 1B, count_1)
         IF (count_1 EQ -1) THEN count_1 = 0L
         idx_2 = WHERE(rccm_2[cam, *, *] EQ 2B, count_2)
         IF (count_2 EQ -1) THEN count_2 = 0L
         idx_3 = WHERE(rccm_2[cam, *, *] EQ 3B, count_3)
         IF (count_3 EQ -1) THEN count_3 = 0L
         idx_4 = WHERE(rccm_2[cam, *, *] EQ 4B, count_4)
         IF (count_4 EQ -1) THEN count_4 = 0L
         idx_253 = WHERE(rccm_2[cam, *, *] EQ 253B, count_253)
         IF (count_253 EQ -1) THEN count_253 = 0L
         idx_254 = WHERE(rccm_2[cam, *, *] EQ 254B, count_254)
         IF (count_254 EQ -1) THEN count_254 = 0L
         idx_255 = WHERE(rccm_2[cam, *, *] EQ 255B, count_255)
         IF (count_255 EQ -1) THEN count_255 = 0L
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         totval = totcnt - count_253 - count_254 - count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, $
            (FLOAT(count_1) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_2) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_3) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_4) / FLOAT(totval)) * 100.0, $
            FORMAT = fmt3

   ;  Update the individual accumulators:
         tot_miss = tot_miss + count_0
         tot_cld_hi = tot_cld_hi + count_1
         tot_cld_lo = tot_cld_lo + count_2
         tot_clr_lo = tot_clr_lo + count_3
         tot_clr_hi = tot_clr_hi + count_4
         tot_obsc = tot_obsc + count_253
         tot_edge = tot_edge + count_254
         tot_fill = tot_fill + count_255
         tot_tot = tot_tot + count_0 + count_1 + count_2 + $
            count_3 + count_4 + count_253 + count_254 + count_255
      ENDFOR
      PRINTF, log_unit, 'Totals', tot_miss, tot_cld_hi, tot_cld_lo, $
         tot_clr_lo, tot_clr_hi, tot_obsc, tot_edge, tot_fill, tot_tot, $
         FORMAT = fmt3
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_2 product if required:
   IF (map_it) THEN BEGIN
      IF (test_id NE '') THEN rccm_logo = 'rccm2_test' ELSE rccm_logo = 'rccm2'
      rccm_lgnd = ' Missing pixels have been replaced by estimates ' + $
      'of the cloud or clear status of the observed areas, based ' + $
      'on the cloudiness level of the 2 neighboring cameras, wherever ' + $
      'they report identical values. '
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_2, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 550
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  === Step 2b: Evaluate the mk_rccm2 replacement algorithm ================
   IF (test_id NE '') THEN BEGIN

      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'Confusion matrix after: ', 'mk_rccm2', $
            FORMAT = fmt1
      ENDIF

   ;  Define the confusion matrix:
      conf_mat = MAKE_ARRAY(9, 5, 5, /LONG, VALUE = 0)

   ;  Loop over the cameras that have been artificially modified:
      FOR cam = 0, n_cams - 1 DO BEGIN
         IF ((first_line[cam] LT 0) OR (first_line[cam] GT 127) OR $
            (last_line[cam] LT 0) OR (last_line[cam] GT 127)) $
            THEN CONTINUE

   ;  Loop over the lines that have been artificially modified:
         FOR line = first_line[cam], last_line[cam] DO BEGIN

   ;  Loop over the samples in those lines:
            FOR sample = 0, 511 DO BEGIN

   ;  Retrieve the original and the reconstructed values:
               ori = ori_data[cam, sample, line]
               new = rccm_2[cam, sample, line]

   ;  Accumulate the performance statistics (for locations that are observable
   ;  in principle) in the confusion matrix:
               IF ((new GT 0) AND (new LT 5)) $
                  THEN conf_mat[cam, ori, new]++
            ENDFOR
         ENDFOR

   ;  Record the number of processed values:
         n_proc = LONG(TOTAL(conf_mat[cam, *, *]))

   ;  Save the confusion matrix for the current camera in the log file:
         IF (log_it) THEN BEGIN
            fmt4 = '(5A12)'
            fmt5 = '(A12, 4I12)'
            PRINTF, log_unit, 'Test results for: ', 'Camera ' + cams[cam], $
               FORMAT = fmt1
            PRINTF, log_unit, 'N = ' + strstr(n_proc), 'Ori = 1', 'Ori = 2', $
               'Ori = 3', 'Ori = 4', FORMAT = fmt4
            PRINTF, log_unit, 'New = 1', conf_mat[cam, 1, 1], $
               conf_mat[cam, 2, 1], conf_mat[cam, 3, 1], $
               conf_mat[cam, 4, 1], FORMAT = fmt5
            PRINTF, log_unit, 'New = 2', conf_mat[cam, 1, 2], $
               conf_mat[cam, 2, 2], conf_mat[cam, 3, 2], $
               conf_mat[cam, 4, 2], FORMAT = fmt5
            PRINTF, log_unit, 'New = 3', conf_mat[cam, 1, 3], $
               conf_mat[cam, 2, 3], conf_mat[cam, 3, 3], $
               conf_mat[cam, 4, 3], FORMAT = fmt5
            PRINTF, log_unit, 'New = 4', conf_mat[cam, 1, 4], $
               conf_mat[cam, 2, 4], conf_mat[cam, 3, 4], $
               conf_mat[cam, 4, 4], FORMAT = fmt5
            PRINTF, log_unit
            correct = conf_mat[cam, 1, 1] + conf_mat[cam, 2, 2] + $
               conf_mat[cam, 3, 3] + conf_mat[cam, 4, 4]
            PRINTF, log_unit, 'Correct assignments: ', strstr(correct) + $
               ' [' + strstr(ROUND(100 * correct/n_proc)) + $
               '% of missing values]'
            approx_cld = conf_mat[cam, 1, 1] + conf_mat[cam, 1, 2] + $
               conf_mat[cam, 2, 1] + conf_mat[cam, 2, 2]
            PRINTF, log_unit, 'Cloudy assignments: ', strstr(approx_cld) + $
               ' [' + strstr(ROUND(100 * approx_cld/n_proc)) + $
               '% of missing values]'
            approx_clr = conf_mat[cam, 3, 3] + conf_mat[cam, 3, 4] + $
               conf_mat[cam, 4, 3] + conf_mat[cam, 4, 4]
            PRINTF, log_unit, 'Clear assignments: ', strstr(approx_clr) + $
               ' [' + strstr(ROUND(100 * approx_clr/n_proc)) + $
               '% of missing values]'
            wrong = conf_mat[cam, 1, 3] + conf_mat[cam, 1, 4] + $
               conf_mat[cam, 2, 3] + conf_mat[cam, 2, 4] + $
               conf_mat[cam, 3, 1] + conf_mat[cam, 3, 2] + $
               conf_mat[cam, 4, 1] + conf_mat[cam, 4, 2]
            PRINTF, log_unit, 'Wrong assignments: ', strstr(wrong) + $
               ' [' + strstr(ROUND(100 * wrong/n_proc)) + $
               '% of missing values]'
            PRINTF, log_unit
         ENDIF
      ENDFOR
   ENDIF

   ;  Return to the calling routine if there are no more missing values:
   IF (TOTAL(n_miss_2) EQ 0) THEN BEGIN
      rccm = rccm_2
      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'End of processing: rccm2 does not contain ' + $
            'any missing values.'
         CLOSE, log_unit
         FREE_LUN, log_unit
         IF (verbose GT 0) THEN PRINT, 'Saved ' + log_spec
         RETURN, return_code
      ENDIF
   ENDIF

   ;  === Step 3a: Replace missing values based on neighboring pixels =========
   ;  Call 'mk_rccm3' if there are missing values in 'rccm_2':
   IF (MAX(n_miss_2) GT 0) THEN BEGIN
      rc = mk_rccm3(rccm_2, rccm_3, n_miss_3, VERBOSE = verbose, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 560
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

   ;  Define category accumulators:
      tot_miss = 0L
      tot_cld_hi = 0L
      tot_cld_lo = 0L
      tot_clr_lo = 0L
      tot_clr_hi = 0L
      tot_obsc = 0L
      tot_edge = 0L
      tot_fill = 0L
      tot_tot = 0L

      PRINTF, log_unit, 'Outcome of mk_rccm3: ', '', FORMAT = fmt1
      PRINTF, log_unit, '', 'Miss (0B)', 'Cld-Hi (1B)', $
         'Cld-Lo (2B)', 'Clr-Lo (3B)', 'Clr-Hi (4B)', 'Obsc (253B)', $
         'Edge (254B)', 'Fill (255B)', 'Total', $
         'Cld-Hi (%)', 'Cld-Lo (%)', 'Clr-Lo (%)', 'Clr-Hi (%)', $
         FORMAT = fmt2
      FOR cam = 0, n_cams - 1 DO BEGIN
         idx_0 = WHERE(rccm_3[cam, *, *] EQ 0B, count_0)
         IF (count_0 EQ -1) THEN count_0 = 0L
         idx_1 = WHERE(rccm_3[cam, *, *] EQ 1B, count_1)
         IF (count_1 EQ -1) THEN count_1 = 0L
         idx_2 = WHERE(rccm_3[cam, *, *] EQ 2B, count_2)
         IF (count_2 EQ -1) THEN count_2 = 0L
         idx_3 = WHERE(rccm_3[cam, *, *] EQ 3B, count_3)
         IF (count_3 EQ -1) THEN count_3 = 0L
         idx_4 = WHERE(rccm_3[cam, *, *] EQ 4B, count_4)
         IF (count_4 EQ -1) THEN count_4 = 0L
         idx_253 = WHERE(rccm_3[cam, *, *] EQ 253B, count_253)
         IF (count_253 EQ -1) THEN count_253 = 0L
         idx_254 = WHERE(rccm_3[cam, *, *] EQ 254B, count_254)
         IF (count_254 EQ -1) THEN count_254 = 0L
         idx_255 = WHERE(rccm_3[cam, *, *] EQ 255B, count_255)
         IF (count_255 EQ -1) THEN count_255 = 0L
         totcnt = count_0 + count_1 + count_2 + count_3 + count_4 + $
            count_253 + count_254 + count_255
         PRINTF, log_unit, cams[cam], count_0, count_1, count_2, count_3, $
            count_4, count_253, count_254, count_255, totcnt, $
            (FLOAT(count_1) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_2) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_3) / FLOAT(totval)) * 100.0, $
            (FLOAT(count_4) / FLOAT(totval)) * 100.0, $
            FORMAT = fmt3

   ;  Update the individual accumulators:
         tot_miss = tot_miss + count_0
         tot_cld_hi = tot_cld_hi + count_1
         tot_cld_lo = tot_cld_lo + count_2
         tot_clr_lo = tot_clr_lo + count_3
         tot_clr_hi = tot_clr_hi + count_4
         tot_obsc = tot_obsc + count_253
         tot_edge = tot_edge + count_254
         tot_fill = tot_fill + count_255
         tot_tot = tot_tot + count_0 + count_1 + count_2 + $
            count_3 + count_4 + count_253 + count_254 + count_255
      ENDFOR
      PRINTF, log_unit, 'Totals', tot_miss, tot_cld_hi, tot_cld_lo, $
         tot_clr_lo, tot_clr_hi, tot_obsc, tot_edge, tot_fill, tot_tot, $
         FORMAT = fmt3
      PRINTF, log_unit
   ENDIF

   ;  Map the rccm_3 product if required:
   IF (map_it) THEN BEGIN
      IF (test_id NE '') THEN rccm_logo = 'rccm3_test' ELSE rccm_logo = 'rccm3'
      rccm_lgnd = ' Missing pixels have been replaced by estimates ' + $
      'of the cloud or clear status of the observed areas, based ' + $
      'on the cloudiness level of neighboring pixels within small ' + $
      'sub-windows of the target camera. '
      rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
         rccm_3, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
         MAP_IT = map_it, MAP_FOLDER = map_folder, $
         DEBUG = debug, EXCPT_COND = excpt_cond)
      IF (debug AND (rc NE 0)) THEN BEGIN
         error_code = 570
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': ' + excpt_cond
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Save the final result in an IDL SAVE file if requested:
   IF (save_it) THEN BEGIN

      IF (KEYWORD_SET(save_folder)) THEN BEGIN
         save_path = save_folder
      ENDIF ELSE BEGIN
         save_path = root_dirs[3] + pob_str + PATH_SEP() + $
            'GM' + PATH_SEP() + 'RCCM'

   ;  Update the save path if this is a test run:
         IF (test_id NE '') THEN save_path = save_path + '_' + test_id
      ENDELSE
      rc = remove_path_sep(save_path)
      IF (edge) THEN save_path = save_path + '_edge'
      rc = force_path_sep(save_path)

   ;  Create the output directory 'save_path' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable:
      res = is_writable_dir(save_path, /CREATE)
      IF (debug AND (res NE 1)) THEN BEGIN
         error_code = 410
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
            rout_name + ': The directory save_path is unwritable.'
         RETURN, error_code
      ENDIF

      IF (test_id EQ '') THEN BEGIN
         save_fname = 'Save_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
            date + '.sav'
      ENDIF ELSE BEGIN
         save_fname = 'Save_RCCM_cldm_' + mpob_str + '_' + acquis_date + '_' + $
            date + '_' + test_id + '.sav'
      ENDELSE
      save_fspec = save_path + save_fname
      SAVE, rccm, FILENAME = save_fspec

      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'Final updated and upgraded RCCM data saved in'
         PRINTF, log_unit, save_fspec
         PRINTF, log_unit
      ENDIF
   ENDIF

   ;  === Step 3b: Evaluate the overall replacement algorithm =================
   IF (test_id NE '') THEN BEGIN

      IF (log_it) THEN BEGIN
         PRINTF, log_unit, 'Confusion matrix after: ', 'mk_rccm3', $
            FORMAT = fmt1
      ENDIF

   ;  Define the confusion matrix:
      conf_mat = MAKE_ARRAY(9, 5, 5, /LONG, VALUE = 0)

   ;  Loop over the cameras that have been artificially modified:
      FOR cam = 0, n_cams - 1 DO BEGIN
         IF ((first_line[cam] LT 0) OR (first_line[cam] GT 127) OR $
            (last_line[cam] LT 0) OR (last_line[cam] GT 127)) $
            THEN CONTINUE

   ;  Loop over the lines that have been artificially modified:
         FOR line = first_line[cam], last_line[cam] DO BEGIN

   ;  Loop over the samples in those lines:
            FOR sample = 0, 511 DO BEGIN

   ;  Retrieve the original and the reconstructed values:
               ori = ori_data[cam, sample, line]
               new = rccm_3[cam, sample, line]

   ;  Accumulate the performance statistics (for locations that are observable
   ;  in principle) in the confusion matrix:
               IF ((new GT 0) AND (new LT 5)) $
                  THEN conf_mat[cam, ori, new]++
            ENDFOR
         ENDFOR

   ;  Record the number of processed values:
         n_proc = LONG(TOTAL(conf_mat[cam, *, *]))

   ;  Save the confusion matrix for the current camera in the log file:
         IF (log_it) THEN BEGIN
            fmt4 = '(5A12)'
            fmt5 = '(A12, 4I12)'
            PRINTF, log_unit, 'Test results for: ', 'Camera ' + cams[cam], $
               FORMAT = fmt1
            PRINTF, log_unit, 'N = ' + strstr(n_proc), 'Ori = 1', 'Ori = 2', $
               'Ori = 3', 'Ori = 4', FORMAT = fmt4
            PRINTF, log_unit, 'New = 1', conf_mat[cam, 1, 1], $
               conf_mat[cam, 2, 1], conf_mat[cam, 3, 1], $
               conf_mat[cam, 4, 1], FORMAT = fmt5
            PRINTF, log_unit, 'New = 2', conf_mat[cam, 1, 2], $
               conf_mat[cam, 2, 2], conf_mat[cam, 3, 2], $
               conf_mat[cam, 4, 2], FORMAT = fmt5
            PRINTF, log_unit, 'New = 3', conf_mat[cam, 1, 3], $
               conf_mat[cam, 2, 3], conf_mat[cam, 3, 3], $
               conf_mat[cam, 4, 3], FORMAT = fmt5
            PRINTF, log_unit, 'New = 4', conf_mat[cam, 1, 4], $
               conf_mat[cam, 2, 4], conf_mat[cam, 3, 4], $
               conf_mat[cam, 4, 4], FORMAT = fmt5
            PRINTF, log_unit
            correct = conf_mat[cam, 1, 1] + conf_mat[cam, 2, 2] + $
               conf_mat[cam, 3, 3] + conf_mat[cam, 4, 4]
            PRINTF, log_unit, 'Correct assignments: ', strstr(correct) + $
               ' [' + strstr(ROUND(100 * correct/n_proc)) + $
               '% of missing values]'
            approx_cld = conf_mat[cam, 1, 1] + conf_mat[cam, 1, 2] + $
               conf_mat[cam, 2, 1] + conf_mat[cam, 2, 2]
            PRINTF, log_unit, 'Cloudy assignments: ', strstr(approx_cld) + $
               ' [' + strstr(ROUND(100 * approx_cld/n_proc)) + $
               '% of missing values]'
            approx_clr = conf_mat[cam, 3, 3] + conf_mat[cam, 3, 4] + $
               conf_mat[cam, 4, 3] + conf_mat[cam, 4, 4]
            PRINTF, log_unit, 'Clear assignments: ', strstr(approx_clr) + $
               ' [' + strstr(ROUND(100 * approx_clr/n_proc)) + $
               '% of missing values]'
            wrong = conf_mat[cam, 1, 3] + conf_mat[cam, 1, 4] + $
               conf_mat[cam, 2, 3] + conf_mat[cam, 2, 4] + $
               conf_mat[cam, 3, 1] + conf_mat[cam, 3, 2] + $
               conf_mat[cam, 4, 1] + conf_mat[cam, 4, 2]
            PRINTF, log_unit, 'Wrong assignments: ', strstr(wrong) + $
               ' [' + strstr(ROUND(100 * wrong/n_proc)) + $
               '% of missing values]'
            PRINTF, log_unit
         ENDIF
      ENDFOR
   ENDIF

   IF (log_it) THEN BEGIN
      CLOSE, log_unit
      FREE_LUN, log_unit
   ENDIF

   IF (log_it AND (verbose GT 0)) THEN PRINT, 'Saved ' + log_spec
   IF (save_it AND (verbose GT 0)) THEN PRINT, 'Saved ' + save_fspec
   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
