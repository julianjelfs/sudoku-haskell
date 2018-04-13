{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_sudoku_haskell (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\bin"
libdir     = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\lib\\x86_64-windows-ghc-8.2.2\\sudoku-haskell-0.1.0.0-JpweTu7Vzg06VMSqVO2S8V"
dynlibdir  = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\lib\\x86_64-windows-ghc-8.2.2"
datadir    = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\share\\x86_64-windows-ghc-8.2.2\\sudoku-haskell-0.1.0.0"
libexecdir = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\libexec\\x86_64-windows-ghc-8.2.2\\sudoku-haskell-0.1.0.0"
sysconfdir = "C:\\Users\\julia\\projects\\sudoku-haskell\\.stack-work\\install\\cd2629c6\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "sudoku_haskell_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "sudoku_haskell_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "sudoku_haskell_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "sudoku_haskell_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "sudoku_haskell_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "sudoku_haskell_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
