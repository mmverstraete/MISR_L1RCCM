FUNCTION plot_rccm_miss, $
   in_fspec, $
   SEMI_LOG = semi_log, $
   OUT_FOLDER = out_folder, $
   VERBOSE = verbose, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function generates a time series plot of the number of
   ;  missing RCCM values found in the 9 cameras of all available ORBITS
   ;  for the MISR PATH and BLOCK specified in the file name in_fspec,
   ;  which is assumed to have been generated by the function
   ;  count_rccm_miss.pro.
   ;
   ;  ALGORITHM: This function reads the file provided by the input
   ;  positional parameter in_fspec and saves the time series plot of the
   ;  total number of missing RCCM values for each processed ORBIT. By
   ;  default, this plot is saved in the same folder as this input file.
   ;  If the optional keyword parameter OUT_FOLDER is specified, it
   ;  supersedes the default directory and the plot is saved in that
   ;  folder instead. If the optional keyword parameter SEMI_LOG is set,
   ;  then two plots are generated: one with a linear and one with a
   ;  logarithmic scale on the Y axis. In this latter case, the minimum
   ;  number of missing values for the purpose of plotting is set to 1.
   ;  The name(s) of the plot file(s) is(are) similar to the name of the
   ;  input file, and include an extra field to indicate whether the plot
   ;  is linear (_lin) or semi-logarithmic (_slog); the plot file
   ;  extension(s) is(are) .png.
   ;
   ;  SYNTAX: rc = plot_rccm_miss(in_fspec, $
   ;  SEMI_LOG = semi_log, OUT_FILE = out_file, $
   ;  VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   in_fspec {STRING} [I]: The full file specification (path and
   ;      name) of the file containing the results generated by the
   ;      function count_rccm_miss.pro.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   SEMI_LOG = semi_log {STRING} [I] (Default value: 0) Flag to
   ;      activate (1) or skip (0) generating the semi-logarithmic plot of
   ;      the time series.
   ;
   ;  *   OUT_FOLDER = out_folder {STRING} [I] (Default value: Set by
   ;      function
   ;      set_roots_vers.pro): The directory address of the folder
   ;      containing the output file(s).
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
   ;      provided in the call. The time series plot(s) of the missing
   ;      RCCM values is(are) saved in the default or specified folder.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered, if the optional input keyword parameter DEBUG is
   ;      set and if the optional output keyword parameter EXCPT_COND is
   ;      provided. The time series plot(s) of the missing RCCM values may
   ;      be inexistent, incomplete or incorrect.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: The input positional parameter in_fspec is not of
   ;      type STRING.
   ;
   ;  *   Error 300: The input file in_fspec exists but is unreadable.
   ;
   ;  *   Error 310: An exception condition occurred in function
   ;      is_readable.pro.
   ;
   ;  *   Error 320: The input file in_fspec does not exist.
   ;
   ;  *   Error 330: The input file in_fspec is not recognized.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_readable.pro
   ;
   ;  *   is_string.pro
   ;
   ;  *   set_year_range.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: This function assumes that the input data file in_fspec
   ;      was generated by the function count_rccm_miss.pro, and therefore
   ;      to the particular output format specified in that function.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> in_fspec = '~/MISR_HR/Outcomes/GM-P168-B110/
   ;         Num_RCCM_miss_P168-B110_2000-03-24_2018-05-29.txt'
   ;      IDL> semi_log = 1
   ;      IDL> rc = plot_rccm_miss(in_fspec, SEMI_LOG = semi_log, $
   ;         VERBOSE = verbose, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;      The linear time series plot has been saved in
   ;         ~/MISR_HR/Outcomes/GM-P168-B110/
   ;         Num_RCCM_miss_P168-B110_2000-03-24_2018-05-29_lin.png
   ;      The semi-logarithmic time series plot has been saved in
   ;         ~/MISR_HR/Outcomes/GM-P168-B110/
   ;         Num_RCCM_miss_P168-B110_2000-03-24_2018-05-29_slog.png
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2019–05–01: Version 1.0 — Initial release.
   ;
   ;  *   2019–05–06: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–05–07: Version 2.15 — Software version described in the
   ;      paper entitled _Replacing Missing Values in the Standard MISR
   ;      Radiometric Camera-by-Camera Cloud Mask (RCCM) Data Product_.
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
   IF (KEYWORD_SET(semi_log)) THEN semi_log = 1 ELSE semi_log = 0
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
      n_reqs = 1
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter: in_fspec.'
         RETURN, error_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'in_fspec' is is not of type STRING:
      res = is_string(in_fspec)
      IF (res NE 1) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': The input positional parameter in_fspec is not of type STRING.'
         RETURN, error_code
      ENDIF
   ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  file 'in_fspec' does not exist or is unreadable:
   rc = is_readable(in_fspec, DEBUG = debug, EXCPT_COND = excpt_cond)
   CASE rc OF
      1: BREAK
      0: BEGIN
            error_code = 300
            excpt_cond = 'Error ' + strstr(error_code) + ' in ' + $
               rout_name + ': The input file ' + in_fspec + $
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
               rout_name + ': The input file ' + in_fspec + ' does not exist.'
            RETURN, error_code
         END
      ELSE: BREAK
   ENDCASE

   ;  Retrieve the MISR Path, Block and date range from the file name:
   fn = FILE_BASENAME(in_fspec)
   parts = STRSPLIT(fn, '_', COUNT = n_parts, /EXTRACT)
   head = parts[0] + '_' + parts[1] + '_' + parts[2]
   IF ((head NE 'Num_RCCM_miss') OR (n_parts NE 6)) THEN BEGIN
      error_code = 330
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': The input file ' + in_fspec + ' is not recognized.'
      RETURN, error_code
   ENDIF
   pb = parts[3]
   from_date = parts[4]
   until_date = parts[5]
   parts = STRSPLIT(pb, '-', COUNT = n_parts, /EXTRACT)
   misr_path_str = parts[0]
   misr_block_str = parts[1]

   ;  Count the number of lines in the input file (minus 3 header lines):
   n_orbits = FILE_LINES(in_fspec) - 3

   ;  Open and read the input file:
   OPENR, in_unit, in_fspec, /GET_LUN

   ;  Define the arrays to be plotted:
   morb = LONARR(n_orbits)
   mdat = STRARR(n_orbits)
   mjul = DBLARR(n_orbits)
   miss = LONARR(n_orbits, 9)
   tot = LONARR(n_orbits)

   ;  Skip the 3 header lines:
   line = ''
   READF, in_unit, line
   READF, in_unit, line
   READF, in_unit, line

   ;  Loop over the input data lines:
   FOR i = 0, n_orbits - 1 DO BEGIN
      READF, in_unit, line
      parts = STRSPLIT(line, ' ', COUNT = n_parts, /EXTRACT)
      morb[i] = LONG(parts[1])
      mdat[i] = parts[2]
      mjul[i] = DOUBLE(parts[3])
      miss[i, 0] = LONG(parts[4])
      miss[i, 1] = LONG(parts[5])
      miss[i, 2] = LONG(parts[6])
      miss[i, 3] = LONG(parts[7])
      miss[i, 4] = LONG(parts[8])
      miss[i, 5] = LONG(parts[9])
      miss[i, 6] = LONG(parts[10])
      miss[i, 7] = LONG(parts[11])
      miss[i, 8] = LONG(parts[12])
      tot[i] = LONG(parts[13])
   ENDFOR

   ;  Close the input file:
   CLOSE, in_unit
   FREE_LUN, in_unit

   ;  Compute the total number of missing RCCM values in that time series:
   gran_tot = LONG(TOTAL(tot))

   ;  Define the range of dates to use for the time axis:
   res = set_year_range(mjul[0], mjul[n_orbits - 1], $
      DEBUG = debug, EXCPT_COND = excpt_cond)

   IF (semi_log) THEN BEGIN

   ;  Define a new output variable suitable for plotting in a semi-logarithmic
   ;  graph (where 0 is not allowed):
      new_tot = tot
      idx_low = WHERE(new_tot LE 1, cnt_low)
      IF (cnt_low GT 0) THEN BEGIN
         new_tot[idx_low] = 1
      ENDIF
      new_tot = ALOG10(new_tot)
   ENDIF

   ;  Generate the linear plot of the time series of missing values:
   plot_title = 'Number of missing RCCM values for ' + $
      misr_path_str + ' and ' + misr_block_str + $
      ' (Total: ' + strstr(gran_tot) + ')'
   my_plot = PLOT(mjul, $
      tot, $
      DIMENSIONS = [1200, 400], $
      /HISTOGRAM, $
      XRANGE = res, $
      XSTYLE = 1, $
      XTICKINTERVAL = 2, $
      XTICKUNITS = 'Years', $
      XTITLE = 'Date', $
      YTITLE = '# missing values', $
      TITLE = plot_title)

   plot_fname = FILE_BASENAME(in_fspec, '.txt') + '_lin.png'
   plot_fspec = FILE_DIRNAME(in_fspec, /MARK_DIRECTORY) + plot_fname
   my_plot.Save, plot_fspec
   my_plot.Close
   PRINT, 'The linear time series plot has been saved in ' + plot_fspec

   ;  Optionally generate the logarithmic plot of the time series of missing
   ;  values:
   IF (semi_log) THEN BEGIN
      plot_title = 'Number of missing RCCM values for ' + $
         misr_path_str + ' and ' + misr_block_str + $
         ' (Total: ' + strstr(gran_tot) + ')'
      my_plot = PLOT(mjul, $
         new_tot, $
         DIMENSIONS = [1200, 400], $
         /HISTOGRAM, $
         XRANGE = res, $
         XSTYLE = 1, $
         XTICKINTERVAL = 2, $
         XTICKUNITS = 'Years', $
         XTITLE = 'Date', $
         YTITLE = '$Log_{10}(# missing values)$', $
         TITLE = plot_title)

      plot_fname = FILE_BASENAME(in_fspec, '.txt') + '_slog.png'
      plot_fspec = FILE_DIRNAME(in_fspec, /MARK_DIRECTORY) + plot_fname
      my_plot.Save, plot_fspec
      my_plot.Close
      PRINT, 'The semi-logarithmic time series plot has been saved in ' + $
         plot_fspec
   ENDIF

   IF (verbose GT 0) THEN PRINT, 'Exiting ' + rout_name + '.'

   RETURN, return_code

END
