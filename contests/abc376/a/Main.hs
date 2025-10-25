{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Data.ByteString.Char8 qualified as BS

solve :: Int -> [Int] -> Int
solve _ [] = 0
solve c (t : ts) = 1 + solve' ts t
  where
    solve' :: [Int] -> Int -> Int
    solve' [] _ = 0
    solve' [putButtonTime] getBefore =
        if putButtonTime - getBefore < c
            then 0
            else 1
    solve' (putButtonTime : putButtonTimes) getBefore =
        if putButtonTime - getBefore < c
            then solve' putButtonTimes getBefore
            else 1 + solve' putButtonTimes putButtonTime

main :: IO ()
main = do
    [_, c] <- map read . words <$> getLine :: IO [Int]
    ts <- map read . words <$> getLine :: IO [Int]
    print $ solve c ts
