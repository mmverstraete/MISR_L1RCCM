FUNCTION map_rccm_block, $
   misr_path, $
   misr_orbit, $
   misr_block, $
   rccm, $
   rccm_logo, $
   rccm_lgnd, $
   TEST_ID = test_id, $
   MAP_IT = map_it, $
   MAP_FOLDER = map_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function saves maps of the MISR L1B2 Georectified
   ;  Radiance Product (GRP) Radiometric Camera-by-camera Cloud Mask
   ;  (RCCM) data product, together with the corresponding legends, in the
   ;  default or specified folder.
   ;
   ;  ALGORITHM: This function generates
   ;
   ;  *   a map of the MISR RCCM data product for each of the 9 cameras of
   ;      the specified PATH, ORBIT and BLOCK into .png files, and
   ;
   ;  *   a legend for each of those maps into .txt files,
   ;
   ;  using a pre-defined color scheme. These files are saved in the
   ;  default or specified folder. If multiple versions of this RCCM data
   ;  product must be mapped, the input positional parameter rccm_logo is
   ;  used to differentiate the filenames, and the input positional
   ;  parameter rccm_lgnd is inserted into the standard legend to describe
   ;  the specificity of this particular set of maps.
   ;
   ;  SYNTAX: rc = map_rccm_block(misr_path, misr_orbit, misr_block, $
   ;  rccm, rccm_logo, rccm_lgnd, TEST_ID = test_id, $
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
   ;  *   rccm {BYTE array} [I]: The RCCM data product, an array
   ;      dimensioned [9, 512, 128].
   ;
   ;  *   rccm_logo {STRING} [I]: The identifier to be used in the map and
   ;      legend filenames to differentiate product versions.
   ;
   ;  *   rccm_lgnd {STRING} [I]: The text fragment to be inserted in the
   ;      map legend to differentiate product versions.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   TEST_ID = test_id {STRING} [I] (Default value: ”): Flag to
   ;      activate (non-empty STRING) or skip (empty STRING) artificially
   ;      introducing missing data in the RCCM data buffer; if set, this
   ;      keyword is used in output file names to label experiments.
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
   ;      provided in the call. The maps and legends are saved in the
   ;      default or specified folder.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The maps and legends may be inexistent, incomplete or
   ;      incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: The input positional parameter misr_orbit is invalid.
   ;
   ;  *   Error 122: The input positional parameter misr_orbit is
   ;      inconsistent with the input positional parameter misr_path.
   ;
   ;  *   Error 124: An exception condition occurred in is_frompath.pro.
   ;
   ;  *   Error 130: The input positional parameter misr_block is invalid.
   ;
   ;  *   Error 140: The input positional parameter rccm is invalid.
   ;
   ;  *   Error 150: The input positional parameter rccm_logo is invalid.
   ;
   ;  *   Error 160: The input positional parameter rccm_lgnd is invalid.
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
   ;  *   Error 299: The computer is not recognized and the optional input
   ;      keyword parameter map_folder is not specified.
   ;
   ;  *   Error 400: The output folder map_fpath is unwritable.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_misr_block.pro
   ;
   ;  *   chk_misr_orbit.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   force_path_sep.pro
   ;
   ;  *   is_frompath.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_scalar.pro
   ;
   ;  *   is_string.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   lr2hr.pro
   ;
   ;  *   make_bytemap.pro
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
   ;  *   strcat.pro
   ;
   ;  *   strstr.pro
   ;
   ;  *   today.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: Since the purpose of this function is to map the input
   ;      positional parameter rccm, these maps are generated irrespective
   ;      of the setting of the input keyword parameter MAP_IT.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> misr_path = 168
   ;      IDL> misr_orbit = 68050
   ;      IDL> misr_block = 110
   ;      IDL> rccm_logo = 'rccm0'
   ;      IDL> rccm_lgnd = ''
   ;      IDL> rc = map_rccm_block(misr_path, misr_orbit, $
   ;         misr_block, rccm_0, rccm_logo, rccm_lgnd, $
   ;         MAP_IT = map_it, MAP_FOLDER = map_folder, $
   ;         DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, rc
   ;             0
   ;
   ;  REFERENCES:
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
   ;  *   2019–02–27: Version 0.9 — Initial release.
   ;
   ;  *   2019–03–01: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–03–28: Version 2.10 — Update the handling of the optional
   ;      input keyword parameter VERBOSE and generate the software
   ;      version consistent with the published documentation.
   ;
   ;  *   2019–05–07: Version 2.15 — Software version described in the
   ;      preprint published in ESSD Discussions mentioned above.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the use of
   ;      verbose and the assignment of numeric return codes), and switch
   ;      to 3-parts version identifiers.
   ;
   ;  *   2019–09–10: Version 2.1.1 — Add the TEST_ID keyword to save the
   ;      output maps in dedicated folders and files.
   ;
   ;  *   2019–09–25: Version 2.1.2 — Update the code to modify the
   ;      default map output directory.
   ;
   ;  *   2019–12–09: Version 2.1.3 — Update the code to output the path
   ;      address of the folder containing the maps if the input keyword
   ;      parameter verbose is set.
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
   IF (~KEYWORD_SET(test_id)) THEN BEGIN
      test_id = ''
      IF (test_id EQ '') THEN BEGIN
         first_line = MAKE_ARRAY(9, 4, /INTEGER, VALUE = -1)
         last_line = MAKE_ARRAY(9, 4, /INTEGER, VALUE = -1)
      ENDIF
   ENDIF
   IF (KEYWORD_SET(map_it)) THEN map_it = 1 ELSE map_it = 0
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
      n_reqs = 6
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): misr_path, misr_orbit, ' + $
            'misr_block, rccm, rccm_logo, rccm_lgnd.'
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

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'rccm' is not a properly dimensioned BYTE array:
      sz = SIZE(rccm)
      IF ((sz[0] NE 3) OR $
         (sz[1] NE 9) OR $
         (sz[2] NE 512) OR $
         (sz[3] NE 128) OR $
         (sz[4] NE 1)) THEN BEGIN
         error_code = 140
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Positional parameter rccm is invalid.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'rccm_logo' is not a STRING scalar:
      IF ((is_string(rccm_logo) NE 1) OR (is_scalar(rccm_logo) NE 1)) THEN BEGIN
         error_code = 150
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The input positional parameter rccm_logo is not a STRING scalar.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'rccm_lgnd' is not a STRING scalar:
      IF ((is_string(rccm_lgnd) NE 1) OR (is_scalar(rccm_lgnd) NE 1)) $
         THEN BEGIN
         error_code = 160
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Positional parameter rccm_lgnd is not a STRING scalar.'
      ENDIF
   ENDIF

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   misr_cams = misr_specs.CameraNames
   n_bnds = misr_specs.NBands
   misr_bnds = misr_specs.BandNames

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

   ;  Generate the long string version of the MISR Path number:
   rc = path2str(misr_path, misr_path_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 200
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

   ;  Generate the long string version of the MISR Block number:
   rc = block2str(misr_block, misr_block_str, $
      DEBUG = debug, EXCPT_COND = excpt_cond)
   IF (debug AND (rc NE 0)) THEN BEGIN
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   pob_str = strcat([misr_path_str, misr_orbit_str, misr_block_str], '-')
   mpob_str = strcat(['GM', pob_str], '-')

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
      IF (map_it AND (~KEYWORD_SET(map_folder))) THEN BEGIN
         error_code = 299
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Computer is unrecognized, function set_roots_vers.pro did ' + $
            'not assign default folder values, and the optional keyword ' + $
            'parameter map_folder is not specified.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the directory address of the folder containing the output map files:
   IF (KEYWORD_SET(map_folder)) THEN BEGIN
      map_fpath = map_folder
   ENDIF ELSE BEGIN
      map_fpath = root_dirs[3] + pob_str + PATH_SEP() + $
         'GM' + PATH_SEP() + 'RCCM'

   ;  Update the map path if this is a test run:
      IF (test_id NE '') THEN map_fpath = map_fpath + '_' + test_id
   ENDELSE
   rc = force_path_sep(map_fpath)

   ;  Create the output directory 'map_fpath' if it does not exist, and
   ;  return to the calling routine with an error message if it is unwritable:
   res = is_writable_dir(map_fpath, /CREATE)
   IF (debug AND (res NE 1)) THEN BEGIN
      error_code = 400
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
         rout_name + ': The directory map_fpath is unwritable.'
      RETURN, error_code
   ENDIF

   ;  Set the color scheme for the expected RCCM pixel values:
   good_vals = [0B, 1B, 2B, 3B, 4B, 253B, 254B, 255B]
   good_vals_cols = ['red', 'white', 'gray', 'aqua', 'blue', 'gold', $
      'black', 'red']

   ;  Iterate over the 9 camera maps:
   FOR cam = 0, n_cams - 1 DO BEGIN

   ;  Generate the specification of the output map file:
      IF (test_id EQ '') THEN BEGIN
         map_fname = 'Map_RCCM_' + rccm_logo + '_' + mpob_str + '_' + $
            misr_cams[cam] + '_' + acquis_date + '_' + date + '.png'
      ENDIF ELSE BEGIN
         map_fname = 'Map_RCCM_' + rccm_logo + '_' + mpob_str + '_' + $
            misr_cams[cam] + '_' + acquis_date + '_' + date + '_' + $
            test_id + '.png'
      ENDELSE
      map_fspec = map_fpath + map_fname

   ;  Generate the specification of the output legend file:
      legend_fname = map_fname.Replace('Map', 'Legend')
      legend_fname = legend_fname.Replace('png', 'txt')
      legend_fspec = map_fpath + legend_fname

   ;  Upscale the RCCM data to the full spatial resolution to ease comparisons
   ;  with other maps:
      map = lr2hr(REFORM(rccm[cam, *, *]))

   ;  Generate and save the RCCM map:
      rc = make_bytemap(map, good_vals, good_vals_cols, map_fspec, $
         DEBUG = debug, EXCPT_COND = excpt_cond)

   ;  Save the map legend in the same folder:
      map_legend_txt = 'Map of the MISR Radiometric ' + $
         'Camera-by-camera Cloud Mask (RCCM) for ' + $
         'Path ' + strstr(misr_path) + $
         ', Orbit ' + strstr(misr_orbit) + $
         ', Block ' + strstr(misr_block) + $
         ' and Camera ' + misr_cams[cam] + '.' + $
         rccm_lgnd + $
         ' All RCCM products are generated at the spatial resolution ' + $
         'of 1100 m and provided as arrays of 512 by 128 pixels. This ' + $
         'map has been enlarged (4x in each direction) by duplication ' + $
         'for viewing convenience and to facilitate comparisons with ' + $
         'other maps. The total size of the Block area is 563.2 km ' + $
         'across-track by 140.8 km along-track, while the ' + $
         'parallelogram-shaped ground area inside the Block is about ' + $
         '380 km across-track. ' + $
         'Color coding: ' + $
         good_vals_cols[0] + ': no retrieval or fill value; ' + $
         good_vals_cols[1] + ': cloud with high confidence; ' + $
         good_vals_cols[2] + ': cloud with low confidence; ' + $
         good_vals_cols[3] + ': clear with low confidence; ' + $
         good_vals_cols[4] + ': clear with high confidence; ' + $
         good_vals_cols[5] + ': pixels obscured by topography; and ' + $
         good_vals_cols[6] + ': pixels in the edges of the instrument swath.'

      OPENW, legend_unit, legend_fspec, /GET_LUN
      PRINTF, legend_unit, 'Legend for the similarly named map:'
      PRINTF, legend_unit, map_legend_txt
      CLOSE, legend_unit
      FREE_LUN, legend_unit
   ENDFOR

   IF ((verbose GT 0) AND map_it) THEN BEGIN
      PRINT, 'The RCCM maps have been saved in' + map_fpath + '.'
   ENDIF
   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
