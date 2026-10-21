module Domain.Action.Entry
  ( addEntry
  , deleteEntry
  , updateEntry
  , filterEntries
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import Domain.Types.Entry

-- | Adds an entry, assigning the next id (max existing id + 1).
-- Fails with 'EmptyTitle' if the title is blank.
addEntry :: NewEntry -> [Entry] -> Either EntryError [Entry]
addEntry new entries
  | isBlank (newTitle new) = Left EmptyTitle
  | otherwise = Right (entries ++ [entry])
  where
    entry =
      Entry
        { entryId = nextId entries
        , title = newTitle new
        , mediaType = newMediaType new
        , source = newSource new
        , url = newUrl new
        , consumedOn = newConsumedOn new
        , summary = newSummary new
        , initialThoughts = newInitialThoughts new
        , tags = newTags new
        , notionPageId = Nothing
        }

deleteEntry :: Int -> [Entry] -> Either EntryError [Entry]
deleteEntry eid entries
  | any ((== eid) . entryId) entries = Right (filter ((/= eid) . entryId) entries)
  | otherwise = Left (EntryNotFound eid)

-- | Replaces the entry whose id matches the given entry's id.
updateEntry :: Entry -> [Entry] -> Either EntryError [Entry]
updateEntry new entries
  | isBlank (title new) = Left EmptyTitle
  | any ((== entryId new) . entryId) entries = Right (map replace entries)
  | otherwise = Left (EntryNotFound (entryId new))
  where
    replace e
      | entryId e == entryId new = new
      | otherwise = e

filterEntries :: EntryFilter -> [Entry] -> [Entry]
filterEntries f = filter matches
  where
    matches e = matchesType e && matchesTag e
    matchesType e = maybe True (== mediaType e) (filterMediaType f)
    matchesTag e = maybe True (`elem` tags e) (filterTag f)

nextId :: [Entry] -> Int
nextId [] = 1
nextId es = maximum (map entryId es) + 1

isBlank :: Text -> Bool
isBlank = T.null . T.strip
