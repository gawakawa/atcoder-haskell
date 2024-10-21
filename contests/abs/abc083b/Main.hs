{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

solve :: Int -> Int -> Int -> Int
solve n a b = 
    sum [ x | x <- [ 1 .. n ], a <= sumDigits x, sumDigits x <= b ]

sumDigits :: Int -> Int
sumDigits 0 = 0
sumDigits n = n `mod` 10 + sumDigits (n `div` 10)

main :: IO ()
main = do
    [ n, a, b ] <- map read . words <$> getLine :: IO [ Int ]
    print $ solve n a b
