DECLARE SUB Read.Introduction ()
DECLARE SUB Creature (A$)
'=============================================================================
' AGC Copyright (c) 1991 Robert J. Sundling, All Rights Reserved.
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
' [ Program Name  ]: Adventure Game Compiler
' [ Version       ]: v1.00á
' [ Author        ]: Robert J. Sundling
' [ Date Started  ]: 04/21/91
' [ Date Finished ]: ??/??/??
'
'-----------------------------------------------------------------------------
' Revision History:
'-----------------------------------------------------------------------------
'  04/21/91 -- Initial beta test version began.
'  05/02/91 -- Added user definable verb prototypes
'  05/03/91 -- Added dynamic array UBOUNDs based on available memory
'=============================================================================

DECLARE FUNCTION ReadCommands& (A$)
DECLARE FUNCTION GetQuotes$ (A$, L$)
DECLARE FUNCTION GetNum& (Min&, Max&, A$, L$)
DECLARE FUNCTION Verb& (X&)
DECLARE SUB DisplayText (X%)
DECLARE FUNCTION ReadText& (A$)
DECLARE SUB Object (A$)
DECLARE SUB SPECIAL (A$)
DECLARE SUB Check ()
DECLARE SUB Error.Chk (A$, B&)
DECLARE SUB Save ()
DECLARE SUB Error.Msg (A$, B$)
DECLARE SUB Error.Com (A$)
DECLARE SUB Room (A$)
DECLARE FUNCTION Get.Line$ ()
DECLARE SUB Open.Files ()
DECLARE SUB Compile ()
DECLARE SUB Filter (L$)
DECLARE SUB Intro ()
DECLARE FUNCTION StrTok$ (Srce$, Delim$)
DECLARE SUB Help ()
DECLARE SUB Parse ()

'$INCLUDE: 'AG.QBI'

COMMON SHARED InputFile AS STRING, OutputFile AS STRING, CommandLine AS STRING
COMMON SHARED Done, LN, Delimiters$, Errors, File$

COMMON SHARED NextRoom, NextObject, NextPerson, NextText, NumVerbs, NextCom, NextEvent
COMMON SHARED MaxRooms&, MaxObjects&, MaxText&, MaxCreatures&, MaxCommands&

COMMON SHARED Rooms()    AS RoomType
COMMON SHARED Objects()  AS ObjectType
COMMON SHARED Text()     AS TextType
COMMON SHARED Verbs()    AS VerbType
COMMON SHARED Objects2() AS ObjectType2
COMMON SHARED Block      AS HeaderType
COMMON SHARED Commands() AS CommandType
COMMON SHARED Events()   AS EventType

X& = (FRE(-1) - 4224) / 924 * .8

MaxRooms& = X& / 2
MaxObjects& = X& + 1000
MaxText& = X& * 2
MaxCreatures& = 32
MaxCommands& = X&

'$DYNAMIC
DIM Rooms(1 TO MaxRooms&)              AS RoomType
DIM Objects(1000 TO MaxObjects&)       AS ObjectType
DIM Objects2(1000 TO MaxObjects&)      AS ObjectType2
DIM Text(1 TO MaxText&)                AS TextType
DIM Verbs(1 TO 32)                     AS VerbType
DIM Events(1 TO 32&)                   AS EventType
DIM Commands(1 TO MaxCommands&)        AS CommandType

NextObject = 1000
  NextRoom = 1
  NextText = 1
   NextCom = 1
 NextEvent = 1

'   ON ERROR GOTO ErrorLine

   Block.Misc = "C v1.00 Adventure Game File" + CHR$(13) + CHR$(10) + "AGC Copyright (c) 1991 Robert J. Sundling, All Rights Reserved." + CHR$(13) + CHR$(10) + CHR$(26)
   Block.Header = BLOCKHEADER
   Block.NumCreatures = 1000
   Block.NumRooms = 1
   Block.NumEvents = 1
   Block.NumObjects = 1000

'$INCLUDE: 'VERBS.QBI'

   FOR X = 1 TO NumVerbs
      Verbs(X).Header = VERBHEADER
      Verbs(X).Number = X
   NEXT

   Intro
   Parse
   Open.Files
   Compile
   Check
   Save

   END

ErrorLine:
   IF ERR = 6 THEN
      ' Number too large/small... Get a LIFE, you user!
      RESUME NEXT
   ELSE
      ON ERROR GOTO 0
   END IF

