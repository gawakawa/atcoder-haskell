{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Control.Monad (replicateM)
import Data.Array.Unboxed (UArray, bounds, listArray, range, (!))
import Data.Bool.HT (if')
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.List (foldl')
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

solve :: VU.Vector (Int, Int) -> [(Int, Int)] -> [Int]
solve _ [] = []
solve qrs ((t, d) : tds) =
    let
        (q, r) = qrs VU.! t
    in
        binDay q r d : solve qrs tds

binDay :: Int -> Int -> Int -> Int
binDay q r d = case compare (d `mod` q) r of
    LT -> q * (d `div` q) + r
    EQ -> d
    GT -> q * succ (d `div` q) + r

main :: IO ()
main = do
    [n] <- ints
    qrs <- VU.replicateM n $ do
        [q, r] <- ints
        pure (q, r)
    [q] <- ints
    tds <- replicateM q $ do
        [t, d] <- ints
        pure (pred t, d)
    putStr $ unlines $ show <$> solve qrs tds

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
