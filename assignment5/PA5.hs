-- PA5.hs  SKELETON
-- Glenn G. Chappell
-- 2022-03-16
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


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_ ## _ = 42  -- DUMMY; REWRITE THIS!!!


-- =====================================================================


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ bs = bs  -- DUMMY; REWRITE THIS!!!


-- =====================================================================


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
sumEvenOdd _ = (0, 0)  -- DUMMY; REWRITE THIS!!!
