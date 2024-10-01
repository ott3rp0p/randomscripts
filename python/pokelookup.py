import pokebase as pb
import argparse

def pokeMon(name):
    mon  = pb.pokemon(name.lower())
    abilities = {}
    try:
        for i in range(len(mon.abilities)):
            abilities.update({"ability_" + str(i):mon.abilities[i].ability.name})
    except:
        pass
    pokeData = {
    'name':mon.name,
    'sprite':mon.sprites.other.official_artwork.front_default,
    'height':mon.height,
    'weight':mon.weight,
    'hp':mon.stats[0].base_stat,
    'attack':mon.stats[1].base_stat,
    'defense':mon.stats[2].base_stat,
    'special_attack':mon.stats[3].base_stat,
    'special_defense':mon.stats[4].base_stat,
    'speed':mon.stats[5].base_stat
    }
    url = {"url":f"https://bulbapedia.bulbagarden.net/wiki/{name.title()}_(Pokémon)"}
    pokeData.update(abilities)
    pokeData.update(url)
    print(pokeData)

def pokeMove(name):
    name.replace(' ' , '-')
    move = pb.move(name.lower())
    pokeData = {
    'name':move.name,
    'accuracy':move.accuracy,
    'effect':move.effect_entries[0].effect,
    'ailment':move.meta.ailment.name,
    'ailment_chance':move.meta.ailment_chance,
    'power':move.power,
    'pp':move.pp,
    'priority':move.priority,
    'type':move.type.name
    }
    url = {"url":f"https://bulbapedia.bulbagarden.net/wiki/{name.replace('-','_').title()}_(move)"}
    pokeData.update(url)
    print(pokeData)

def pokeAbility(name):
    name.replace(' ', '-')
    ability = pb.ability(name)
    pokeData = {
        'name':ability.name,
        'effect':ability.effect_entries[1].effect
    }
    url= {"url":f"https://bulbapedia.bulbagarden.net/wiki/{name.replace('-','_').title()}_(Ability)"}
    pokeData.update(url)
    print(pokeData)

def pokeItem(name):
    name.replace(' ', '-')
    item = pb.item(name.lower())
    length = range(len(item.attributes))
    attributes = {}
    for i in range(len(item.attributes)):
        attributes.update({"attribute_" + str(i):item.attributes[i].name})
    pokeData = {
    'name':item.names[7].name,
    'effect':item.effect_entries[0].effect,
    'sprite':item.sprites.default
    }
    pokeData.update(attributes)
    print(pokeData)
   
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--mon", "-p", type = str)
    parser.add_argument("--move", "-m", type = str)
    parser.add_argument("--ability", "-a", type = str)
    parser.add_argument("--item", "-i", type = str)
    args = parser.parse_args()
    if args.mon:
        pokeMon(args.mon)
    elif args.move:
        pokeMove(args.move)
    elif args.ability:
        pokeAbility(args.ability)
    elif args.item:
        pokeItem(args.item)
    else:
        print('needs args')