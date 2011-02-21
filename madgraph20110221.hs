{-# LANGUAGE PackageImports #-}

module Main where

import "mtl" Control.Monad.Reader 

import Model
import Machine
import UserCut
import Cluster
import SetupType
import Run


import System.Posix.Unistd (sleep)


my_ssetup :: ScriptSetup
my_ssetup = SS {
    scriptbase = "/Users/iankim/mac/workspace/ttbar/madgraph_auto/"
  , mg5base    = "/Users/iankim/mac/montecarlo/MG_ME_V4.4.44/MadGraph5_v0_6_1/"
  , workbase   = "/Users/iankim/mac/workspace/ttbar/mc/"
  } 

ucut :: UserCut
ucut = UserCut { 
    uc_metcut    = 15.0 
  , uc_etacutlep = 1.2 
  , uc_etcutlep  = 18.0
  , uc_etacutjet = 2.5
  , uc_etcutjet  = 15.0 
}

processTTBar0or1jet :: [Char]
processTTBar0or1jet =  
  "\ngenerate P P > t t~  QED=99 @1 \nadd process P P > t t~ J QED=99 @2 \n"

psetup_axi_ttbar01j :: ProcessSetup
psetup_axi_ttbar01j = PS {  
    mversion = MadGraph4
  , model = AxiGluon 
  , process = processTTBar0or1jet 
  , processBrief = "ttbar01j"  
  , workname   = "216Axi1J"
  }

rsetupGen :: Param -> MatchType -> Int -> RunSetup
rsetupGen p matchtype num = RS { 
    param   = p
  , numevent = 100000
  , machine = TeVatron 
  , rgrun   = Fixed
  , rgscale = 200.0 
  , match   = matchtype
  , cut     = case matchtype of 
      NoMatch -> NoCut 
      MLM     -> DefCut
  , pythia  = case matchtype of 
      NoMatch -> NoPYTHIA
      MLM     -> RunPYTHIA
  , usercut = UserCutDef ucut 
  , pgs     = RunPGS
  , setnum  = num
}

my_csetup :: ClusterSetup
my_csetup = CS { cluster = Parallel 3 }

axiparamset :: [Param]
axiparamset = [ AxiGluonParam 1800.0 0.0 0.0 (1.5*sqrt 2.0) (-1.5*sqrt 2.0) 
              , AxiGluonParam 1800.0 0.0 0.0 (1.5*2.0) (-1.5*2.0) ]

psetuplist :: [ProcessSetup]
psetuplist = [ psetup_axi_ttbar01j ]

sets :: [Int]
sets = [1 .. 50 ]

axitasklist :: [WorkSetup]
axitasklist =  [ WS my_ssetup (psetup_axi_ttbar01j) (rsetupGen p MLM num) my_csetup  
                | p <- axiparamset 
                , num <- sets     ]

totaltasklist :: [WorkSetup]
totaltasklist = axitasklist 

main :: IO ()
main = do putStrLn "benchmark models 20110215 sets" 
          putStrLn "models : axigluon "

	  let cmdSequence = do 
                compileFortran
                cardPrepare                      
                generateEvents   
                runHEP2LHE       
                runHEPEVT2STDHEP
	        runPGS            
                runClean          
                updateBanner     
                cleanHepFiles
       
          -- create working directory (only once for each process)
--          mapM_ (createWorkDir my_ssetup) psetuplist
          sleep 2
          mapM_ (runReaderT cmdSequence) totaltasklist 

          