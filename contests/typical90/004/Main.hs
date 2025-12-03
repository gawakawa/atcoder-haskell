{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((&&&), (***), (>>>))
import Control.Monad (replicateM)
import Data.Array.Unboxed
    ( UArray,
      accum,
      accumArray,
      bounds,
      elems,
      listArray,
      (!),
    )
import Data.Bool.HT (if')
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.Ix (range)
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

solve :: UArray (Int, Int) Int -> UArray (Int, Int) Int
solve mat =
    listArray
        (bounds mat)
        [ rowSums mat ! r + colSums mat ! c - mat ! (r, c)
        | r <- range $ both fst $ bounds mat
        , c <- range $ both snd $ bounds mat
        ]

rowSums :: UArray (Int, Int) Int -> UArray Int Int
rowSums mat =
    accumArray
        (+)
        0
        (both fst $ bounds mat)
        [ (r, mat ! (r, c))
        | r <- range $ both fst $ bounds mat
        , c <- range $ both snd $ bounds mat
        ]

colSums :: UArray (Int, Int) Int -> UArray Int Int
colSums mat =
    accumArray
        (+)
        0
        (both snd $ bounds mat)
        [ (c, mat ! (r, c))
        | r <- range $ both fst $ bounds mat
        , c <- range $ both snd $ bounds mat
        ]

showMat :: UArray (Int, Int) Int -> String
showMat mat =
    unlines
        [ unwords
            [ show $ mat ! (r, c)
            | c <- range $ both snd $ bounds mat
            ]
        | r <- range $ both fst $ bounds mat
        ]

main :: IO ()
main = do
    [h, w] <- ints
    ass <- intMat h w
    putStr $ showMat $ solve ass

-- my lib
ints :: IO [Int]
ints = BS.getLine <&> (BS.words >>> map (BS.readInt >>> fromJust >>> fst))

intMat :: Int -> Int -> IO (UArray (Int, Int) Int)
intMat h w = replicateM h ints <&> (concat >>> listArray @UArray ((1, 1), (h, w)))

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
