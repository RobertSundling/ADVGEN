DECLARE SUB Draw.Box (Y1&, X1&, Y2&, X2&)
DECLARE SUB Event ()
DECLARE SUB Restore.Screen ()
DECLARE SUB Save.Screen ()
DECLARE SUB CXPR (X&, F&, B&, St$)
DECLARE SUB XPR (X&, Y&, F&, B&, St$)
DECLARE SUB NiceBeep ()
DECLARE SUB Follow ()
DECLARE SUB Delegate.One.Noun (X&, NumWords&, Found&, A$, Z&)
DECLARE SUB Delegate.Two.Noun (X&, NumWords&, Found&, A$, Z&)
DECLARE SUB First.Intro ()
DECLARE SUB Second.Intro ()
DECLARE SUB Do.Object (Num&, A$, VerbNum&)
DECLARE SUB Execute (N&, Object&, Verb&)
DECLARE SUB Default (Object&, Verb&)
DECLARE SUB Read.Object (Num&, A$)
DECLARE FUNCTION CommandN& (ObjNum&, VerbNum&)
DECLARE SUB Look.Object (Num&, A$)
DECLARE SUB Drop (Num&, A$)
DECLARE SUB Find (NumWords&, X&, Found&, Times&, Num&, Skip&)
DECLARE SUB Remove (Word$, X&, NumWords&)
DECLARE SUB PR (A$)
DECLARE SUB PR2 (A$)
DECLARE SUB Pause ()
DECLARE FUNCTION Edit$ ()
DECLARE SUB Quit.Game ()
DECLARE SUB Inventory ()
DECLARE FUNCTION VerbN& (X&)
DECLARE SUB Take (Num&, A$)
DECLARE SUB Parse (A$)
DECLARE FUNCTION StrTok$ (Srce$, Delim$)
DECLARE SUB Play.Game ()
DECLARE SUB Look.Long ()
DECLARE SUB Look.Short ()
DECLARE SUB DisplayText (X%)
DECLARE SUB Load ()
DECLARE SUB Introduction ()
'=============================================================================
' AGI Copyright (c) 1991 Robert J. Sundling, All Rights Reserved.
'-----------------------------------------------------------------------------
' Copyright (c) Robert J. Sundling.  This program is a CONFIDENTIAL,
' unpublished work of authorship created in 1991.  IT CONTAINS TRADE
' SECRETS WHICH ARE THE PROPERTY OF ROBERT J. SUNDLING.  ALL USE,
' DISCLOSURE, AND/OR REPRODUCTION NOT SPECIFICALLY AUTHORIZED BY
' ROBERT J. SUNDLING, IS PROHIBITED.  This program is protected
' under the copyright laws of the United States and foreign countries.
' All rights reserved.
'
'-----------------------------------------------------------------------------
' Program Information:
'-----------------------------------------------------------------------------
' [ Program Name  ]: Adventure Game Interpreter
' [ Version       ]: v1.00á
' [ Author        ]: Robert J. Sundling
' [ Date Started  ]: 04/21/91
' [ Date Finished ]: ??/??/??
'
'-----------------------------------------------------------------------------
' Revision History:
'-----------------------------------------------------------------------------
'  05/05/91 - Started program
'=============================================================================

DEFLNG A-Z

TYPE ScreenType
   Top            AS INTEGER
   Bottom         AS INTEGER
   WTop           AS INTEGER
   WBottom        AS INTEGER
END TYPE

'$INCLUDE: 'AG.QBI'
'$INCLUDE: 'AGI.QBI'

X& = (FRE(-1) - 4224) / 924 * .8

MaxRooms& = X& / 2
MaxObjects& = X& + 1000
MaxText& = X& * 2
MaxCreatures& = X& / 8 + 1000
MaxCommands& = X&
DIM Verbs(1 TO 32)                          AS VerbType
DIM Word(1 TO 130) AS STRING

''$DYNAMIC
'DIM Rooms(1 TO MaxRooms&)              AS RoomType
'DIM Objects(1000 TO MaxObjects&)       AS ObjectType
'DIM Objects2(1000 TO MaxObjects&)      AS ObjectType2
'DIM Text(1 TO MaxText&)                AS TextType
'DIM Verbs(1 TO 32)                     AS VerbType
'DIM Creatures1(1000 TO MaxCreatures&)  AS CreatureType1
'DIM Creatures2(1000 TO MaxCreatures&)  AS CreatureType2
'DIM Commands(1 TO MaxCommands&)        AS CommandType

DIM SHARED Verb(1 TO 4) AS STRING
DIM SHARED Adj(1 TO 4) AS STRING
DIM SHARED Noun(1 TO 4) AS STRING
DIM SHARED Prep(1 TO 4) AS STRING

NextObject = 1000
  NextRoom = 1
  NextText = 1
   NextCom = 1

'   ON ERROR GOTO ErrorLine

   Block.Misc = "C v1.00 Adventure Game File" + CHR$(13) + CHR$(10) + "AGC Copyright (c) 1991 Robert J. Sundling, All Rights Reserved." + CHR$(13) + CHR$(10) + CHR$(26)
   Block.Header = BLOCKHEADER

'$INCLUDE: 'VERBS.QBI'

RANDOMIZE TIMER

Normal = 3
Bright = 11
Highlight = 10
Background = 0
Prompt = 15

PLAY "MF"
File$ = COMMAND$ + ".ADV"
Introduction
Play.Game

FUNCTION CommandN (ObjNum, VerbNum)

   X = (VerbNum - 1) * 2 + 1
   V$ = MID$(Objects2(ObjNum).Commands, X, 2)
   CommandN = CVI(V$)

END FUNCTION

SUB Default (Object, Verb)

   SELECT CASE Verb
      CASE 3
         Objects(Object).Location = -1
      CASE 7
         Objects(Object).Location = Room
      CASE ELSE
   END SELECT

END SUB

SUB Delegate.One.Noun (X, NumWords, Found, A$, Z)
                  
   SELECT CASE Verb(1)
      CASE "TAKE"
         Take Found, A$
      CASE "DROP"
         Drop Found, A$
      CASE "LOOK"
         Look.Object Found, A$
      CASE "READ"
         Read.Object Found, A$
      CASE "CLOSE", "OPEN", "PUSH", "CLIMB"
         Do.Object Found, A$, Z
      CASE ELSE
         IF Verb(1) = "LOCK" OR Verb(1) = "UNLOCK" THEN
            COLOR Normal
            PR "With what?"
         ELSEIF Verb(1) = "ASK" THEN
            COLOR Normal
            PR "Ask about what?"
         ELSEIF Verb(1) = "GIVE" THEN
            COLOR Normal
            PR "Give it to whom?"
         ELSE
            COLOR Normal
            PR "BOB: Check your verbs.  Ya'll musta be missin' " + Verb(1) + "."
         END IF
   END SELECT

END SUB

