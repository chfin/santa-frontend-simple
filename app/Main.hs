module Main where

import           Lib

data Santa = Gabi
           | Klaus
           | Helmut
           | Irmgard
  deriving (Show, Eq, Enum)

santas :: [Santa]
santas = enumFrom Gabi

incops = [(Gabi, Klaus), (Helmut, Irmgard)] ++ zip santas santas

main :: IO ()
main = makeSimpleSanta santas incops >>= putStrLn
