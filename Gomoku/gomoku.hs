module Main where

import Prelude
import Data.Matrix
import Data.Tree
import Data.Maybe
import Data.List


data Cell = White | Black | None deriving (Eq,Ord) -- pole na planszy

instance Show Cell where
     show White = "O"
     show Black = "X"
     show None = "-"


initBoard x = (matrix x x $ \ (a,b) -> None) -- inicjacja planszy




---------------do pokazywania

addBreak [] = []
addBreak (a:as) = show a ++" "++ (addBreak as)

--showRows :: Int -> matrix -> String      --dodaje znaki z lewej i prawej kolumny
showRows a board = if (a+1) < 10 then  "\t " ++ show (a+1) ++ "  "++addBreak ((toLists board)!!a) ++ " "++show (a+1) ++"\n" ++ showRows (a+1) board
                   else if a < (length (toLists board)) then  "\t" ++ show (a+1) ++ "  "++addBreak ((toLists board)!!a) ++ " "++show (a+1) ++"\n" ++ showRows (a+1) board
                        else []

showDescription = "\t    A B C D E F G H I J K L M N O P R S T \n"

showB board = putStrLn ( showDescription++"\n" ++ showRows 0 board ++"\n"++ showDescription) --pokazuje plansze




----------------------- tworzenie nowych hipotetycznych plansz

cellContent n m board = if (n < 1) || (n > 19) || (m < 1) || (m > 19) then None else getElem n m board -- zwraca co zawiera komorka, jak wspolzedne poza plansza to pokazuje ze None

isNeighbor n m board
  | ((n > 1) && (n < 19) && (m > 1) && (m < 19) && ((cellContent (n+1) m board) /= None) || ((cellContent (n+1) (m+1) board) /= None) || ((cellContent (n+1) (m-1) board) /= None) || ((cellContent n (m+1) board) /= None) || ((cellContent n (m-1) board) /= None) || ((cellContent (n-1) m board) /= None) || ((cellContent (n-1) (m+1) board) /= None) || ((cellContent (n-1) (m-1) board) /= None)) = True
  | otherwise = False   --sprawdza czy komorka ma jakiegokolwiek sasiada


isEmpty n m board          --sprawdza czy komorka jest pusta
  | (getElem n m board == None) = True
  | otherwise = False

makeEmptyCellList board = [ (n,m) | n <- [1..19], m <- [1..19], isEmpty n m board, isNeighbor n m board]--tworzy krotki wspolrzednych gdzie mozna wstawic


makeBoard board typ [] = [] --robi nowe hipotetyczne plansze
makeBoard board typ (a:as) = (setElem typ ((fst a),(snd a)) board) : (makeBoard board typ as)   

makePossibleBoards board typ = makeBoard board typ (makeEmptyCellList board)--robi nowe hipotetyczne plansze w postaci lisy





-------------ocenianie planszy
checkVector typ (x,y) _ 1 board --warunek stopu
        | ((cellContent x y board) == typ) = True 
        | otherwise = False

checkVector typ (x,y) (a,b) n board --sprawdza ilość kolek/krzyżyków pod rzad wzgledem wektora (a,b)
        | (((cellContent x y board) == typ) && (checkVector typ ((x-b),(y+a)) (a,b) (n-1) board) == True) = True 
        | otherwise = False

vectorLength typ (x,y) (a,b) board = if ((cellContent x y board) == typ) then 1 + vectorLength typ (x-b,y+a) (a,b) board else 0



makeMark typ (x,y) (a,b) board = 16 ^ (vectorLength typ (x,y) (a,b) board)




checkAllPossibilities _ (19,19) _ suma = suma
checkAllPossibilities typ (x,y) board suma
  | cellContent x y board == None = if (x < 19) then (checkAllPossibilities typ (x+1,y) board suma) else (checkAllPossibilities typ (1,y+1) board suma)
  | (x < 19) = checkAllPossibilities typ (x+1,y) board (suma + (makeMark typ (x,y) (1,0) board) + (makeMark typ (x,y) (1,-1) board) + (makeMark typ (x,y) (0,-1) board) + (makeMark typ (x,y) (1,1) board))
  | otherwise = checkAllPossibilities typ (1,y+1) board (suma + (makeMark typ (x,y) (1,0) board) + (makeMark typ (x,y) (1,-1) board) + (makeMark typ (x,y) (0,-1) board) + (makeMark typ (x,y) (1,1) board))
     --przechodzi i wyszukuje wzorców, sprawdza wektory (1,0), (1,-1), (0,-1) dzieki czemu przechodzi po wszystkich mozliwosciach

rateBoard typ board = checkAllPossibilities typ (1,1) board 0 - (checkAllPossibilities (changeType typ) (1,1) board 0)----funkcja oceniajaca plansze

