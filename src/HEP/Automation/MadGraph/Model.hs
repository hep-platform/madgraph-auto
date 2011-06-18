{-# LANGUAGE TypeFamilies, FlexibleInstances, FlexibleContexts #-}

module HEP.Automation.MadGraph.Model where


class (Show a, Show (ModelParam a)) => Model a where
  data ModelParam a :: * 
  briefShow       :: a -> String 
  modelName       :: a -> String 
  paramCard4Model :: a -> String 
  paramCardSetup  :: FilePath -> a -> ModelParam a -> IO String 
  briefParamShow  :: ModelParam a -> String 
  interpreteParam :: String -> ModelParam a

data MadGraphVersion = MadGraph4 | MadGraph5
                  deriving Show


makeProcessFile :: Model a => a  -> MadGraphVersion -> String -> String -> String
makeProcessFile model mgver process dirname = 
  let importline = case mgver of
        MadGraph4 -> "import model_v4 " ++ modelName model
        MadGraph5 -> "import model " ++ modelName model
  in importline ++ "\n" ++ process ++ "\n" ++ "output " ++ dirname ++ "\n\n" 

data DummyModel = DummyModel 
                deriving Show 
                        
instance Model DummyModel where
  data ModelParam DummyModel = DummyParam deriving Show 
  briefShow _ = "" 
  modelName _ = "" 
  paramCard4Model _ = "" 
  paramCardSetup _ _ _ = return "" 
  briefParamShow _ = "" 
  interpreteParam _ = DummyParam