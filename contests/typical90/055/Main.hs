{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import qualified Data.ByteString.Char8 as BS
import qualified Data.Vector.Unboxed as VU
import Data.List ( foldl' )
import Data.Maybe ( fromJust )

solve :: Int -> Int -> Int -> VU.Vector Int -> Int
solve n p q as = length
    [ () | i1 <- [ 0      .. n - 5 ]
         , i2 <- [ i1 + 1 .. n - 4 ]
         , i3 <- [ i2 + 1 .. n - 3 ]
         , i4 <- [ i3 + 1 .. n - 2 ]
         , i5 <- [ i4 + 1 .. n - 1 ]
         , modProd p ((as VU.!) <$> [ i1, i2, i3, i4, i5 ]) == q
    ]

modProd :: Int -> [ Int ] -> Int
modProd m = foldl' (\acc x -> acc * x `mod` m) 1 

main :: IO ()
main = do
    [ n, p, q ] <- map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    as <- VU.fromList . map (fst . fromJust . BS.readInt) . BS.words <$> BS.getLine
    print $ solve n p q as
