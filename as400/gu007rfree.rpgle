**free
// *==========================================================================================
// *                                                                      datacrush@gmail.com
// * GU007RFREE
// * Snake/400 - Traditional snake game on iSeries
// *
// * Version 3 Release 1 Modifications 0
// * October 2026
// * Version 2 Release 1 Modifications 0
// *  March 2013
// * Version 1 Release 1 Modifications 0
// *  February 2003
// *
// * (C) Copyright Isaac Syaz, 2003-2013.
// * All Rights Reserved
// *
// *==========================================================================================
// * Modifications log
// * ----------------------------------------------------------------------------------------
// * Trace   User        Date        Description
// * ----------------------------------------------------------------------------------------
// *         Chi-Iroh    15/10/2026  Made a full free version.
// *         SyazwanH    10/03/2013  Added computer opponent.
// *         SyazwanH    28/02/2003  Improved game speed and cursor accuracy.
// *         SyazwanH    16/02/2003  New program.
// * ----------------------------------------------------------------------------------------
// *==========================================================================================
// *
// * Instructions
// * ------------
// * There should be three files:
// *  GU007D     *FILE        (DSPF)
// *  GU007RFREE *PGM/*MODULE (RPGLE)
// *  GU007CFREE *PGM         (CLLE)
// *
// * Compile GU007CFREE as program. Compile GU007D as per normal.
// * Compile GU007RFREE as module (CRTRPGMOD). Then type the following:
// *  CRTPGM PGM(GU007RFREE) MODULE(GU007RFREE) BNDDIR(QC2LE) ACTGRP(*CALLER) ALWLIBUPD(*YES)
// *
// * When running the program, make sure you have QTEMP in your library list.
// *  CALL PGM(GU007CFREE)
// *
// *==========================================================================================

Ctl-Opt AltSeq(*None) BndDir('QC2LE');

Dcl-F Gu007D workstn;

// Prototype procedure
Dcl-Pr GetRandom Int(10) ExtProc('rand');
End-Pr;

Dcl-Pr Sleep Int(10) ExtProc('usleep');
    SleepTime Int(10) Value;
End-Pr;

// System status data structure
Dcl-Ds *n PSDS;
    QMsgTyp Char(3) Pos(40);
    QMsgNbr Char(4) Pos(43);
End-Ds;

// Local variables
// Informations on snake's Position
Dcl-Ds SnakePos Len(500) Inz;
    SnakePos_Arr Char(1) Dim(500);
    SnakePos_Char Char(500) Pos(1);
End-Ds;

Dcl-S Snake_Cur_X Int(10) Inz(*Zeros);
Dcl-S Snake_Cur_Y Int(10) Inz(*Zeros);
Dcl-S Snake_Length Int(10) Inz(*Zeros);
Dcl-S Snake_Grow Int(10) Inz(*Zeros);
Dcl-S Snake_Food Int(10) Inz(*Zeros);
Dcl-S Snake_Heading Char(1) Inz(*Blanks);

Dcl-S Snake_Prev_X Int(10) Dim(500) Inz(*Zeros);
Dcl-S Snake_Prev_Y Int(10) Dim(500) Inz(*Zeros);
Dcl-S Snake_Prev_Cnt Int(10) Inz(*Zeros);

Dcl-S Snake_Food_X Int(10) Inz(*Zeros);
Dcl-S Snake_Food_Y Int(10) Inz(*Zeros);

// Information on snake's Position
Dcl-S Snak2_Cur_X Int(10) Inz(*Zeros);
Dcl-S Snak2_Cur_Y Int(10) Inz(*Zeros);
Dcl-S Snak2_Length Int(10) Inz(*Zeros);
Dcl-S Snak2_Grow Int(10) Inz(*Zeros);
Dcl-S Snak2_Food Int(10) Inz(*Zeros);
Dcl-S Snak2_Heading Char(1) Inz(*Blanks);

Dcl-S Snak2_Prev_X Int(10) Dim(500) Inz(*Zeros);
Dcl-S Snak2_Prev_Y Int(10) Dim(500) Inz(*Zeros);
Dcl-S Snak2_Prev_Cnt Int(10) Inz(*Zeros);

Dcl-S Ind_EndGame Ind Inz(*Off);

