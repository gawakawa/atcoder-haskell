{-# LANGUAGE StrictData #-}

module Main where

main :: IO ()
main = do
    [ a, b ] <- map read . words <$> getLine :: IO [ Int ]
    putStrLn $ solve a b

solve :: Int -> Int -> String
solve a b =
    if even $ a * b then "Even" else "Odd"