REM $STATIC
SUB Check

   IF Rooms(1).Header <> ROOMHEADER THEN
      Error.Chk "There is no room number", 1
   END IF

   FOR X = 1 TO MaxRooms&
      IF Rooms(X).Header = ROOMHEADER THEN
         IF Rooms(X).North THEN
            IF Rooms(Rooms(X).North).Header <> ROOMHEADER THEN
               Error.Chk "Undefined north room specified for room", X
            END IF
         END IF

         IF Rooms(X).South THEN
            IF Rooms(Rooms(X).South).Header <> ROOMHEADER THEN
               Error.Chk "Undefined south room specified for room", X
            END IF
         END IF

         IF Rooms(X).East THEN
            IF Rooms(Rooms(X).East).Header <> ROOMHEADER THEN
               Error.Chk "Undefined east room specified for room", X
            END IF
         END IF

         IF Rooms(X).West THEN
            IF Rooms(Rooms(X).West).Header <> ROOMHEADER THEN
               Error.Chk "Undefined west room specified for room", X
            END IF
         END IF
      
         IF Rooms(X).Up THEN
            IF Rooms(Rooms(X).Up).Header <> ROOMHEADER THEN
               Error.Chk "Undefined up room specified for room", X
            END IF
         END IF
      
         IF Rooms(X).Down THEN
            IF Rooms(Rooms(X).Down).Header <> ROOMHEADER THEN
               Error.Chk "Undefined down room specified for room", X
            END IF
         END IF
      
         IF Rooms(X).SPECIAL > 0 THEN
            IF Rooms(X).KeyObject < 1000 OR Rooms(X).KeyObject > 1150 THEN
               Error.Chk "Invalid key object number in room", X
            ELSE
               IF Objects(Rooms(X).KeyObject).Header <> OBJECTHEADER THEN
                  Error.Chk "An undefined object was specified as special's key in room", X
               END IF
            END IF
         
            'IF Specials(Rooms(X).Special).Header <> SPECIALHEADER THEN
            '   Error.Chk "Special text not defined for room", X
            'END IF

            IF Rooms(Rooms(X).NewRoom).Header <> ROOMHEADER THEN
               Error.Chk "Undefined room specified for new special location in room", X
            END IF

         END IF
      END IF
   NEXT

   FOR X = 1000 TO MaxObjects&
      IF Objects(X).Header = OBJECTHEADER THEN
         IF Objects(X).Location < 0 OR Objects(X).Location > 300 THEN
            Error.Chk "Invalid location for object", X
         ELSEIF Objects(X).Location <> 0 THEN
            IF Rooms(Objects(X).Location).Header <> ROOMHEADER THEN
               Error.Chk "An undefined room was specified for the location of object", X
            END IF
         END IF
      
         'IF Objects(X).Lockable THEN
         '   IF Objects(X).KeyObject = 0 THEN
         '      LN$ = LTRIM$(STR$(B))
         '
         '      COLOR 12: PRINT "WARNING: ";
         '      COLOR 13: PRINT "There is no key defined for object number ";
         '      COLOR 11: PRINT LN$
         '   ELSE
         '      IF Objects(Objects(X).KeyObject).Header <> OBJECTHEADER THEN
         '         Error.Chk "An undefined key object was specified for object", X
         '      END IF
         '   END IF
         'END IF
      END IF
   NEXT

END SUB

SUB Compile

   Delimiters$ = " .,;()?" + CHR$(9) + CHR$(34)

   Done = 0

   COLOR 15
   DO UNTIL EOF(1)
   
      L$ = Get.Line
      IF Done THEN EXIT DO
   
      Token$ = UCASE$(StrTok$(L$, Delimiters$))
      SELECT CASE Token$
         CASE "ROOM"
            Room UCASE$(StrTok$("", Delimiters$))
         CASE "OBJECT"
            Object UCASE$(StrTok$("", Delimiters$))
         CASE "INTRO"
            Read.Introduction
         CASE "SPECIAL"
            'Special UCASE$(StrTok$("", Delimiters$))
         CASE "EVENT"
            EventNum = VAL(StrTok$("", Delimiters$))

            IF EventNum > 32 OR EventNum < 1 THEN
               Error.Msg "Invalid event number (1-32)", A$
            ELSE
               IF EventNum > Block.NumEvents THEN Block.NumEvents = EventNum
               A = ReadCommands("command")
               Events(EventNum).Header = EVENTHEADER
               Events(EventNum).Number = EventNum
               Events(EventNum).Commands = A
            END IF
         CASE "{", "}"
            Error.Com "{ or } encountered outside of definition"
         CASE ELSE
            Error.Msg "Invalid descriptor outside of definition", Token$
      END SELECT

   LOOP

