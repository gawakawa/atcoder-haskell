{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((&&&), (>>>))
import Control.Lens (uncurried)
import Control.Monad (replicateM)
import Data.Array.Unboxed (UArray, bounds, listArray, range, (!))
import Data.Bool.HT (if')
import Data.Char (digitToInt, intToDigit)
import Data.Containers.ListUtils (nubOrd)
import Data.Functor ((<&>))
import Data.List (foldl', scanl', sort, uncons)
import Data.Massiv.Array (toByteString)
import Data.Maybe (fromJust)
import Data.Tuple.Extra (both)

import Data.ByteString.Char8 qualified as BS
import Data.HashMap.Strict qualified as HM
import Data.HashSet qualified as HS
import Data.IntMap.Strict qualified as IM
import Data.IntSet qualified as IS
import Data.Map.Strict qualified as M
import Data.Sequence qualified as Seq
import Data.Set qualified as S
import Data.Vector.Unboxed qualified as VU

solve :: Int -> [String]
solve = genParens >>> filter validParen

genParens :: Int -> [String]
genParens 0 = [""]
genParens n = do
    paren <- genParens $ n - 1
    ['(' : paren, ')' : paren]

validParen :: String -> Bool
validParen s =
    all (>= (0 :: Int)) &&& (last >>> (== 0)) >>> uncurry (&&)
        $ scanl' (flip $ \c -> if c == '(' then succ else pred) 0 s

main :: IO ()
main = do
    [n] <- ints
    putStr $ unlines $ sort $ solve n

-- my lib
ints :: IO [Int]
ints = BS.getLine <&> (BS.words >>> map (BS.readInt >>> fromJust >>> fst))

intMat :: Int -> Int -> IO (UArray (Int, Int) Int)
intMat h w = replicateM h ints <&> (concat >>> listArray @UArray ((1, 1), (h, w)))

showIntMat :: UArray (Int, Int) Int -> String
showIntMat mat =
    unlines
        [ unwords
            [ show $ mat ! (r, c)
            | c <- range $ both snd $ bounds mat
            ]
        | r <- range $ both fst $ bounds mat
        ]

fromBase :: Int -> String -> Int
fromBase n = foldl' (\acc d -> acc * n + digitToInt d) 0

toBase :: Int -> Int -> String
toBase n =
    liftA3
        if'
        (== 0)
        (const "0")
        $ iterate (`div` n)
            >>> takeWhile (> 0)
            >>> foldl' (flip $ (`mod` n) >>> intToDigit >>> (:)) ""
