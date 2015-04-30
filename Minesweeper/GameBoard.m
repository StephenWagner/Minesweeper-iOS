//
//  GameBoard.m
//  Minesweeper
//
//  Created by Stephen Wagner on 3/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "GameBoard.h"
#import "Constants.h"

@interface GameBoard()

@property (nonatomic) BOOL firstClick;
@property (nonatomic) BOOL speedyOpenOk;

@end


@implementation GameBoard


/**
 * Creates a new game board with a medium difficulty, i.e. 16 rows, 16 columns and 40 total mines.
 */
-(instancetype) init{
    return [self initWithRows:MEDIUM andColumns:MEDIUM andNumberOfMines:40];
}

/**
 * Create a custom sized minesweeper game board by specifying the number of rows and columns you want, and the total
 * number of mines.
 *
 * @param row
 *            Row position, as in array[row][column]. This is the y-position cell on a screen (zero-based).
 * @param col
 *            Column position, as in array[row][column]. This is the x-position cell on a screen (zero-based).
 * @param mines
 *            Total number of mines you want in your new board.
 */
-(instancetype) initWithRows: (NSInteger)row andColumns: (NSInteger)col andNumberOfMines: (NSInteger)mines{
    [self newGameWithNumberOfRows:row andColumns:col andMines:mines];
    return self;
}

/**
 * Creates a new minesweeper game board with a specified difficulty. Easy = 9 rows, 9 columns, 10 mines. Medium = 16
 * rows, 16 columns, 40 mines. Hard = 30 rows, 16 columns, 99 mines.
 *
 * @param difficulty
 *            must be either "Easy" or "Hard" -- any other String will initialize it as medium.
 */
-(instancetype) initWithDifficulty: (NSString*)difficulty{
    self.difficulty = difficulty;
    
    if ([difficulty isEqualToString:@"Easy"]) {
        return [self initWithRows:EASY andColumns:EASY andNumberOfMines:10];
    }else if([difficulty isEqualToString:@"Hard"]){
        return [self initWithRows:HARD andColumns:MEDIUM andNumberOfMines:99];
    }else{
        return [self initWithRows:MEDIUM andColumns:MEDIUM andNumberOfMines:40];
    }
}

//used to set the board of every game
-(void) newGameWithNumberOfRows: (NSInteger)numRows andColumns: (NSInteger)numCol andMines: (NSInteger)mines{
    
    self.totMines = mines;
    self.totalColumns = numCol;
    self.totalRows = numRows;
    
    self.hintsRemaining = 3;
    self.firstClick = YES;
    self.speedyOpenOk = YES;
    self.gameOver = NO;
    self.totFlags = 0;
    
    //initialize the nsarray board property
    self.board = [[NSMutableArray alloc]initWithCapacity:numRows];

    for (int i=0; i < numRows; i++) {
        self.board[i] = [[NSMutableArray alloc]initWithCapacity:numCol];
    }
    
    for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < numCol; j++) {
            self.board[i][j]  = [[Cell alloc]init];
        }
    }
    
    NSLog(@"rows: %ld, cols: %ld, mines: %ld", self.totalRows, self.totalColumns, self.totMines);
    
    if (numRows == 16 && numCol == 16 && mines == 40) {
        self.difficulty = @"Normal";
    }else if (numRows == 9 && numCol == 9 && mines == 10){
        self.difficulty = @"Easy";
    }else if (numRows == 30 && numCol == 16 && mines == 99){
        self.difficulty = @"Hard";
    }
}


/**
 * Flags a cell. If already flagged, it will un-flag the cell. You must pass in the row and column of the cell which
 * you would like to toggle, represented by a double-dimensional array: array[row][col].
 *
 * @param row
 *            Row position, as in array[row][column]. This is the y-position cell on a screen (zero-based).
 * @param col
 *            Column position, as in array[row][column]. This is the x-position cell on a screen (zero-based).
 * */
-(void) toggleFlagWithRow: (NSInteger)row andColumn: (NSInteger)col{
    
    if ([self.board[row][col] hidden]) {
        BOOL current = [self.board[row][col] flagged];
        
        if (current) {
            [self.board[row][col] setImage:[UIImage imageNamed:@"CellHidden"]];
            self.totFlags--;
        }else{
            [self.board[row][col] setImage:[UIImage imageNamed:@"CellFlagged"]];
            self.totFlags++;
        }
        
        [self.board[row][col] setFlagged:!current];        
    }
}