END SUB

SUB Creature (A$)



END SUB

SUB DisplayText (X%)

   Y = X%
   DO WHILE Y <> 0
   
      X$ = RTRIM$(Text(Y).Text): CALL BusqLen(X$, SLen%)
      U$ = SPACE$(SLen%): CALL Busq(X$, U$)

      V$ = V$ + U$

      Y = Text(Y).NextRec
   LOOP

   PRINT V$;

END SUB

SUB Error.Chk (A$, B)

   LN$ = LTRIM$(STR$(B))

   COLOR 12: PRINT "ERROR: ";
   COLOR 13: PRINT A$ + " number ";
   COLOR 11: PRINT LN$

   Errors = Errors + 1

END SUB

SUB Error.Com (A$)

   LN$ = "    "
   RSET LN$ = LTRIM$(STR$(LN))

   COLOR 12: PRINT "ERROR: ";
   COLOR 15: PRINT "Line #[";
   COLOR 11: PRINT LN$;
   COLOR 15: PRINT "]: ";
   COLOR 13: PRINT A$ + "."
   Errors = Errors + 1

END SUB

SUB Error.Msg (A$, B$)
        
   LN$ = "    "
   RSET LN$ = LTRIM$(STR$(LN))

   COLOR 12: PRINT "ERROR: ";
   COLOR 15: PRINT "Line #[";
   COLOR 11: PRINT LN$;
   COLOR 15: PRINT "]: ";
   COLOR 13: PRINT A$ + ": ";
   COLOR 3: PRINT CHR$(34);
   COLOR 11: PRINT B$;
   COLOR 3: PRINT CHR$(34)
   Errors = Errors + 1

END SUB

SUB Filter (L$)

   DO
      A = INSTR(L$, CHR$(9))
      IF A THEN
         L$ = LEFT$(L$, A - 1) + SPACE$((INT((A - 1) / 9) + 1) * 9 - (A - 1)) + MID$(L$, A + 1)
      END IF
   LOOP WHILE A

END SUB

FUNCTION Get.Line$
   
   DO
      IF EOF(1) THEN Done = -1: EXIT DO
      LINE INPUT #1, L$: LN = LN + 1
      Filter L$
   LOOP WHILE LEFT$(LTRIM$(L$), 1) = ";" OR LTRIM$(L$) = ""
   Get.Line$ = LTRIM$(RTRIM$(L$))

END FUNCTION

FUNCTION GetNum (Min, Max, A$, L$)
         
   Num = VAL(StrTok$("", Delimiters$))
   IF Num < Min OR KeyNum > Max THEN
      Error.Msg "Invalid " + A$ + " # (" + LTRIM$(STR$(Min)) + "-" + LTRIM$(STR$(Max)) + ", " + LTRIM$(RTRIM$(STR$(Num))) + ")", L$
      Num = 0
   END IF
   GetNum = Num

END FUNCTION

FUNCTION GetQuotes$ (A$, L$)
         
   N = INSTR(L$, CHR$(34))
   IF N <> 0 AND N <> LEN(L$) THEN
      NN = INSTR(N + 1, L$, CHR$(34))
      IF NN THEN
         D$ = MID$(L$, N + 1, (NN - N - 1))
      ELSE
         Error.Msg A$ + " missing a " + CHR$(34), L$
      END IF
   ELSE
      Error.Msg A$ + " missing a " + CHR$(34), L$
   END IF

   GetQuotes$ = D$

END FUNCTION

SUB Help

   COLOR 13: PRINT "AGC Invocation Syntax: ";
   COLOR 15: PRINT "AGC inputfile[, outputfile]"
   COLOR 7:  PRINT
   PRINT "        inputfile  = The text file containing the adventure game"
   PRINT "                     definitions."
   PRINT "        outputfile = A name of a binary file to be created that"
   PRINT "                     is to contain the compiled adventure game."
   END

END SUB

