-- PA5.hs  SKELETON
-- Glenn G. Chappell
-- 2022-03-16
--
-- For CS F331 / CSCE A331 Spring 2022
-- Solutions to Assignment 5 Exercise B

module PA5 where


-- =====================================================================

collatz n
  | n == 1 = 0
  | mod n 2 == 0 = collatz (div n 2) + 1
  | otherwise = collatz (3*n+1) + 1

-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map collatz [1..]  -- DUMMY; REWRITE THIS!!!


-- =====================================================================


-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList _ _ = Just 42  -- DUMMY; REWRITE THIS!!!


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
