{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Data.ByteString.Char8 qualified as BS

solve :: [ Char ] -> Bool
solve s
    | null s                = True
    | take 7 s == "dreamer" = any (solve . flip drop s) [ 5, 7 ]
    | take 6 s == "eraser"  = any (solve . flip drop s) [ 5, 6 ]
    | take 5 s == "dream"   = solve $ drop 5 s
    | take 5 s == "erase"   = solve $ drop 5 s
    | otherwise             = False



main :: IO ()
main = do
    s <- BS.unpack <$> BS.getLine
    putStrLn $ if solve s then "YES" else "NO"
