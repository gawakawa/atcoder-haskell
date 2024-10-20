{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import qualified Data.ByteString.Char8 as BS
import Data.List ( sortBy )
import Data.Ord ( Down(Down), comparing )
import Data.Maybe ( isNothing )

solve :: [ Int ] -> [ Int ] -> Maybe Int
solve toys boxes = 
    let
        sortedToys = sortBy (comparing Down) toys
        sortedBoxes = sortBy (comparing Down) boxes
    in
        solve' sortedToys sortedBoxes Nothing
        where
            solve' :: [ Int ] -> [ Int ] -> Maybe Int -> Maybe Int
            solve' []      _  x       = x
            solve' [ toy ] [] Nothing = Just toy
            solve' _       [] _        = Nothing
            solve' (toy : restToys) (box : restBoxes) x
                | toy <= box              = solve' restToys restBoxes x
                | toy > box && isNothing x = solve' restToys (box : restBoxes) (Just toy)
                | otherwise               = Nothing

main :: IO ()
main = do
    _ <- readLn :: IO Int
    as <- map read . words <$> getLine :: IO [ Int ]
    bs <- map read . words <$> getLine :: IO [ Int ]
    case solve as bs of
        Just x -> print x
        Nothing -> print (-1 :: Int)
