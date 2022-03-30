--
-- Darian Marvel
-- 3/29/2022
-- Completing Project 5 Exercise C
--

-- DOES NOT handle bad input well at all! Only enter Integers!

import Data.List

inputList list = do
  item <- getLine
  if item == ""
      then return list
  else inputList ( [(read item ::Integer)] ++ list )

get_median arr
  | mod (length arr) 2 == 0 = (sort arr) !! (div (length arr) 2)
  | mod (length arr) 2 == 1 = (sort arr) !! ((div (length arr) 2))

main :: IO()
main = do
  putStrLn "Please type in numbers, one per line. When you are done enter a blank line."
  putStrLn "ONLY enter integers, entering other values may crash the program"
  putStrLn "Output: median of the sorted list of numbers you entered"
  list <- inputList []
  let med = get_median list
  putStr "Median: "
  putStrLn (show med)