SUB Intro

   COLOR 11: PRINT "AGC -- Adventure Game Compiler (v1.05á, 05/05/91)"
   COLOR 15: PRINT "Copyright (c) 1991 Robert J. Sundling, All Rights Reserved."
   COLOR 7:  PRINT "For OmniTechnologies' Internal Use Only.  Not for distribution."
   PRINT
   COLOR 13: PRINT "[Memory Limits]:"; : COLOR 11
   PRINT STR$(MaxRooms&); " rooms,";
   PRINT STR$(MaxObjects& - 1000); " objects,";
   PRINT " 32 events,";
   PRINT STR$(INT((MaxText& * 126) / 1024)); "k of text."
   COLOR 13: PRINT "[Free Memory  ]:"; : COLOR 11: PRINT STR$(INT(FRE(-1) / 1024)); "k available for required buffers."
   PRINT

END SUB

SUB Object (A$)

   CT$ = STRING$(64, 0)

   Num = VAL(A$)
   Weight = 1: Size = 1

   IF VAL(A$) < 1000 OR VAL(A$) > MaxObjects& THEN
      Error.Msg "Invalid object number (1000-" + LTRIM$(STR$(MaxObjects&)) + ")", A$
      EXIT SUB
   END IF

   IF Objects(Num).Header = OBJECTHEADER THEN
      Error.Msg "Object already defined.", A$
      EXIT SUB
   END IF

   IF Num > Block.NumObjects THEN Block.NumObjects = Num

   IF Get.Line$ <> "{" THEN Error.Com "Leading { missing in object #" + LTRIM$(STR$(Num)) + "'s definition"

   VF = 0
   FOR X = 1 TO NumVerbs
      IF Verbs(X).Default THEN
         VF = VF OR Verb(X)
      END IF
   NEXT

   DO
      L$ = Get.Line$
      IF Done THEN EXIT DO
      T$ = StrTok$(L$, Delimiters$)
      SELECT CASE UCASE$(T$)
         CASE "SHORT", "SHRT"
            SP$ = StrTok$("", Delimiters$)

            IF LEFT$(SP$, 1) = "C" THEN
               SC = ReadCommands("SHORT COMMANDS definition")
            ELSE
               SD = ReadText("SHORT DESC definition")
            END IF
         CASE "FOLLOW"
            Follow = -1
         CASE "LONG", "LNG"
            LD = ReadText("LONG DESC definition")
         CASE "ADJECTIVE", "ADJ"
            Adj$ = GetQuotes$("Object adjective", L$)
         CASE "NAME", "NM"
            Nam$ = GetQuotes$("Object name", L$)
         CASE "SYNONYM"
            IF ASC(Objects2(Num).Synonym1) = 0 THEN
               Objects2(Num).Synonym1 = GetQuotes$("Object synonym", L$)
            ELSEIF ASC(Objects2(Num).Synonym2) = 0 THEN
               Objects2(Num).Synonym2 = GetQuotes$("Object synonym", L$)
            ELSE
               Error.Com "Too many object synonyms (Two allowed)"
            END IF
         CASE "POINTS", "PNTS"
            Points = VAL(StrTok$("", Delimiters$))
         CASE "KEY", "K"
            KeyNum = GetNum(1000, MaxObjects&, "object", L$)
         CASE "LOCATION", "LOC"
            Location = GetNum(-1, MaxCreatures&, "location", L$)
         CASE "WEIGHT", "WT"
            Weight = GetNum(0, 100, "weight", L$)
         CASE "SIZE", "SZ"
            Size = GetNum(0, 100, "size", L$)
         CASE "LIGHT", "LT"
            IsLight = -1
         CASE "ON"
            IsOn = -1
         CASE "{"
            Error.Com "Invalid '{' inside of object definition without cause"
            COLOR 11: PRINT "                     --- Ignoring contents..."
            DO
               L$ = Get.Line$
               IF Done THEN EXIT DO
            LOOP UNTIL L$ = "}"
         CASE "}"
            EXIT DO
         CASE ELSE
            V$ = UCASE$(T$)
            OK = 0
          
            FOR X = 1 TO NumVerbs
               IF RTRIM$(Verbs(X).Desc) = V$ THEN
              
                  MID$(CT$, (X - 1) * 2 + 1, 2) = MKI$(ReadCommands("command"))
                  VF = VF OR Verb(X)
                  OK = -1
            
               ELSEIF RTRIM$(Verbs(X).Capable) = V$ THEN
               
                  VF = VF OR Verb(X)
                  OK = -1

               ELSEIF RTRIM$(Verbs(X).UnCapable) = V$ THEN
               
                  IF VF AND Verb(X) THEN
                     VF = VF XOR Verb(X)
                  END IF
                  OK = -1

               ELSEIF RTRIM$(Verbs(X).Yes) = V$ THEN

                  VS = VS OR Verb(X)
                  OK = -1
            
               ELSEIF RTRIM$(Verbs(X).No) = V$ THEN

                  IF VS AND Verb(X) THEN
                     VS = VS XOR Verb(X)
                  END IF
                  OK = -1

               END IF
            NEXT

            IF OK = 0 THEN
               Error.Msg "Invalid object statement", T$
            END IF

      END SELECT

   LOOP UNTIL Done
   IF Done THEN
      Error.Com "Unexpected end of file"
   END IF

   Objects(Num).Capabilities = VF
   Objects(Num).Header = OBJECTHEADER
   Objects(Num).Number = Num
   Objects(Num).Adjective = Adj$
   Objects(Num).ObjectName = Nam$
   Objects(Num).ShortCommands = SC
   Objects(Num).ShortDesc = SD
   Objects(Num).LongDesc = LD
   Objects(Num).Location = Location
   Objects(Num).Weight = Weight
   Objects(Num).Size = Size
   Objects(Num).Points = Points
   Objects(Num).IsOn = IsOn
   Objects(Num).IsLight = IsLight
   Objects(Num).KeyObject = KeyNum
   Objects(Num).Follow = Follow

   Objects2(Num).Header = OBJECTHEADER2
   Objects2(Num).Number = Num
   Objects2(Num).Commands = CT$

