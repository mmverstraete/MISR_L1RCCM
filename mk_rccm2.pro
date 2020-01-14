FUNCTION mk_rccm2, $
   rccm_1, $
   n_miss_1, $
   rccm_2, $
   n_miss_2, $
   EDGE = edge, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function replaces missing values in the cloud mask
   ;  rccm_1 for one camera by the values found in its 2 immediate
   ;  neighbors whenever the latter are identical, and optionally by the
   ;  cloud mask in one of the neighbors where ever they do not overlap.
   ;
   ;  ALGORITHM: For each camera-specific cloud mask containing missing
   ;  values, this function inspects the 2 immediate neighboring cameras,
   ;  replaces the missing values if both of them report the same cloud
   ;  mask value, and updates the output cloud mask rccm_2. If those
   ;  neighboring cameras have different swath widths, the cloud mask of
   ;  the camera with the wider swath may optionally be copied over to the
   ;  camera being repaired, outside of this overlap zone.
   ;
   ;  SYNTAX: rc = mk_rccm2(rccm_1, n_miss_1, rccm_2, n_miss_2, $
   ;  EDGE = edge, VERBOSE = verbose, $
   ;  DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   rccm_1 {BYTE array} [O]: An array containing the updated RCCM
   ;      product for the 9 camera files corresponding to the selected
   ;      MISR PATH, ORBIT and BLOCK, i.e., with non zero values for edge
   ;      and obscured pixels.
   ;
   ;  *   n_miss_1 {LONG array} [O]: An array reporting how many missing
   ;      values (0B) remain in each of these 9 cloud masks at the end of
   ;      processing in mk_rccm1.pro.
   ;
   ;  *   rccm_2 {BYTE array} [O]: An array containing the upgraded RCCM
   ;      product for the 9 camera files corresponding to the selected
   ;      MISR PATH, ORBIT and BLOCK, i.e., with non zero values for edge
   ;      and obscured pixels, and with some of the missing values already
   ;      replaced by mk_rccm2.pro.
   ;
   ;  *   n_miss_2 {LONG array} [O]: An array reporting how many missing
   ;      values (0B) remain in each of these 9 cloud masks at the end of
   ;      processing in mk_rccm2.pro.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   EDGE = edge {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) copying the cloud mask of the neighboring camera
   ;      with the wider swath outside of the region where it overlaps
   ;      with the cloud mask of the neighboring camera with the narrower
   ;      swath.
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
   ;      provided in the call. The output positional parameters rccm_2
   ;      and n_miss_2 contain the upgraded cloud masks and the number of
   ;      missing values in each of them, respectively. The meaning of
   ;      pixel values in rccm_2 is as follows:
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
   ;      provided. The output positional parameters rccm_2 and n_miss_2
   ;      may be inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Positional parameter rccm_1 is invalid.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   set_misr_specs.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: This function only replaces missing values when both
   ;      neighboring cameras report identical valid values. This assumes
   ;      that the cloud fields are homogeneous over the range of
   ;      observation angles encompassing the 3 cameras. Errors may occur
   ;      with highly discontinuous cloud fields at high altitude.
   ;      Ambiguous cases (i.e., where neighboring cameras report
   ;      different values) are treated by function mk_rccm3.
   ;
   ;  *   NOTE 2: If the optional keyword parameter EDGE is set, the cloud
   ;      mask of the neighboring camera with the widest swath is copied
   ;      to the cloud mask in the camera being updated, wherever the
   ;      latter has missing values, and outside of the overlap between
   ;      the two neighboring cameras. This optional step generates more
   ;      accurate results than letting the mk_rccm3 function fill the
   ;      remaining missing values.
   ;
   ;  EXAMPLES:
   ;
   ;      [See the outcome(s) generated by fix_rccm.pro]
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
   ;  *   2019–02–25: Version 1.0 — Initial release.
   ;
   ;  *   2019–02–27: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–27: Version 2.01 — New improved algorithm, capable of
   ;      dealing with cases where most values are missing within a BLOCK,
   ;      as long as values are not missing in neighboring cameras, and
   ;      update the documentation.
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
   ;  *   2020–01–12: Version 2.1.1 — Add the optional keyword parameter
   ;      EDGE to control the use of the cloud mask of one of the two
   ;      neighboring cameras wherever they do not overlap; update the
   ;      code to process the cameras in the order of increasing number of
   ;      missing values; update the documentation.
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
   IF (KEYWORD_SET(edge)) THEN edge = 1 ELSE edge = 0
   IF (KEYWORD_SET(verbose)) THEN BEGIN
      IF (is_numeric(verbose)) THEN verbose = FIX(verbose) ELSE verbose = 0
      IF (verbose LT 0) THEN verbose = 0
      IF (verbose GT 3) THEN verbose = 3
   ENDIF ELSE verbose = 0
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (verbose GT 1) THEN PRINT, 'Entering ' + rout_name + '.'

   ;  Initialize the output positional parameter(s):
   rccm_2 = rccm_1

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 4
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): rccm_1, n_miss_1, rccm_2, n_miss_2.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'rccm_1' is not a properly dimensioned BYTE array:
      sz = SIZE(rccm_1)
      IF ((sz[0] NE 3) OR $
         (sz[1] NE 9) OR $
         (sz[2] NE 512) OR $
         (sz[3] NE 128) OR $
         (sz[4] NE 1)) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Positional parameter rccm_1 is invalid.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Set the MISR specifications:
   misr_specs = set_misr_specs()
   n_cams = misr_specs.NCameras
   misr_cam_ids = misr_specs.CameraIDs
   misr_cams = misr_specs.CameraNames

   n_miss_2 = LONARR(n_cams)

   ;  Order the cameras in the order of increasing number of missing values:
   miss_order = SORT(n_miss_1)
   cam_ids_order = misr_cam_ids[miss_order]
   cam_nam_order = misr_cams[miss_order]
   IF (verbose GT 2) THEN BEGIN
      PRINT, 'n_miss_1 = ', n_miss_1
      PRINT, 'cam_nam_order = ', cam_nam_order
   ENDIF

   ;  Keep track of which cameras have already been processed:
   processed = MAKE_ARRAY(9, /INTEGER, VALUE = 0)

   ;  Process all 9 cameras, starting with those that contain the smallest
   ;  number of missing values:
   FOR c = 0, n_cams - 1 DO BEGIN
      cam = cam_ids_order[c]
      IF (verbose GT 2) THEN PRINT, 'Processing ' + cam_nam_order[c] + $
         ' with ' + strstr(n_miss_1[cam_nam_order[c]]) + ' missing values.'

   ;  Process this camera only if it contains missing values:
      IF (n_miss_1[cam] GT 0) THEN BEGIN

         CASE 1 OF
            (cam EQ 0): BEGIN

   ;  === DF ==================================================================
   ;  Process the DF camera, if it contains any missing values:

   ;  Generate temporary 2D cloud masks for the DF, CF and BF cameras, using
   ;  the already processed cloud masks, if available:
               cld_msk_df = REFORM(rccm_1[0, *, *])
               IF (processed[1]) THEN BEGIN
                  cld_msk_cf = REFORM(rccm_2[1, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_cf = REFORM(rccm_1[1, *, *])
               ENDELSE
               IF (processed[2]) THEN BEGIN
                  cld_msk_bf = REFORM(rccm_2[2, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_bf = REFORM(rccm_1[2, *, *])
               ENDELSE

   ;  Identify the missing values in DF that are cloud high confidence in
   ;  both the CF and the BF cameras, and reset the DF values accordingly:
               miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                  (cld_msk_cf[*, *] EQ 1B) AND $
                  (cld_msk_bf[*, *] EQ 1B), count)
               IF (count GT 0) THEN cld_msk_df[miss_idx] = 1B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DF to high confidence cloud.'

   ;  Identify the missing values in DF that are cloud low confidence in
   ;  both the CF and the BF cameras, and reset the DF values accordingly:
               miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                  (cld_msk_cf[*, *] EQ 2B) AND $
                  (cld_msk_bf[*, *] EQ 2B), count)
               IF (count GT 0) THEN cld_msk_df[miss_idx] = 2B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DF to low confidence cloud.'

   ;  Identify the missing values in DF that are clear low confidence in
   ;  both the CF and the BF cameras, and reset the DF values accordingly:
               miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                  (cld_msk_cf[*, *] EQ 3B) AND $
                  (cld_msk_bf[*, *] EQ 3B), count)
               IF (count GT 0) THEN cld_msk_df[miss_idx] = 3B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DF to low confidence clear.'

   ;  Identify the missing values in DF that are clear high confidence in
   ;  both the CF and the BF cameras, and reset the DF values accordingly:
               miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                  (cld_msk_cf[*, *] EQ 4B) AND $
                  (cld_msk_bf[*, *] EQ 4B), count)
               IF (count GT 0) THEN cld_msk_df[miss_idx] = 4B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DF to high confidence clear.'

               IF (edge) THEN BEGIN
   ;  Identify the missing values in DF that are valid in CF but missing or
   ;  part of the edges of BF, if any, and reset the DF values to those in CF:
                  miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                     (cld_msk_cf[*, *] GE 1B) AND $
                     (cld_msk_cf[*, *] LE 4B) AND $
                     ((cld_msk_bf[*, *] EQ 0B) OR $
                     (cld_msk_bf[*, *] EQ 254B)), count)
                  IF (count GT 0) THEN cld_msk_df[miss_idx] = $
                     cld_msk_cf[miss_idx]
                  IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                     ' missing values in camera DF based on CF values only.'

   ;  Identify the missing values in DF that are valid in BF but missing or
   ;  part of the edges of CF, if any, and reset the DF values to those in BF:
                  miss_idx = WHERE((cld_msk_df[*, *] EQ 0B) AND $
                     ((cld_msk_cf[*, *] EQ 0B) OR $
                     (cld_msk_cf[*, *] EQ 254B)) AND $
                     (cld_msk_bf[*, *] GE 1B) AND $
                     (cld_msk_bf[*, *] LE 4B), count)
                  IF (count GT 0) THEN cld_msk_df[miss_idx] = $
                     cld_msk_bf[miss_idx]
                  IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                     ' missing values in camera DF based on BF values only.'
               ENDIF

   ;  Copy the temporary cld_msk_df back into the rccm_2 array:
               rccm_2[0, *, *] = cld_msk_df
               idx = WHERE(cld_msk_df EQ 0B, cnt)
               n_miss_2[0] = cnt
               processed[0] = 1
               IF (verbose GT 2) THEN BEGIN
                  PRINT, 'At the end of rccm2 processing, Camera ' + $
                     misr_cams[0] + ' contains ' + strstr(cnt) + $
                     ' missing values.'
               ENDIF

            END

            (cam EQ 1) OR (cam EQ 2) OR (cam EQ 3) OR (cam EQ 4) OR $
               (cam EQ 5) OR (cam EQ 6) OR (cam EQ 7): BEGIN

   ;  === CF to CA ============================================================
   ;  Process the cameras other than DF and DA, if they contain any missing
   ;  values:

   ;  Generate temporary 2D cloud masks for the current camera and its 2
   ;  neighbors, using the already processed cloud masks, if available:
               IF (processed[cam - 1]) THEN BEGIN
                  cld_msk_bef = REFORM(rccm_2[cam - 1, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_bef = REFORM(rccm_1[cam - 1, *, *])
               ENDELSE
               cld_msk_cur = REFORM(rccm_1[cam, *, *])
               IF (processed[cam + 1]) THEN BEGIN
                  cld_msk_aft = REFORM(rccm_2[cam + 1, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_aft = REFORM(rccm_1[cam + 1, *, *])
               ENDELSE

   ;  Identify the missing values in the current camera that are cloud high
   ;  confidence in both the preceding and following cameras, and reset the
   ;  current values accordingly:
               miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                  (cld_msk_bef[*, *] EQ 1B) AND $
                  (cld_msk_aft[*, *] EQ 1B), count)
               IF (count GT 0) THEN cld_msk_cur[miss_idx] = 1B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera ' + misr_cams[cam] + $
                  ' to high confidence cloud.'

   ;  Identify the missing values in the current camera that are cloud low
   ;  confidence in both the preceding and following cameras, and reset the
   ;  current values accordingly:
               miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                  (cld_msk_bef[*, *] EQ 2B) AND $
                  (cld_msk_aft[*, *] EQ 2B), count)
               IF (count GT 0) THEN cld_msk_cur[miss_idx] = 2B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera ' + misr_cams[cam] + $
                  ' to low confidence cloud.'

   ;  Identify the missing values in the current camera that are clear low
   ;  confidence in both the preceding and following cameras, and reset the
   ;  current values accordingly:
               miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                  (cld_msk_bef[*, *] EQ 3B) AND $
                  (cld_msk_aft[*, *] EQ 3B), count)
               IF (count GT 0) THEN cld_msk_cur[miss_idx] = 3B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera ' + misr_cams[cam] + $
                  ' to high confidence clear.'

   ;  Identify the missing values in the current camera that are clear high
   ;  confidence in both the preceding and following cameras, and reset the
   ;  current values accordingly:
               miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                  (cld_msk_bef[*, *] EQ 4B) AND $
                  (cld_msk_aft[*, *] EQ 4B), count)
               IF (count GT 0) THEN cld_msk_cur[miss_idx] = 4B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera ' + misr_cams[cam] + $
                  ' to high confidence clear.'

               IF (edge) THEN BEGIN
   ;  Identify the missing values in the current camera that are valid in one
   ;  of the neighboring cameras but missing or part of the edges in the other,
   ;  if any, and reset the current values accordingly, checking the most
   ;  inclined camera first:
                  IF (cam LE 4) THEN BEGIN
                     miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                        (cld_msk_bef[*, *] GE 1B) AND $
                        (cld_msk_bef[*, *] LE 4B) AND $
                        ((cld_msk_aft[*, *] EQ 0B) OR $
                        (cld_msk_aft[*, *] EQ 254B)), count)
                     IF (count GT 0) THEN cld_msk_cur[miss_idx] = $
                        cld_msk_bef[miss_idx]
                     IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                        ' missing values in camera ' + misr_cams[cam] + $
                        ' based on ' + misr_cams[cam - 1] + ' only.'

                     miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                        ((cld_msk_bef[*, *] EQ 0B) OR $
                        (cld_msk_bef[*, *] EQ 254B)) AND $
                        (cld_msk_aft[*, *] GE 1B) AND $
                        (cld_msk_aft[*, *] LE 4B), count)
                     IF (count GT 0) THEN cld_msk_cur[miss_idx] = $
                        cld_msk_aft[miss_idx]
                     IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                        ' missing values in camera ' + misr_cams[cam] + $
                        ' based on ' + misr_cams[cam + 1] + ' only.'
                  ENDIF ELSE BEGIN
                     miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                        ((cld_msk_bef[*, *] EQ 0B) OR $
                        (cld_msk_bef[*, *] EQ 254B)) AND $
                        (cld_msk_aft[*, *] GE 1B) AND $
                        (cld_msk_aft[*, *] LE 4B), count)
                     IF (count GT 0) THEN cld_msk_cur[miss_idx] = $
                        cld_msk_aft[miss_idx]
                     IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                        ' missing values in camera ' + misr_cams[cam] + $
                        ' based on ' + misr_cams[cam + 1] + ' only.'

                     miss_idx = WHERE((cld_msk_cur[*, *] EQ 0B) AND $
                        (cld_msk_bef[*, *] GE 1B) AND $
                        (cld_msk_bef[*, *] LE 4B) AND $
                        ((cld_msk_aft[*, *] EQ 0B) OR $
                        (cld_msk_aft[*, *] EQ 254B)), count)
                     IF (count GT 0) THEN cld_msk_cur[miss_idx] = $
                        cld_msk_bef[miss_idx]
                     IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                        ' missing values in camera ' + misr_cams[cam] + $
                        ' based on ' + misr_cams[cam - 1] + ' only.'
                  ENDELSE
               ENDIF

   ;  Copy the temporary cld_msk_cur back into the rccm_2 array:
               rccm_2[cam, *, *] = cld_msk_cur
               idx = WHERE(cld_msk_cur EQ 0B, cnt)
               n_miss_2[cam] = cnt
               processed[cam] = 1
               IF (verbose GT 2) THEN BEGIN
                  PRINT, 'At the end of rccm2 processing, Camera ' + $
                     misr_cams[cam] + ' contains ' + strstr(cnt) + $
                     ' missing values.'
               ENDIF

            END

            (cam EQ 8): BEGIN

   ;  === DA ==================================================================
   ;  Process the DA camera, if it contains any missing values, using
   ;  the already processed cloud masks, if available:

   ;  Generate temporary 2D cloud masks for the DA, CA and BA cameras:
               IF (processed[6]) THEN BEGIN
                  cld_msk_ba = REFORM(rccm_2[6, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_ba = REFORM(rccm_1[6, *, *])
               ENDELSE
               IF (processed[7]) THEN BEGIN
                  cld_msk_ca = REFORM(rccm_2[7, *, *])
               ENDIF ELSE BEGIN
                  cld_msk_ca = REFORM(rccm_1[7, *, *])
               ENDELSE
               cld_msk_da = REFORM(rccm_1[8, *, *])

   ;  Identify the missing values in DA that are cloud high confidence in
   ;  both the CA and the BA cameras, and reset the DA values accordingly:
               miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                  (cld_msk_ca[*, *] EQ 1B) AND $
                  (cld_msk_ba[*, *] EQ 1B), count)
               IF (count GT 0) THEN cld_msk_da[miss_idx] = 1B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DA to high confidence cloud.'

   ;  Identify the missing values in DA that are cloud low confidence in
   ;  both the CA and the BA cameras, and reset the DA values accordingly:
               miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                  (cld_msk_ca[*, *] EQ 2B) AND $
                  (cld_msk_ba[*, *] EQ 2B), count)
               IF (count GT 0) THEN cld_msk_da[miss_idx] = 2B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DA to low confidence cloud.'

   ;  Identify the missing values in DA that are clear low confidence in
   ;  both the CA and the BA cameras, and reset the DA values accordingly:
               miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                  (cld_msk_ca[*, *] EQ 3B) AND $
                  (cld_msk_ba[*, *] EQ 3B), count)
               IF (count GT 0) THEN cld_msk_da[miss_idx] = 3B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DA to low confidence clear.'

   ;  Identify the missing values in DA that are clear high confidence in
   ;  both the CA and the BA cameras, and reset the DA values accordingly:
               miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                  (cld_msk_ca[*, *] EQ 4B) AND $
                  (cld_msk_ba[*, *] EQ 4B), count)
               IF (count GT 0) THEN cld_msk_da[miss_idx] = 4B
               IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                  ' missing values in camera DA to high confidence clear.'

               IF (edge) THEN BEGIN
   ;  Identify the missing values in DA that are valid in CA but missing or
   ;  part of the edges of BA, if any, and reset the DA values to those in CA:
                  miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                     (cld_msk_ca[*, *] GE 1B) AND $
                     (cld_msk_ca[*, *] LE 4B) AND $
                     ((cld_msk_ba[*, *] EQ 0B) OR $
                     (cld_msk_ba[*, *] EQ 254B)), count)
                  IF (count GT 0) THEN cld_msk_da[miss_idx] = cld_msk_ca[miss_idx]
                  IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                     ' missing values in camera DA based on CA values only.'

   ;  Identify the missing values in DA that are valid in BA but missing or
   ;  part of the edges of CA, if any, and reset the DA values to those in BA:
                  miss_idx = WHERE((cld_msk_da[*, *] EQ 0B) AND $
                     ((cld_msk_ca[*, *] EQ 0B) OR $
                     (cld_msk_ca[*, *] EQ 254B)) AND $
                     (cld_msk_ba[*, *] GE 1B) AND $
                     (cld_msk_ba[*, *] LE 4B), count)
                  IF (count GT 0) THEN cld_msk_da[miss_idx] = cld_msk_ba[miss_idx]
                  IF (verbose GT 2) THEN PRINT, 'Reset ' + strstr(count) + $
                     ' missing values in camera DA based on BA values only.'
               ENDIF

   ;  Copy the temporary cld_msk_da back into the rccm_2 array:
               rccm_2[8, *, *] = cld_msk_da
               idx = WHERE(cld_msk_da EQ 0B, cnt)
               n_miss_2[8] = cnt
               processed[8] = 1
               IF (verbose GT 2) THEN BEGIN
                  PRINT, 'At the end of rccm2 processing, Camera ' + $
                     misr_cams[8] + ' contains ' + strstr(cnt) + $
                     ' missing values.'
               ENDIF
            END

         ENDCASE
      ENDIF
   ENDFOR

   IF (verbose GT 1) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
