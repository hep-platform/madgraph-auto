-- {-# LANGUAGE QuasiQuotes #-}

module Main where

import Model
import Machine
import Work
import Fortran 
import UserCut 

-- import SimpleQQ

import System.Posix.Unistd (sleep)

ssetup = SS {
    scriptbase = "/nobackup/iankim/script/madgraph_auto/"
  , mg5base    = "/nobackup/iankim/montecarlo/MG_ME_V4.4.44/MadGraph5_v0_6_1/"
  , workbase   = "/nobackup/iankim/wk/"
  }

ucut = UserCut { 
    uc_metcut    = 15.0 
  , uc_etacutlep = 1.2 
  , uc_etcutlep  = 18.0
  , uc_etacutjet = 2.5
  , uc_etcutjet  = 15.0 
}


processTTBar0or1jet =  
  "\ngenerate P P > t t~  QED=99 @1 \nadd process P P > t t~ J QED=99 @2 \n"

psetup_wp_ttbar01j = PS {  
    mversion = MadGraph4
  , model = Wp 
  , process = processTTBar0or1jet 
  , processBrief = "ttbar01j"  
  , workname   = "205Wp1J"
  }

psetup_zp_ttbar01j = PS {  
    mversion = MadGraph4
  , model = ZpH 
  , process = processTTBar0or1jet 
  , processBrief = "ttbar01j"  
  , workname   = "205ZpH1J"
  }

psetup_trip_ttbar01j = PS {  
    mversion = MadGraph5
  , model = Trip 
  , process = processTTBar0or1jet 
  , processBrief = "ttbar01j"  
  , workname   = "205Trip1J"
  }

psetup_six_ttbar01j = PS {  
    mversion = MadGraph5
  , model = Six
  , process = processTTBar0or1jet 
  , processBrief = "ttbar01j"  
  , workname   = "205Six1J"
  }


rsetup p matchtype num = RS { 
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
  , usercut = UserCutDefined
  , pgs     = RunPGS
  , cluster = Cluster "test"
  , setnum  = num
}


-- wpparamset =  [ WpParam 200.0 (0.85*sqrt 2) ] 

zpparamset = [ ZpHParam 300.0 1.41 ]

{-             , WpParam 300.0 (1.20*sqrt 2) 
             , WpParam 400.0 (1.50*sqrt 2)
             , WpParam 600.0 (2.00*sqrt 2) ] 

zpparamset = [ ZpHParam 200.0 (0.70*sqrt 2) 
             , ZpHParam 300.0 (1.00*sqrt 2) 
             , ZpHParam 400.0 (1.30*sqrt 2) 
             , ZpHParam 600.0 (1.70*sqrt 2) ] 
           
tripparamset = [ TripParam 400.0 3.45
               , TripParam 400.0 3.3 
               , TripParam 400.0 3.15
               , TripParam 600.0 4.4  
               , TripParam 600.0 4.2 
               , TripParam 600.0 4.0  ] 
             
sixparamset = [ SixParam  600.0 3.5   
              , SixParam  600.0 3.35 
              , SixParam  600.0 3.2  ]  -}


-- psetuplist = [ psetup_wp_ttbar01j ]
--             , psetup_zp_ttbar01j
--             , psetup_trip_ttbar01j
--             , psetup_six_ttbar01j ] 

psetuplist = [ psetup_zp_ttbar01j ]

sets = [ 1 .. 50 ] -- ] --  [1,2] -- [ 3..10 ] 

zptasklist =  [ (psetup_zp_ttbar01j, rsetup p MLM num) | p <- zpparamset 
                                                       , num <- sets     ] 


{-
wptasklist =  [ (psetup_wp_ttbar01j, rsetup p MLM num) | p <- wpparamset 
        					       , num <- sets     ]  
	
                  
triptasklist =  [ (psetup_trip_ttbar01j, rsetup p MLM num) | p <- tripparamset 
                                                           , num <- sets     ]

sixtasklist =  [ (psetup_six_ttbar01j, rsetup p MLM num) | p <- sixparamset 
                                                         , num <- sets     ] -}



totaltasklist = zptasklist 

-- wptasklist ++ zptasklist ++ triptasklist ++ sixtasklist 

main = do putStrLn "benchmark models 20110205 sets" 
          putStrLn "models : ZpH "

	  let combinedfunc (psetup,rsetup) = do 
                cardPrepare      ssetup psetup rsetup
                generateEvents   ssetup psetup rsetup
                runHEP2LHE       ssetup psetup rsetup
                runHEPEVT2STDHEP ssetup psetup rsetup
	        runPGS           ssetup psetup rsetup 
                runClean         ssetup psetup rsetup 
                updateBanner     ssetup psetup rsetup ucut
                return () 


          compileFortran ssetup ucut

          mapM_ (createWorkDir ssetup) psetuplist
          sleep 2
          mapM_ combinedfunc totaltasklist 

          