-(void) firstClickWithRow: (NSInteger)row andCol: (NSInteger)col{
    NSInteger numY, numX, mineCount = 0;
    
    while (mineCount < self.totMines) {
        numY = arc4random_uniform((uint32_t)self.totalRows);
        numX = arc4random_uniform((uint32_t)self.totalColumns);
        
        if (![self.board[numY][numX] mined] && [self checkPlacementWithClickedRow:row andClickedCol:col andCheckingRow:numY andCheckingCol:numX]) {
            [self.board[numY][numX] setMined:YES];
            mineCount++;
        }
    }
    
    for (int i = 0; i < self.totalRows; i++){
        for (int j = 0; j < self.totalColumns; j++) {
            if (![self.board[i][j] mined]) {
                [self.board[i][j] setMinesClose:[self minesCloseWithRow:i andCol:j]];
            }
        }
    }
    
    self.firstClick = NO;
    [self revealWithRow:row andCol:col];
}


-(BOOL) checkPlacementWithClickedRow: (NSInteger)y andClickedCol: (NSInteger)x andCheckingRow: (NSInteger)numY andCheckingCol: (NSInteger)numX{

    for (NSInteger i = y - 1; i <= y + 1; i++) {
        for (NSInteger j = x - 1; j <= x + 1; j++) {
            if (numY == i & numX == j)
                return NO;
        }
    }
    
    return YES;
    
}


-(int) minesCloseWithRow: (NSInteger)row andCol: (NSInteger)col{
    int count = 0;
    
    for (NSInteger i = row-1; i <= row+1; i++){
        for (NSInteger j = col-1; j <= col+1; j++){
            if (![self outOfBoundsWithRow:i andCol:j]){
                if ([self.board[i][j] mined]){
                    count++;
                }
            }
        }
    }
    
    return count;
}


-(BOOL) outOfBoundsWithRow: (NSInteger)row andCol: (NSInteger)col{
    return col < 0 || row < 0 || row >= self.totalRows || col >= self.totalColumns;
}


/**
 * When a mine is selected to be revealed (clicked on in a game), use this function to reveal it. You must pass in
 * the row and column of the cell to be revealed like a double-dimensional array: array[row][column]. This will
 * recursively open spaces that are empty with no mines around it.
 *
 * @param col
 *            Column position, as in array[row][column]. This is the x-position cell on a screen (zero-based).
 * @param row
 *            Row position, as in array[row][column]. This is the y-position cell on a screen (zero-based).
 * @return TRUE if the cell is clear, FALSE only if the cell has a mine in it.
 */
-(BOOL) revealWithRow: (NSInteger)row andCol: (NSInteger)col{
    /*-
     * All the possibilities of tiles to reveal:
     * 0. it is not hidden
     * 1. it is hidden, it has 0 mines close to it
     * 2. it is hidden, it has one of more mines close to it
     * 3. it is hidden, it has a mine in it
     * 4. it is not hidden, it has a number of mines close to it,
     * 	it has the same number of flags close to it.
     */
    
    
    if ([self outOfBoundsWithRow:row andCol:col])
        return YES;
    
    if (self.firstClick)
        [self firstClickWithRow:row andCol:col];
    
    //check user defaults
    // 4. it is not hidden, it has a number of mines close to it, it has the same number of flags close to it.
    if ([[NSUserDefaults standardUserDefaults]boolForKey:keyQuickOpen] && self.speedyOpenOk && ![self.board[row][col] hidden] && [self.board[row][col] minesClose] > 0 && [self sameNumberOfFlagsWithRow:row andCol:col]) {
        self.speedyOpenOk = NO;
        if ([self speedyOpenerWithRow:row andCol:col]) {
            self.speedyOpenOk = YES;
            return true;
        } else {
            self.speedyOpenOk = YES;
            return false;
        }
    }

    
    // 0. it is not hidden
    if (![self.board[row][col] hidden])
        return true;
    
    // 1. it is hidden, it is not mined, it has 0 mines close to it,
    // recursively reveal all others like it
    if (![self.board[row][col] mined] && [self.board[row][col] minesClose] == 0) {
        [self.board[row][col] setHidden:NO];
        [self.board[row][col] setImage:[UIImage imageNamed:@"CellRevealed"]];

        [self revealWithRow:row-1 andCol:col-1];    // above and left
        [self revealWithRow:row-1 andCol:col];      // above
        [self revealWithRow:row-1 andCol:col+1];    // above and right
        [self revealWithRow:row andCol:col-1];      // left
        [self revealWithRow:row andCol:col+1];      // right
        [self revealWithRow:row+1 andCol:col-1];    // below and left
        [self revealWithRow:row+1 andCol:col];      // below
        [self revealWithRow:row+1 andCol:col+1];    // below and right
        return YES;
    }
    
    // 2. it is hidden, it has one or more mines close to it
    if ([self.board[row][col] minesClose] > 0) {
        [self.board[row][col] setHidden:NO];
        [self.board[row][col] setButtonTitle:[NSString stringWithFormat:@"%d", [self.board[row][col] minesClose]]];
        [self.board[row][col] setImage:[UIImage imageNamed:@"CellRevealed"]];

        return YES;
    }
    
    // 3. it is hidden, it has a mine in it
    if ([self.board[row][col] mined] && ![self.board[row][col] flagged]) {
        [self gameOverWithRow:row andCol:col];
        return NO;
    }
    
    return YES;
}