SUB Delegate.Two.Noun (X, NumWords, Found, A$, Z)

   SELECT CASE Verb(1)
      CASE "TAKE", "DROP", "LOOK", "READ", "CLOSE", "OPEN", "PUSH", "CLIMB"
         COLOR Normal
         PR "I don't understand."
      CASE "ASK", "GIVE"
         Do.Object Found, A$, Z
      CASE ELSE
         IF Verb(1) = "LOCK" OR Verb(1) = "UNLOCK" THEN
            COLOR Normal
            PR "With what?"
         ELSE
            COLOR Normal
            PR "BOB: Check your verbs.  Ya'll musta be missin' " + Verb(1) + "."
         END IF
   END SELECT

END SUB

SUB DisplayText (X%)

   IF X% < 0 THEN X% = -X%: B = -1
   Y = X%
   DO WHILE Y <> 0
      X$ = RTRIM$(Text(Y).Text): CALL BusqLen(X$, SLen%)
      U$ = SPACE$(SLen%): CALL Busq(X$, U$)

      V$ = V$ + U$

      Y = Text(Y).NextRec
   LOOP

   DO
      A = INSTR(V$, CHR$(13))
      IF A THEN
         IF B = 0 AND A < LEN(V$) THEN B = -1: PR ""
         PR LEFT$(V$, A - 1)
         V$ = MID$(V$, A + 1)
      END IF
   LOOP WHILE A

END SUB

SUB Do.Object (Num, A$, VerbNum)

   IF Num = -1 THEN
      FOR Y = 1000 TO Block.NumObjects
         IF (Objects(Y).Location = Room OR (A$ <> "" AND Objects(Y).Location = -1)) AND (A$ = "" OR RTRIM$(UCASE$(Objects(Y).ObjectName)) = A$) AND Objects(Y).ShortDesc <> 0 AND (Objects(Y).Capabilities AND VerbN(VerbNum)) THEN
            IF Yes = 0 THEN
               Yes = -1
            END IF
            COLOR Bright
            PR2 "(" + LTRIM$(LCASE$(RTRIM$(Objects(Y).Adjective) + " " + RTRIM$(Objects(Y).ObjectName)))
            IF Objects(Y).Location = -1 THEN PR2 " [which you are carrying]"
            PR2 "): "
            COLOR Normal
            Do.Object Y, "", VerbNum
         END IF
      NEXT
      COLOR Normal
      IF Yes = 0 THEN
         IF A$ <> "" THEN PR "You can't do that to those."
         IF A$ = "" THEN PRINT "There is nothing here to do that to."
      END IF
      Found = -1
      EXIT SUB
   END IF

   COLOR Normal
   X = Num
   IF (Objects(X).Location = Room OR Objects(X).Location = -1) THEN
      IF Objects(X).Capabilities AND VerbN(VerbNum) THEN
         Execute CommandN(X, VerbNum), X, VerbNum
         EXIT SUB
      END IF
   END IF
   PR "You can't do that."

END SUB

SUB Drop (Num, A$)
  
   IF Num = -1 THEN
      FOR Y = 1000 TO Block.NumObjects
         IF Objects(Y).Location = -1 AND (Objects(Y).Capabilities AND VerbN(3)) AND (A$ = "" OR RTRIM$(UCASE$(Objects(Y).ObjectName)) = A$) THEN
            IF Yes = 0 THEN
               Yes = -1
            END IF
            COLOR Bright
            PR2 "(" + LTRIM$(LCASE$(RTRIM$(Objects(Y).Adjective) + " " + RTRIM$(Objects(Y).ObjectName) + "): "))
            COLOR Normal
            Drop Y, ""
         END IF
      NEXT
      COLOR Normal
      IF Yes = 0 THEN
         IF A$ <> "" THEN PR "You don't have those."
         IF A$ = "" THEN PR "You are carrying nothing."
      END IF
      Found = -1
      EXIT SUB
   END IF

   COLOR Bright
   X = Num
   IF Objects(X).Location = -1 THEN
      IF (Objects(X).Capabilities AND VerbN(3)) THEN
         COLOR Normal
        
         V = CommandN(X, 7)
         IF V THEN
            Execute V, X, 7
            EXIT SUB
         ELSE
            Objects(X).Location = Room
            PR "Dropped."
            TotalWeight = TotalWeight - Objects(X).Weight
            TotalSize = TotalSize - Objects(X).Size

'          PR "You drop the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))
         END IF

         EXIT SUB
      ELSE
         COLOR Normal
         PR "You cannot drop the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))
         EXIT SUB
      END IF
   ELSEIF Objects(X).Location <> -1 THEN
      COLOR Normal
      PR "You don't have the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))
      EXIT SUB
   END IF

   COLOR Normal
   PR "You can't drop the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))

END SUB

FUNCTION Edit$
STATIC Last AS STRING
  
   LOCATE , , 1
   St$ = ""
   DO
      K$ = INKEY$

      SELECT CASE K$
         CASE CHR$(32) TO CHR$(126)
            IF LEN(St$) < 253 THEN
               St$ = St$ + K$
               IF POS(X) < 78 THEN
                  PR2 K$
               ELSE
                  PR2 K$
                  PR2 CHR$(13)
               END IF
            END IF
         CASE CHR$(13)
            EXIT DO
         CASE CHR$(8)
            IF LEN(St$) THEN
               St$ = LEFT$(St$, LEN(St$) - 1)
               IF POS(X) > 1 THEN
                  PR2 CHR$(29) + " " + CHR$(29)
               ELSE
                  LOCATE CSRLIN - 1, 78: PR2 " " + CHR$(29)
               END IF
            END IF
         CASE CHR$(0) + CHR$(&H3D)
            IF LEN(St$) = 0 THEN
               St$ = Last: PR2 St$
            ELSE
               PR2 MID$(Last, LEN(St$) + 1)
               St$ = St$ + MID$(Last, LEN(St$) + 1)
            END IF
         CASE CHR$(0) + CHR$(&H48) ' Up
            IF LEN(St$) = 0 THEN St$ = "Go north.": PR2 St$: EXIT DO
         CASE CHR$(0) + CHR$(&H50) ' Down
            IF LEN(St$) = 0 THEN St$ = "Go south.": PR2 St$: EXIT DO
         CASE CHR$(0) + CHR$(&H4B) ' Left
            IF LEN(St$) = 0 THEN St$ = "Go west.": PR2 St$: EXIT DO
         CASE CHR$(0) + CHR$(&H4D) ' Right
            IF LEN(St$) = 0 THEN St$ = "Go east.": PR2 St$: EXIT DO
         CASE ELSE
            IF LEN(K$) THEN NiceBeep  'SOUND 2000, .5: SOUND 500, .25: SOUND 2000, .5
      END SELECT
   LOOP
   LOCATE , , 0
   PR ""
   Last = St$
   Edit$ = St$

END FUNCTION

DEFINT X
SUB Event

   FOR X = 1 TO Block.NumEvents
      IF Events(X).Enabled THEN
         Nu = Events(X).Commands
         Execute Nu, 0, 0
      END IF
   NEXT

END SUB

SUB Execute (N, Object, Verb)
 
   ABORT = 0
   Y = N
   DO WHILE Y <> 0
      X$ = RTRIM$(Commands(Y).Commands)
      V$ = V$ + X$
      Y = Commands(Y).NextRec
   LOOP