END SUB

SUB Open.Files

   CALL Exist(InputFile + CHR$(0), I.Exists%)
   CALL Exist(OutputFile + CHR$(0), O.Exists%)

   IF I.Exists% = 0 THEN
      COLOR 12: PRINT "Input file does not exist."
      END
   END IF

   IF O.Exists% = -1 THEN
      COLOR 12: PRINT "Overwrite already existing output file? [y/N]: ";
      LOCATE , , 1
      COLOR 11
      DO
         A$ = UCASE$(INKEY$)
      LOOP UNTIL INSTR("YN" + CHR$(13), A$) <> 0 AND LEN(A$) <> 0
      LOCATE , , 0

      IF A$ <> "Y" THEN PRINT "N": END
      PRINT "Y"
      PRINT
      KILL OutputFile
   END IF

   OPEN InputFile FOR INPUT AS #1
   OPEN OutputFile FOR RANDOM AS #2 LEN = 132
   COLOR 15: PRINT "Compiling . . ."
   PRINT

END SUB

SUB Parse

   InputFile = ""
   CommandLine = COMMAND$
   IF LEN(CommandLine) = 0 THEN Help

   ' Change all /'s to -'s.
   DO
      A = INSTR(CommandLine, "/")
      IF A THEN MID$(CommandLine, A, 1) = "-"
   LOOP WHILE A

   Delimiters$ = "  ,;()?" + CHR$(9) + CHR$(34)

   Token$ = StrTok$(CommandLine, Delimiters$)
   IF Token$ <> "" THEN InputFile = Token$
   IF Token$ <> "" THEN OutputFile = StrTok$("", Delimiters$)

   IF InputFile = "" THEN Help
   IF OutputFile = "" THEN
      IF INSTR(InputFile, ".") = 0 THEN
         OutputFile = InputFile
      ELSE
         OutputFile = LEFT$(InputFile, INSTR(InputFile, ".") - 1)
      END IF
   END IF
 
   IF INSTR(InputFile, ".") = 0 THEN InputFile = InputFile + ".TXT"
   IF INSTR(OutputFile, ".") = 0 THEN OutputFile = OutputFile + ".ADV"
 
   COLOR 11: PRINT "[Input filename ]: "; : COLOR 13: PRINT InputFile
   COLOR 11: PRINT "[Output filename]: "; : COLOR 13: PRINT OutputFile
   PRINT

END SUB

SUB Read.Introduction

   Block.Introduction = ReadText("introduction")

END SUB

