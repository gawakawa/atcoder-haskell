{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Applicative (liftA2)
import Data.Maybe (fromJust)

import qualified Data.ByteString.Char8 as BS

solve :: Int -> [ Int ] -> [ Int ] -> Bool
solve k = ((plus2n . (k -)) .) . sumDiff

plus2n :: Int -> Bool
plus2n = liftA2 (&&) (>= 0) even

sumDiff :: [ Int ] -> [ Int ] -> Int
sumDiff = (sum .) . zipWith ((abs .) . subtract)

main :: IO ()
main = do
    [ _, k ] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    as       <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    bs       <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    putStrLn $ if solve k as bs then "Yes" else "No"
