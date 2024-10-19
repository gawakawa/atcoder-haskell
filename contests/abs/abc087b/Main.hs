{-# LANGUAGE StrictData #-}

module Main where

main :: IO ()
main = do
    [ a, b, c, x ] <- map read . lines <$> getContents :: IO [ Int ]
    print $ solve a b c x

solve :: Int -> Int -> Int -> Int -> Int
solve a b c x = 
    length $ filter (== x) [ 500 * a' + 100 * b' + 50 * c' 
                           | a' <- [ 0 .. a ]
                           , b' <- [ 0 .. b ]
                           , c' <- [ 0 .. c ]]
