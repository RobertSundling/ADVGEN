DECLARE SUB XPR (X&, Y&, F&, B&, St$)
DECLARE FUNCTION Find.Help! (Fil$)
DECLARE FUNCTION Get.KeyCode! ()
DEFLNG A-Z

REM $DYNAMIC
SUB CXPR (X, F, B, St$)

   Y = 40 - LEN(St$) \ 2
   XPR X, Y, F, B, St$

END SUB

REM $STATIC
SUB Draw.Box (Y1, X1, Y2, X2) STATIC

   W = X2 - X1 - 1
 
   XPR Y1, X1, 15, 7, "Û" + STRING$(W, 223)
   XPR Y1, X2, 8, 7, "Ü"
   FOR X = Y1 + 1 TO Y2 - 1
      XPR X, X1, 15, 7, "Û" + SPACE$(W)
      XPR X, X2, 8, 7, "Û"
      XPR X, X2 + 1, 8, 0, "°°"
   NEXT
 
   XPR Y2, X1, 15, 7, "ß"
   XPR Y2, X1 + 1, 8, 7, STRING$(W, 220) + "Û"
   XPR Y2, X2 + 1, 8, 0, "°°"
   XPR Y2 + 1, X1 + 2, 8, 0, STRING$(W + 2, 176)

END SUB

REM $DYNAMIC
SUB Draw.Rect (Y1, X1, Y2, X2, Label$, Cont$, X)

   XPR Y1, X1, 8, 7, "É" + STRING$(X2 - X1 - 1, 205)
   XPR Y1, X2, 15, 7, "¸"
   FOR X = Y1 + 1 TO Y2 - 1
      XPR X, X1, 8, 7, "º"
      XPR X, X2, 15, 7, "³"
   NEXT
   XPR Y2, X1, 8, 7, "Ó"
   XPR Y2, X1 + 1, 15, 7, STRING$(X2 - X1 - 1, 196) + "Ù"
   V = X2 - X1 - 2
   'XPR Y1 + 1, X1 + 2, 0, 7, LEFT$(Object(NO).Contents, V)
 
END SUB

