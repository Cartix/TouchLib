--[[
TOUCHLIB - VERSION 0.5 - 09/08/2014
Codée par Cartix et -florian66- (de Planète Casio)
Définit TL_GetXY(),TL_WaitDn(),TL_WaitUp,TL_GetDir(),TL_Wait().
Ces fonctions permettent de simuler un pavé tactile sur la calculatrice, à la place des touches du pavé d'en bas (entre [7] et [EXE], comprises)
Les coordonnées obtenues par les différentes fonctions varient donc en fonction des touches sur lesquelles l'utilisateur appuye.
Le pavé est paramétrés de la sorte : la touche [7] correspond au point (0,0) et la touche [EXE] au point (128,64)
]]
 
 --[[
CODE D'APPEL DE LA LIBRAIRIE :
TCLib,err = misc.modload ( "touch")
if TCLib == nil then                -- Si il y a erreur, TCLib = nil. err contient alors le message d'erreur
nbdraw.print(err)                   -- Affiche l'erreur lors du chargement du fichier
end
TCLib()                             -- Execute le fichier (et donc defini les fonctions et les variables globales qui deviennent accessibles)
]]
------------------
 
def="module touch"                  -- Définition du module

-- FONCTIONS MATHÉMATIQUES NÉCESSAIRES
--[[Ces fonctions sont là uniquement afin d'alléger la librairie et la rendre indépendante, pour faire en sorte de n'avoir pas besoin
du module math.lua pour que celle-ci fonctionne.
]]

function flr(x)                     -- Cette fonction renvoie la partie entière d'un nombre (x)
  return x - x % 1
end

function abs(x)                     -- Cette fonction renvoie la valeur absolue d'un nombre (x)
  if(x > 0) then
    return x
  else
    return -x
  end
end

function sgn(x)                     -- Cette fonction renvoie le signe d'un nombre (x)
  if(x==0) then
    return 0
  else
    return x/abs(x)
  end
end

-- FONCTIONS PERMETTANT DE SIMULER L'EFFET TACTILE

--[[ x, y, tch = TL_GetXT()
Description         : Cette fonction regarde l'ensemble des touches pressées dans la zone d'intêret (entre 7 et EXE) et
                      calcule à partir de celles-ci les coordonnées du point appuyé
Arguments d'entrée  : Aucun
Arguments de sortie : x   : Entier  : Contient l'abscisse du point où l'on a appuyé
                      y   : Entier  : Contient l'ordonnée du point où l'on a appuyé
                      tch : Booléen : Contient vrai si on a appuyé quelque part, faux sinon
]]
function TL_GetXY()
  local j,x,y,i = 0,0,0
  for i = 1,20,1 do
    if key(i) then
      x = x + 25.6 * ((i - 1) % 5)
      y = y + flr(i / 5 - .2) * 16
      j = j + 1
    end
  end
  if j ~= 0 then
    return flr(12.8 + x / j),abs(flr(8 + y / j) - 64),true
  else
    return 0,0,false
  end
end

--[[ x,y = TL_WaitDn()
Description         : Cette fonction attend que l'utilisateur appuie sur un point, et renvoie alors les coordonnées de celui-ci
Arguments d'entrée  : Aucun
Arguments de sortie : x : Entier : Contient l'abscisse du point où l'on a appuyé
                      y : Entier : Contient l'ordonnée du point où l'on a appuyé
]]

function TL_WaitDn()
  local x,y,tch
  repeat
    x,y,tch = TL_GetXY()
  until tch
  return x,y
end

--[[ x,y = TL_WaitDn()
Description         : Cette fonction attend que l'utilisateur n'appuie plus sur aucun point, et renvoie alors les
                      coordonnées du dernier point appuyé
Arguments d'entrée  : Aucun
Arguments de sortie : x : Entier : Contient l'abscisse du point où l'on a appuyé
                      y : Entier : Contient l'ordonnée du point où l'on a appuyé
]]

function TL_WaitUp()
  local x,tx,y,ty,tch
  repeat
    x,y,tch = TL_GetXY()
    if tch then
      tx,ty = x,y
    end
  until not(tch)
  return tx,ty
end

--[[ dx,dy : TL_GetDir()
Description         : Cette fonction attend que l'utilisateur se soit déplacé sur le pavé "tactile" et renvoie
                      la direction de son mouvement, définie comme suivant :
                      Déplacement vers la gauche : dx,dy = -1, 0
                      Déplacement vers la droite : dx,dy =  1, 0
                      Déplacement vers le haut   : dx,dy =  0,-1
                      Déplacement vers le bas    : dx,dy =  0, 1
Arguments d'entrée : Aucun
Argument de sortie : dx : Entier : Contient la direction en x (v. ci-dessus)
                     dy : Entier : Contient la direction en y
]]

function TL_GetDir()
  local x1,y1 = TL_WaitDn()
  local x2,y2 = TL_WaitUp()
  if abs(x2-x1) < abs(y2-y1) then
    return 0,sgn(y2-y1)
  else
    return sgn(x2-x1),0
  end
end

--[[ x,y = TL_Wait(x1,y1,x2,y2)
Description        : Cette fonction attend que l'utilisateur ait appuyé dans une zone précise, et renvoie les coordonnées
                      du point appuyé
Arguments d'entrée :  x1 : Entier : Limite à gauche de la zone
                      y1 : Entier : Limite en haut de la zone
                      x2 : Entier : Limite à droite de la zone (x1<x2)
                      y2 : Entier : Limite en bas de la zone (y1<y2)
Arguments de sortie : x : Entier : Abscisse du point appuyé
                      y : Entier : Ordonnée du point appuyé
]]

function TL_Wait(x1,y1,x2,y2)
  local x,y
  repeat
    x,y = TL_WaitDn()
  until (x < x1) or (x > x2) or (y < y1) or (y > y2)
  return x,y
end

--[[ tst = TL_Wait(x1,y1,x2,y2)
Description        : Cette fonction teste si l'utilisateur appuie dans une zone précise
Arguments d'entrée :  x1 : Entier : Limite à gauche de la zone
                      y1 : Entier : Limite en haut de la zone
                      x2 : Entier : Limite à droite de la zone (x1<x2)
                      y2 : Entier : Limite en bas de la zone (y1<y2)
Arguments de sortie : tst : Booléen : Contient vrai si le resultat du test est positif, faux sinon
]]

function TL_Test(x1, y1, x2, y2)
  local x,y,tch = TL_GetXY()
  return tch and (x >= x1) and (x <= x2) and (y >= y1) and (y <= y2)
end