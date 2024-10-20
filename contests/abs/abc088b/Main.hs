{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Data.List
import Data.Ord

solve :: [ Int ] -> Int
solve = 
    sum . zipWith (*) (cycle [ 1, -1 ]) . sortBy (comparing Down)

main :: IO ()
main = do
    _ <- readLn :: IO Int
    as <- map read . words <$> getLine :: IO [ Int ]
    print $ solve as
