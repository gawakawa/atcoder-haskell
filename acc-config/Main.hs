#!/usr/bin/env stack
{- stack script --resolver lts-21.6 -}

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE NumDecimals #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StrictData #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -Wno-unused-imports -Wno-unused-top-binds -Wno-missing-signatures -Wno-unused-matches -funbox-small-strict-fields #-}

module Main where

import Control.Applicative
import Control.Monad
import Data.Array qualified as A
import Data.Array.Unboxed qualified as AU
import Data.ByteString.Char8 qualified as BS
import Data.Char
import Data.Function
import Data.Int
import Data.List qualified as L
import Data.Maybe
import Data.Proxy
import Data.Reflection
import Data.Vector qualified as V
import Data.Vector.Generic qualified as VG
import Data.Vector.Unboxed qualified as VU
import Data.Vector.Unboxing qualified as Unboxing
import GHC.TypeLits


main :: IO ()
main = do
    undefined


-- my library
int :: IO Int
int = fst . fromJust . BS.readInt <$> BS.getLine


intList :: IO [Int]
intList = L.unfoldr (BS.readInt . BS.dropWhile isSpace) <$> BS.getLine


intPair :: IO (Int, Int)
intPair = do
    [x, y] <- intList
    return (x, y)


newtype ModInt (m :: Nat) = ModInt Int64 deriving (Eq)
instance Show (ModInt m) where
    show (ModInt x) = show x
instance (KnownNat m) => Num (ModInt m) where
    ModInt x + ModInt y =
        if x + y >= modulus then ModInt (x + y - modulus) else ModInt (x + y)
        where
            modulus = fromInteger (natVal (Proxy :: Proxy m))
    ModInt x - ModInt y = if x - y < 0 then ModInt (x - y + modulus) else ModInt (x - y)
        where
            modulus = fromInteger (natVal (Proxy :: Proxy m))
    ModInt x * ModInt y = ModInt ((x * y) `rem` modulus)
        where
            modulus = fromInteger (natVal (Proxy :: Proxy m))
    fromInteger n = ModInt (fromInteger (n `mod` fromIntegral modulus))
        where
            modulus = natVal (Proxy :: Proxy m)
    abs = undefined
    signum = undefined
instance Ord (ModInt m) where
    compare (ModInt x) (ModInt y) = compare x y
instance (KnownNat m) => Real (ModInt m) where
    toRational (ModInt x) = toRational x
instance Enum (ModInt m) where
    toEnum n = ModInt (fromIntegral n)
    fromEnum (ModInt x) = fromIntegral x
instance (KnownNat m) => Fractional (ModInt m) where
    recip (ModInt x) = case exEuclid x modulus of
        (1, s, t) -> ModInt $ s `mod` modulus
        (-1, s, t) -> ModInt $ (-s) `mod` modulus
        _ -> error $ show x ++ " has no inverse modulo " ++ show modulus
        where
            modulus = fromInteger (natVal (Proxy :: Proxy m))
    fromRational = undefined
instance (KnownNat m) => Integral (ModInt m) where
    toInteger (ModInt x) = toInteger x
    quotRem x y = (q, r)
        where
            q = x * recip y
            r = x - q * y
instance Unboxing.Unboxable (ModInt m) where
    type Rep (ModInt m) = Int64


-- exEuclid a b = (g, s, t) <=> g = gcd(a, b) = s*a + t*b
exEuclid :: (Integral a) => a -> a -> (a, a, a)
exEuclid = loop 1 0 0 1
    where
        loop s t s' t' a_ b_ = case b_ of
            0 -> (a_, s, t)
            _ ->
                let (q, r) = a_ `divMod` b_
                 in loop s' t' (s - q * s') (t - q * t') b_ r
