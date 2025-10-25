{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Control.Monad (guard, replicateM)
import Data.Array.Base (UArray (UArray))
import Data.Array.Unboxed (UArray, bounds, listArray, range, (!))
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.List (foldl')
import Data.Maybe (fromJust)
import Data.Text.Internal.Fusion.Common (isSingleton)
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

isTilde :: UArray Int Int -> Bool
isTilde as =
    arrayLength as >= 4
        && as ! 1 < as ! 2
        && hasExactlyOnePeak as
        && hasExactlyOneValley as
  where
    arrayLength :: UArray Int Int -> Int
    arrayLength arr = let (low, high) = bounds arr in high - low + 1

    hasExactlyOnePeak :: UArray Int Int -> Bool
    hasExactlyOnePeak arr = (== 1) . length $ do
        i <- let (low, high) = bounds arr in range (low, high - 2)
        guard $ arr ! i < arr ! (i + 1) && arr ! (i + 1) > arr ! (i + 2)
        pure i

    hasExactlyOneValley :: UArray Int Int -> Bool
    hasExactlyOneValley arr = (== 1) . length $ do
        i <- let (low, high) = bounds arr in range (low, high - 2)
        guard $ arr ! i > arr ! (i + 1) && arr ! (i + 1) < arr ! (i + 2)
        pure i

runLengthEncode :: [Char] -> [(Char, Int)]
runLengthEncode = foldl' f e
  where
    f :: [(Char, Int)] -> Char -> [(Char, Int)]
    f acc cur =
        let
            (prevChar, n) = head acc
        in
            if prevChar == cur
                then undefined
                else undefined

    e :: [(Char, Int)]
    e = [('<', 0)]

solve :: [Int] -> Int
solve ps = undefined

main :: IO ()
main = do
    _ <- ints
    ps <- ints
    print $ solve ps

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
