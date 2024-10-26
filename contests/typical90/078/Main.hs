{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad (replicateM)
import Data.Array (Array, (!))
import Data.Graph (Graph, Vertex, buildG, vertices)
import Data.Maybe (fromJust)

import qualified Data.ByteString.Char8 as BS

solve :: Graph -> Int
solve g = length [ () | v <- vertices g, hasOneSmallerAdjacents v (g ! v) ]

hasOneSmallerAdjacents :: Vertex -> [ Vertex ] -> Bool
hasOneSmallerAdjacents v = (== 1) . length . filter (< v)

main :: IO ()
main = do
    [ n, m ] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    edges    <- replicateM m $ do
        [ a, b ] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
        pure (a, b)
    print $ solve $ buildG (1, n) $ concatMap (\(u, v) -> [ (u, v), (v, u) ]) edges
