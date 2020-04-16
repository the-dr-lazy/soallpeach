module Main
  ( main
  , isPrimeMemo
  )
where

import           Data.Int
import           Data.ByteString                ( ByteString )
import qualified Data.ByteString.Char8         as BS
import           Prelude
import           System.Environment

-- | Utils

data Tree a = Tree (Tree a) a (Tree a)

instance Functor Tree where
  fmap f (Tree l m r) = Tree (fmap f l) (f m) (fmap f r)

index :: Integral a => Tree b -> a -> b
index (Tree _ m _) 0 = m
index (Tree l _ r) n = case (n - 1) `divMod` 2 of
  (q, 0) -> index l q
  (q, 1) -> index r q
  _      -> error "not reachable"

nats :: Integral a => Tree a
nats = go 0 1
 where
  go !n !s = Tree (go l s') n (go r s')
   where
    l  = n + s
    r  = l + s
    s' = s * 2

isqrt :: Integral a => a -> a
isqrt = floor @Double . sqrt . fromIntegral
{-# INLINE isqrt #-}

-- | Main logic

factors :: Int -> [Int]
factors n = [ x | x <- [3, 5 .. isqrt n], n `mod` x == 0 ]

isPrime :: Int -> Bool
isPrime 0 = False
isPrime 1 = False
isPrime 2 = True
isPrime n | n `mod` 2 == 0   = False
          | null $ factors n = True
          | otherwise        = False

isPrimeTree :: Tree Bool
isPrimeTree = fmap isPrime nats

isPrimeMemo :: Integral a => a -> Bool
isPrimeMemo = index isPrimeTree
{-# INLINE isPrimeMemo #-}

-- | I/O

convert :: Maybe Int -> ByteString
convert Nothing = error "Parser error: not number input."
convert (Just x) | isPrimeMemo x = "1"
                 | otherwise     = "0"

main :: IO ()
main = do
  inputFilePath <- head <$> getArgs
  output        <-
    BS.intercalate "\n"
    .   fmap (convert . fmap fst . BS.readInt)
    .   BS.lines
    <$> BS.readFile inputFilePath
  BS.putStrLn output

-- | I/O - Streaming

-- main :: IO ()
-- main = do
--   threads  <- getNumCapabilities
--   filePath <- head <$> getArgs
--   runConduitRes
--     $  C.sourceFile filePath
--     .| C.decodeUtf8
--     .| C.linesUnbounded
--     .| C.conduitVector 4096
--     .| asyncMapC threads (V.map $ convert . parseIntegral)
--     .| C.concat
--     .| C.unlines
--     .| C.encodeUtf8
--     .| C.stdout
