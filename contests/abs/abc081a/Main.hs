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
