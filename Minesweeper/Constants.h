//
//  Constants.h
//  Minesweeper
//
//  Created by Stephen Wagner on 4/9/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#ifndef Minesweeper_Constants_h
#define Minesweeper_Constants_h

//used by MainWindowViewController
#define MAINTIMER       @"mainTimer"
#define OFFSETTIMER     @"offsetTimer"

//used by GameBoard
#define EASY            9
#define MEDIUM          16
#define HARD            30
#define TOTALHINTS      3

//keys for settings
#define keyDifficulty   @"difficulty"
#define keyNormal       @"Normal"
#define keyVibrate      @"vibrate"
#define keyPressLength  @"pressLength"
#define keyPortraitLock @"portraitLock"
#define keyQuickOpen    @"quickOpen"

//keys for observations
#define keyImage        @"image"
#define keyButtonTitle  @"buttonTitle"
#define keyGameOver     @"gameOver"
#define keyTotalFlags   @"totFlags"
#define keyTime         @"time"

//stored in Cell
#define keyMined        @"mined"
#define keyHidden       @"hidden"
#define keyFlagged      @"flagged"
#define keyBlown        @"blown"
#define keyMinesClose   @"minesClose"
#define keyRow          @"row"
#define keyCol          @"col"

//stored in GameBoard
#define keyFirstClick   @"firstClick"
#define keySpeedyOpenOK @"speedyOpenOk"
#define keyTotalRows    @"totalRows"
#define keyTotalColumns @"totalColumns"
#define keyTotalMines   @"totMines"
#define keyExploded     @"exploded"
#define keyBoard        @"board"
#define keyElapsedTime  @"elapsedTime"
#define keyHintsRemain  @"hintsRemaining"

//used by DataManager
#define keySavedGame            @"savedGameBoard"
#define keyGameWon              @"gameWon"
#define keyPercentDone          @"percentFinished"
#define keyGamesPlayed          @"gamesPlayed"
#define keyExplorationPercent   @"explorationPercentage"
#define keyCurrentLoseStreak    @"currentLoseStreak"
#define keyAverageWinTime       @"averageWinTime"
#define keyCurrentWinStreak     @"currentWinStreak"
#define keyGamesLost            @"gamesLost"
#define keyGamesWon             @"gamesWon"
#define keyLongestLoseStreak    @"longestLoseStreak"
#define keyLongestWinStreak     @"longestWinStreak"
#define keySortOrder            @"sortOrder"
#define keyWinPercent           @"winPercentage"
#define keyFastest              @"fastestWin"
#define keySecondFastest        @"secondFastestWin"
#define keyThirdFastest         @"thirdFastestWin"

#endif
