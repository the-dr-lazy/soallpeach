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

type NumberRef = IORef (Maybe Int)
type TimesRef = IORef Int

whenNothing_ :: Applicative f => Maybe a -> f () -> f ()
whenNothing_ Nothing m = m
whenNothing_ _       _ = pure ()
{-# INLINE whenNothing_ #-}

whenNothingM_ :: Monad m => m (Maybe a) -> m () -> m ()
whenNothingM_ mm action = mm >>= \m -> whenNothing_ m action
{-# INLINE whenNothingM_ #-}

modify :: Int -> (Int, ())
modify x = (x + 1, ())
{-# INLINE modify #-}

application :: NumberRef -> TimesRef -> Application
application numberRef timesRef request@Request { requestMethod = "POST" } respond = do
  whenNothingM_ (readIORef numberRef) $ do
    body <- LBS8.readInt <$> strictRequestBody request
    case body of
      Nothing     -> error "!!!"
      Just (x, _) -> atomicWriteIORef numberRef $ Just x
  atomicModifyIORef' timesRef modify
  respond $ responseLBS status200 [] mempty
application numberRef timesRef _ respond = do
  number <- maybe 0 id <$> readIORef numberRef
  times <- readIORef timesRef
  respond . responseLBS status200 [] $ encode (number * times)

main :: IO ()
main = do
  numberRef <- newIORef Nothing
  timesRef <- newIORef 0
  run 80 $ application numberRef timesRef
