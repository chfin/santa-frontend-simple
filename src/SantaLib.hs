{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module SantaLib where

import           System.Random.MWC              ( GenIO
                                                , createSystemRandom
                                                )
import           System.Random.MWC.Distributions
                                                ( uniformShuffle )
import qualified Data.Vector                   as V
import           Html
import qualified Html.Attribute                as A
import           Data.List                      ( intercalate )

type Incop a = (a, a)
type Assign a = (a, a)

check :: (Eq a) => [Assign a] -> [Incop a] -> Bool
check assigns incops = all isComp assigns
 where
  eqAssign asgn (i1, i2) = asgn == (i1, i2) || asgn == (i2, i1)
  isComp asgn@(s1, s2) = (s1 /= s2) && not (any (eqAssign asgn) incops)

randomSantas :: GenIO -> [a] -> IO [Assign a]
randomSantas gen santas = do
  targets <- uniformShuffle (V.fromList santas) gen
  return $ zip santas (V.toList targets)

sampleSantas :: (Eq a) => GenIO -> [a] -> [Incop a] -> IO [Assign a]
sampleSantas gen santas incops = do
  rs <- randomSantas gen santas
  if check rs incops then return rs else sampleSantas gen santas incops

jsAssigns :: (Show a) => [Assign a] -> String
jsAssigns as = "var assignment = {" ++ jsas ++ "};"
 where
  jsas = intercalate ", " $ map jsa as
  jsa (from, to) = "\"" ++ show from ++ "\": \"" ++ show to ++ "\""

assignmentScript :: (Show a) => [Assign a] -> ('Script > Raw String)
assignmentScript assigns = script_ $ Raw $ jsAssigns assigns

santaList :: (Show a) => [a] -> ('Ul > [ 'Li > String])
santaList santas = ul_ (map (li_ . show) santas)

simpleScript
  :: String -> ('Script > Raw String) # (:@:) 'Script ('SrcA := String) String
simpleScript group =
  script_ (Raw $ "const GROUP = " <> show group <> ";")
    # script_A (A.src_ "wichteln.js") ""

backendScript :: (:@:) 'Script ('SrcA := String) String
backendScript = script_A (A.src_ "santa/static/api.js") ""

jsDependencies =
  script_A (A.src_ "https://unpkg.com/maquette@3.3.4/dist/maquette.umd.js") ""
    # script_A (A.src_ "/santa/static/api.js") ""

makeSanta :: (Eq a, Show a) => [a] -> [Incop a] -> IO [Assign a]
makeSanta santas incops = do
  gen <- createSystemRandom
  sampleSantas gen santas incops