// General calculations
Dcl-S Pos_X Int(10) Inz(*Zeros);
Dcl-S Pos_Y Int(10) Inz(*Zeros);
Dcl-S Result Int(10) Inz(*Zeros);
Dcl-S Time_LstMove Timestamp Inz;
Dcl-S Time_CurMove Timestamp Inz;
Dcl-S Time_Secs Int(10) Inz(*Zeros);
Dcl-S Temp_Rand Int(10) Inz(*Zeros);
Dcl-S User_Score Int(10) Inz(*Zeros);
Dcl-S Comp_Score Int(10) Inz(*Zeros);
Dcl-S Add_To_Tail Int(10) Inz(*Zeros);

// Use with data queue
Dcl-S QNam Char(10) Inz('GU007DQ');
Dcl-S QLib Char(10) Inz('*LIBL');
Dcl-S QLen Packed(5) Inz(*Zeros);
Dcl-S QMsg Char(640) Inz(*Blanks);
Dcl-S QWait Packed(5) Inz(1);

// Use with sleep
Dcl-S Warn Int(10) Inz(*Zeros);
Dcl-S SleepTime Int(10) Inz(300000);

// Parameters list
Dcl-Pr WrcvDtaq ExtPgm('QRCVDTAQ');
    *n like(QNam);
    *n like(QLib);
    *n like(QLen);
    *n like(QMsg);
    *n like(QWait);
End-Pr;

// For #Repeat Tag in main program
Dcl-S Repeat_Exit Ind Inz(*Off);

// Main logic
ExSr SrInit;

DoW (*In03 = *Off) And (*In12 = *Off);
    ExSr SrPutToScreen;

    Write(E) D01;
    *In31 = %error;
    If (*In31 = *On) And (QMsgTyp = 'CPF' And QMsgNbr = '4737');
        Read D01;
    EndIf;

    QLen = *Zeros;
    QMsg = *Blanks;
    QWait = *Zeros;
    WrcvDtaq(QNam : QLib : QLen : QMsg : QWait);

    Reset Repeat_Exit;
    DoW *On; // #Repeat Tag
        If (QLen > *Zeros);
            Read D01;
            If (*In03 = *On) Or (*In12 = *On);
                Repeat_Exit = *On;
                Leave;
            EndIf;
        Else;
            Warn = Sleep(SleepTime);
            QLen = *Zeros;
            QMsg = *Blanks;
            QWait = *Zeros;
            WrcvDtaq(QNam : QLib : QLen : QMsg : QWait);
            If (QLen > *Zeros);
               Iter;
            EndIf;
        EndIf;

        Leave;
    EndDo;
    If (Repeat_Exit = *On);
        Iter;
    EndIf;

    If (Ind_EndGame = *Off);
        Time_CurMove = %timestamp(*UNIQUE);
        Time_Secs = %diff(Time_CurMove : Time_LstMove : *Ms);
        If (Time_Secs >= 299999);
            ExSr SrCheckMove;
            ExSr SrAutoMove;
            ExSr SrAutoMove2;
        EndIf;
    EndIf;
EndDo;
*Inlr = *On;
Return;

// SrCheckMove Sub Routine
// Check movement made
BegSr SrCheckMove;
    Time_LstMove = (Time_CurMove);

    Select;
        When (WInput = 'I') And (Snake_Heading <> 'S');
            Snake_Heading = 'N';

        When (WInput = 'K') And (Snake_Heading <> 'N');
            Snake_Heading = 'S';

        When (WInput = 'J') And (Snake_Heading <> 'E');
            Snake_Heading = 'W';

        When (WInput = 'L') And (Snake_Heading <> 'W');
            Snake_Heading = 'E';
    EndSl;
EndSr;

