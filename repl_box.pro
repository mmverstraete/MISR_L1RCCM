FUNCTION repl_box, $
   array, $
   sample, $
   line, $
   box_inc, $
   min_num_required, $
   value, $
   HOMOGENEOUS = homogeneous, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function suggests to replace the missing value (0B)
   ;  located at coordinates [sample, line] within the 2-D input
   ;  positional parameter array by a suitable value established from an
   ;  analysis of its valid neighbors within a square sub-window of
   ;  (2 \times box_inc) + 1 pixels on the side.
   ;
   ;  ALGORITHM: This function assumes that the input positional parameter
   ;  array is of type BYTE, is dimensioned [512, 128], and contains MISR
   ;  RCCM data, where individual element values can be 0B (indicating
   ;  missing data), lie within the range [1B, 4B] (indicating valid data:
   ;  1B = cloudy with high confidence, 2B = cloudy with low confidence,
   ;  3B = clear with low confidence, and 4B = clear with high
   ;  confidence), or take on values larger than 250 (indicating
   ;  unobservable pixels, e.g., obscured by topography or outside the
   ;  swath of the instrument).
   ;  The function (1) inspects a sub-window of (2 \times box_inc) + 1 by
   ;  (2 \times box_inc) + 1 values, centred on the presumed missing
   ;  pixel, and possibly trimmed to exclude elements lying outside the
   ;  bounds of the array, (2) computes statistics on the values of the
   ;  valid neighbors within that sub-window, and (3) proposes a
   ;  reasonable non-null replacement value if at least min_num_required
   ;  of those neighbors are valid (i.e., are themselves not missing and
   ;  not flagged with values larger than 250).
   ;  The return code of the function indicates which decision rule has
   ;  been applied, and the suggested replacement value for the missing
   ;  pixel depends upon basic non-parametric statistics on the
   ;  frequencies of appearance among valid neighbors of the missing
   ;  value. Negative return codes refer to situations in which no
   ;  replacement value for the missing pixel is proposed. Let min, med
   ;  and max be the minimum, the median and the maximum values of the
   ;  valid neighbors of the presumed missing value within the sub-window:
   ;
   ;  *   If rc = -3: No replacement value is suggested because the pixel
   ;      at the specified line and sample position within the input
   ;      positional parameter array is not a missing value (0B).
   ;
   ;  *   If rc = -2: No replacement value is suggested as fewer than
   ;      min_num_required valid neighboring values (not counting those
   ;      that might fall outside the array) are available for analysis.
   ;
   ;  *   If rc = -1: No replacement value is suggested because the
   ;      optional keyword parameter HOMOGENEOUS is set and the neighbors
   ;      of the missing pixels in the current sub-window are not
   ;      homogeneous.
   ;
   ;  *   If rc = 0: All valid neighbors of the missing pixel have the
   ;      same value; then value is that same value.
   ;
   ;  *   If rc = 1: min = 1B, max = 2B, and med < 1.5; then value = 1B.
   ;
   ;  *   If rc = 2: min = 1B, max = 2B, and 1.5 \leq med; then
   ;      value = 2B.
   ;
   ;  *   If rc = 3: min = 2B, max = 3B, and med < 2.5; then value = 2B.
   ;
   ;  *   If rc = 4: min = 2B, max = 3B, and 2.5 \leq med; then
   ;      value = 3B.
   ;
   ;  *   If rc = 5: min = 3B, max = 4B, and med < 3.5; then value = 3B.
   ;
   ;  *   If rc = 6: min = 3B, max = 4B, and 3.5 \leq med; then
   ;      value = 4B.
   ;
   ;  *   If rc = 7: min = 1B, max = 3B, and med < 1.5; then value = 1B.
   ;
   ;  *   If rc = 8: min = 1B, max = 3B, and 1.5 \leq med < 2.5; then
   ;      value = 2B.
   ;
   ;  *   If rc = 9: min = 1B, max = 3B, and 2.5 \leq med; then
   ;      value = 3B.
   ;
   ;  *   If rc = 10: min = 2B, max = 4B, and med < 2.5; then value = 2B.
   ;
   ;  *   If rc = 11: min = 2B, max = 4B, and 2.5 \leq med < 3.5; then
   ;      value = 3B.
   ;
   ;  *   If rc = 12: min = 2B, max = 4B, and 3.5 \leq med; then
   ;      value = 4B.
   ;
   ;  *   If rc = 13: min = 1B, max = 4B, and med < 1.5; then value = 1B.
   ;
   ;  *   If rc = 14: min = 1B, max = 4B, and 1.5 \leq med < 2.5; then
   ;      value = 2B.
   ;
   ;  *   If rc = 15: min = 1B, max = 4B, and 2.5 \leq med < 3.5; then
   ;      value = 3B.
   ;
   ;  *   If rc = 16: min = 1B, max = 4B, and 3.5 \leq med; then
   ;      value = 4B.
   ;
   ;  *   If rc > 99: An exception condition has been detected while
   ;      executing this function.
   ;
   ;  SYNTAX:
   ;  rc = repl_box(array, sample, line, box_inc, min_num_required, $
   ;  value, HOMOGENEOUS = homogeneous, DEBUG = debug, $
   ;  EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   array {BYTE array} [I]: The 2-D input array containing missing
   ;      values.
   ;
   ;  *   sample {INT} [I]: The sample coordinate of the missing value in
   ;      the 2-D array.
   ;
   ;  *   line {INT} [I]: The line coordinate of the missing value in the
   ;      2-D array.
   ;
   ;  *   box_inc {INT} [I]: The parameter controlling the size of the
   ;      sub-window to consider (e.g., 1 for a 3 × 3 sub-window, 2 for a
   ;      5 × 5 sub-window), etc.
   ;
   ;  *   min_num_required {INT} [I]: The minimum number of valid
   ;      neighbors needed to choose the replacement value.
   ;
   ;  *   value {BYTE} [O]: The proposed replacement value for the missing
   ;      value.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   HOMOGENEOUS = homogeneous {INT} [I]: Flag to enable (1) or
   ;      skip (0) considering only cases where all neighbors take on
   ;      identical values.
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
   ;      returns a value in the range [0, 16], indicating which decision
   ;      rule has been applied, and the output keyword parameter
   ;      excpt_cond is set to a null string, if the optional input
   ;      keyword parameter DEBUG is set and if the optional output
   ;      keyword parameter EXCPT_COND is provided in the call. The output
   ;      positional parameter value contains the suggested replacement
   ;      value for the missing pixel, if one could be determined.
   ;      Negative return codes indicate that no replacement value can be
   ;      suggested.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code larger than 99, and the output
   ;      keyword parameter excpt_cond contains a message about the
   ;      exception condition encountered, if the optional input keyword
   ;      parameter DEBUG is set and if the optional output keyword
   ;      parameter EXCPT_COND is provided. The output positional
   ;      parameter value may be inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input positional parameter array is invalid.
   ;
   ;  *   Error 120: Input positional parameter sample is invalid.
   ;
   ;  *   Error 130: Input positional parameter line is invalid.
   ;
   ;  *   Error 140: Input positional parameter box_inc must be an
   ;      INTEGER.
   ;
   ;  *   Error 150: Input positional parameter box_inc must be smaller
   ;      than half the smallest dimension of array.
   ;
   ;  *   Error 160: Input positional parameter min_num_required must be
   ;      an INTEGER.
   ;
   ;  *   Error 200: An unforeseen condition occurred in function
   ;      repl_box.pro.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   is_array.pro
   ;
   ;  *   is_integer.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   percentile.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: This function is exclusively intended for use in the
   ;      specific context of replacing missing values in the MISR RCCM
   ;      data products, where the valid individual pixel values are
   ;      limited to [0B, 1B, 2B, 3B, 4B, 253B, 254B, 255B]. Other
   ;      functions in this package may add meaning to other intermediate
   ;      values, such as [253B, 254B], which are flags to indicate
   ;      unretrievable values.
   ;
   ;  EXAMPLES:
   ;
   ;      [See the outcome(s) generated by fix_rccm.pro]
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2019–02–04: Version 1.0 — Initial release, this function
   ;      supersedes the former functions repl_box3.pro and repl_box5.pro;
   ;      it implements the most current coding and documentation
   ;      standards.
   ;
   ;  *   2019–02–05: Version 1.1 — Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
   ;
   ;  *   2019–02–18: Version 2.00 — Implement new algorithm (multiple
   ;      scans of the input cloud mask) to minimize artifacts in the
   ;      filled areas.
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
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   ;  Initialize the output positional parameter(s):
   value = 0B

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 6
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): array, sample, line, box_inc, ' + $
            'min_num_required, value.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'array' is invalid:
      rc1 = is_array(array)
      rc2 = is_numeric(array)
      IF ((rc1 NE 1) OR (rc2 NE 1)) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter array is invalid.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'sample' is invalid:
      sz = SIZE(array, /DIMENSIONS)
      rc = is_numeric(sample)
      IF ((rc NE 1) OR (sample LT 0) OR (sample GT sz[0])) THEN BEGIN
         error_code = 120
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter sample is invalid.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'line' is invalid:
      rc = is_numeric(line)
      IF ((rc NE 1) OR (line LT 0) OR (line GT sz[1])) THEN BEGIN
         error_code = 130
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter line is invalid.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'box_inc' is invalid:
      rc = is_integer(box_inc)
      IF (rc NE 1) THEN BEGIN
         error_code = 140
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter box_inc is invalid.'
         RETURN, error_code
      ENDIF
      max_box_inc = MIN([sz[0], sz[1]]) / 10
      IF (box_inc GT max_box_inc / 2) THEN BEGIN
         error_code = 150
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter box_inc cannot exceed 1/2 of ' + $
            'the smallest dimension of array.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the positional
   ;  parameter 'min_num_required' is invalid:
      rc = is_integer(min_num_required)
      IF (rc NE 1) THEN BEGIN
         error_code = 160
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter min_num_required is invalid.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Return -3 to the calling routine if the specified pixel within array
   ;  is not a missing value (0B):
   IF (array[sample, line] NE 0B) THEN BEGIN
      RETURN, -3
   ENDIF

   ;  Define the box around the missing pixel at [sample, line], adjusting
   ;  the box boundaries near the borders of array, and count the number of
   ;  elements:
   sz = SIZE(array, /DIMENSIONS)
   left = sample - MIN([box_inc, sample])
   right = sample + MIN([box_inc, (sz[0] - 1) - sample])

   top = line - MIN([box_inc, line])
   bottom = line + MIN([box_inc, (sz[1] - 1) - line])

   pixcut = array[left:right, top:bottom]
   n_pixcut = N_ELEMENTS(pixcut)

   ;  Count the number of valid pixels within that box:
   jdx_val = WHERE(((pixcut GT 0B) AND (pixcut LT 5B)), cnt_jdx_val)

   ;  Return -2 to the calling routine if fewer than the required minimum
   ;  number of valid neighbors are available for analysis:
   IF (cnt_jdx_val LT min_num_required) THEN BEGIN
      RETURN, -2
   ENDIF

   ;  Compute the MIN, MAX, and the range of valid values among the neighbors:
   min_val = MIN(pixcut[jdx_val], MAX = max_val)
   rng_val = max_val - min_val

   ;  If all surrounding valid pixels have the same value (homogeneous
   ;  conditions), assign that value to the missing pixel:
   IF ((rng_val EQ 0) AND (min_val GT 0B)) THEN BEGIN
      value = pixcut[jdx_val[0]]
      RETURN, 0
   ENDIF

   ;  Abort the processing if the HOMOGENEOUS keyword is set and the neighbors'
   ;  values within the current sub-window are heterogeneous:
   IF (KEYWORD_SET(homogeneous)) THEN BEGIN
      RETURN, -1
   ENDIF ELSE BEGIN

   ;  Ensure that the positional parameter 'min_num_required' is at least 3
   ;  to enable the 'percentile.pro' function to estimate the median:
      min_num_required = MAX([3, FIX(min_num_required)])

   ;  Compute the median of the valid surrounding values:
      rc = percentile(0.5, pixcut[jdx_val], amin, amax, med_val, $
         AMISS = 0, ASORT = 0, COUNT = count, DOUBLE = 0, $
         DEBUG = debug, EXCPT_COND = excpt_cond)

      CASE 1 OF
         ((min_val EQ 1B) AND (max_val EQ 2B) AND (med_val LT 1.5)): BEGIN
            value = 1B
            RETURN, 1
         END
         ((min_val EQ 1B) AND (max_val EQ 2B) AND (med_val GE 1.5)): BEGIN
            value = 2B
            RETURN, 2
         END

         ((min_val EQ 2B) AND (max_val EQ 3B) AND (med_val LT 2.5)): BEGIN
            value = 2B
            RETURN, 3
         END
         ((min_val EQ 2B) AND (max_val EQ 3B) AND (med_val GE 2.5)): BEGIN
            value = 3B
            RETURN, 4
         END

         ((min_val EQ 3B) AND (max_val EQ 4B) AND (med_val LT 3.5)): BEGIN
            value = 3B
            RETURN, 5
         END
         ((min_val EQ 3B) AND (max_val EQ 4B) AND (med_val GE 3.5)): BEGIN
            value = 4B
            RETURN, 6
         END

         ((min_val EQ 1B) AND (max_val EQ 3B) AND (med_val LT 1.5)): BEGIN
            value = 1B
            RETURN, 7
         END
         ((min_val EQ 1B) AND (max_val EQ 3B) AND (med_val GE 1.5) AND $
            (med_val LT 2.5)): BEGIN
            value = 2B
            RETURN, 8
         END
         ((min_val EQ 1B) AND (max_val EQ 3B) AND (med_val GE 2.5)): BEGIN
            value = 3B
            RETURN, 9
         END

         ((min_val EQ 2B) AND (max_val EQ 4B) AND (med_val LT 2.5)): BEGIN
            value = 2B
            RETURN, 10
         END
         ((min_val EQ 2B) AND (max_val EQ 4B) AND (med_val GE 2.5) AND $
            (med_val LT 3.5)): BEGIN
            value = 3B
            RETURN, 11
         END
         ((min_val EQ 2B) AND (max_val EQ 4B) AND (med_val GE 3.5)): BEGIN
            value = 4B
            RETURN, 12
         END

         ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val LT 1.5)): BEGIN
            value = 1B
            RETURN, 13
         END
         ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 1.5) AND $
            (med_val LT 2.5)): BEGIN
            value = 2B
            RETURN, 14
         END
         ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 2.5) AND $
            (med_val LT 3.5)): BEGIN
            value = 3B
            RETURN, 15
         END
         ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 3.5)): BEGIN
            value = 4B
            RETURN, 16
         END
      ELSE: BEGIN
         PRINT, 'Unforeseen case: Check the size, type and values of ' + $
            'pixcut = ', pixcut
         RETURN, 200
         END
      ENDCASE

   ENDELSE

END
