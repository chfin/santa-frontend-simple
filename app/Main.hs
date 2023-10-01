module Main where

import           SantaLib
import           Html

data Santa = Gabi
           | Klaus
           | Helmut
           | Irmgard
  deriving (Show, Eq, Enum)

santas :: [Santa]
santas = enumFrom Gabi

incops = reflexive [(Gabi, Klaus), (Helmut, Irmgard)]

-- pageSimple santas assigns = Html :>
--   (Head :> (Title :> "Wichteln 2019" # Script :> (jsAssigns assigns)) # Body :>
--     ( H1 :> "Wichteln 2019"
--     # Img :@ (SrcA := "wichtel.gif")
--     # P :> "Hallo liebe:r Wichtel:in. Gib hier deinen Namen ein und schubse den Button."
--     # P :> "Hey! Nicht einfach irgendwelche anderen Namen eingeben!"
--     # Input :@ (IdA := "name")
--     # Button :@ (IdA := "pushbutton") :> "Gimme dat Wichtelname!"
--     # Div :@ (IdA := "result")
--     # P :> "Folgende Wichtel machen mit:"
--     # santaList santas
--     # jsDependencies
--     # simpleScript "examle"
--     )
--   )

main :: IO ()
main = do
  assign <- makeSanta santas incops
  -- putStrLn $ renderString (pageSimple santas assign)
  putStrLn $ jsAssigns assign
