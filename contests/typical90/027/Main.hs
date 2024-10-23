{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import qualified Data.ByteString.Char8 as BS
import qualified Data.HashSet as HS
import qualified Data.Vector.Unboxed as VU

solve :: [ BS.ByteString ] -> [ Int ]
solve = solve' 1 HS.empty
    where
        solve' :: Int -> HS.HashSet BS.ByteString -> [ BS.ByteString ] -> [ Int ]
        solve' _ _          []       = []
        solve' i registered (u : us) = 
            if HS.member u registered
                then     solve' (i + 1) registered  us
                else i : solve' (i + 1) (HS.insert u registered) us

main :: IO ()
main = do
    _  <- readLn @Int
    ss <- BS.words <$> BS.getContents
    putStr $ unlines $ show <$> solve ss
