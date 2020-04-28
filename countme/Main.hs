module Main
  ( main
  )
where

import           Prelude
import           Network.Wai.Internal           ( Request(..) )
import           Network.Wai
import           Network.Wai.Handler.Warp       ( run )
import           Data.IORef
import           Network.HTTP.Types
import           Data.Aeson                     ( encode )
import qualified Data.ByteString.Lazy.Char8    as LBS8

type CounterRef = IORef Int

modify :: LBS8.ByteString -> Int -> Int
modify body = case LBS8.readInt body of
  Nothing -> error "!!!"
  Just (x, _) -> (+ x)
{-# INLINE modify #-}

application :: CounterRef -> Application
application ref request@Request { requestMethod = "POST" } respond = do
  modifyIORef ref . modify =<< strictRequestBody request
  respond $ responseLBS status200 [] mempty
application ref _ respond =
  respond . responseLBS status200 [] . encode =<< readIORef ref

main :: IO ()
main = run 80 <$> application =<< newIORef 0
