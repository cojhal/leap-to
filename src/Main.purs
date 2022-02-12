module Main where

import Prelude
import Data.Command (parseCommand, Alias(..), Command(..), Path(..))
import Data.Either (Either(..))
import Data.Foldable (traverse_)
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
  dirname <- getDirname
  let
    dataDir = Path.concat [ dirname, "data" ]

    dataFile = Path.concat [ dataDir, "dirs.json" ]
  unlessM (exists dataDir) (mkdir dataDir)
  hash <- ifM (exists dataFile) (retrieve dataFile) (pure FO.empty)
  case parseCommand args of
    Left errs -> traverse_ error errs
    Right cmd -> eval hash dataFile cmd

eval :: Store -> String -> Command -> Effect Unit
eval hash dataFile = case _ of
  Help -> printUsage
  Register (Alias a) (Path p) -> do
    dir <- Path.resolve [] p
    store (FO.insert a dir hash) dataFile
    log $ "Registered " <> dir <> " as " <> a
  Delete (Alias a) -> store (FO.delete a hash) dataFile
  Print -> printHash hash
  To (Alias a) -> traverse_ (\path -> log $ "cd " <> path) (FO.lookup a hash)
