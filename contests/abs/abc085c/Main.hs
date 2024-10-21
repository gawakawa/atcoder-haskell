{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

solve :: Int -> Int -> [ Int ]
solve n y = head $
    [ [ a, b, c ] | a <- [ 0 .. n ]
                  , b <- [ 0 .. n - a ]
                  , let c = n - a - b
                  , 10000 * a + 5000 * b + 1000 * c == y
    ] ++ [ [ -1, -1, -1 ] ]

main :: IO ()
main = do
    [ n, y ] <- map read . words <$> getLine :: IO [ Int ]
    putStrLn $ unwords $ show <$> solve n y
