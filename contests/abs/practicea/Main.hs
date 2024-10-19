{-# LANGUAGE StrictData #-}

module Main where

main :: IO ()
main = do
    a <- readLn :: IO Int
    [ b, c ] <- map read . words <$> getLine :: IO [ Int ]
    s <- getLine
    putStrLn $ unwords [ show $ a + b + c, s ] 
