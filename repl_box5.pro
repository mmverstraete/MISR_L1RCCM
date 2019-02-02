FUNCTION repl_box5, $
   array, $
   sample, $
   line, $
   value, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function suggests to replace the missing value (0B) at
   ;  coordinates [sample, line] within the 2-D input array by a suitable
   ;  value established from an analysis of its up to 24 valid neighbors
   ;  within a box of 5 × 5 pixels; the return value of the function
   ;  indicates which rule has been applied.
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
   ;  The function (1) inspects a subwindow of 5 × 5 values centred on the
   ;  presumed missing pixel, thus containing up to 24 values (not
   ;  counting those lying outside the bounds of the main array), (2)
   ;  computes basic non-parametric statistics on the frequencies of
   ;  appearance among these up to 24 valid neighbors, and (3) proposes a
   ;  reasonable non-null replacement value if at least 1/4 of the
   ;  neighbors are valid (i.e., are themselves not missing and not
   ;  flagged with values larger than 250). The suggested replacement
   ;  value for the missing pixel depends on the statistics derived from
   ;  the valid (i.e., lying within the array, non-missing and
   ;  non-flagged) neighbors, and the numeric code rc returned by the
   ;  function is smaller than 99 to indicate which decision rule has been
   ;  applied to suggest the replacement value.
   ;  Let min, med and max be the minimum, the median and the maximum
   ;  values of the up to 24 valid neighbors of the presumed missing
   ;  value:
   ;
   ;  *   If rc = -2: The pixel at the specified line and sample position
   ;      within the input positional parameter array is not a missing
   ;      value (0B); the suggested replacement value is the original
   ;      value of that pixel.
   ;
   ;  *   If rc = -1: Less than 1/4 of the neighboring values (not
   ;      counting those that might fall outside the array) are available
   ;      for analysis; the suggested replacement value remains 0B (a
   ;      better estimate could be obtained using a larger window).
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
   ;  SYNTAX: rc = repl_box5(array, sample, line, value, $
   ;  DEBUG = debug, EXCPT_COND = excpt_cond)
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
   ;  *   value {BYTE} [O]: The proposed replacement value for the missing
   ;      value.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
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
   ;      returns a numeric code rc smaller than 99, and the output
   ;      keyword parameter excpt_cond is set to a null string, if the
   ;      optional input keyword parameter DEBUG is set and if the
   ;      optional output keyword parameter EXCPT_COND is provided in the
   ;      call. The output positional parameter value contains the
   ;      suggested replacement value for the missing value and the
   ;      returned code rc indicates which decision rule has been applied
   ;      to suggest the replacement value.
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
   ;  DEPENDENCIES:
   ;
   ;  *   is_array.pro
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
   ;      [See the outcome(s) generated by get_l1rccm.pro]
   ;
   ;  REFERENCES: None.
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
   ;  *   2019–01–30: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–02–02: Version 2.01 — Minor code update.
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
      n_reqs = 4
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): array, sample, line, value.'
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
   ENDIF

   ;  Return -2 to the calling routine if the specified pixel within array
   ;  is not a missing value (0B):
   IF (array[sample, line] NE 0B) THEN BEGIN
      value = array[sample, line]
      RETURN, -2
   ENDIF

   ;  Define the 5x5 box around the missing pixel at [sample, line], adjusting
   ;  the box boundaries near the borders of array:
   sz = SIZE(array, /DIMENSIONS)
   box_inc = 2
   left5 = sample - MIN([box_inc, sample])
   right5 = sample + MIN([box_inc, (sz[0] - 1) - sample])

   top5 = line - MIN([box_inc, line])
   bottom5 = line + MIN([box_inc, (sz[1] - 1) - line])

   pixcut5 = array[left5:right5, top5:bottom5]

   ;  Count the numbers of missing, flagged and valid pixels within that box:
   jdx_mis = WHERE(pixcut5 EQ 0B, cnt_jdx_mis)
   jdx_flg = WHERE(pixcut5 GT 4B, cnt_jdx_flg)
   jdx_val = WHERE(((pixcut5 GT 0B) AND (pixcut5 LT 5B)), cnt_jdx_val)

   ;  Return -1 to the calling routine if fewer than 1/4 of the surrounding
   ;  values in the 5x5 box are missing or flagged as edge or obscured: a
   ;  replacement value must be determined on the basis of a larger window:
   box_sid = (2 * box_inc) + 1
   box_siz = FLOOR(((box_sid * box_sid) - 1 - cnt_jdx_mis - cnt_jdx_flg) / 4.0)
   IF (cnt_jdx_val LE MAX([2, box_siz])) THEN BEGIN
      value = 0B
      RETURN, -1
   ENDIF

   ;  Compute basic statistics on the surrounding valid values:
   max_val = MAX(pixcut5[jdx_val])
   min_val = MIN(pixcut5[jdx_val])
   rng_val = max_val - min_val

   ;  If all surrounding valid pixels have the same value, assign that value to
   ;  the missing pixel:
   IF (rng_val EQ 0) THEN BEGIN
      value = pixcut5[jdx_val[0]]
      RETURN, 0
   ENDIF

   ;  Compute the median of the valid surrounding values:
   rc = percentile(0.5, pixcut5[jdx_val], amin, amax, med_val, $
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
      ((min_val EQ 1B) AND (max_val EQ 3B) AND (med_val GE 1.5) AND (med_val LT 2.5)): BEGIN
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
      ((min_val EQ 2B) AND (max_val EQ 4B) AND (med_val GE 2.5) AND (med_val LT 3.5)): BEGIN
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
      ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 1.5) AND (med_val LT 2.5)): BEGIN
         value = 2B
         RETURN, 14
      END
      ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 2.5) AND (med_val LT 3.5)): BEGIN
         value = 3B
         RETURN, 15
      END
      ((min_val EQ 1B) AND (max_val EQ 4B) AND (med_val GE 3.5)): BEGIN
         value = 4B
         RETURN, 16
      END
      ELSE: BEGIN
         print, 'Unforeseen case: Check the size, type and values of ' + $
            'pixcut5 = ', pixcut5
         RETURN, 16
      END
   ENDCASE

END
