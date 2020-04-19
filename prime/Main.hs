module Main
  ( main
  )
where

import           Data.Int
import           Data.ByteString                ( ByteString )
import qualified Data.ByteString.Char8         as BS
import           Prelude
import           System.Environment
import           Math.NumberTheory.Primes.Testing
                                                ( isPrime )
import           Data.Vector                    ( (!)
                                                , Vector
                                                )
import qualified Data.Vector                   as V


-- | Main Logic

nats :: Integral a => Vector a
nats = V.enumFromN 0 99992

isPrimeVector :: Vector Bool
isPrimeVector = fmap isPrime nats

isPrimeMemo :: Int -> Bool
isPrimeMemo = (isPrimeVector !)
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
