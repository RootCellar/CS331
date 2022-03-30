-- PA5.hs
-- Darian Marvel
-- Started by Glenn G. Chappell
-- 3/29/2022
--
-- For CS F331 / CSCE A331 Spring 2022
-- Solutions to Assignment 5 Exercise B

module PA5 where

import Data.List

-- =====================================================================

collatzC n
  | n == 1 = 0
  | mod n 2 == 0 = collatzC (div n 2) + 1 -- even
  | otherwise = collatzC (3*n+1) + 1 -- odd

-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map collatzC [1..]

-- =====================================================================

findL n pre list
    | length list == 0 = Nothing -- Nothing left
    | isPrefixOf pre list == False = findL (n+1) pre (drop 1 list) -- Continuing search
    | isPrefixOf pre list == True = Just n -- Found it!

-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList pre list = findL 0 pre list

-- =====================================================================

countEqual first second
 -- 0 if either is empty
 | length first == 0 = 0
 | length second == 0 = 0
 -- found one! now recurse
 | head first == head second = 1 + countEqual (drop 1 first) (drop 1 second)
 -- didn't find one, recurse
 | otherwise = countEqual (drop 1 first) (drop 1 second)

-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
first ## second = count where
  count = countEqual first second

-- =====================================================================

findEquals func first second
  -- 0 if either is empty
  | length first == 0 = []
  | length second == 0 = []
  -- found one!
  | func (head first) == True = [head second] ++ findEquals func (drop 1 first) (drop 1 second)
  | otherwise = findEquals func (drop 1 first) (drop 1 second)

-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB func first second = equals where
  equals = findEquals func first second

-- =====================================================================

-- add tuple to current tuple
accumulate current item
  | otherwise = (fst current + fst item, snd current + snd item)

-- transform list into tuples - first value being even index, second being odd
tuplify list
  | length list == 0 = []
  | length list == 1 = [(head list, 0)]
  | otherwise = (list !! 0, list !! 1) : tuplify (drop 2 list)

-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written as a fold.
  Like this:

    sumEvenOdd xs = fold* ... xs  where
        ...

  Above, "..." should be replaced by other code. "fold*" must be one of
  the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd list = foldl (accumulate) (0, 0) (tuplify list)
