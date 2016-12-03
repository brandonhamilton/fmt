{-# LANGUAGE FlexibleInstances #-}

module Fmt
(
  (%<),
  (>%),
  (>%%<),

  (%<<),
  (>>%),
  (>>%%<<),

  (>%%<<),
  (>>%%<),

  FromBuilder(..),
)
where

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder hiding (fromString)
import Data.Monoid
import Data.Text.Buildable

----------------------------------------------------------------------------
-- Operators with 'Buildable'
----------------------------------------------------------------------------

(%<) :: (Buildable a, FromBuilder b) => Builder -> a -> b
(%<) x a = fromBuilder (x <> build a)

(>%) :: (FromBuilder b) => Builder -> Builder -> b
(>%) x a = fromBuilder (x <> a)

(>%%<) :: (Buildable a, FromBuilder b) => Builder -> a -> b
(>%%<) x a = fromBuilder (x <> build a)

infixl 1 %<
infixl 1 >%
infixl 1 >%%<

----------------------------------------------------------------------------
-- Operators with 'Show'
----------------------------------------------------------------------------

(%<<) :: (Show a, FromBuilder b) => Builder -> a -> b
(%<<) x a = x %< show a
{-# INLINE (%<<) #-}

(>>%) :: (FromBuilder b) => Builder -> Builder -> b
(>>%) x a = x >% a
{-# INLINE (>>%) #-}

(>>%%<<) :: (Show a, FromBuilder b) => Builder -> a -> b
(>>%%<<) x a = x %< show a
{-# INLINE (>>%%<<) #-}

infixl 1 %<<
infixl 1 >>%
infixl 1 >>%%<<

----------------------------------------------------------------------------
-- Combinations
----------------------------------------------------------------------------

(>>%%<) :: (Buildable a, FromBuilder b) => Builder -> a -> b
(>>%%<) x a = x >%%< a
{-# INLINE (>>%%<) #-}

(>%%<<) :: (Show a, FromBuilder b) => Builder -> a -> b
(>%%<<) x a = x >>%%<< a
{-# INLINE (>%%<<) #-}

infixl 1 >>%%<
infixl 1 >%%<<

-- TODO: something for indentation
-- TODO: something to format a record nicely (with generics, probably)
-- TODO: something like https://hackage.haskell.org/package/groom
-- TODO: reexport Buildable
-- TODO: write docs
-- TODO: mention printf in description so that it would be findable
-- TODO: mention things that work (<n+1>, <f n>, <show n>)
-- TODO: colors?
-- TODO: add NL for newline?
-- TODO: have to decide on whether it would be >%< or >%%< or maybe >|<
-- TODO: actually, what about |< and >|?
-- TODO: what effect does it have on compilation time? what effect do
--       other formatting libraries have on compilation time?

class FromBuilder a where
  fromBuilder :: Builder -> a

instance FromBuilder Builder where
  fromBuilder = id
  {-# INLINE fromBuilder #-}

instance FromBuilder String where
  fromBuilder = TL.unpack . toLazyText
  {-# INLINE fromBuilder #-}

instance FromBuilder T.Text where
  fromBuilder = TL.toStrict . toLazyText
  {-# INLINE fromBuilder #-}

instance FromBuilder TL.Text where
  fromBuilder = toLazyText
  {-# INLINE fromBuilder #-}