{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad (ap)
import Data.Bool.HT (if')
import Data.Function (on)
import Data.Maybe (fromJust)

import qualified Data.ByteString.Char8 as BS

solve :: Int -> Int -> Int
solve h w =
    if ((||) `on` (== 1)) h w
        then h * w
        else ((*) `on` \n -> (n + 1) `div` 2) h w

solve' :: Int -> Int -> Int
solve' = ap . ap (ap . (if' .) . cnd) thn <*> els
    where
        cnd = (||) `on` (== 1)
        thn = (*)
        els = (*) `on` \n -> (n + 1) `div` 2

main :: IO ()
main = do
    [ h, w ] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    print $ solve' h w
