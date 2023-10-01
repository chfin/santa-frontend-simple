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
import qualified Html                as A
import           Data.List                      ( intercalate )

type Incomp a = (a, a)
type Assign a = (a, a)

check :: (Eq a) => [Assign a] -> [Incomp a] -> Bool
check assigns incomps = all isComp assigns
 where
   -- eqAssign asgn (i1, i2) = asgn == (i1, i2)
  isComp asgn@(s1, s2) = (s1 /= s2) && not (any (asgn ==) incomps)

reflexive :: [Incomp a] -> [Incomp a]
reflexive incomps = incomps ++ (reflect <$> incomps)
  where reflect (i1, i2) = (i2, i1)

randomSantas :: GenIO -> [a] -> IO [Assign a]
randomSantas gen santas = do
  targets <- uniformShuffle (V.fromList santas) gen
  return $ zip santas (V.toList targets)

sampleSantas :: (Eq a) => GenIO -> [a] -> [Incomp a] -> IO [Assign a]
sampleSantas gen santas incomps = do
  rs <- randomSantas gen santas
  if check rs incomps then return rs else sampleSantas gen santas incomps

jsAssigns :: (Show a) => [Assign a] -> String
jsAssigns as = "var assignment = {" ++ jsas ++ "};"
 where
  jsas = intercalate ", " $ map jsa as
  jsa (from, to) = "\"" ++ show from ++ "\": \"" ++ show to ++ "\""

-- assignmentScript :: (Show a) => [Assign a] -> ('Script > Raw String)
assignmentScript assigns = Script :> jsAssigns assigns

-- santaList :: (Show a) => [a] -> ('Ul > [ 'Li > String])
santaList santas = Ul :> (map ((Li :>) . show) santas)

-- simpleScript
--  :: String -> ('Script > Raw String) # (:@:) 'Script ('SrcA := String) String
simpleScript group =
  (Script :> ("const GROUP = \"" <> group <> "\";"))
    # (Script :@ (SrcA := "wichteln.js"))

-- backendScript :: (:@:) 'Script ('SrcA := String) String
backendScript = Script :@ (SrcA := "santa/static/api.js")

jsDependencies =
  Script :@ (A.SrcA := "https://unpkg.com/maquette@3.3.4/dist/maquette.umd.js")
    # Script :@ (A.SrcA := "/santa/static/api.js")

makeSanta :: (Eq a, Show a) => [a] -> [Incomp a] -> IO [Assign a]
makeSanta santas incomps = do
  gen <- createSystemRandom
  sampleSantas gen santas incomps
