{-# LANGUAGE StrictData #-}

module Main where

main :: IO ()
main = do
    _ <- readLn :: IO Int
    as <- map read . words <$> getLine :: IO [ Int ]
    print $ solve as

solve :: [ Int ] -> Int 
solve as = 
    if all even as 
    then 1 + solve (map (`div` 2) as) 
    else 0
