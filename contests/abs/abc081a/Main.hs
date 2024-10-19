{-# LANGUAGE StrictData #-}

module Main where

import Data.ByteString.Char8 as BS

main :: IO ()
main = do
    s <- BS.getLine
    print $ solve s

solve :: BS.ByteString -> Int
solve = BS.length . BS.filter (== '1')