'CONST C.IFLOC = "A"
'CONST C.MOVE = "B"
'CONST C.DISPLAY = "C"
'CONST C.LOCK = "D"
'CONST C.UNLOCK = "E"
'CONST C.OPEN = "F"
'CONST C.CLOSE = "G"
'CONST C.DEFAULT = "H"
'CONST C.CREATURE = "I"
'CONST C.POINTS = "J"
      
   DO
      A$ = LEFT$(V$, 1)
      V$ = MID$(V$, 2)

      SELECT CASE A$
         CASE C.STARTEVENT
            X = CVI(MID$(V$, 1, 2))
            V$ = MID$(V$, 3)
            Events(X).Enabled = -1

         CASE C.KILLEVENT
            X = CVI(MID$(V$, 1, 2))
            V$ = MID$(V$, 3)
            Events(X).Enabled = 0

         CASE C.ADDEXIT
            D$ = MID$(V$, 1, 1)
            X = CVI(MID$(V$, 2, 2)) ' = oops fuck
            Y = CVI(MID$(V$, 4, 2)) ' = this is screwed
            V$ = MID$(V$, 6)

            SELECT CASE D$
               CASE "N": Rooms(Y).North = X
               CASE "S": Rooms(Y).South = X
               CASE "W": Rooms(Y).West = X
               CASE "E": Rooms(Y).East = X
               CASE ELSE
            END SELECT

         CASE C.STOP
            ABORT = -1
            EXIT SUB
         CASE C.IFLOC
            X = CVI(MID$(V$, 1, 2)) ' = thing being tested
            Y = CVI(MID$(V$, 3, 2)) ' = is it equal to this?
            Z = CVI(MID$(V$, 5, 2)) ' = commands to execute
            V$ = MID$(V$, 7)

            IF Y = -2 THEN Y = Room

            IF X = -1 THEN
               IF Room = Y THEN
                  Execute Z, Object, Verb
                  IF ABORT THEN EXIT SUB
               END IF
            ELSE
               IF Objects(X).Location = Y THEN
                  Execute Z, Object, Verb
                  IF ABORT THEN EXIT SUB
               END IF
            END IF

         CASE C.IFLOCNOT
            X = CVI(MID$(V$, 1, 2)) ' = thing being tested
            Y = CVI(MID$(V$, 3, 2)) ' = is it equal to this?
            Z = CVI(MID$(V$, 5, 2)) ' = commands to execute
            V$ = MID$(V$, 7)

            IF Y = -2 THEN Y = Room

            IF X = -1 THEN
               IF Room <> Y THEN
                  Execute Z, Object, Verb
                  IF ABORT THEN EXIT SUB
               END IF
            ELSE
               IF Objects(X).Location <> Y THEN
                  Execute Z, Object, Verb
                  IF ABORT THEN EXIT SUB
               END IF
            END IF
        
         CASE C.MOVE, C.CREATURE
            X = CVI(MID$(V$, 1, 2)) ' = what's being moved
            Y = CVI(MID$(V$, 3, 2)) ' = where being moved to
            V$ = MID$(V$, 5)

            IF X >= 1000 AND X <= 1998 THEN
               IF Objects(X).Location = -1 THEN
                  TotalWeight = TotalWeight - Objects(X).Weight
                  TotalSize = TotalSize - Objects(X).Size
               END IF

               IF Y = -2 THEN
                  Objects(X).Location = Room
               ELSEIF Y <> -1 THEN
                  Objects(X).Location = Y
               ELSE
                  IF TotalWeight + Objects(X).Weight <= 99 AND TotalSize + Objects(X).Size <= 99 THEN
                     Objects(X).Location = -1
                     TotalWeight = TotalWeight + Objects(X).Weight
                     TotalSize = TotalSize + Objects(X).Size
                  ELSE
                     Objects(X).Location = Room
                  END IF
               END IF
            ELSEIF X = -1 THEN
               Room = Y
               PR ""
               Look.Long
            END IF

         CASE C.DISPLAY
            IF Blank THEN Blank = 0: PR ""
            X = CVI(MID$(V$, 1, 2)) ' = what's being displayed
            V$ = MID$(V$, 3)
            DisplayText X
           
            'CASE "LOCK"
            '   S$ = S$ + C.LOCK
            '   X = GetNum(1000, MaxObjects&, "object", L$)
            '   S$ = S$ + MKI$(X)
            'CASE "UNLOCK"
            '   S$ = S$ + C.UNLOCK
            '   X = GetNum(1000, MaxObjects&, "object", L$)
            '   S$ = S$ + MKI$(X)
            'CASE "OPEN"
            '   S$ = S$ + C.OPEN
            '   X = GetNum(1000, MaxObjects&, "object", L$)
            '   S$ = S$ + MKI$(X)
            'CASE "CLOSE"
            '   S$ = S$ + C.CLOSE
            '   X = GetNum(1000, MaxObjects&, "object", L$)
            '   S$ = S$ + MKI$(X)
         CASE C.IFABOUT
            X$ = LEFT$(V$, 1)       ' = Is it a number or a string?
            V$ = MID$(V$, 2)

            SELECT CASE X$
               CASE "N"
               CASE "S"
                  Length = ASC(LEFT$(V$, 1))
                  V$ = MID$(V$, 2)
                  Word$ = LEFT$(V$, Length)
                  V$ = MID$(V$, Length + 1)

                  Z = CVI(LEFT$(V$, 2))
                  V$ = MID$(V$, 2)

                  IF LTRIM$(RTRIM$(UCASE$(Noun(2)))) = LTRIM$(RTRIM$(UCASE$(Word$))) THEN
                     Execute Z, Object, Verb
                     IF ABORT THEN EXIT SUB
                  END IF
               CASE ELSE
            END SELECT

         CASE C.DEFAULT
            Default Object, Verb
            'CASE "DEFAULT"
            '   S$ = S$ + C.DEFAULT
            'CASE "CREATURE_MOVE", "CREATURE"
            '   S$ = S$ + C.CREATURE
            '   X = GetNum(-2, 2998, "CREATURE_MOVE", L$)
            '   A$ = StrTok$("", Delimiters$)
            '   Y = GetNum(-2, 2998, "CREATURE_MOVE", L$)
            '   S$ = S$ + MKI$(X) + MKI$(Y)
         CASE C.POINTS
            X = CVI(MID$(V$, 1, 2)) ' = how many points?
            V$ = MID$(V$, 3)
            IF (Objects(Object).Status AND VerbN(Verb)) = 0 THEN
               Objects(Object).Status = Objects(Object).Status OR VerbN(Verb)
               Points = Points + X
            END IF
         CASE ELSE
      END SELECT
   LOOP WHILE LEN(V$)

END SUB