/**
 * This is used when the user clicks on a space which has a number on it AND the immediate surrounding cells have
 * the same number of flags on them as the number on the cell which was clicked on. In other words, use only if
 * GameBoard.sameNumberOfFlags(int row, int col) returns TRUE for the cell which the user clicked on. This is
 * already implemented in the GameBoard.reveal(row, col) method.
 *
 * @param row
 *            Row position, as in array[row][column]. This is the y-position cell on a screen (zero-based).
 * @param col
 *            Column position, as in array[row][column]. This is the x-position cell on a screen (zero-based).
 */
-(BOOL) speedyOpenerWithRow: (NSInteger)row andCol: (NSInteger)col{
    //4. it is not hidden, it has a number of mines close to it, it has the same number of flags close to it
    for (NSInteger i = row-1; i <= row+1; i++) {
        for (NSInteger j = col-1; j <= col+1; j++) {
            if (![self outOfBoundsWithRow:i andCol:j]) {
                if (![self.board[i][j] flagged])
                    if (![self revealWithRow:i andCol:j]) {
                        return NO;
                    }
            }
        }
    }
    
    return YES;
}

/**
 * Use this method when the user clicks on a cell which is already cleared (GameBoard.getHidden(row, col) returns
 * false) and the cell has a number on it greater than 0 (GameBoard.getMinesClose(row, col) returns > 0). Example of
 * how to use it in a click event:
 *
 * <pre>
 * if (!board.getHidden(ySq, xSq) &amp;&amp; board.getMinesClose(ySq, xSq) &gt; 0 &amp;&amp; board.sameNumberOfFlags(ySq, xSq)) {
 *     board.speedyOpener(ySq, xSq);
 * } else
 *     board.reveal(xSq, ySq);
 * </pre>
 *
 * @param row
 *            Row position, as in array[row][column]. This is the y-position cell on a screen (zero-based).
 * @param col
 *            Column position, as in array[row][column]. This is the x-position cell on a screen (zero-based).
 * @return True only if the cell which was clicked on has the same number of flags immediately surrounding it as it
 *         has mines immediately surrounding it.
 */
-(BOOL) sameNumberOfFlagsWithRow: (NSInteger)row andCol: (NSInteger)col{
    int count = 0;

    for (NSInteger i = row - 1; i <= row + 1; i++) {
        for (NSInteger j = col - 1; j <= col + 1; j++) {
            if (![self outOfBoundsWithRow:i andCol:j])
                if ([self.board[i][j] flagged])
                    count++;
        }
    }
    
    return count == [self.board[row][col] minesClose];
}


//============================================================
#pragma mark - End of Game Behavior
/**
 * Use this method to determine if the player has won the game. If the player has won, it will make every mined cell
 * flagged.
 *
 * @return True if all non-mined cells have been revealed.
 */
-(BOOL) winner{
    int revealed = 0;
    
    for (int i = 0; i < self.totalRows; i++)
        for (int j = 0; j < self.totalColumns; j++) {
            if (![self.board[i][j] hidden])
                revealed++;
        }
    
    if (revealed == self.totalRows * self.totalColumns - self.totMines) {
        [self makeAllMinesFlagged];
        self.totFlags = self.totMines;
    }
    
    return revealed == self.totalRows * self.totalColumns - self.totMines && !self.gameOver;

}


-(void) makeAllMinesFlagged{
    for (int i = 0; i < self.totalRows; i++)
        for (int j = 0; j < self.totalColumns; j++) {
            if ([self.board[i][j] mined]){
                [self.board[i][j] setFlagged:YES];
                [self.board[i][j] setImage:[UIImage imageNamed:@"CellFlagged"]];
            }
        }
}