findMaxVector _ (19,19) _ suma = suma -- szuka najdłuższego ustawienia pod rząd
findMaxVector typ (x,y) board suma
  | cellContent x y board == None = if (x < 19) then (findMaxVector typ (x+1,y) board suma) else (findMaxVector typ (1,y+1) board suma)
  | (x < 19) = findMaxVector typ (x+1,y) board (maximum [suma,(vectorLength typ (x,y) (1,0) board),(vectorLength typ (x,y) (1,-1) board),(vectorLength typ (x,y) (0,-1) board),(vectorLength typ (x,y) (1,1) board)])
  | otherwise = findMaxVector typ (1,y+1) board (maximum [suma,(vectorLength typ (x,y) (1,0) board),(vectorLength typ (x,y) (1,-1) board),(vectorLength typ (x,y) (0,-1) board),(vectorLength typ (x,y) (1,1) board)])


isWin board typ =
  if (findMaxVector typ (1,1) board 0) == 5 then True else False

--------------------- generowanie drzewa gry
changeType typ --zmienia White na Black i odwrotnie, żeby w drzewie też szło na przemian
     | typ == White = Black
     | typ == Black = White
     | otherwise = None

makeNods typ [] = []
--makeNods (b:bs) = (Node b []):(makeNods bs)

makeNods typ (b:bs) = (Node b (makeNods (changeType typ) (makePossibleBoards b (changeType typ) ))):(makeNods typ bs)


makeTree typ board = Node board $ makeNods typ (makePossibleBoards board typ)--tworzy NIESKONCZONE drzewo przeszukiwania

----------------------------------------------------------------------------------------------------------------------



getRoot [] = [] -- zwraca liste dzieci
getRoot ((Node root _):cos) = root : (getRoot cos)

listChildren (Node _ []) = []
listChildren (Node root list) =  getRoot list




--minmax :: Tree (Board Cell) -> Cell -> Int -> Integer
minmax (Node board []) cell _= rateBoard cell board 
minmax (Node board _) cell 0 = rateBoard cell board
minmax (Node _ xs ) White index = minimum (my_map minmax xs Black (index-1) )
minmax (Node _ xs ) Black index = maximum (my_map minmax xs White (index-1) )

--my_map :: (a -> b) -> [a] -> [b]
my_map _ [] _  _= []
my_map f (x:xs) cell index = f x cell index : my_map f xs cell index

minmax2 (Node _ xs ) White index =  minIndex (my_map minmax xs Black (index-1) )
minmax2 (Node _ xs ) Black index =  maxIndex (my_map minmax xs White (index-1) )

maxIndex xs = head $ filter ((== maximum xs) . (xs !!)) [0..]
minIndex xs = head $ filter ((== minimum xs) . (xs !!)) [0..]



--------------------GRA-----------------------------------------------
data Player = Human Cell | AI Cell deriving (Eq,Show)


--updateBoard :: Board Cell -> Int -> Int -> Player -> Board Cell
updateBoard x row col player = setElem (cellColor player) (row,col) x

helper :: t -> t -> Player -> t
helper _ b ( Human White ) = b
helper a _ ( AI Black ) = a


currentPlayer :: Player -> IO()
currentPlayer = helper (putStrLn "Ruch krzyżyk(AI): ") (putStrLn "Ruch kółko(Gracz): ")

cellColor :: Player -> Cell
cellColor = helper Black White

nextPlayer :: Player  -> Player
nextPlayer (AI Black) = helper (Human White) (AI Black) (AI Black)
nextPlayer (Human White) = helper (Human White) (AI Black) (Human White)

isNumber :: String -> Bool
isNumber str =
    case (reads str) :: [(Double, String)] of
      [(_, "")] -> True
      _         -> False



getRow :: IO String
getRow = do
  putStrLn "Row: "
  c <- getLine
  if isNumber c 
    then return c
    else do
      putStrLn "podaj poprawna pozycje" 
      Main.getRow



getCol :: IO String
getCol = do
  putStrLn "Col: "
  c <- getLine
  if isNumber c 
    then return c
    else do 
      putStrLn "podaj poprawna pozycje"
      Main.getCol




--makeMove :: Board Cell -> Int -> Int -> Player -> IO ()
makeMove x row col player = 
    do
      if isEmpty row col x
      then do
          gameLoop (updateBoard x row col player) (nextPlayer player) 
      else do
        print "pole jest zajete"
        gameLoop x player



--gameLoop :: Board Cell -> Player -> IO ()
gameLoop x (AI o) = --pętla dla AI
  do 
    if isWin x White
    then do
     showB x
     putStrLn "Wygrywa Kółko"
     getLine >>= putStrLn
    else do
      showB x
      currentPlayer (AI o)
      let t = (makeTree Black x)
      let x = ( listChildren t ) !! ( minmax2 t Black 4 )
      if isWin x Black 
      then do
        showB x
        putStrLn "Wygrywa Krzyżyk"
        getLine >>= putStrLn
      else do
        gameLoop x (nextPlayer (AI o))

gameLoop x (Human o) = --pętla dla gracza
  do 
     showB x
     currentPlayer (Human o)
     r <- Main.getRow
     c <- Main.getCol
     let row = read r :: Int
     let col = read c :: Int
     makeMove x row col (Human o)




main :: IO ()
main = do
gameLoop (initBoard 19) (Human White)

