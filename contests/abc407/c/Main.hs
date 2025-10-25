{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA3)
import Control.Arrow ((>>>))
import Control.Monad (replicateM)
import Data.Array.Unboxed (UArray, bounds, listArray, range, (!))
import Data.ByteString.Internal (c2w)
import Data.Char (digitToInt, intToDigit)
import Data.Functor ((<&>))
import Data.List (foldl')
import Data.List.Extra (unsnoc)
import Data.Maybe (fromJust)
import Data.Tuple.Extra (both)
import Data.Word (Word32, Word8)

import Data.ByteString qualified as BS
import Data.ByteString.Char8 qualified as BSC
import Data.HashMap.Strict qualified as HM
import Data.HashSet qualified as HS
import Data.IntMap.Strict qualified as IM
import Data.IntSet qualified as IS
import Data.List.NonEmpty qualified as NE
import Data.Map.Strict qualified as M
import Data.Sequence qualified as Seq
import Data.Set qualified as S
import Data.Vector.Unboxed qualified as VU

solve :: BS.ByteString -> Int
solve s = buttonAClickCount + buttonBClickCount
  where
    buttonAClickCount :: Int
    buttonAClickCount = BS.length s

    buttonBClickCount :: Int
    buttonBClickCount =
        sum
            $ fromIntegral
                <$> BS.zipWith (\c c' -> (10 + c - c') `mod` 10) s (BS.snoc (BS.tail s) zero)

    zero :: Word8
    zero = c2w '0'

main :: IO ()
main = do
    s <- BSC.getLine
    print $ solve s

-- my lib
ints :: IO [Int]
ints = BSC.getLine <&> (BSC.words >>> map (BSC.readInt >>> fromJust >>> fst))

integers :: IO [Integer]
integers = BSC.getLine <&> (BSC.words >>> map (BSC.readInteger >>> fromJust >>> fst))

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
