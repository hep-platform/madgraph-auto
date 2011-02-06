{-# LANGUAGE ScopedTypeVariables #-}

module UserCut where

import System.IO
import System.Process
import System.Directory
import System.Posix.Unistd (sleep)
import System.Posix.Env 

import Control.Monad

import Text.StringTemplate
import Text.StringTemplate.Helpers

import Text.Printf

import Work 
import Fortran 

runHEP2LHE :: ScriptSetup -> ProcessSetup -> RunSetup -> IO () 
runHEP2LHE ssetup psetup rsetup = do
  let eventdir = workbase ssetup ++ workname psetup ++ "/Events/" 
      workingdir = scriptbase ssetup ++ "working/"
      taskname = makeRunName psetup rsetup 
      hepfilename = taskname++"_pythia_events.hep"
      hepevtfilename = "afterusercut.hepevt"  
  setCurrentDirectory eventdir
  
  b <- doesFileExist hepfilename 
  if b 
    then do 
      putStrLn "Start hep2lhe"
      readProcess (workingdir++"hep2lhe.iw") [hepfilename,hepevtfilename] "" 
    else error "ERROR pythia result does not exist"  
  return () 

runHEPEVT2STDHEP :: ScriptSetup -> ProcessSetup -> RunSetup -> IO () 
runHEPEVT2STDHEP ssetup psetup rsetup = do
  let eventdir = workbase ssetup ++ workname psetup ++ "/Events/" 
      workingdir = scriptbase ssetup ++ "working/"
      taskname = makeRunName psetup rsetup 
      hepevtfilename = "afterusercut.hepevt"  
      stdhepfilename = "afterusercut.stdhep" 
  
  setCurrentDirectory eventdir
  
  b <- doesFileExist hepevtfilename 
  if b 
    then do 
      putStrLn "Start hepevt2stdhep"
      readProcess (workingdir++"hepevt2stdhep.iw") [hepevtfilename,stdhepfilename] "" 
    else error "ERROR pythia result does not exist"  
  return () 

runPGS :: ScriptSetup -> ProcessSetup -> RunSetup -> IO () 
runPGS ssetup psetup rsetup = do
  let eventdir = workbase ssetup ++ workname psetup ++ "/Events/" 
      workingdir = scriptbase ssetup ++ "working/"
      pgsdir = workbase ssetup ++ workname psetup ++ "/../pythia-pgs/src/"
      taskname = makeRunName psetup rsetup 
      carddir = workbase ssetup ++ workname psetup ++ "/Cards/"
      pgscardname = "pgs_card.dat"
      stdhepfilename = "afterusercut.stdhep" 
      uncleanedfilename = "pgs_uncleaned.lhco"
  

  setCurrentDirectory eventdir
  
  renameFile (carddir++"pgs_card.dat.user") (carddir++"pgs_card.dat")

  sleep 1

  b <- doesFileExist stdhepfilename 
  if b 
    then do 
      putStrLn "Start pgs"
      putEnv  $ "PDG_MASS_TBL=" ++ pgsdir ++ "mass_width_2004.mc "
      readProcess (pgsdir++"pgs") ["--stdhep",stdhepfilename,"--nev","0","--detector","../Cards/pgs_card.dat",uncleanedfilename] "" 
    else error "ERROR pythia result does not exist"  
  return () 


runClean :: ScriptSetup -> ProcessSetup -> RunSetup -> IO () 
runClean ssetup psetup rsetup = do
  let eventdir = workbase ssetup ++ workname psetup ++ "/Events/" 
      workingdir = scriptbase ssetup ++ "working/"
      pgsdir = workbase ssetup ++ workname psetup ++ "/../pythia-pgs/src/"
      taskname = makeRunName psetup rsetup 
      carddir = "../Cards/"
      hepfilename = taskname++"_pythia_events.hep"
      hepevtfilename = "afterusercut.hepevt"  
      stdhepfilename = "afterusercut.stdhep" 
      uncleanedfilename = "pgs_uncleaned.lhco"
      cleanedfilename = "pgs_cleaned.lhco"
      finallhco = taskname ++ "_pgs_events.lhco"

      existThenRemoveForAny x = existThenRemove (eventdir ++ x)
    
      clean_event_directory = 
        mapM_ existThenRemoveForAny  [ hepfilename
                                     , hepevtfilename
                                     , stdhepfilename
                                     , uncleanedfilename
                                     , cleanedfilename ]
         

  setCurrentDirectory eventdir
  
  b <- doesFileExist stdhepfilename 
  if b 
    then do 
      putStrLn "Start clean_output"
      readProcess (pgsdir++"clean_output") [ "-muon", uncleanedfilename, cleanedfilename ] "" 
      renameFile (eventdir++cleanedfilename) (eventdir++finallhco)

      sleep 10

      clean_event_directory

    else error "ERROR pythia result does not exist"  
  return () 

updateBanner :: ScriptSetup -> ProcessSetup -> RunSetup -> UserCut -> IO () 
updateBanner ssetup psetup rsetup uc = do
  let eventdir = workbase ssetup ++ workname psetup ++ "/Events/" 
      taskname = makeRunName psetup rsetup 
      carddir = workbase ssetup ++ workname psetup ++ "/Cards/"
      bannerfilename = taskname ++ "_banner.txt"
      newbannerfilename = taskname ++ "_newbanner.txt"
      usercutcontent = prettyprintUserCut uc
  setCurrentDirectory eventdir
  bannerstr  <- readFile (eventdir ++ bannerfilename)
  pgscardstr <- readFile (carddir ++ "pgs_card.dat")  
  let newbannerstr = bannerstr ++ usercutcontent ++ pgscardstr
  writeFile (eventdir ++ newbannerfilename) newbannerstr 

  
