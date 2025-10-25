{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Control.Monad (replicateM)
import Data.Array.Unboxed (UArray, bounds, listArray, range, (!))
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.List (foldl')
import Data.Maybe (fromJust)
import Data.Tuple.Extra (both)

import qualified Data.ByteString.Char8 as BS
import qualified Data.HashMap.Strict as HM
import qualified Data.HashSet as HS
import qualified Data.IntMap.Strict as IM
import qualified Data.IntSet as IS
import qualified Data.Map.Strict as M
import qualified Data.Sequence as Seq
import qualified Data.Set as S
import qualified Data.Vector.Unboxed as VU

main :: IO ()
main = do
    undefined

-- my lib
ints :: IO [Int]
ints = BS.getLine <&> (BS.words >>> map (BS.readInt >>> fromJust >>> fst))

integers :: IO [Integer]
integers = BS.getLine <&> (BS.words >>> map (BS.readInteger >>> fromJust >>> fst))

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

ceiling :: (Integral a) => a -> a -> a
ceiling n m
    | m > 0 = (n + m - 1) `div` m
    | m < 0 = (n + m + 1) `div` m
    | otherwise = undefined

binarySearch
    :: (Ord a, Integral a)
    => a -- 述語を満たす境界値
    -> a -- 述語を満たさない境界値
    -> (a -> Bool) -- 述語
    -> a -- 述語を満たす新たな境界値
binarySearch ok ng satisfies
    | abs (ok - ng) <= 1 = ok
    | satisfies mid = binarySearch mid ng satisfies
    | otherwise = binarySearch ok mid satisfies
  where
    mid = (ok + ng) `quot` 2

fromBase :: Int -> String -> Int
fromBase n = foldl' (\acc d -> acc * n + digitToInt d) 0

toBase :: Int -> Int -> String
toBase n x
    | x == 0 = "0"
    | otherwise = reverse $ map intToDigit $ unfoldr getDigit x
  where
    getDigit 0 = Nothing
    getDigit y = Just (y `mod` n, y `div` n)

unfoldr :: (b -> Maybe (a, b)) -> b -> [a]
unfoldr f b = case f b of
    Nothing -> []
    Just (a, b') -> a : unfoldr f b'