// SrAutoMove Sub Routine
// Automatically move the snake forward
BegSr SrAutoMove;
    Snake_Cur_X = (Snake_Prev_X(1));
    Snake_Cur_Y = (Snake_Prev_Y(1));

    Select;
        When (Snake_Heading = 'N');
            Snake_Cur_X -= 1;
            If (Snake_Cur_X < 1);
                Snake_Cur_X = 10;
            EndIf;

        When (Snake_Heading = 'S');
            Snake_Cur_X += 1;
            If (Snake_Cur_X > 10);
                Snake_Cur_X = 1;
            EndIf;

        When (Snake_Heading = 'W');
            Snake_Cur_Y -= 1;
            If (Snake_Cur_Y < 1);
                Snake_Cur_Y = 50;
            EndIf;

        When (Snake_Heading = 'E');
            Snake_Cur_Y += 1;
            If (Snake_Cur_Y > 50);
                Snake_Cur_Y = 1;
            EndIf;
    EndSl;

    // Clear the previous buffer
    Clear SnakePos_Char;
    ExSr SrPlaceFood;

    // Get current position
    // Move the body only
    If (Snake_Grow > *Zeros);
        If (Add_To_Tail = (Snake_Length - 1));
            Add_To_Tail = *Zeros;
            Snake_Prev_X(Snake_Length + 1) = Snake_Prev_X(Snake_Length);
            Snake_Prev_Y(Snake_Length + 1) = Snake_Prev_Y(Snake_Length);
            Result = (50 * (Snake_Prev_X(Snake_Length + 1) - 1) + Snake_Prev_Y(Snake_Length + 1));
            SnakePos_Arr(Result) = ('o');
        Else;
            Add_To_Tail += 1;
        EndIf;
    EndIf;

    For Snake_Prev_Cnt = Snake_Length DownTo 2;
        Snake_Prev_X(Snake_Prev_Cnt) = Snake_Prev_X(Snake_Prev_Cnt - 1);
        Snake_Prev_Y(Snake_Prev_Cnt) = Snake_Prev_Y(Snake_Prev_Cnt - 1);
        Result = (50 * (Snake_Prev_X(Snake_Prev_Cnt) - 1) + Snake_Prev_Y(Snake_Prev_Cnt));
        SnakePos_Arr(Result) = ('o');
    EndFor;

    If (Snake_Grow > *Zeros) And (Add_To_Tail = *Zeros);
        Snake_Grow -= 1;
        Snake_Length += 1;
        If (Snake_Grow > *Zeros);
            Add_To_Tail += 1;
        EndIf;
    EndIf;

    // Move head
    Snake_Prev_X(1) = (Snake_Cur_X);
    Snake_Prev_Y(1) = (Snake_Cur_Y);
    Result = (50 * (Snake_Prev_X(1) - 1) + Snake_Prev_Y(1));
    If (SnakePos_Arr(Result) <> (*Blanks));
        ExSr SrBlockUsed;
    EndIf;

    If (Ind_EndGame = *On);
        WStatus = 'GAME OVER';
        LeaveSr;
    EndIf;
    SnakePos_Arr(Result) = ('$');

    // Place food block
    ExSr SrPlaceFood;
EndSr;