SUB Editor (Text$, LeftCol, RightCol, KeyCode)
STATIC Insert

   Visible = 1
   '----- Find the cursor's size in scan lines
   DEF SEG = 0                          'Peek at low memory to see
   IF PEEK(&H463) = &HB4 THEN           'what type of moniter we have
      CsrSize = 12                      'Monochrome uses 13 scan lines
   ELSE                                 '   (numbered 0-12)
      CsrSize = 7                       'Color uses 8 (0 to 7)
   END IF

   IF Insert THEN
      LOCATE , , , CsrSize \ 2, CsrSize
   ELSE
      LOCATE , , , CsrSize - 1, CsrSize
   END IF

   Edit$ = SPACE$(RightCol - LeftCol + 1)    'Make a temporary string for
   LSET Edit$ = Text$                        'editing

   TxtPos = POS(0) - LeftCol + 1        'Get the cursor's posistion to see
   IF TxtPos < 1 THEN TxtPos = 1        '  where to begin editing
   IF TxtPos > LEN(Edit$) THEN TxtPos = LEN(Edit$)

   '----- Main loop for handling key presses.
   DO
      'Edit$ = PropCap$(Edit$)
      XPR CSRLIN, LeftCol, 15, 0, Edit$
     
      LOCATE , LeftCol + TxtPos - 1, 1  'Locate the cursor, turn it on

      'KeyCode = Get.KeyCode
      IF KeyCode > 0 THEN Ky$ = CHR$(KeyCode)

      '----- Branch according to the key pressed
      SELECT CASE KeyCode

         '----- Backspace
         CASE 8
            TxtPos = TxtPos - 1
            IF TxtPos > 0 THEN
               IF Insert THEN
                  MID$(Edit$, TxtPos) = MID$(Edit$, TxtPos + 1) + " "
               ELSE
                  MID$(Edit$, TxtPos) = " "
               END IF
            END IF

         '----- Enter or Escape
         CASE 13, 27
            EXIT DO

         '----- Letter keys
         CASE 32 TO 127
            IF Insert THEN
               IF TxtPos <> LEN(Edit$) THEN
                  MID$(Edit$, TxtPos) = Ky$ + LEFT$(MID$(Edit$, TxtPos), LEN(MID$(Edit$, TxtPos)) - 2)
               END IF
            ELSE
               MID$(Edit$, TxtPos) = Ky$
            END IF
            TxtPos = TxtPos + 1

         '----- Left arrow
         CASE -75
            TxtPos = TxtPos - 1

         '----- Right arrow
         CASE -77
            TxtPos = TxtPos + 1

         '----- Home key
         CASE -71
            TxtPos = 1

         '----- End key
         CASE -79
            TxtPos = LEN(RTRIM$(Edit$)) + 1

         '----- Insert key
         CASE -82
            Insert = NOT Insert
            IF Insert THEN
               LOCATE , , , CsrSize \ 2, CsrSize
            ELSE
               LOCATE , , , CsrSize - 1, CsrSize
            END IF

         '----- Delete key
         CASE -83
            MID$(Edit$, TxtPos) = MID$(Edit$, TxtPos + 1) + " "

         '----- CTRL-Left
         CASE -115
            IF TxtPox <> 1 THEN
               DO
                  FOR N = TxtPos - 2 TO 1 STEP -1
                     IF MID$(Edit$, N, 1) = " " THEN EXIT FOR
                  NEXT
                  TxtPos = N + 1
                  IF TxtPos = 0 THEN TxtPos = 1: EXIT DO
               LOOP UNTIL MID$(Edit$, TxtPos, 1) <> " "
               IF TxtPos > LEN(Edit$) THEN TxtPos = LEN(Edit$)
            END IF

         '----- CTRL-Right
         CASE -116
            AA = LEN(RTRIM$(Edit$))
            IF TxtPos < AA - 1 THEN
               DO
                  FOR N = TxtPos + 1 TO AA STEP 1
                     IF MID$(Edit$, N, 1) = " " THEN EXIT FOR
                  NEXT
                  TxtPos = N + 1
                  IF TxtPos >= AA THEN TxtPos = AA: EXIT DO
               LOOP UNTIL MID$(Edit$, TxtPos, 1) <> " "
               IF TxtPos > LEN(Edit$) THEN TxtPos = LEN(Edit$)
            END IF
                         
         CASE ELSE
            EXIT DO
      END SELECT

   IF TxtPos > LEN(Edit$) AND KeyCode > 31 AND KeyCode < 127 THEN
      Edit$ = LEFT$(Edit$, LEN(Edit$) - 1) + " "
      TxtPos = TxtPos - 1
     
      XPR CSRLIN, LeftCol, 15, 0, Edit$
   END IF

   IF TxtPos < 1 AND KeyCode = 8 THEN
      TxtPos = 1
   END IF

'If cursor is out of field, quit editing
   LOOP UNTIL TxtPos < 1 OR TxtPos > LEN(Edit$)

   Text$ = RTRIM$(Edit$)

   LOCATE , LeftCol + TxtPos - 1, 0
   XPR CSRLIN, LeftCol, 0, 7, Edit$
   Visible = 0

END SUB

SUB NiceBeep

   SOUND 500, .15: SOUND 2000, .3: SOUND 500, .15: SOUND 32767, .1

END SUB

SUB Restore.Screen

   IF Mouse THEN CALL MmCursorOff
   PCOPY 1, 0
   IF Mouse THEN CALL MmCursorOn

END SUB

SUB Save.Screen

   IF Mouse THEN CALL MmCursorOff
   PCOPY 0, 1
   IF Mouse THEN CALL MmCursorOn

END SUB

REM $STATIC
SUB XPR (X, Y, F, B, St$)

   IF Mouse THEN CALL MmCursorOff
   CALL CalcAttr(F, B, Attr)
   CALL XQPrintD(St$, X, Y, Attr, 0)
   IF Mouse THEN CALL MmCursorOn

END SUB