DEFLNG X
SUB Find (NumWords, X, Found, Times, Num, Skip)
     
   Maybe = 0: Found = 0: Times = 0: Plus = 0

   FOR Y = 1000 TO Block.NumObjects
      IF Word(X) = UCASE$(RTRIM$(Objects(Y).ObjectName)) OR Word(X) = UCASE$(RTRIM$(Objects2(Y).Synonym1)) OR Word(X) = UCASE$(RTRIM$(Objects2(Y).Synonym2)) THEN
         IF (Objects(Y).Location = Room AND Verb(1) <> "DROP") OR (Objects(Y).Location = -1 AND Verb(1) <> "TAKE") THEN
            Times = Times + 1
            Adj(Num) = RTRIM$(UCASE$(Objects(Y).Adjective))
            Noun(Num) = RTRIM$(UCASE$(Objects(Y).ObjectName))
            Found = Y
            Plus = 1
         ELSEIF Skip = 0 AND (Objects(Y).Location = Room OR Objects(Y).Location = -1) THEN
            Adj(Num) = RTRIM$(UCASE$(Objects(Y).Adjective))
            Noun(Num) = RTRIM$(UCASE$(Objects(Y).ObjectName))
            Maybe = Y
            Plus = 1
         END IF
      END IF

      IF Word(X) = UCASE$(RTRIM$(Objects(Y).Adjective)) THEN
         IF Word(X + 1) = UCASE$(RTRIM$(Objects(Y).ObjectName)) OR Word(X + 1) = UCASE$(RTRIM$(Objects2(Y).Synonym1)) OR Word(X + 1) = UCASE$(RTRIM$(Objects2(Y).Synonym2)) THEN
            IF (Objects(Y).Location = Room AND Verb(1) <> "DROP") OR (Objects(Y).Location = -1 AND Verb(1) <> "TAKE") THEN
               Adj(Num) = UCASE$(RTRIM$(Objects(Y).Adjective))
               Noun(Num) = UCASE$(RTRIM$(Objects(Y).ObjectName))
               Found = Y
               Plus = 2
            ELSEIF Skip = 0 AND (Objects(Y).Location = Room OR Objects(Y).Location = -1) THEN
               Adj(Num) = UCASE$(RTRIM$(Objects(Y).Adjective))
               Noun(Num) = UCASE$(RTRIM$(Objects(Y).ObjectName))
               Maybe = Y
               Plus = 2
            END IF
         END IF
      END IF
   NEXT

   IF Times > 1 THEN
      IF Skip = 0 THEN
         COLOR Normal
         PR2 "Which " + LCASE$(Word(X)) + ":"
         FOR Y = 1000 TO Block.NumObjects
            IF Word(X) = UCASE$(RTRIM$(Objects(Y).ObjectName)) THEN
               IF (Objects(Y).Location = Room AND Verb(1) <> "DROP") OR (Objects(Y).Location = -1 AND Verb(1) <> "TAKE") THEN
                  T2 = T2 + 1
                  IF T2 <> Times THEN
                     PR2 " the " + LCASE$(RTRIM$(Objects(Y).Adjective)) + " " + LCASE$(RTRIM$(Objects(Y).ObjectName)) + ","
                  ELSE
                     PR " or the " + LCASE$(RTRIM$(Objects(Y).Adjective)) + " " + LCASE$(RTRIM$(Objects(Y).ObjectName)) + "?"
                     EXIT FOR
                  END IF
               END IF
            END IF
         NEXT
      END IF
     
      Found = -1
      EXIT SUB
   END IF
       
   IF Found = 0 THEN
      Found = Maybe
   END IF

   X = X + Plus

END SUB

SUB First.Intro
  
   Y = Block.Introduction
   DO WHILE Y <> 0
      X$ = RTRIM$(Text(Y).Text): CALL BusqLen(X$, SLen%)
      U$ = SPACE$(SLen%): CALL Busq(X$, U$)

      V$ = V$ + U$

      Y = Text(Y).NextRec
   LOOP

   A = INSTR(V$, CHR$(13))
   G$ = LEFT$(V$, A - 1)
   V$ = MID$(V$, A + 1)
  
   A = INSTR(V$, CHR$(13))
   A$ = "by " + LEFT$(V$, A - 1)
   V$ = MID$(V$, A + 1)

      Draw.Box 10, 19, 16, 60
      CXPR 12, 0, 7, "Welcome To"
      CXPR 13, 15, 7, G$
      CXPR 14, 8, 7, A$
  
      CXPR 1, 0, 3, "ADVGEN and AGI Copyright (c) 1991 Robert J. Sundling, All Rights Reserved"
     
      FOR X = 1 TO 8
         PLAY "P16": 'COLOR 7, 0: PRINT
      NEXT

      PLAY "T150P1T255"

      FOR X = 1 TO 11
         PLAY "P16": 'COLOR 7, 0: PRINT
      NEXT

END SUB

SUB Follow
     
   FOR X = 1000 TO Block.NumObjects
      IF Objects(X).Follow = -1 AND Objects(X).Location = OldRoom THEN
         Objects(X).Location = Room
      END IF
   NEXT

END SUB

SUB Introduction
  
   WIDTH 80, 25
   CLS
   LOCATE , , 0

   DEF SEG = &HB800: CLS : BLOAD "AGI.INT", 0
        
   XPR 25, 1, 14, 5, SPACE$(80)
   CXPR 25, 14, 5, "Please Wait.  (Loading adventure game " + CHR$(34) + File$ + CHR$(34) + "...)"
     
   PLAY "T32P1T255"
   Load
   PLAY "P16"
  
   IF Block.Introduction THEN
      XPR 25, 1, 0, 3, SPACE$(80)
     
      XPR 1, 1, 0, 3, SPACE$(80)
      XPR 2, 1, 9, 1, STRING$(1840, 177)
      First.Intro
   END IF

   SCREEN 0
   WIDTH 80, 25

   Sline.Top = 1:     Sline.WTop = 2
   Sline.Bottom = 25: Sline.WBottom = 24

   VIEW PRINT Sline.Top TO Sline.Bottom
   COLOR Bright, Background: CLS
   COLOR 0, 3: PRINT SPACE$(80)
   LOCATE Sline.Bottom, 1
   PRINT SPACE$(80);
   LOCATE Sline.Bottom, 1
   PRINT "  Some commands: LOOK, INVENTORY, GET/TAKE, DROP/LEAVE, NORTH/SOUTH/EAST/WEST";
   COLOR Bright, Background: LOCATE Sline.WTop, 1
   VIEW PRINT Sline.WTop TO Sline.WBottom

   IF Block.Introduction THEN
      Second.Intro
   END IF

END SUB

SUB Inventory

   PR ""
   COLOR Bright
   'PR "Weight Capacity: " + LTRIM$(STR$(INT((99 - TotalWeight)))) + "%"
   'PR "  Size Capacity: " + LTRIM$(STR$(INT((99 - TotalSize)))) + "%"
   'PR ""
   PR "You have:"
   COLOR Normal
   PR2 "  No tea."
  
   FOR X = 1000 TO Block.NumObjects
      IF Objects(X).Location = -1 THEN
         PR ""
         A$ = LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective)) + " " + LCASE$(RTRIM$(Objects(X).ObjectName))) + "."
         IF UCASE$(RIGHT$(A$, 2)) <> "S." AND UCASE$(RIGHT$(A$, 3)) <> "SS." THEN
            IF INSTR("AEIOU", UCASE$(LEFT$(A$, 1))) = 0 THEN
               PR2 "  A " + A$
            ELSE
               PR2 "  An " + A$
            END IF
         ELSE
            PR2 "  " + UCASE$(LEFT$(A$, 1)) + MID$(A$, 2)
         END IF
         Found = -1
      END IF
   NEXT

   IF Found = 0 THEN PR2 "  (And nothing else, either...)"
   PR ""