// SrAutoMove2 Sub Routine
// Automatically move the snake forward
BegSr SrAutoMove2;
    Snak2_Cur_X = (Snak2_Prev_X(1));
    Snak2_Cur_Y = (Snak2_Prev_Y(1));

    // Find out where to move next
    Snake_Food_X = Snak2_Food / 50;
    Snake_Food_Y = %Rem(Snak2_Food : 50);

    If ((Snak2_Cur_X - 1) = Snake_Food_X);
        If (Snak2_Cur_Y < Snake_Food_Y);
            Snak2_Heading = 'E';
        ElseIf (Snak2_Cur_Y > Snake_Food_Y);
            Snak2_Heading = 'W';
        EndIf;
    ElseIf (Snak2_Cur_Y = Snake_Food_Y);
        If ((Snak2_Cur_X - 1) < Snake_Food_X);
            Snak2_Heading = 'S';
        ElseIf ((Snak2_Cur_X - 1) > Snake_Food_X);
            Snak2_Heading = 'N';
        EndIf;
    EndIf;

    Select;
        When (Snak2_Heading = 'N');
            Snak2_Cur_X -= 1;
            If (Snak2_Cur_X < 1);
                Snak2_Cur_X = 10;
            EndIf;

        When (Snak2_Heading = 'S');
            Snak2_Cur_X += 1;
            If (Snak2_Cur_X > 10);
                Snak2_Cur_X = 1;
            EndIf;

        When (Snak2_Heading = 'W');
            Snak2_Cur_Y -= 1;
            If (Snak2_Cur_Y < 1);
                Snak2_Cur_Y = 50;
            EndIf;

        When (Snak2_Heading = 'W');
            Snak2_Cur_Y += 1;
            If (Snak2_Cur_Y > 50);
                Snak2_Cur_Y = 1;
            EndIf;
    EndSl;

    // Get curent position
    // Move the body only
    If (Snak2_Grow > *Zeros);
        If (Add_To_Tail = (Snak2_Length - 1));
            Add_To_Tail = *Zeros;
            Snak2_Prev_X(Snak2_Length + 1) = Snak2_Prev_X(Snak2_Length);
            Snak2_Prev_Y(Snak2_Length + 1) = Snak2_Prev_Y(Snak2_Length);
            Result = (50 * (Snak2_Prev_X(Snak2_Length + 1) - 1) + Snak2_Prev_Y(Snak2_Length + 1));
            SnakePos_Arr(Result) = ('x');
        Else;
            Add_To_Tail += 1;
        EndIf;
    EndIf;

    For Snak2_Prev_Cnt = Snak2_Length DownTo 2;
        Snak2_Prev_X(Snak2_Prev_Cnt) = Snak2_Prev_X(Snak2_Prev_Cnt - 1);
        Snak2_Prev_Y(Snak2_Prev_Cnt) = Snak2_Prev_Y(Snak2_Prev_Cnt - 1);
        Result = (50 * (Snak2_Prev_X(Snak2_Prev_Cnt) - 1) + Snak2_Prev_Y(Snak2_Prev_Cnt));
        SnakePos_Arr(Result) = ('x');
    EndFor;

    If (Snak2_Grow > *Zeros) And (Add_To_Tail = *Zeros);
        Snak2_Grow -= 1;
        Snak2_Length += 1;
        If (Snak2_Grow > *Zeros);
            Add_To_Tail += 1;
        EndIf;
    EndIf;

    // Move head
    Snak2_Prev_X(1) = (Snak2_Cur_X);
    Snak2_Prev_Y(1) = (Snak2_Cur_Y);
    Result = (50 * (Snak2_Prev_X(1) - 1) + Snak2_Prev_Y(1));
    If (SnakePos_Arr(Result) <> (*Blanks));
        ExSr SrBlockUse2;
    EndIf;

    If (Ind_EndGame = *On);
        WStatus = 'GAME OVER';
    EndIf;
    SnakePos_Arr(Result) = ('@');
EndSr;

// SrBlockUsed Sub Routine
// Check if the block is already occupied
BegSr SrBlockUsed;
    Select;
        // Economy Class points
        When (SnakePos_Arr(Result) = 'Y');
            User_Score += 1;
            Snake_Grow += 1;
            ExSr SrRand;

        // Raffles Class or Business Class points
        When (SnakePos_Arr(Result) = 'C');
            User_Score += 8;
            Snake_Grow += 1;
            ExSr SrRand;

        // First Class points
        When (SnakePos_Arr(Result) = 'F');
            User_Score += 10;
            Snake_Grow += 1;
            ExSr SrRand;

        // The snake ran into itself, game over !
        Other;
            Ind_EndGame = *On;
    EndSl;
EndSr;

// SrBlockUse2 Sub Routine
// Check if the block is already occupied
BegSr SrBlockUse2;
    Select;
        // Economy Class points
        When (SnakePos_Arr(Result) = 'Y');
            User_Score += 1;
            Snak2_Grow += 1;
            ExSr SrRand;

        // Raffles Class or Business Class points
        When (SnakePos_Arr(Result) = 'C');
            User_Score += 8;
            Snak2_Grow += 1;
            ExSr SrRand;

        // First Class points
        When (SnakePos_Arr(Result) = 'F');
            User_Score += 10;
            Snak2_Grow += 1;
            ExSr SrRand;

        // The snake ran into itself, game over !
        Other;
            Ind_EndGame = *On;
    EndSl;
EndSr;

// SrPutToScreen Sub Routine
// Move program data to display
BegSr SrPutToScreen;
    // Move the block elements
    WLine01 = (%Subst(SnakePos_Char : 001 : 50));
    WLine02 = (%Subst(SnakePos_Char : 051 : 50));
    WLine03 = (%Subst(SnakePos_Char : 101 : 50));
    WLine04 = (%Subst(SnakePos_Char : 151 : 50));
    WLine05 = (%Subst(SnakePos_Char : 201 : 50));
    WLine06 = (%Subst(SnakePos_Char : 251 : 50));
    WLine07 = (%Subst(SnakePos_Char : 301 : 50));
    WLine08 = (%Subst(SnakePos_Char : 351 : 50));
    WLine09 = (%Subst(SnakePos_Char : 401 : 50));
    WLine10 = (%Subst(SnakePos_Char : 451 : 50));

    // Move score information
    WScore = User_Score;
    WScor2 = Comp_Score;
    WLength = Snake_Length;
    WLengt2 = Snak2_Length;