-(void)gameOverWithRow: (NSInteger)row andCol: (NSInteger)col{
    self.exploded = self.board[row][col];
    [self.board[row][col] setBlown:YES];
    [self.board[row][col] setImage:[UIImage imageNamed:@"CellExploded"]];
    self.gameOver = YES;
    
    for (int i = 0; i < self.totalRows; i++)
        for (int j = 0; j < self.totalColumns; j++) {
            if ([self.board[i][j] flagged] && ![self.board[i][j] mined]) {
                [self.board[i][j] setImage:[UIImage imageNamed:@"CellFlaggedIncorrectly"]];
            }
        }

    NSLog(@"finished gameOver");
}

-(float)getPercentFinished{
    float totalCells, clearedCells, percentFinished;
    
    totalCells = self.totalRows * self.totalColumns;
    clearedCells = [self totalClearedCells];
    percentFinished = (clearedCells*100)/totalCells;
    
    return percentFinished;
}

-(float)totalClearedCells{
    int totalClearedCells = 0;
    
    for (int i = 0; i < self.totalRows; i++) {
        for (int j = 0; j < self.totalColumns; j++) {
            if ([self correctlyCompletedCellWithRow:i andCol:j]) {
                totalClearedCells++;
            }
        }
    }
    
    return totalClearedCells;
}

-(BOOL)correctlyCompletedCellWithRow: (NSInteger)row andCol: (NSInteger)col{
//     A cell has been correctly done if it is:
//     1. revealed and not mined
//     2. flagged and mined

    Cell *cell = self.board[row][col];
    return (!cell.hidden && !cell.mined) || (cell.flagged && cell.mined);
}

//=================================================
#pragma mark - Timer Functions
-(void)startTimerWithOffset: (BOOL)doOffset{
    if (doOffset) {
        self.time = (NSInteger)(floor(self.elapsedTime));
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 1 - (self.elapsedTime - floor(self.elapsedTime)) target:self selector:@selector((addTime:)) userInfo:OFFSETTIMER repeats:NO];
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTime:) userInfo:MAINTIMER repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
}

-(void)stopTimer{
    if ([self.timer isValid]) {
        self.endTime = [NSDate timeIntervalSinceReferenceDate];
        self.elapsedTime += self.endTime - self.startTime;
        [self.timer invalidate];        
    }
}

-(void)addTime: (NSTimer *)sender{
    self.time++;
    
    if ([sender.userInfo  isEqual: OFFSETTIMER]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTime:) userInfo:MAINTIMER repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - Encoding functions
-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeBool:self.firstClick forKey:keyFirstClick];
    [encoder encodeBool:self.speedyOpenOk forKey:keySpeedyOpenOK];
    [encoder encodeInteger:self.totalRows forKey:keyTotalRows];
    [encoder encodeInteger:self.totalColumns forKey:keyTotalColumns];
    [encoder encodeInteger:self.totMines forKey:keyTotalMines];
    [encoder encodeInteger:self.totFlags forKey:keyTotalFlags];
    [encoder encodeBool:self.gameOver forKey:keyGameOver];
    [encoder encodeObject:self.exploded forKey:keyExploded];
    [encoder encodeDouble:self.elapsedTime forKey:keyElapsedTime];
    [encoder encodeInteger:self.hintsRemaining forKey:keyHintsRemain];
    [encoder encodeObject:self.board forKey:keyBoard];
}

- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        self.firstClick = [decoder decodeBoolForKey:keyFirstClick];
        self.speedyOpenOk = [decoder decodeBoolForKey:keySpeedyOpenOK];
        self.totalRows = [decoder decodeIntegerForKey:keyTotalRows];
        self.totalColumns = [decoder decodeIntegerForKey:keyTotalColumns];
        self.totMines = [decoder decodeIntegerForKey:keyTotalMines];
        self.totFlags = [decoder decodeIntegerForKey:keyTotalFlags];
        self.gameOver = [decoder decodeBoolForKey:keyGameOver];
        self.exploded = [decoder decodeObjectForKey:keyExploded];
        self.elapsedTime = [decoder decodeDoubleForKey:keyElapsedTime];
        self.time = (NSInteger)floor(self.elapsedTime);
        self.hintsRemaining = [decoder decodeIntegerForKey:keyHintsRemain];
        self.board = [decoder decodeObjectForKey:keyBoard];
        
        self.time = (NSInteger)floor(self.elapsedTime);
    }
    return self;
}


@end
