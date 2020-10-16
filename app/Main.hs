module Main where

import           SantaLib
import qualified Html.Attribute                as A
import           Html

data Santa = Gabi
           | Klaus
           | Helmut
           | Irmgard
  deriving (Show, Eq, Enum)

santas :: [Santa]
santas = enumFrom Gabi

incops = [(Gabi, Klaus), (Helmut, Irmgard)] ++ zip santas santas

pageSimple santas assigns = html_
  (head_ (title_ "Wichteln 2019" # script_ (Raw $ jsAssigns assigns)) # body_
    ( h1_ "Wichteln 2019"
    # img_A (A.src_ "wichtel.gif")
    # p_
        "Hallo liebe*r Wichtel*in. Gib hier deinen Namen ein und schubse den Button."
    # p_ "Hey! Nicht einfach irgendwelche anderen Namen eingeben!"
    # input_A (A.id_ "name")
    # button_A (A.id_ "pushbutton") "Gimme dat Wichtelname!"
    # div_A (A.id_ "result") ""
    # p_ "Folgende Wichtel machen mit:"
    # santaList santas
    # simpleScript
    )
  )

main :: IO ()
main = do
  assign <- makeSanta santas incops
  putStrLn $ renderString (pageSimple santas assign)
