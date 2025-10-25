{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Data.Bool.HT (if')
import Data.Char (digitToInt, intToDigit)
import Data.List (foldl')

import Data.ByteString.Char8 qualified as BS

solve :: Int -> String -> String
solve k = foldr (.) id $ replicate k $ base8to9 >>> replace8with5

base8to9 :: String -> String
base8to9 = fromBase8 >>> toBase9

fromBase8 :: String -> Int
fromBase8 = foldl' (\acc d -> acc * 8 + digitToInt d) 0

toBase9 :: Int -> String
toBase9 =
    liftA3 if' (== 0) (const "0")
        $ iterate (`div` 9)
            >>> takeWhile (> 0)
            >>> foldl' (flip $ (`mod` 9) >>> intToDigit >>> (:)) ""

replace8with5 :: String -> String
replace8with5 = map $ \c -> if c == '8' then '5' else c

main :: IO ()
main = do
    [n, k'] <- words <$> getLine
    let
        k = read @Int k'
    putStrLn $ solve k n
