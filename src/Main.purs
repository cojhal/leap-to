module Main where

import Prelude
import Data.Array (elem, (!!))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (uncurry)
import Effect (Effect)
import Effect.Console (error, log)
import Foreign.Object as FO
import Node.FS.Sync (exists, mkdir)
import Node.Path as Path

type Store
  = FO.Object String

foreign import getArgs :: Effect (Array String)

foreign import getDirname :: Effect String

foreign import store :: Store -> String -> Effect Unit

foreign import retrieve :: String -> Effect Store

printUsage :: Effect Unit
printUsage =
  traverse_ log
    [ "Usage: leap [to] <name>"
    , "       leap register <name> [<dir>]"
    , "       leap delete <name>"
    , "       leap print"
    ]

printHash :: Store -> Effect Unit
printHash = traverse_ log <<< showEntries
  where
  showEntries :: Store -> Array String
  showEntries = map (uncurry showEntry) <<< FO.toAscUnfoldable

  showEntry :: String -> String -> String
  showEntry k v = k <> " => " <> v

main :: Effect Unit
main = do
  args <- getArgs
  if "--help" `elem` args then
    printUsage
  else do
    dirname <- getDirname
    let
      dataDir = Path.concat [ dirname, "data" ]

      dataFile = Path.concat [ dataDir, "dirs.json" ]
    unlessM (exists dataDir) (mkdir dataDir)
    hash <- ifM (exists dataFile) (retrieve dataFile) (pure FO.empty)
    let
      cmd = args !! 0

      arg1 = args !! 1

      arg2 = args !! 2
    case cmd of
      Just "register" -> case arg1 of
        Just name -> do
          dir <- Path.resolve [] (fromMaybe "." arg2)
          store (FO.insert name dir hash) dataFile
          log $ "Registered " <> dir <> " as " <> name
        Nothing -> error "Must provide name"
      Just "delete" -> traverse_ (\name -> store (FO.delete name hash) dataFile) arg1
      Just "print" -> printHash hash
      Just "to" -> traverse_ (\path -> log $ "cd " <> path) (join $ FO.lookup <$> arg1 <*> pure hash)
      Just name -> traverse_ (\path -> log $ "cd " <> path) (FO.lookup name hash)
      Nothing -> pure unit
