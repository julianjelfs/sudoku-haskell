module Solver where

import           Data.Char
import           Data.List
import           Data.Maybe
import           Data.Set                       ( Set )
import qualified Data.Set                      as Set

allValues :: Set Int
allValues = Set.fromList [1 .. 9]

newtype Puzzle = Puzzle [[Maybe Int]]

instance Show Puzzle where
  show (Puzzle grid) = intercalate "\n" $ showLine <$> grid

showCell :: Maybe Int -> Char
showCell (Just n) = intToDigit n
showCell Nothing  = '_'

showLine :: [Maybe Int] -> String
showLine line = intersperse ' ' $ showCell <$> line

valueAt :: Puzzle -> (Int, Int) -> Maybe Int
valueAt (Puzzle grid) (x, y)
  | x >= 0 && x < 10 && y >= 0 && y < 10 = let row = grid !! y in row !! x
  | otherwise                            = Nothing

usedInRow :: [[Maybe Int]] -> Int -> [Int]
usedInRow grid y = catMaybes $ grid !! y

usedInCol :: [[Maybe Int]] -> Int -> [Int]
usedInCol grid x = catMaybes $ (!! x) <$> grid

usedInQuad :: Puzzle -> (Int, Int) -> [Int]
usedInQuad puzzle (x, y) =
  let
    xq = div x 3 * 3
    yq = div y 3 * 3
    quad =
      [ valueAt puzzle (x, y) | x <- [xq .. (xq + 2)], y <- [yq .. (yq + 2)] ]
  in
    catMaybes quad

possibleValues :: Puzzle -> (Int, Int) -> [Int]
possibleValues (Puzzle grid) (x, y) = case valueAt (Puzzle grid) (x, y) of
  Just n -> []
  Nothing ->
    let r       = usedInRow grid y
        c       = usedInCol grid x
        q       = usedInQuad (Puzzle grid) (x, y)
        allUsed = Set.fromList $ concat [r, c, q]
    in  Set.toList $ Set.difference allValues allUsed

replace :: Puzzle -> (Int, Int) -> Int -> Puzzle
replace (Puzzle grid) (x, y) v =
  Puzzle $ (\(r, y') -> mapCol y' <$> zip r [0 ..]) <$> zip grid [0 ..]
 where
  mapCol y' (c, x') | x' == x && y' == y = Just v
                    | otherwise          = c

solve :: Puzzle -> Maybe Puzzle
solve puzzle = case firstBlank puzzle of
  Nothing     -> Just puzzle
  Just coords -> case possibleValues puzzle coords of
    [] -> Nothing
    p ->
      let candidates = replace puzzle coords <$> p
          solutions  = catMaybes $ solve <$> candidates
      in  case solutions of
            []       -> Nothing
            (x : xs) -> Just x

firstBlank :: Puzzle -> Maybe (Int, Int)
firstBlank puzzle =
  case
      [ (x, y)
      | x <- [0 .. 8]
      , y <- [0 .. 8]
      , isNothing (valueAt puzzle (x, y))
      ]
    of
      []       -> Nothing
      (x : xs) -> Just x

convert = fmap
  (\c -> case c of
    '.' -> Nothing
    _   -> Just (digitToInt c)
  )

parse = do
  d <- readFile "data/puzzle.txt"
  return $ Puzzle $ convert <$> lines d

solveFromFile = do
  puzzle <- parse
  return $ fromMaybe puzzle (solve puzzle)