FUNCTION ReadCommands& (A$)

   IF Get.Line$ <> "{" THEN Error.Com "Leading { missing in " + A$

   DO
      L$ = Get.Line$
      IF Done THEN EXIT DO

      IF L$ = "." THEN L$ = ""
   
      IF L$ <> "}" THEN
         T$ = StrTok$(L$, Delimiters$)
         SELECT CASE UCASE$(T$)
            CASE "IFLOCNOT"
               S$ = S$ + C.IFLOCNOT
               X = GetNum(-2, 2998, "IFLOCNOT", L$)
               A$ = StrTok$("", Delimiters$)
               Y = GetNum(-2, 2998, "IFLOCNOT", L$)
               Z = ReadCommands("IFLOCNOT")
               S$ = S$ + MKI$(X) + MKI$(Y) + MKI$(Z)
            CASE "IFABOUT", "IFAT"
               S$ = S$ + C.IFABOUT
               A$ = StrTok$("", Delimiters$)
               IF VAL(A$) = 0 THEN
                  A$ = StrTok$(L$, Delimiters$)
                  About$ = GetQuotes$("IFABOUT", L$)
                  IF LEN(About$) <= 255 THEN
                     S$ = S$ + "S" + CHR$(LEN(About$)) + About$
                     Z = ReadCommands("IFLOC")
                     S$ = S$ + MKI$(Z)
                  ELSE
                     Error.Msg "String too long", T$
                  END IF
               ELSE
                  A$ = StrTok$(L$, Delimiters$)
                  Y = GetNum(-2, 2998, "IFABOUT", L$)
                  S$ = S$ + "N" + MKI$(Y)
                  Z = ReadCommands("IFLOC")
                  S$ = S$ + MKI$(Z)
               END IF
            CASE "IFLOC"
               S$ = S$ + C.IFLOC
               X = GetNum(-2, 2998, "IFLOC", L$)
               A$ = StrTok$("", Delimiters$)
               Y = GetNum(-2, 2998, "IFLOC", L$)
               Z = ReadCommands("IFLOC")
               S$ = S$ + MKI$(X) + MKI$(Y) + MKI$(Z)
            CASE "MOVE"
               S$ = S$ + C.MOVE
               X = GetNum(-2, 2998, "MOVE", L$)
               A$ = StrTok$("", Delimiters$)
               Y = GetNum(-2, 2998, "MOVE", L$)
               S$ = S$ + MKI$(X) + MKI$(Y)
            CASE "STOP"
               S$ = S$ + C.STOP
            CASE "DISPLAY"
               S$ = S$ + C.DISPLAY
               X = ReadText("DISPLAY")
               S$ = S$ + MKI$(X)
            CASE "LOCK"
               S$ = S$ + C.UNLOCK
               X = GetNum(1000, MaxObjects&, "object", L$)
               S$ = S$ + MKI$(X)
            CASE "UNLOCK"
               S$ = S$ + C.UNLOCK
               X = GetNum(1000, MaxObjects&, "object", L$)
               S$ = S$ + MKI$(X)
            CASE "OPEN"
               S$ = S$ + C.OPEN
               X = GetNum(1000, MaxObjects&, "object", L$)
               S$ = S$ + MKI$(X)
            CASE "CLOSE"
               S$ = S$ + C.CLOSE
               X = GetNum(1000, MaxObjects&, "object", L$)
               S$ = S$ + MKI$(X)
            CASE "DEFAULT"
               S$ = S$ + C.DEFAULT
            CASE "CREATURE_MOVE", "CREATURE"
               S$ = S$ + C.CREATURE
               X = GetNum(-2, 2998, "CREATURE_MOVE", L$)
               A$ = StrTok$("", Delimiters$)
               Y = GetNum(-2, 2998, "CREATURE_MOVE", L$)
               S$ = S$ + MKI$(X) + MKI$(Y)
            CASE "POINTS"
               S$ = S$ + C.POINTS
               X = GetNum(-1000, 1000, "points", L$)
               S$ = S$ + MKI$(X)
            CASE "ADDEVENT", "STARTEVENT"
               S$ = S$ + C.STARTEVENT
               X = GetNum(1, 32, "event", L$)
               S$ = S$ + MKI$(X)
            CASE "KILLEVENT"
               S$ = S$ + C.KILLEVENT
               X = GetNum(1, 32, "event", L$)
               S$ = S$ + MKI$(X)
            CASE "ADDEXIT"
               S$ = S$ + C.ADDEXIT
               D$ = StrTok$("", Delimiters$)
               D$ = LEFT$(D$, 1)
               SELECT CASE D$
                  CASE "N", "S", "E", "W"
                     X = GetNum(0, 999, "ADDEXIT", L$)
                     A$ = StrTok$("", Delimiters$)
                     Y = GetNum(0, 999, "ADDEXIT", L$)
                     S$ = S$ + D$ + MKI$(X) + MKI$(Y)
                  CASE ELSE: Error.Msg "Bad direction", T$
               END SELECT
            CASE ELSE
               Error.Msg "Invalid command statement", T$
         END SELECT

      END IF
   LOOP UNTIL L$ = "}"

   IF Done THEN
      Error.Com "Unexpected end of file"
   ELSE
      V = NextCom
      DO
         V$ = LEFT$(S$, 126)
         S$ = MID$(S$, 127)

         Commands(NextCom).Number = NextCom
         Commands(NextCom).Header = COMMANDHEADER
         Commands(NextCom).Commands = V$
         Commands(NextCom).NextRec = NextCom + 1
         NextCom = NextCom + 1
      LOOP WHILE LEN(S$)

      Commands(NextCom - 1).NextRec = 0
   END IF
   ReadCommands = V

