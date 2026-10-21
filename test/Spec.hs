{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Data.Time (fromGregorian)
import Domain.Action.Entry
import Domain.Types.Entry
import Test.Hspec

newEntry :: NewEntry
newEntry =
  NewEntry
    { newTitle = "Episode 1"
    , newMediaType = Podcast
    , newSource = "Some Show"
    , newUrl = Nothing
    , newConsumedOn = fromGregorian 2026 10 21
    , newSummary = "s"
    , newInitialThoughts = "t"
    , newTags = ["haskell"]
    }

main :: IO ()
main = hspec $ do
  describe "addEntry" $ do
    it "assigns id 1 to the first entry" $
      fmap (map entryId) (addEntry newEntry []) `shouldBe` Right [1]
    it "assigns max id + 1" $ do
      let Right two = addEntry newEntry [] >>= addEntry newEntry
      map entryId two `shouldBe` [1, 2]
    it "rejects a blank title" $
      addEntry newEntry {newTitle = "  "} [] `shouldBe` Left EmptyTitle

  describe "deleteEntry" $ do
    it "removes the entry" $ do
      let Right es = addEntry newEntry []
      deleteEntry 1 es `shouldBe` Right []
    it "fails when the id is missing" $
      deleteEntry 9 [] `shouldBe` Left (EntryNotFound 9)

  describe "updateEntry" $ do
    it "replaces the matching entry" $ do
      let Right es = addEntry newEntry []
          changed = (head es) {title = "Renamed"}
      fmap (map title) (updateEntry changed es) `shouldBe` Right ["Renamed"]
    it "fails when the id is missing" $ do
      let Right es = addEntry newEntry []
      updateEntry ((head es) {entryId = 5}) es `shouldBe` Left (EntryNotFound 5)

  describe "filterEntries" $ do
    let Right es = addEntry newEntry [] >>= addEntry newEntry {newMediaType = Youtube, newTags = []}
    it "keeps everything with an empty filter" $
      length (filterEntries (EntryFilter Nothing Nothing) es) `shouldBe` 2
    it "filters by media type" $
      map entryId (filterEntries (EntryFilter (Just Youtube) Nothing) es) `shouldBe` [2]
    it "filters by tag" $
      map entryId (filterEntries (EntryFilter Nothing (Just "haskell")) es) `shouldBe` [1]
