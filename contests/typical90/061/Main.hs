{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad (replicateM)
import Data.Maybe (fromJust)

import Data.ByteString.Char8 qualified as BS
import Data.Sequence qualified as Seq

solve :: Seq.Seq Int -> [(Int, Int)] -> [Int]
solve _ [] = []
solve deck ((t, x) : txs) = case t of
    1 -> solve (x Seq.<| deck) txs
    2 -> solve (deck Seq.|> x) txs
    3 -> fromJust (deck Seq.!? pred x) : solve deck txs
    _ -> error "impossible"

main :: IO ()
main = do
    q <- readLn @Int
    txs <- replicateM q $ do
        [t, x] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
        pure (t, x)
    putStr $ unlines $ show <$> solve Seq.empty txs
