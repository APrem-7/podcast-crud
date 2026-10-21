{-# LANGUAGE OverloadedStrings #-}
module Domain.Types.Entry where

import Data.Text (Text)
import Data.Time (Day)

data MediaType = Podcast | Youtube | Spiritual
    deriving (Show, Eq)

data Entry = Entry
  { entryId         :: Int
  , title           :: Text
  , mediaType       :: MediaType
  , source          :: Text         -- show or channel name
  , url             :: Maybe Text   -- optional
  , consumedOn      :: Day
  , summary         :: Text
  , initialThoughts :: Text
  , tags            :: [Text]
  , notionPageId    :: Maybe Text   -- Nothing until synced
  }
  deriving (Show, Eq)

-- | What the user supplies when creating an entry. The id is assigned by
-- 'Domain.Action.Entry.addEntry' and the Notion page id is set after syncing.
data NewEntry = NewEntry
  { newTitle           :: Text
  , newMediaType       :: MediaType
  , newSource          :: Text
  , newUrl             :: Maybe Text
  , newConsumedOn      :: Day
  , newSummary         :: Text
  , newInitialThoughts :: Text
  , newTags            :: [Text]
  }
  deriving (Show, Eq)

-- | 'Nothing' means "don't filter on this".
data EntryFilter = EntryFilter
  { filterMediaType :: Maybe MediaType
  , filterTag       :: Maybe Text
  }
  deriving (Show, Eq)

data EntryError
  = EntryNotFound Int
  | EmptyTitle
  deriving (Show, Eq)