END SUB

SUB Load

   OPEN File$ FOR RANDOM AS #1 LEN = 132

      GET #1, 1, Block
     
      DIM Commands(1 TO Block.NumCommands)        AS CommandType
      DIM Rooms(1 TO Block.NumRooms)              AS RoomType
      DIM Objects(1000 TO Block.NumObjects)       AS ObjectType
      DIM Objects2(1000 TO Block.NumObjects)      AS ObjectType2
      DIM Text(1 TO Block.NumText)                AS TextType
      DIM Events(1 TO Block.NumEvents)            AS EventType
      DIM Temp                                    AS TextType

      R = 2
      DO UNTIL R > LOF(1) \ 132
         GET #1, R, Temp

         SELECT CASE Temp.Header
            CASE COMMANDHEADER
               GET #1, R, Commands(Temp.Number)
            CASE ROOMHEADER
               GET #1, R, Rooms(Temp.Number)
            CASE OBJECTHEADER
               GET #1, R, Objects(Temp.Number)
            CASE OBJECTHEADER2
               GET #1, R, Objects2(Temp.Number)
            CASE VERBHEADER
               GET #1, R, Verbs(Temp.Number)
            CASE TEXTHEADER
               GET #1, R, Text(Temp.Number)
            CASE EVENTHEADER
               GET #1, R, Events(Temp.Number)
            CASE ELSE
               END
         END SELECT
         R = R + 1
      LOOP
   CLOSE #1

END SUB

SUB Look.Long
     
   COLOR Bright
   DisplayText -Rooms(Room).ShortDesc
  
   COLOR Normal
   Event

   IF Rooms(Room).LookCommands = 0 THEN
      PR ""
      DisplayText -Rooms(Room).LongDesc
   ELSE
      V = Rooms(Room).LookCommands
      Execute V, 0, 0
   END IF
  
   PR ""
   PR2 "Exits:"
   COLOR Bright
   IF Rooms(Room).North THEN Z = -1: PR2 " North"
   IF Rooms(Room).South THEN Z = -1: PR2 " South"
   IF Rooms(Room).East THEN Z = -1: PR2 " East"
   IF Rooms(Room).West THEN Z = -1: PR2 " West"
   IF Z = 0 THEN PR " None." ELSE PR "."
   COLOR Normal

   FOR X = 1000 TO Block.NumObjects
      IF Objects(X).Location = Room THEN
         IF Objects(X).ShortDesc THEN
            IF Y = 0 THEN PR "": Y = -1
            DisplayText -Objects(X).ShortDesc
            V = -1
         ELSEIF Objects(X).ShortCommands THEN
            IF Y = 0 THEN Blank = -1: Y = -1
            V = Objects(X).ShortCommands
            Execute V, X, 0
            IF Blank THEN Y = 0: Blank = 0
            V = -1
         END IF
      END IF
   NEXT

END SUB

SUB Look.Object (Num, A$)
  
   IF Num = -1 THEN
      FOR Y = 1000 TO Block.NumObjects
         IF (Objects(Y).Location = Room OR (A$ <> "" AND Objects(Y).Location = -1)) AND (A$ = "" OR RTRIM$(UCASE$(Objects(Y).ObjectName)) = A$) AND Objects(Y).ShortDesc <> 0 THEN
            IF Yes = 0 THEN
               Yes = -1
            END IF
            COLOR Bright
            PR2 "(" + LTRIM$(LCASE$(RTRIM$(Objects(Y).Adjective) + " " + RTRIM$(Objects(Y).ObjectName)))
            IF Objects(Y).Location = -1 THEN PR2 " [which you are carrying]"
            PR2 "): "
            COLOR Normal
            Look.Object Y, ""
         END IF
      NEXT
      COLOR Normal
      IF Yes = 0 THEN PR "You can't look at that now."
      Found = -1
      EXIT SUB
   END IF

   COLOR Normal
   X = Num
   IF (Objects(X).Location = Room OR Objects(X).Location = -1) THEN
      IF Objects(X).LongDesc = 0 THEN
         V = CommandN(X, 9)
         IF V THEN
            Execute V, X, 9
            EXIT SUB
         END IF
      ELSE
         DisplayText Objects(X).LongDesc
         EXIT SUB
      END IF
   END IF
   PR "You can't look at that."

END SUB

SUB Look.Short
  
   COLOR Highlight: DisplayText Rooms(Room).ShortDesc
   COLOR Bright: PR ""
   FOR X = 1000 TO Block.NumObjects
      IF Objects(X).Location = Room AND Objects(X).ShortDesc THEN
         DisplayText Objects(X).ShortDesc
         V = -1
      END IF
   NEXT
   IF V THEN PR ""

END SUB

