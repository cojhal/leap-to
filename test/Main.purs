module Test.Main where

import Prelude
import Data.Command (Alias(..), Command(..), Path(..), parseCommand)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = do
  launchAff_ $ runSpec [ consoleReporter ] commandSpec

commandSpec :: Spec Unit
commandSpec =
  describe "Command parsing" do
    describe "invalid" do
      it "fails on empty input" do
        parseCommand [] `shouldEqual` Left []
    describe "Help" do
      it "parses the help option" do
        parseCommand [ "--help" ] `shouldEqual` Right Help
      it "prioritizes help over other actions" do
        parseCommand [ "print", "--help" ] `shouldEqual` Right Help
      it "searches the input words for the help option" do
        parseCommand [ "a", "b", "c", "--help", "d" ] `shouldEqual` Right Help
    describe "Register" do
      it "fails without a name" do
        parseCommand [ "register" ] `shouldEqual` Left [ "Must provide name" ]
      it "uses . as the default path" do
        parseCommand [ "register", "alias" ] `shouldEqual` Right (Register (Alias "alias") (Path "."))
      it "parses custom paths" do
        parseCommand [ "register", "alias", "path" ] `shouldEqual` Right (Register (Alias "alias") (Path "path"))
      it "accepts relative paths" do
        parseCommand [ "register", "relative", "../../directory" ] `shouldEqual` Right (Register (Alias "relative") (Path "../../directory"))
      it "accepts absolute paths" do
        parseCommand [ "register", "absolute", "/tmp/path" ] `shouldEqual` Right (Register (Alias "absolute") (Path "/tmp/path"))
      it "ignores extra arguments" do
        parseCommand [ "register", "alias", "path", "extra" ] `shouldEqual` Right (Register (Alias "alias") (Path "path"))
    describe "Delete" do
      it "fails without an alias name" do
        parseCommand [ "delete" ] `shouldEqual` Left []
      it "parses the given name" do
        parseCommand [ "delete", "alias" ] `shouldEqual` Right (Delete (Alias "alias"))
      it "ignores extra args" do
        parseCommand [ "delete", "alias", "extra" ] `shouldEqual` Right (Delete (Alias "alias"))
    describe "Print" do
      it "parses the print command" do
        parseCommand [ "print" ] `shouldEqual` Right Print
      it "ignores extra args" do
        parseCommand [ "print", "extra", "args" ] `shouldEqual` Right Print
    describe "To" do
      it "fails without an alias name" do
        parseCommand [ "to" ] `shouldEqual` Left []
      it "parses the given name" do
        parseCommand [ "to", "alias" ] `shouldEqual` Right (To (Alias "alias"))
      it "ignores extra args" do
        parseCommand [ "to", "alias", "extra" ] `shouldEqual` Right (To (Alias "alias"))
      it "treats unknown commands as a To command" do
        parseCommand [ "cd" ] `shouldEqual` Right (To (Alias "cd"))
      it "treats misspelled commands as a To command" do
        parseCommand [ "--helpp" ] `shouldEqual` Right (To (Alias "--helpp"))
      it "ignores extra args for assumed To commands" do
        parseCommand [ "rm", "-rf" ] `shouldEqual` Right (To (Alias "rm"))
