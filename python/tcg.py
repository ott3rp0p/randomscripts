import argparse
import requests 
from mtgsdk import Card as mtgCard, Set as mtgSet
from pokemontcgsdk import Card as pkmonCard, Set as pkmonSet

def tcgMtgCardData(tcgName):
   tcgName = tcgName.replace(" ","_")
   request = mtgCard.where(name=tcgName).all()
   print(request[0].name)

def tcgMtgSetData(tcgName):
    tcgName = tcgName.replace(" ","_")
    request = mtgSet.where(name=tcgName).all()
    print(dir(request[0].name))

def tcgPkmonCardData(tcgName):
    tcgName = tcgName.replace(" ","_")
    print(tcgName)

def tcgYugiCardData(tcgName):
    tcgName = tcgName.replace(" ","_")
    try:
        request = requests.get(f"https://db.ygoprodeck.com/api/v7/cardinfo.php?name={tcgName}")
    except: 
        print("something went wrong")
    if str("error") in request.text:
        print("no card found")
    else:     
        print(request.text)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--mtg", type = str)
    parser.add_argument("--pokemon", type = str)
    parser.add_argument("--gemini", type = str)
    parser.add_argument("--yugi", type = str)
    args = parser.parse_args()

    if args.mtg:
        tcgMtgCardData(args.mtg)
    elif args.pokemon:
        tcgPkmonCardData(args.pokemon)
    elif args.yugi:
        tcgYugiCardData(args.yugi)
