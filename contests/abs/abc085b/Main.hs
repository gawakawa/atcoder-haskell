{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad ( replicateM )
import Data.Containers.ListUtils ( nubOrd )

solve :: [ Int ] -> Int
solve = length . nubOrd

main :: IO ()
main = do
    n <- readLn :: IO Int
    ds <- replicateM n readLn :: IO [ Int ]
    print $ solve ds