SUB Parse (A$)
  
   COLOR Normal

   Turns = Turns + 1

   FOR X% = 1 TO 127
      Word(X%) = ""
   NEXT

   FOR X% = 1 TO 4
      Noun(X%) = ""
      Verb(X%) = ""
      Prep(X%) = ""
      Adj(X%) = ""
   NEXT

   A$ = LTRIM$(RTRIM$(UCASE$(A$)))

   IF A$ = "" THEN
      COLOR Normal
      PR "You can say more than that!"
      Turns = Turns - 1
      EXIT SUB
   END IF

   Verb1 = ""
   Adj1 = ""
   Noun1 = ""
   Prep = ""
   Noun2 = ""
   Adj2 = ""

   Delim$ = CHR$(34) + " ,.<>/?;:[]{}-=_+\|`~!@#$%^&*()"
   
   NumWords = 1
   Word(NumWords) = StrTok$(A$, Delim$)
   DO
      IF Word(NumWords) = "" THEN NumWords = NumWords - 1: EXIT DO
      NumWords = NumWords + 1
      Word(NumWords) = StrTok$("", Delim$)
      IF Word(NumWords) = "EVERYTHING" THEN Word(NumWords) = "ALL"
      IF INSTR(" PLEASE NOW ", " " + Word(NumWords) + " ") THEN
         NumWords = NumWords - 1
      END IF
   LOOP

   FOR X = 1 TO NumWords
      SELECT CASE Word(X)
         CASE "FUCK", "SHIT", "DAMN", "ASS", "ASSHOLE", "PUSSY", "COCK"
            PR "Watch that language, you little prick."
            EXIT SUB
         CASE ELSE
      END SELECT
   NEXT
  
   IF NumWords = 1 THEN
      SELECT CASE Word(1)
         CASE "DUH"
            PR "Duh yourself!"
            EXIT SUB
         CASE "SCUM"
            PR "Get a life, you pagan."
            EXIT SUB
         CASE "OOPS"
            PR "It's okay, everything'll be fine."
            EXIT SUB
         CASE "SORRY"
            PR "'Tis okay.  No need to say sorry."
            EXIT SUB
         CASE "HI"
            PR "Hello."
            EXIT SUB
         CASE "HELLO"
            PR "Hi."
            EXIT SUB
         CASE "HOLA"
            PR "I don't speak Spanish."
            EXIT SUB
         CASE "CIAO"
            PR "Hey!  Is that you?"
            EXIT SUB
         CASE "LOOK", "L"
            Look.Long
            EXIT SUB
         CASE "INVENTORY", "I"
            Inventory
            EXIT SUB
         CASE "QUIT", "Q"
            Quit.Game
            EXIT SUB
         CASE "CLS"
            CLS 2
            EXIT SUB
         CASE "TIME", "DATE"
            COLOR Normal
            X$ = TIME$
            IF VAL(X$) > 12 THEN
               V$ = SPACE$(2)
               RSET V$ = LTRIM$(STR$(VAL(X$) - 12))
               MID$(X$, 1, 2) = V$
            END IF
            X$ = LTRIM$(LEFT$(X$, 5))
            PR "It is " + X$ + " on " + DATE$ + "."
            EXIT SUB
         CASE ELSE
      END SELECT
   END IF

   FOR X = 1 TO NumWords
       
      IF Verb(1) = "" THEN     ' We are looking for a verb.
         IF Word(X) = "PICK" AND Word(X + 1) = "UP" THEN
            Word(X) = "TAKE"
            FOR Y = X + 1 TO NumWords - 1
               Word(Y) = Word(Y + 1)
            NEXT
            NumWords = NumWords - 1
         END IF

         IF Word(X) = "GET" THEN Word(X) = "TAKE"
         IF Word(X) = "TOUCH" THEN Word(X) = "PUSH"
         IF Word(X) = "PRESS" THEN Word(X) = "PUSH"
         IF Word(X) = "LEAVE" THEN Word(X) = "DROP"
         IF Word(X) = "EXAMINE" THEN Word(X) = "LOOK"

         IF Word(X) = "DON'T" OR Word(X) = "DONT" THEN
            X = X + 1
            IF Word(X) = "GET" THEN Word(X) = "TAKE"
            IF Word(X) = "TOUCH" THEN Word(X) = "PUSH"
            IF Word(X) = "PRESS" THEN Word(X) = "PUSH"
            IF Word(X) = "LEAVE" THEN Word(X) = "DROP"
            IF Word(X) = "EXAMINE" THEN Word(X) = "LOOK"
            X = X - 1
           
            FOR Z = 1 TO NumVerbs
               IF RTRIM$(UCASE$(Verbs(Z).VerbName)) = Word(X + 1) THEN
                  COLOR 3
                  IF RTRIM$(UCASE$(Verbs(Z).VerbName)) = "TAKE" THEN
                     PR "Not taken."
                  ELSEIF RTRIM$(UCASE$(Verbs(Z).VerbName)) = "LOOK" THEN
                     PR "That won't help."
                  ELSE
                     PR "Not done."
                  END IF

                  EXIT SUB
               END IF
            NEXT

            IF Word(X + 1) = "GO" THEN
               PR "Not done."
               EXIT SUB
            END IF
         END IF

         IF Word(X) = "GO" THEN
            Remove "IN", X, NumWords
            Remove "INTO", X, NumWords
            Remove "TO", X, NumWords
            Remove "THE", X, NumWords

            SELECT CASE Word(X + 1)
               CASE "NORTH", "SOUTH", "EAST", "WEST"
                  Verb(1) = Word(X + 1)
                  GOTO PastIf
               CASE ELSE
                  IF Rooms(Room).North THEN
                     IF UCASE$(RTRIM$(Rooms(Rooms(Room).North).RoomName)) = Word(X + 1) THEN
                        Verb(1) = "NORTH"
                     ELSEIF UCASE$(RTRIM$(Rooms(Rooms(Room).North).Adjective)) = Word(X + 1) AND UCASE$(RTRIM$(Rooms(Rooms(Room).North).RoomName)) = Word(X + 2) THEN
                        Verb(1) = "NORTH"
                     END IF
                  END IF
                 
                  IF Rooms(Room).South THEN
                     IF UCASE$(RTRIM$(Rooms(Rooms(Room).South).RoomName)) = Word(X + 1) THEN
                        Verb(1) = "SOUTH"
                     ELSEIF UCASE$(RTRIM$(Rooms(Rooms(Room).South).Adjective)) = Word(X + 1) AND UCASE$(RTRIM$(Rooms(Rooms(Room).South).RoomName)) = Word(X + 2) THEN
                        Verb(1) = "SOUTH"
                     END IF
                  END IF

                  IF Rooms(Room).West THEN
                     IF UCASE$(RTRIM$(Rooms(Rooms(Room).West).RoomName)) = Word(X + 1) THEN
                        Verb(1) = "WEST"
                     ELSEIF UCASE$(RTRIM$(Rooms(Rooms(Room).West).Adjective)) = Word(X + 1) AND UCASE$(RTRIM$(Rooms(Rooms(Room).West).RoomName)) = Word(X + 2) THEN
                        Verb(1) = "WEST"
                     END IF
                  END IF

                  IF Rooms(Room).East THEN
                     IF UCASE$(RTRIM$(Rooms(Rooms(Room).East).RoomName)) = Word(X + 1) THEN
                        Verb(1) = "EAST"
                     ELSEIF UCASE$(RTRIM$(Rooms(Rooms(Room).East).Adjective)) = Word(X + 1) AND UCASE$(RTRIM$(Rooms(Rooms(Room).East).RoomName)) = Word(X + 2) THEN
                        Verb(1) = "EAST"
                     END IF
                  END IF
                 
                  IF Verb(1) = "" THEN
                     COLOR Normal
                     PR "I cannot go there right now."
                     EXIT SUB
                  END IF
            END SELECT
         END IF

         FOR Z = 1 TO NumVerbs

         '   IF RTRIM$(Verbs(Z).VerbName) = "ASK" THEN GOTO Skip
         '   IF RTRIM$(Verbs(Z).VerbName) = "READ" THEN GOTO Skip
         '   IF RTRIM$(Verbs(Z).VerbName) = "LOOK" THEN GOTO Skip
         '   IF RTRIM$(Verbs(Z).VerbName) = "TAKE" THEN GOTO Skip
         '   IF RTRIM$(Verbs(Z).VerbName) = "DROP" THEN GOTO Skip
         
            IF Word(X) = UCASE$(RTRIM$(Verbs(Z).VerbName)) THEN
               Verb(1) = LTRIM$(RTRIM$(UCASE$(Verbs(Z).VerbName)))
              
                  IF Verb(1) = "LOOK" THEN
                  Remove "AT", X, NumWords
               END IF

               Remove "THE", X, NumWords
               Remove "A", X, NumWords
               Remove "ONE", X, NumWords
              
               X = X + 1
               Find NumWords, X, Found, Times, 1, 0

               IF Found = -1 THEN      ' Which one?
                  EXIT SUB             ' We don't know.
               END IF                  ' So exit.

               IF Found THEN           ' Okay, we've found what they mean.
                  IF X > NumWords THEN
                     X = X - 1
                     Delegate.One.Noun X, NumWords, Found, "", Z
                     EXIT SUB
                  ELSE
                     SELECT CASE Verb(1)
                        CASE "ASK"
                           IF Word(X) = "ABOUT" THEN
                              Remove "THE", X, NumWords
                              Remove "A", X, NumWords
                              Remove "ONE", X, NumWords
                              
                              Noun(2) = Word(X + 1)
                              Delegate.Two.Noun X, NumWords, Found, "", Z

                              EXIT SUB
                           ELSE
                              COLOR Normal
                              PR "I don't understand."
                              EXIT SUB
                           END IF
                        CASE "GIVE"
                           IF Word(X) = "TO" THEN
                              Remove "THE", X, NumWords
                              Remove "A", X, NumWords
                              Remove "ONE", X, NumWords
                             
                              Noun(2) = Word(X + 1)
                              Delegate.Two.Noun X, NumWords, Found, "", Z

                              EXIT SUB
                           ELSE
                              ' Assume they said "GIVE HOLMES THE STICK"
                              X = X - 1
                              Remove "THE", X, NumWords
                              Remove "A", X, NumWords
                              Remove "ONE", X, NumWords

                              Noun(2) = Word(X + 1)
                              Delegate.Two.Noun X, NumWords, Found, "", Z
                              EXIT SUB
                           END IF
                     END SELECT
                  END IF
               ELSEIF Word(X) = "ALL" THEN
                  Remove "OF", X, NumWords
                  Remove "THE", X, NumWords

                  IF NumWords = X THEN
                     Delegate.One.Noun X, NumWords, -1, "", Z
                     EXIT SUB
                  ELSE
                     IF RIGHT$(Word(X + 1), 1) = "S" AND RIGHT$(Word(X + 1), 2) <> "SS" THEN Word(X + 1) = LEFT$(Word(X + 1), LEN(Word(X + 1)) - 1)
                     Find NumWords, X + 1, Found, Times, 1, -1
                     IF Found THEN
                        Delegate.One.Noun X, NumWords, Found, Word(X + 1), Z
                        EXIT SUB
                     END IF
                  END IF
               ELSEIF RIGHT$(Word(X), 1) = "S" AND RIGHT$(Word(X + 1), 2) <> "SS" THEN
                  Word(X) = LEFT$(Word(X), LEN(Word(X)) - 1)
                  Find NumWords, X, Found, Times, 1, -1
                  IF Found THEN
                     Delegate.One.Noun X, NumWords, Found, Word(X), Z
                     EXIT SUB
                  END IF
               END IF

               COLOR Normal
               PR "You can't do that."
               EXIT SUB
            END IF
