{-# LANGUAGE OverloadedStrings #-}
module Domain.Types.Entry where

import Data.Text (Text)
import Data.Time (Day)

data MediaType = Podcast | Youtube | Spiritual
    deriving (Show,Eq)
    
data Entry = Entry
  { entryId         :: Int          -- your call, see below
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