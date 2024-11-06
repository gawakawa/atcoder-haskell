{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Data.ByteString.Char8 qualified as BS
import Data.IntMap.Strict qualified as IM
import Data.IntSet qualified as IS
import Data.HashMap.Strict qualified as HM
import Data.HashSet qualified as HS
import Data.Map.Strict qualified as M
import Data.Sequence qualified as Seq
import Data.Set qualified as S
import Data.Vector.Unboxed qualified as VU

import Control.Applicative (liftA3)
import Control.Arrow ((>>>), first, second)
import Control.Monad (join, replicateM, replicateM_)
import Data.Array.Unboxed (UArray, (!), bounds, listArray, range)
import Data.Bool.HT (if')
import Data.Char (digitToInt, intToDigit)
import Data.Foldable (toList)
import Data.Function (on)
import Data.Functor ((<&>))
import Data.List (foldl', scanl')
import Data.Maybe (fromJust)
import Data.Tuple.Extra (both)
import Data.Tuple.Strict (zipWithPair)

solve :: VU.Vector (Int, Int) -> (Int, Int) -> (Int, Int)
solve s (l, r) = (s VU.! succ r) `subPair` (s VU.! l)

calcCumsums :: VU.Vector (Int, Int) -> VU.Vector (Int, Int)
calcCumsums = VU.scanl' (flip $ \(c, p) -> if c == 1 then first (+ p) else second (+ p)) (0, 0)

subPair :: (Int, Int) -> (Int, Int) -> (Int, Int)
subPair (a, b) (c, d) = (a - c, b - d)

showPair :: (Show a, Show b) => (a, b) -> String
showPair (a, b) = show a ++ " " ++ show b

main :: IO ()
main = do
    [ n ] <- ints
    cps <- VU.replicateM n $ do
        [ c, p ] <- ints
        pure (c, p)
    let cumsums = calcCumsums cps
    [ q ] <- ints
    replicateM_ q $ do
        [ l, r ] <- ints
        putStrLn $ showPair $ solve cumsums $ both pred (l, r)

-- my lib
ints :: IO [ Int ]
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
toBase n = liftA3 if' (== 0)
    (const "0")
    $ iterate (`div` n) >>> takeWhile (> 0)
      >>> foldl' (flip $ (`mod` n) >>> intToDigit >>> (:)) ""
