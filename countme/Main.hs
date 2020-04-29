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
import           Control.Concurrent

type CounterRef = IORef Int

application :: CounterRef -> Application
application ref request@Request { requestMethod = "POST" } respond = do
  body <- strictRequestBody request
  _    <- forkIO $ case LBS8.readInt body of
    Nothing     -> error "!!!"
    Just (x, _) -> modifyIORef' ref (+ x)
  respond $ responseLBS status200 [] mempty
application ref _ respond =
  respond . responseLBS status200 [] . encode =<< readIORef ref

main :: IO ()
main = run 80 <$> application =<< newIORef 0
