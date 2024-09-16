import requests
import argparse
from mytoken import myToken
from inspect import getmembers
import sys 

def list():
    req = requests.get('https://labs.hackthebox.com/api/v4/season/machines/', headers ={'Authorization': myToken, 'User-Agent': 'Chrome'})
    print(req.json())

def machine(machine):
    req = requests.get('https://labs.hackthebox.com/api/v4/machine/profile/' + machine, headers={'Authorization': myToken, 'User-Agent': 'not python requests'}).json()
    print(req)

def team():
    req = requests.get('https://www.hackthebox.com/api/v4/team/info/3929', headers ={'Authorization': myToken, 'User-Agent': 'not python requests'})
    print(req.json())

def active():
    req = requests.get('https://labs.hackthebox.com/api/v4/season/machine/active', headers ={'Authorization': myToken, 'User-Agent': 'not python requests'}).json()
    print(req)

def userActivity(id):
    req = requests.get('https://www.hackthebox.com/api/v4/profile/activity/' + id, headers ={'Authorization': myToken, 'User-Agent': 'not python requests'}).json()
    print(req)

def userBadge(id):
    req = requests.get('https://www.hackthebox.com/badge/image/'+ id, headers ={'Authorization': myToken, 'User-Agent': 'not python requests'})
    print(req.text)

def textReplace(text):
    newtext = text.replace("instagram", "instagramez")
    print(newtext)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--list", "-l",  help ="list seasonal machines", action = "store_true")
    parser.add_argument("--machine", "-m", help ="get machine info", type = str)
    parser.add_argument("--team", "-t", help = "lookup team", action = "store_true")
    parser.add_argument("--active", "-a", help = "list active machine", action = "store_true")
    parser.add_argument("--string", help = "replace instagram string", type = str)
    parser.add_argument("--useractivity", type = str)
    parser.add_argument("--userbadge", type = str)
    args = parser.parse_args()
    if args.list:
        list()
    elif args.machine:
        machine(args.machine)
    elif args.team:
        team()
    elif args.active:
        active()
    elif args.useractivity:
        userActivity(args.useractivity)
    elif args.userbadge:
        userBadge(args.userbadge)
    elif args.string:
        textReplace(args.string)