END FUNCTION

'
' This function reads text from the file and places into a text array...
' The returned variable is the pointer to the beginning.
'
FUNCTION ReadText& (A$)

   IF Get.Line$ <> "{" THEN Error.Com "Leading { missing in " + A$

   DO
      L$ = Get.Line$
      IF Done THEN EXIT DO
      IF L$ = "." THEN L$ = ""
      IF L$ <> "}" THEN
         S$ = S$ + L$ + CHR$(13)
      END IF
   LOOP UNTIL L$ = "}"

   IF Done THEN
      Error.Com "Unexpected end of file"
   ELSE
  
      CALL Bsq(S$, SLen%)
      S$ = LEFT$(S$, SLen%)

      V = NextText
      DO
         V$ = LEFT$(S$, 126)
         S$ = MID$(S$, 127)

         Text(NextText).Number = NextText
         Text(NextText).Header = TEXTHEADER
         Text(NextText).Text = V$
         Text(NextText).NextRec = NextText + 1
         NextText = NextText + 1
      LOOP WHILE LEN(S$)

      Text(NextText - 1).NextRec = 0
   END IF
   ReadText = V

END FUNCTION

SUB Room (A$)

   RoomNum = VAL(A$)

   IF VAL(A$) > MaxRooms& OR VAL(A$) < 1 THEN
      Error.Msg "Invalid room number (1-" + LTRIM$(STR$(MaxRooms&)) + ")", A$
      EXIT SUB
   END IF

   IF RoomNum > Block.NumRooms THEN Block.NumRooms = RoomNum

   IF Get.Line$ <> "{" THEN Error.Com "Leading { missing in room #" + LTRIM$(STR$(RoomNum)) + "'s definition"

   DO
      L$ = Get.Line$
      IF Done THEN EXIT DO
      T$ = StrTok$(L$, Delimiters$)
      SELECT CASE UCASE$(T$)
         CASE "SHORT", "SHRT"
            S = ReadText("SHORT DESC definition")
         CASE "LONG", "LNG"
            L = ReadText("LONG DESC definition")
         CASE "ADJECTIVE", "ADJ"
            Adj$ = GetQuotes$("Adjective", L$)
         CASE "NAME"
            Nam$ = GetQuotes$("Name", L$)
         CASE "POINTS"
            Points = VAL(StrTok$("", Delimiters$))
         CASE "SPECIAL"
            SP$ = StrTok$("", Delimiters$)

            IF SP$ = "" OR LEFT$(SP$, 4) = "DESC" THEN
               Spec = ReadText("Special")
            ELSE
               IF UCASE$(SP$) <> "POINTS" THEN
                  Error.Msg "Invalid room statement", L$
               ELSE
                  SP = VAL(StrTok$("", Delimiters$))
               END IF
            END IF
         CASE "KEY"
            SpecialKey = GetNum(1000, MaxObjects&, "object", L$)
         CASE "ROOM"
            SpecialRoom = GetNum(1, 300, "room", L$)
         CASE "UP"
            Up = GetNum(1, MaxRooms&, "room", L$)
         CASE "DOWN"
            Down = GetNum(1, MaxRooms&, "room", L$)
         CASE "NORTH"
            North = GetNum(1, MaxRooms&, "room", L$)
         CASE "SOUTH"
            South = GetNum(1, MaxRooms&, "room", L$)
         CASE "LOOK"
            LookCommand = ReadCommands("look")
         CASE "EAST"
            East = GetNum(1, MaxRooms&, "room", L$)
         CASE "WEST"
            West = GetNum(1, MaxRooms&, "room", L$)
         CASE "LIGHT"
            Light = GetNum(1000, MaxObjects&, "object", L$)
         CASE "END"
            RoomEnd = -1
         CASE "{"
            Error.Com "Invalid '{' inside of room definition without cause"
            COLOR 11: PRINT "                     --- Ignoring contents..."
            DO
               L$ = Get.Line$
               IF Done THEN EXIT DO
            LOOP UNTIL L$ = "}"

         CASE "}"
            EXIT DO
      
         CASE ELSE
            Error.Msg "Invalid room statement", T$
      END SELECT

   LOOP UNTIL Done
   IF Done THEN
      Error.Com "Unexpected end of file"
   END IF

   Rooms(RoomNum).Up = Up
   Rooms(RoomNum).Down = Down
   Rooms(RoomNum).North = North
   Rooms(RoomNum).South = South
   Rooms(RoomNum).East = East
   Rooms(RoomNum).West = West

   Rooms(RoomNum).Header = ROOMHEADER
   Rooms(RoomNum).Number = RoomNum
   Rooms(RoomNum).RoomName = Nam$
   Rooms(RoomNum).Adjective = Adj$
   Rooms(RoomNum).LongDesc = L
   Rooms(RoomNum).ShortDesc = S
   Rooms(RoomNum).Points = Points
   Rooms(RoomNum).SPECIAL = Spec
   Rooms(RoomNum).NewRoom = SpecialRoom
   Rooms(RoomNum).KeyObject = SpecialKey
   Rooms(RoomNum).SpecialPoints = SP
   Rooms(RoomNum).Light = Light
   Rooms(RoomNum).LookCommands = LookCommand

