{-# LANGUAGE StrictData #-}

module Main where

import Data.ByteString.Char8 qualified as BS

solve :: [Char] -> Int
solve (first : second : third : rest)
    | first == '#' && second == '.' && third == '#' = 1 + solve (third : rest)
    | otherwise = solve $ second : third : rest
solve _ = 0

main :: IO ()
main = do
    _ <- readLn :: IO Int
    s <- BS.unpack <$> BS.getLine
    print $ solve s