EndSr;

// SrRand Sub Routine
// Generate random number using ILE C function
BegSr SrRand;
    Snake_Food = *Zeros;

    Dow *On;
        Temp_Rand = (GetRandom());
        If (Temp_Rand > 1001);
            Temp_Rand /= 50;
        EndIf;

        If (Temp_Rand > 500);
            DoW (Temp_Rand > 500);
                Temp_Rand -= 500;
            EndDo;
        EndIf;

        If SnakePos_Arr(Temp_Rand) = (*Blanks);
            Snake_Food = Temp_Rand;
        EndIf;

        If (Snake_Food = *Zeros);
            Iter;
        EndIf;

        Leave;
    EndDo;
EndSr;

// SrPlaceFood Sub Routine
// Plac food for snake
BegSr SrPlaceFood;
    Select;
        // First Class meals = 10 points
        // (You've got to fly Singapore Airlines to know what I mean !)
        When (Snake_Food = 123) Or
             (Snake_Food = 456) Or
             (Snake_Food = 321) Or
             (Snake_Food = 497) Or
             (Snake_Food = 135) Or
             (Snake_Food = 498) Or
             (Snake_Food = 246) Or
             (Snake_Food = 155) Or
             (Snake_Food = 255) Or
             (Snake_Food = 355) Or
             (Snake_Food = 455) Or
             (Snake_Food = 122) Or
             (Snake_Food = 322) Or
             (Snake_Food = 331);
             SnakePos_Arr(Snake_Food) = ('F');

        // Raffles Class or Business Class meals = 5 points
        // (You've got to fly Singapore Airlines to know what I mean !)
        When (Snake_Food = 011) Or
             (Snake_Food = 022) Or
             (Snake_Food = 033) Or
             (Snake_Food = 044) Or
             (Snake_Food = 055) Or
             (Snake_Food = 066) Or
             (Snake_Food = 077) Or
             (Snake_Food = 088) Or
             (Snake_Food = 099) Or
             (Snake_Food = 111) Or
             (Snake_Food = 222) Or
             (Snake_Food = 333) Or
             (Snake_Food = 444) Or
             (Snake_Food = 499);
             SnakePos_Arr(Snake_Food) = ('C');

        // Economy Class meals = 1 point
        Other;
            SnakePos_Arr(Snake_Food) = ('Y');
    EndSl;
EndSr;

// SrInit Sub Routine
// Program initialize routine
BegSr SrInit;
    // Initialize snaje length
    Snake_Length = 2;
    Snak2_Length = 2;

    // Initialize snake position
    // Get head
    Pos_X = 5;
    Pos_Y = 25;
    Result = (50 * (Pos_X - 1) + Pos_Y);
    SnakePos_Arr(Result) = ('$');
    // Get body
    Pos_X = 6;
    Pos_Y = 25;
    Result = (50 * (Pos_X - 1) + Pos_Y);
    SnakePos_Arr(Result) = ('o');

    // Get head
    Pos_X = 3;
    Pos_Y = 23;
    Result = (50 * (Pos_X - 1) + Pos_Y);
    SnakePos_Arr(Result) = ('@');
    // Get body
    Pos_X = 2;
    Pos_Y = 23;
    Result = (50 * (Pos_X - 1) + Pos_Y);
    SnakePos_Arr(Result) = ('x');

    // Initialize snake path
    Snake_Heading = 'N';
    Snake_Prev_X(1) = 5;
    Snake_Prev_Y(1) = 25;
    Snake_Prev_X(2) = 6;
    Snake_Prev_Y(2) = 25;

    Snak2_Heading = 'S';
    Snak2_Prev_X(1) = 3;
    Snak2_Prev_Y(1) = 23;
    Snak2_Prev_X(2) = 2;
    Snak2_Prev_Y(2) = 23;

    // Get time
    Time_LstMove = %timestamp(*UNIQUE);

    // Get food back
    ExSr SrRand;
    ExSr SrPlaceFood;
EndSr;
