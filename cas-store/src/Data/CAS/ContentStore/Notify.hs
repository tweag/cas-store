{-# LANGUAGE LambdaCase #-}

-- | Generic file change notifier library for unix-based systems.
--
--   This library abstracts over specific implementations for BSD and linux
--   systems.
--
--   It provides facilities to watch specific directories for the following changes:
--   - File moves
--   - File deletion
--   - Attribute changes.
module Data.CAS.ContentStore.Notify
  ( Notifier,
    initNotifier,
    killNotifier,
    Watch,
    addDirWatch,
    removeDirWatch,
  )
where

import System.FSNotify

type Notifier = WatchManager

initNotifier :: IO Notifier
initNotifier = startManager

killNotifier :: Notifier -> IO ()
killNotifier = stopManager

type Watch = StopListening

addDirWatch :: Notifier -> FilePath -> IO () -> IO Watch
addDirWatch inotify dir f = watchDir inotify dir defaultEvent (const f)
  where
    defaultEvent e@ModifiedAttributes{} = isDirectory e
    defaultEvent e@Modified{} = isDirectory e 
    defaultEvent e@Removed{} = isDirectory e
    defaultEvent e@WatchedDirectoryRemoved{} = isDirectory e
    defaultEvent _ = False
    isDirectory = (IsDirectory==) . eventIsDirectory

removeDirWatch :: Watch -> IO ()
removeDirWatch w = w
