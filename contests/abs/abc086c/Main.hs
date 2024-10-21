{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import Control.Monad ( replicateM )
import Data.List ( foldl' )

solve :: (Int, Int, Int) -> [ (Int, Int, Int) ] -> Bool
solve _    []          = True
solve from (to : rest) = reachable from to && solve to rest

reachable :: (Int, Int, Int) -> (Int, Int, Int) -> Bool
reachable (t1, x1, y1) (t2, x2, y2) =
    (&&) <$> (>= 0) <*> even $ (t2 - t1) - abs (x1 - x2) - abs (y1 - y2)

main :: IO ()
main = do
    n <- readLn :: IO Int
    txys <- replicateM n $ do
        [ t, x, y ] <- map read . words <$> getLine
        pure (t, x, y) :: IO (Int, Int, Int)
    putStrLn $ if solve (0, 0, 0) txys then "Yes" else "No"
