
import Data.Char
import Data.List
import Text.XHtml (rows)

import Data.List

data PieceType = Pawn | King | Bishop | Knight | Queen | Rook deriving (Show, Eq)
data Side = Black | White deriving (Show, Eq)

type Pos = (Int, Int) -- (x, y) 

--to keep track of each piece
type Piece = (PieceType, Side)

--to navigate the squares around a piece
type Square = (Pos, Piece)
type Board = [Square]

--maybe isCheck, isCheckMate
type Move = (Square, Pos)

-- (currentBoard, currentSideTurn)
type Game = (Board, Side)

initialBoard :: Board 
-- change to Board type 
initialBoard = [((1, 1), (Rook, White)),
                ((2, 1), (Knight, White)),
                ((3, 1), (Bishop, White)),
                ((4, 1), (Queen, White)),
                ((5, 1), (King, White)),
                ((6, 1), (Bishop, White)),
                ((7, 1), (Knight, White)),
                ((8, 1), (Rook, White)),
                
                ((1, 2), (Pawn, White)),
                ((2, 2), (Pawn, White)),
                ((3, 2), (Pawn, White)),
                ((4, 2), (Pawn, White)),
                ((5, 2), (Pawn, White)),
                -- ((5, 3), (Pawn, White)),
                ((6, 2), (Pawn, White)),
                ((7, 2), (Pawn, White)),
                ((8, 2), (Pawn, White)),

                ((1, 7), (Pawn, Black)),
                ((2, 7), (Pawn, Black)),
                ((3, 7), (Pawn, Black)),
                ((4, 7), (Pawn, Black)),
                ((5, 7), (Pawn, Black)),
                ((6, 7), (Pawn, Black)),
                ((7, 7), (Pawn, Black)),
                ((8, 7), (Pawn, Black)),
                
                ((1, 8), (Rook, Black)),
                ((2, 8), (Knight, Black)),
                ((3, 8), (Bishop, Black)),
                ((4, 8), (Queen, Black)),
                ((5, 8), (King, Black)),
                ((6, 8), (Bishop, Black)),
                ((7, 8), (Knight, Black)),
                ((8, 8), (Rook, Black))
                ]

--                                        SHOWING BOARD

showPiece :: Piece -> String
showPiece (Rook, Black) = " ♖ "
showPiece (Knight, Black) = " ♘ "
showPiece (Bishop, Black) = " ♗ "
showPiece (Queen, Black) = " ♕ "
showPiece (King, Black) = " ♔ "
showPiece (Pawn, Black) = " ♙ "
showPiece (Rook, White) = " ♜ "
showPiece (Knight, White) = " ♞ "
showPiece (Bishop, White) = " ♝ "
showPiece (Queen, White) = " ♛ "
showPiece (King, White) = " ♚ "
showPiece (Pawn, White) = " ♟ "


-- Returns a string representing specified row on the board
showRow :: Int -> Side -> Board -> String
showRow y White board = concat $ [show y, "  "] ++ intersperse "|" [getPiece (x,y) board | x <- [1..8]]
showRow y Black board = concat $ [show y, "  "] ++ intersperse "|" [getPiece (x,y) board | x <- [8, 7..1]]

-- Returns a string of the piece symbol at the given location on the board
getPiece :: Pos -> Board -> String
getPiece pos board = case lookup pos board of
                        Just piece -> showPiece piece
                        Nothing -> "   "

-- Converts a board to a string when printed to output. 
-- If not printed to output, newlines and pieces are not displayed properly. 
showBoard :: Board -> Side -> String
showBoard board Black = showBoardBlack board
showBoard board White = showBoardWhite board

-- Converts a board to a string from black's perspective (black is on the bottom).
showBoardBlack :: Board -> String
showBoardBlack board = 
    let rows = [showRow y Black board | y <- [1..8]]
        separator = "   " ++ replicate (31) '-'
        coordinateLine = concat $ intersperse "   " ["", "8", "7", "6", "5", "4", "3", "2", "1"]
    in unlines (intersperse separator rows) ++ "\n " ++ coordinateLine

-- Converts a board to a string from white's perspective (white is on the bottom).
showBoardWhite :: Board -> String
showBoardWhite board = 
    let rows = [showRow y White board | y <- [8, 7..1]]
        separator = "   " ++ replicate (31) '-'
        coordinateLine = concat $ intersperse "   " ["", "1", "2", "3", "4", "5", "6", "7", "8"]
    in unlines (intersperse separator rows) ++ "\n " ++ coordinateLine


--                                            GENERATING MOVES

--TODO: pawn is taking into account legal moves too, maybe change this
generatePawnMoves :: (Pos,Piece) -> Board -> [Pos]
generatePawnMoves ((x,y), (Pawn, side)) board = 
    let pushOnce = case side of
            White -> [(x, y+1)| y+1 <= 8, isNothing (lookup (x,y+1) board)]
            Black -> [(x, y - 1) | y - 1 >= 1, isNothing (lookup (x, y - 1) board)]
        pushTwice = case side of
            White -> [(x,y+2)| y+2 <= 8, isNothing (lookup (x,y+2) board), isNothing (lookup (x,y+1) board), y==2]
            Black -> [(x,y-2) | y-2 >= 1, isNothing (lookup(x,y-2) board), isNothing (lookup (x,y-1) board), y==7]
        captures = case side of
            White ->  [(x+dx,y+1) | dx <- [-1,1], x+dx >= 1, x+dx <= 8, isBlack (lookup (x+dx,y+1) board)]
            Black -> [(x+dx,y-1)| dx <- [-1,1], x+dx >= 1, x+dx <= 8, isWhite (lookup (x+dx,y-1) board)]
    in pushOnce ++ pushTwice ++ captures

