module Solver where

import Data.Char
import Data.List
import Data.Maybe
import Data.Set (Set)
import qualified Data.Set as Set

testPuzzle :: Puzzle
testPuzzle =
  Puzzle $ 
    [ [ Just 5, Just 1, Nothing, Nothing, Just 6, Just 3, Nothing, Just 9, Just 7 ]
    , [ Nothing, Nothing, Just 8, Just 9, Nothing, Nothing, Just 2, Just 6, Nothing ]
    , [ Just 6, Nothing, Just 9, Nothing, Nothing, Nothing, Nothing, Just 3, Nothing ]
    , [ Nothing, Just 9, Just 6, Just 7, Just 2, Just 1, Nothing, Nothing, Nothing ]
    , [ Nothing, Just 7, Nothing, Just 6, Nothing, Just 8, Nothing, Just 4, Nothing ]
    , [ Nothing, Nothing, Nothing, Just 5, Just 3, Just 4, Just 9, Just 7, Nothing ]
    , [ Nothing, Just 5, Nothing, Nothing, Nothing, Nothing, Just 7, Nothing, Just 3 ]
    , [ Nothing, Just 6, Just 3, Nothing, Nothing, Just 9, Just 5, Nothing, Nothing ]
    , [ Just 1, Just 4, Nothing, Just 3, Just 5, Nothing, Nothing, Just 8, Just 9 ]
    ]

allValues :: Set Int 
allValues =
  Set.fromList [1..9]

newtype Puzzle = Puzzle [[Maybe Int]]

instance Show Puzzle where
  show (Puzzle grid) = concat $ intersperse "\n" $ showLine <$> grid

showCell :: Maybe Int -> Char
showCell (Just n) = intToDigit n
showCell Nothing = '_'

showLine :: [Maybe Int] -> String
showLine line =
  intersperse ' ' $ showCell <$> line

valueAt :: Puzzle -> (Int, Int) -> Maybe Int
valueAt (Puzzle grid) (x, y)
  | x >= 0 && x < 10 && y >= 0 && y < 10 = 
    let row = grid !! y
    in row !! x
  | otherwise = Nothing

usedInRow :: [[Maybe Int]] -> Int -> [Int]
usedInRow grid y =
  catMaybes $ grid !! y

usedInCol :: [[Maybe Int]] -> Int -> [Int]
usedInCol grid x =
  catMaybes $ (\l -> l !! x) <$> grid

usedInQuad :: Puzzle -> (Int, Int) -> [Int]
usedInQuad puzzle (x, y) =
  let xq = (div x 3) * 3
      yq = (div y 3) * 3
      quad = [ valueAt puzzle (x, y) | x <- [xq .. (xq+2)], y <- [yq .. (yq+2)] ] 
  in catMaybes quad

possibleValues :: Puzzle -> (Int, Int) -> [Int]
possibleValues (Puzzle grid) (x, y) =
  case valueAt (Puzzle grid) (x, y) of
    Just n -> [] 
    Nothing -> 
      let r = usedInRow grid y
          c = usedInCol grid x
          q = usedInQuad (Puzzle grid) (x, y)
          allUsed = Set.fromList $ concat [r, c, q]
      in Set.toList $ Set.difference allValues allUsed

replace :: Puzzle -> (Int, Int) -> Int -> Puzzle
replace (Puzzle grid) (x, y) v =
  Puzzle $ (\(r, y') ->  (mapCol y') <$> zip r [0..]) <$> zip grid [0..]
  where mapCol y' (c, x') 
          | x' == x && y' == y = Just v
          | otherwise = c

solve :: Puzzle -> Maybe Puzzle
solve puzzle =
  let b = firstBlank puzzle
  in 
    case b of
      Nothing -> Just puzzle
      Just coords -> 
        let p = possibleValues puzzle coords
        in 
          case length p of
            0 -> Nothing
            _ -> 
              let candidates = replace puzzle coords <$> p 
                  solutions = catMaybes $ solve <$> candidates
              in 
                case solutions of
                  [] -> Nothing
                  (x:xs) -> Just x

firstBlank :: Puzzle -> Maybe (Int, Int)
firstBlank puzzle =
  let blanks = [ (x, y) | x <- [0..8], y <- [0..8], valueAt puzzle (x, y) == Nothing ]
  in 
    case blanks of
      [] -> Nothing
      (x:xs) -> Just x

depipe line =
  filter (\c -> c /= '|') line

convert =
  fmap 
    (\c ->
      case c of
        '_' -> Nothing
        _ -> Just (digitToInt c))

parse = do
  d <- readFile "data/puzzle.txt"
  let l = (convert . depipe) <$> lines d
  return $ Puzzle l

solveFromFile = do
  puzzle <- parse
  return $
    case solve puzzle of
      Nothing -> testPuzzle
      Just p -> p