END SUB

SUB Save

   IF Errors = 0 THEN
   
      COLOR 11: PRINT "No errors encountered."
      COLOR 15: PRINT "Writing output file...";
      Block.NumCommands = NextCom
      Block.NumText = NextText
      PUT #2, 1, Block

      R = 2
   
      FOR X = 1 TO NextCom
         IF Commands(X).Header = COMMANDHEADER THEN
            PUT #2, R, Commands(X)
            R = R + 1
         END IF
      NEXT

      FOR X = 1 TO Block.NumRooms
         IF Rooms(X).Header = ROOMHEADER THEN
            PUT #2, R, Rooms(X)
            R = R + 1
         END IF
      NEXT

      FOR X = 1 TO Block.NumEvents
         IF Events(X).Header = EVENTHEADER THEN
            PUT #2, R, Events(X)
            R = R + 1
         END IF
      NEXT

      FOR X = 1000 TO Block.NumObjects
         IF Objects(X).Header = OBJECTHEADER THEN
            PUT #2, R, Objects(X)
            R = R + 1
         END IF
         IF Objects2(X).Header = OBJECTHEADER2 THEN
            PUT #2, R, Objects2(X)
            R = R + 1
         END IF
      NEXT

      FOR X = 1 TO NumVerbs
         PUT #2, R, Verbs(X)
         R = R + 1
      NEXT

      FOR X = 1 TO NextText
         IF Text(X).Header = TEXTHEADER THEN
            PUT #2, R, Text(X)
            R = R + 1
         END IF
      NEXT


   
      PRINT " Done."
      COLOR 7
      CLOSE
   ELSE
      CLOSE
      PRINT
      COLOR 13: PRINT LTRIM$(STR$(Errors)) + " error(s) detected.  ";
      COLOR 12: PRINT "Output file not created."
      KILL OutputFile
   END IF

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

'=============================================================================
' Adventure Game Compiler - FUNCTION Verb
'-----------------------------------------------------------------------------
'
' Return the value of 2 ^ (X - 1), or if X = 32 return -2,147,483,647.
'
'=============================================================================
FUNCTION Verb& (X)

   IF X& = 32 THEN
      Verb = -2147483647
      EXIT FUNCTION
   END IF

   Verb = 2 ^ (X - 1)

END FUNCTION

