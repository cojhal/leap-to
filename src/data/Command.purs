module Data.Command where

import Prelude
import Control.Alternative (empty, guard, (<|>))
import Control.Monad.Error.Class (throwError)
import Control.Monad.Except (Except, runExcept)
import Control.Monad.State (StateT, evalStateT, get, put)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.List as L
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)

newtype Alias
  = Alias String

instance showAlias :: Show Alias where
  show (Alias s) = "Alias " <> show s

derive newtype instance eqAlias :: Eq Alias

newtype Path
  = Path String

instance showPath :: Show Path where
  show (Path s) = "Path " <> show s

derive newtype instance eqPath :: Eq Path

cwd :: Path
cwd = Path "."

data Command
  = To Alias
  | Register Alias Path
  | Delete Alias
  | Print
  | Help

derive instance genericCommand :: Generic Command _

derive instance eqCommand :: Eq Command

instance showCommand :: Show Command where
  show c = genericShow c

type StringListParser
  = StateT (L.List String) (Except (Array String))

parseCommand :: Array String -> Either (Array String) Command
parseCommand args = runExcept $ evalStateT commandParser (L.fromFoldable args)

commandParser :: StringListParser Command
commandParser = help <|> command
  where
  help :: StringListParser Command
  help = search "--help" *> pure Help

  command :: StringListParser Command
  command = do
    t <- token
    case t of
      "register" -> Register <$> (alias <|> throwError [ "Must provide name" ]) <*> (path <|> pure cwd)
      "delete" -> Delete <$> alias
      "print" -> pure Print
      "to" -> To <$> alias
      a -> pure $ To (Alias a)

token :: StringListParser String
token = do
  tokens <- get
  case L.uncons tokens of
    Just { head, tail } -> do
      put tail
      pure head
    Nothing -> empty

match :: String -> StringListParser Unit
match s = do
  t <- token
  guard $ t == s

alias :: StringListParser Alias
alias = Alias <$> token

path :: StringListParser Path
path = Path <$> token

search :: String -> StringListParser Unit
search s = do
  t <- token
  unless (s == t) (search s)
