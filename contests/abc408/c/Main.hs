{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Data.ByteString.Char8 qualified as BS
import Data.HashMap.Strict qualified as HM
import Data.HashSet qualified as HS
import Data.IntMap.Strict qualified as IM
import Data.IntSet qualified as IS
import Data.Map.Strict qualified as M
import Data.Sequence qualified as Seq
import Data.Set qualified as S
import Data.Vector.Unboxed qualified as VU

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Control.Monad (replicateM)
import Data.Array.Unboxed (UArray, array, bounds, listArray, range, (!))
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.List (foldl')
import Data.Maybe (fromJust)
import Data.Tuple.Extra (both)

-- 初期状態で守られていない城壁があるかどうかチェックしなきゃいけない
solve :: Int -> [(Int, Int)] -> Int
solve n = snd . foldl' f (array (1, 0) [], 0)
  where
    f :: (UArray Int Int, Int) -> (Int, Int) -> (UArray Int Int, Int)
    f acc (l, r) = undefined

main :: IO ()
main = do
    [n, m] <- ints
    lrs <- replicateM m $ do
        [l, r] <- ints
        pure (l, r)
    print $ solve n lrs

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
