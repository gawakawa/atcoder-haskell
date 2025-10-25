{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad

import Data.ByteString.Char8 qualified as BS

solve :: Int -> (Int, Int) -> [(Char, Int)] -> Int
solve _ _ [] = 0
solve n (l, r) (('L', t) : rest)
    | (l < r && r < t) || (t < r && r < l) = n - abs (t - l) + solve n (t, r) rest
    | otherwise = abs (t - l) + solve n (t, r) rest
solve n (l, r) (('R', t) : rest)
    | (r < l && l < t) || (t < l && l < r) = n - abs (t - r) + solve n (l, t) rest
    | otherwise = abs (t - r) + solve n (l, t) rest
solve _ _ _ = error "unreachable"

main :: IO ()
main = do
    [n, q] <- map read . words <$> getLine :: IO [Int]
    hts <- replicateM q $ do
        [h, t] <- words <$> getLine
        pure (head h, read @Int t - 1)
    print $ solve n (0, 1) hts
