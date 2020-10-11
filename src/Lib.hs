module Lib where

import           System.Random.MWC
import           System.Random.MWC.Distributions
import qualified Data.Vector                   as V
import           Html
import qualified Html.Attribute                as A
import qualified Data.Text.Lazy.IO             as TL
import           Data.List                      ( intercalate )

type Incop a = (a, a)
type Assign a = (a, a)

check :: (Eq a) => [Assign a] -> [Incop a] -> Bool
check assigns incops = all isComp assigns
 where
  isComp asgn =
    all (\(i1, i2) -> not (asgn == (i1, i2) || asgn == (i2, i1))) incops

randomSantas :: GenIO -> [a] -> IO [Assign a]
randomSantas gen santas = do
  targets <- uniformShuffle (V.fromList santas) gen
  return $ zip santas (V.toList targets)

sampleSantas :: (Eq a) => GenIO -> [a] -> [Incop a] -> IO [Assign a]
sampleSantas gen santas incops = do
  rs <- randomSantas gen santas
  if check rs incops then return rs else sampleSantas gen santas incops

jsAssings as = "var assignment = {" ++ jsas ++ "};"
 where
  jsas = intercalate ", " $ map jsa as
  jsa (from, to) = "\"" ++ show from ++ "\": \"" ++ show to ++ "\""

-- render :: [Assign] -> _
pageSimple santas assigns = html_
  (head_ (title_ "Wichteln 2019" # script_ (Raw $ jsAssings assigns)) # body_
    ( h1_ "Wichteln 2019"
    # img_A (A.src_ "wichtel.gif")
    # p_
        "Hallo liebe*r Wichtel*in. Gib hier deinen Namen ein und schubse den Button."
    # p_ "Hey! Nicht einfach irgendwelche anderen Namen eigenben!"
    # input_A (A.id_ "name")
    # button_A (A.id_ "pushbutton") "Gimme dat Wichtelname!"
    # div_A (A.id_ "result") ""
    # p_ "Folgende Wichtel machen mit:"
    # ul_ (map (li_ . show) santas)
    # script_A (A.src_ "wichteln.js") ""
    )
  )

makeSimpleSanta :: (Eq a, Show a) => [a] -> [Incop a] -> IO String
makeSimpleSanta santas incops = do
  gen     <- createSystemRandom
  assigns <- sampleSantas gen santas incops
  pure $ renderString (pageSimple santas assigns)
