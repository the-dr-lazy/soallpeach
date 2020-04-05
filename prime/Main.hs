module Main (main) where

import           Data.Attoparsec.Text
import           Data.Conduit
import qualified Data.Conduit.Combinators as C
import           Data.Int
import           Data.Text                (Text)
import           Prelude
import           System.Environment

-- | Main logic

isqrt :: Integral a => a -> a
isqrt = floor @Double . sqrt . fromIntegral

factors :: Integral a => a -> [a]
factors n = [ x | x <- [3,5..isqrt n], n `mod` x == 0]

isPrime :: Integral a => a -> Bool
isPrime 1                    = False
isPrime 2                    = True
isPrime n | n `mod` 2 == 0   = False
          | null $ factors n = True
          | otherwise        = False

-- | I/O

output :: Integral a => Either String a -> Text
output (Left _)              = error "Parser error: not number input."
output (Right x) | isPrime x = "1"
                 | otherwise = "0"

parseIntegral :: Text -> Either String Int32
parseIntegral = parseOnly decimal

main :: IO ()
main = do
  filePath <- head <$> getArgs
  runConduitRes $ C.sourceFile filePath
               .| C.decodeUtf8
               .| C.linesUnbounded
               .| C.map (output . parseIntegral)
               .| C.unlines
               .| C.encodeUtf8
               .| C.stdout