Skip:
         NEXT
        
         SELECT CASE Word(X)
            CASE "N"
               Verb(1) = "NORTH"
            CASE "S"
               Verb(1) = "SOUTH"
            CASE "W"
               Verb(1) = "WEST"
            CASE "E"
               Verb(1) = "EAST"
            CASE ELSE
               COLOR Normal
               PR "I don't know how to do that."
               EXIT SUB
         END SELECT

      ELSEIF Noun(1) = "" THEN ' We are looking for the first noun or an adj.
      ELSEIF Prep(1) = "" THEN ' We are looking for the first prep.
      ELSEIF Noun(2) = "" THEN ' We are looking for the second noun or an adj.
      ELSE                     ' We don't know WHAT we are looking for.
      END IF

PastIf:
   NEXT

   SELECT CASE Verb(1)
      CASE "NORTH"
         IF Rooms(Room).North THEN
            Room = Rooms(Room).North
            Follow
            Look.Long
         ELSE
            COLOR Normal
            PR "You can't go that way."
         END IF
         EXIT SUB

      CASE "SOUTH"
         IF Rooms(Room).South THEN
            Room = Rooms(Room).South
            Follow
            Look.Long
         ELSE
            COLOR Normal
            PR "You can't go that way."
         END IF
         EXIT SUB

      CASE "EAST"
         IF Rooms(Room).East THEN
            Room = Rooms(Room).East
            Follow
            Look.Long
         ELSE
            COLOR Normal
            PR "You can't go that way."
         END IF
         EXIT SUB

      CASE "WEST"
         IF Rooms(Room).West THEN
            Room = Rooms(Room).West
            Follow
            Look.Long
         ELSE
            COLOR Normal
            PR "You can't go that way."
         END IF
         EXIT SUB

      CASE ELSE

   END SELECT

   IF NumWords = 0 THEN
      COLOR Normal
      PR "I don't understand."
      Turns = Turns - 1
      EXIT SUB
   END IF
   COLOR Normal

END SUB

SUB Play.Game

   Room = 1
   Points = 0
   Turns = 0

   Look.Long
   PR ""

   DO
      X = CSRLIN: Y = POS(X)
      VIEW PRINT Sline.Top TO Sline.Top
      COLOR 0, 3
      A$ = SPACE$(48)
      LSET A$ = RTRIM$(Rooms(Room).Adjective) + " " + Rooms(Room).RoomName
      LOCATE Sline.Top, 1: PRINT " " + A$;
      LOCATE Sline.Top, 50: PRINT USING "Score: \  \    Turns: \   \"; LTRIM$(STR$(Points)); LTRIM$(STR$(Turns));
      COLOR Prompt, Background
      VIEW PRINT Sline.WTop TO Sline.WBottom
      LOCATE X, Y
      PR2 "Command >> "
      COLOR Highlight
'      LINE INPUT A$
      A$ = Edit$
      Lines = 0
      OldRoom = Room
      Parse A$
      PR ""
   LOOP

END SUB

SUB PR (A$)
   
   Lines = Lines + 1
   IF Lines = Sline.WBottom - Sline.WTop THEN
      Char = SCREEN(Sline.WTop, 80)
      Col = SCREEN(Sline.WTop, 80, -1)
      Fore = Col AND 15: Back = (Col \ 16) AND 7
      X = CSRLIN: Y = POS(X)
          
      LOCATE Sline.WTop, 80
      PRINT CHR$(Char);
      Attr = SCREEN(Sline.WTop, 80, -1)
      COLOR Fore, Back
      LOCATE Sline.WTop, 80
      PRINT CHR$(Char);
      LOCATE X, Y

      Fore = Attr AND 15: Back = (Attr \ 16) AND 7
     
      COLOR 12
      PRINT "(* more *)";
      LOCATE , , 1
      DO: LOOP UNTIL LEN(INKEY$)
      LOCATE , , 0
      PRINT STRING$(10, 29); SPACE$(10); STRING$(10, 29);
      Lines = 0
      COLOR Fore, Back
   END IF
  
   CALL PR2(A$ + CHR$(13))

END SUB

SUB PR2 (A$)

   PRINT A$;

END SUB

SUB Quit.Game
   
   PR ""
   COLOR Bright
   PR2 "Quit the game -- Are you sure? [y/N]: "
   COLOR Highlight
   LOCATE , , 1
   DO
      A$ = UCASE$(INKEY$)
   LOOP UNTIL LEN(A$) <> 0 AND INSTR("YN" + CHR$(13), A$) <> 0
   IF A$ = CHR$(13) THEN A$ = "N"
   LOCATE , , 0
   IF A$ = "N" THEN PR "No" ELSE PR "Yes"
   COLOR Normal
  
   IF A$ <> "Y" THEN EXIT SUB
  
   PLAY "T120 P8 T255P64"
  
   SCREEN 0
   WIDTH 80, 25
   COLOR 7, 0
   VIEW PRINT 1 TO 25
   CLS
   END