generateBishopMoves :: (Pos,Piece) -> [Pos]
generateBishopMoves ((x,y), (Bishop, side))  = 
        let downLeftDiagonalMoves = [(x-i,y-i)|i <- [1..8], x-i <= 8, x-i>= 1, y-i<= 8, y-i >= 1]
            downRightDiagonalMoves = [(x+i,y-i)|i <- [1..8], x+i <= 8, x+i>= 1, y-i<= 8, y-i >= 1]
            upLeftDiagonalMoves = [(x-i,y+i)|i <- [1..8], x-i <= 8, x-i>= 1, y+i<= 8, y+i >= 1]
            upRightDiagonalMoves = [(x+i,y+i)|i <- [1..8], x+i <= 8, x+i>= 1, y+i<= 8, y+i >= 1]
            in downLeftDiagonalMoves ++ downRightDiagonalMoves ++ upLeftDiagonalMoves ++ upRightDiagonalMoves

generateRookMoves :: (Pos,Piece) -> [Pos]
generateRookMoves ((x,y), (Rook, side)) = 
        let rookRange = [(-8)..(-1)] ++ [1..8]
            verticalMoves = [(x,y+i) | i<- rookRange, y+i <= 8, y+i>= 1]
            horizontalMoves = [(x+i,y)|i<- rookRange, x+i <= 8, x+i >= 1]
        in (verticalMoves ++ horizontalMoves)

--TODO: lookup takes in a coordinate and outputs a piece tuple, 
--need to define a function to do the reverse, so that we can find the input position values to generate movess

isNothing :: Maybe a -> Bool
isNothing Nothing = True
isNothing (Just _) = False

isSomething :: Maybe a -> Bool
isSomething (Just _) = True
isSomething Nothing = False

isWhite :: Maybe Piece -> Bool
isWhite (Just (_, White)) = True
isWhite _ = False

isBlack :: Maybe Piece -> Bool
isBlack (Just (_, Black)) = True
isBlack _ = False

--NATE
-- given a piece and a position, return ALL POSSIBLE positions to move that piece (respecting bounds).
generateMoves :: (Pos, Piece) -> [Pos]
generateMoves ((x,y), (Rook, side)) =  generateRookMoves ((x,y), (Rook, side))
generateMoves ((x,y), (Bishop, side)) =  generateBishopMoves ((x,y), (Bishop, side))
generateMoves ((x,y), (Pawn, Black)) = undefined


-- generate a list of numbers in between two numbers not including them
numberInBetween :: Int -> Int -> [Int]
numberInBetween start end 
    | abs (start - end) <= 1 = []
    | start > end = (start - 1) : numberInBetween (start - 1) end
    | otherwise   = (start + 1) : numberInBetween (start + 1) end

isLegalMove :: Board -> Move -> Bool
isLegalMove board (((x,y), (p, s)), (x1,y1)) =
    -- can not move to the same square
    if (x == x1 && y == y1)
    then False
    else isLegalMoveAux board (((x,y), (p, s)), (x1,y1))
    
isLegalMoveAux :: Board -> Move -> Bool
isLegalMoveAux board (((x,y), (Pawn, _)), (x1,y1)) = True
isLegalMoveAux board (((x,y), (Rook, side)), (x1,y1)) 
    | x == x1 =
        let destination = lookup (x1,y1) board
            hasNothingInBetween = all (== Nothing) [lookup (x, iy) board | iy <- numberInBetween y y1]
        in case side of
            White -> not (isWhite destination) && hasNothingInBetween
            Black -> not (isBlack destination) && hasNothingInBetween
    | y == y1 =
        let destination = lookup (x1,y1) board
            hasNothingInBetween = all (== Nothing) [lookup (ix, y) board | ix <- numberInBetween x x1]
        in case side of
            White -> not (isWhite destination) && hasNothingInBetween
            Black -> not (isBlack destination) && hasNothingInBetween
    | otherwise = False

isLegalMoveAux board (((x,y), (Bishop, side)), (x1,y1)) =
    if abs (x1 - x) /= abs (y1 - y)
    then False
    else let destination = lookup (x1,y1) board
             inBetween = [lookup (ix, iy) board | ix <- numberInBetween x x1, iy <- numberInBetween y y1, abs (ix - x) == abs (iy - y)]
             hasNothingInBetween = all (== Nothing) inBetween
        in case side of 
            White -> not (isWhite destination) && hasNothingInBetween
            Black -> not (isBlack destination) && hasNothingInBetween


-- isLegalMoveAux board ((()))

legalMoves :: Board -> (Pos, Piece) -> [Pos]
legalMoves board ((x, y), (Pawn, side)) = undefined
legalMoves board ((x,y), (Rook, side)) = filter (\pos -> isLegalMove board (((x,y), (Rook, side)),pos)) (generateMoves ((x,y), (Rook, side)))
legalMoves board ((x,y), (Bishop, side)) = filter (\pos -> isLegalMove board (((x,y), (Bishop, side)),pos)) (generateMoves ((x,y), (Bishop, side)))


--OPTIMIZATION NOTES:
--IF A MOVE MAKES A KING VULNERABLE --> NOT LEGAL


-- look for king, if still have both king --> return Nothing, otherwise return winning side
win :: Board -> Maybe Side
win = undefined


--MAHAD
-- you take in a board and a move, then return a new board after the change
makeMove :: Board -> Move -> Board
makeMove board (fromSquare, toPos) = 
    let updatedBoard = [(pos, piece) | (pos, piece) <- board, pos /= fst fromSquare]
    in (toPos, snd fromSquare) : updatedBoard


-- for the solver, not do yet
-- generate all legal moves for a given color on a given turn
allLegalMoves :: Board -> Side -> [((Pos, Piece, [Pos]))]
allLegalMoves = undefined