END SUB

SUB Read.Object (Num, A$)
 
   IF Num = -1 THEN
      FOR Y = 1000 TO Block.NumObjects
         IF (Objects(Y).Location = Room OR (A$ <> "" AND Objects(Y).Location = -1)) AND (A$ = "" OR RTRIM$(UCASE$(Objects(Y).ObjectName)) = A$) AND Objects(Y).ShortDesc <> 0 AND (Objects(Y).Capabilities AND VerbN(5)) THEN
            IF Yes = 0 THEN
               Yes = -1
            END IF
            COLOR Bright
            PR2 "(" + LTRIM$(LCASE$(RTRIM$(Objects(Y).Adjective) + " " + RTRIM$(Objects(Y).ObjectName)))
            IF Objects(Y).Location = -1 THEN PR2 " [which you are carrying]"
            PR2 "): "
            COLOR Normal
            Read.Object Y, ""
         END IF
      NEXT
      COLOR Normal
      IF Yes = 0 THEN
         IF A$ <> "" THEN PR "You can't read those."
         IF A$ = "" THEN PRINT "There is nothing here to read."
      END IF
      Found = -1
      EXIT SUB
   END IF

   COLOR Normal
   X = Num
   IF (Objects(X).Location = Room OR Objects(X).Location = -1) THEN
      IF Objects(X).Capabilities AND VerbN(5) THEN
         Execute CommandN(X, 5), X, 5
         EXIT SUB
      END IF
   END IF
   PR "You can't read that."

END SUB

SUB Remove (Word$, X, NumWords)
           
   IF Word(X + 1) = Word$ THEN
      X = X + 1
   END IF

END SUB

SUB Second.Intro
  
   Y = Block.Introduction
   DO WHILE Y <> 0
      X$ = RTRIM$(Text(Y).Text): CALL BusqLen(X$, SLen%)
      U$ = SPACE$(SLen%): CALL Busq(X$, U$)

      V$ = V$ + U$

      Y = Text(Y).NextRec
   LOOP

   A = INSTR(V$, CHR$(13))
   G$ = LEFT$(V$, A - 1)
   V$ = MID$(V$, A + 1)
 
   A = INSTR(V$, CHR$(13))
   A$ = "by " + LEFT$(V$, A - 1)
   V$ = MID$(V$, A + 1)
 
   VIEW PRINT 1 TO 1
   LOCATE 1, 1
   COLOR 0, 3: PRINT " Introduction to ";
   COLOR 15: PRINT G$; " ";
   COLOR 0: PRINT A$; ".";
   VIEW PRINT Sline.WTop TO Sline.WBottom
   COLOR 7, 0

   COLOR Bright
   PR "Introduction"
   PR ""
   COLOR Normal

   DO
      A = INSTR(V$, CHR$(13))
      IF A THEN
         PR LEFT$(V$, A - 1)
         V$ = MID$(V$, A + 1)
      END IF
   LOOP WHILE A

   PR ""
   COLOR 12
   PRINT "(* key *)";
   LOCATE , , 1
   DO: LOOP UNTIL LEN(INKEY$)
   LOCATE , , 0
   PRINT STRING$(10, 29); SPACE$(10); STRING$(10, 29);
   COLOR Normal

END SUB

FUNCTION StrTok$ (Srce$, Delim$)
STATIC Start&, SaveStr$

   ' If first call, make a copy of the string.
   IF Srce$ <> "" THEN
      Start& = 1: SaveStr$ = Srce$
   END IF
 
   IF SaveStr$ = "" THEN StrTok$ = "": EXIT FUNCTION

   BegPos& = Start&: Length& = LEN(SaveStr$)
   ' Look for start of a token (character that isn't delimiter).
   WHILE BegPos& <= Length& AND INSTR(Delim$, MID$(SaveStr$, BegPos&, 1)) <> 0
      BegPos& = BegPos& + 1
   WEND
   ' Test for token start found.
   IF BegPos& > Length& THEN
      StrTok$ = "": EXIT FUNCTION
   END IF
   ' Find the end of the token.
   EndPos& = BegPos&
   WHILE EndPos& <= Length& AND INSTR(Delim$, MID$(SaveStr$, EndPos&, 1)) = 0
      EndPos& = EndPos& + 1
   WEND
   StrTok$ = MID$(SaveStr$, BegPos&, EndPos& - BegPos&)
   ' Set starting point for search for next token.
   Start& = EndPos& + 1

END FUNCTION

SUB Take (Num, A$)

   IF Num = -1 THEN
      FOR Y = 1000 TO Block.NumObjects
         IF Objects(Y).Location = Room AND (Objects(Y).Capabilities AND VerbN(3)) AND (A$ = "" OR RTRIM$(UCASE$(Objects(Y).ObjectName)) = A$) THEN
            IF Yes = 0 THEN
               Yes = -1
            END IF
            COLOR Bright
            PR2 "(" + LTRIM$(LCASE$(RTRIM$(Objects(Y).Adjective) + " " + RTRIM$(Objects(Y).ObjectName) + "): "))
            COLOR Normal
            Take Y, ""
         END IF
      NEXT
      COLOR Normal
      IF Yes = 0 THEN
         IF A$ <> "" THEN PR "You can't take those."
         IF A$ = "" THEN PR "There is nothing here to take."
      END IF
      Found = -1
      EXIT SUB
   END IF

   COLOR Bright
   X = Num
   IF Objects(X).Location = Room THEN
      IF (Objects(X).Capabilities AND VerbN(3)) THEN
        
         COLOR Normal

         V = CommandN(X, 3)
         IF V THEN
            Execute V, X, 3
            EXIT SUB
         ELSE
            IF TotalWeight + Objects(X).Weight <= 99 AND TotalSize + Objects(X).Size <= 99 THEN
               Objects(X).Location = -1
               PR "Taken."
               TotalWeight = TotalWeight + Objects(X).Weight
               TotalSize = TotalSize + Objects(X).Size
            ELSE
               IF TotalWeight + Objects(X).Weight > 99 THEN PR "You can't.  It's too heavy to carry with your other things.": EXIT SUB
               IF TotalSize + Objects(X).Size > 99 THEN PR "You can't.  It's too big to carry with your other things."
            END IF

         END IF

         EXIT SUB
      ELSE
         COLOR Normal
         PR "You cannot take the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))
         EXIT SUB
      END IF
   ELSEIF Objects(X).Location = -1 THEN
      COLOR Normal
      PR "You already have the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))
      EXIT SUB
   END IF

   COLOR Normal
   PR "You can't take the " + LTRIM$(LCASE$(RTRIM$(Objects(X).Adjective) + " " + RTRIM$(Objects(X).ObjectName) + "."))

END SUB

FUNCTION VerbN& (X)

   IF X = 32 THEN
      VerbN = -2147483647
      EXIT FUNCTION
   END IF

   VerbN = 2 ^ (X - 1)

END FUNCTION

