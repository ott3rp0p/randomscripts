import requests
import re
import argparse
from pprint import pprint

def movieSearch(args, type ):
    search = args.replace(' ', '%20')
    data = requests.get(f'https://api.watchmode.com/v1/search/?apiKey={key}&search_field=name&search_value={search}&types={type}').json()
    try:
        print(data['title_results'][0].keys())
        print(data['title_results'][0]['year'])
        print(data['title_results'][0]['id'])
        name = data['title_results'][0]['name'] + (f' ({data["title_results"][0]["year"]})')
        #re.search('^(.*?)\s*\(', name).group(1)
        print(name)
    except:
        print(data)

def streamSearch(args):
    streamData = {}
    data = requests.get(f'https://api.watchmode.com/v1/title/{args}/sources/?apiKey={key}').json()
    count = range(len(data))
    allowed_services = ['Amazon', 'Netflix', 'Hulu', 'HBO MAX', 'AppleTV+', 'Prime Video', 'MAX', 'Peacock', 'Peacock Premium', 'Disney+']
    try:
        for i in range(len(data)):
            print(data[i]['name'])
            print(data[i]['region'])
            if data[i]['region'] == 'US':
                print(data[i]['name'])
                if data[i]['type'] in ['sub', 'free']:
                    if data[i]['name'] in allowed_services:
                        streamData[f'service_{i}'] = data[i]['name']
                        streamData[f'service_url_{i}'] = data[i]['web_url']
    except Exception as e:
        print(e)
        return 
    pprint(streamData)

def searchFull(args):
    streamData = {}
    search = args.replace(' ', '%20')
    data = requests.get(f'https://api.watchmode.com/v1/search/?apiKey={key}&search_field=name&search_value={search}').json()
    count = range(len(data))
    allowed_services = ['Amazon', 'Netflix', 'Hulu', 'HBO MAX', 'AppleTV', 'Prime Video', 'MAX', 'Peacock', 'Peacock Premium', 'Disney+']
    try:
        j = 0
        for i in count:
            if data[i]['region'] == 'US':
                if data[i]['type'] in ['sub', 'free']:
                    if data[i]['name'] in allowed_services:
                        streamData[f'service{j}'] = data[i]['name']
                        streamData[f'service_url{j}'] = data[i]['web_url']
                        j += 1
    except:
        pass
    data = requests.get(f'https://api.watchmode.com/v1/title/{id}/sources/?apiKey={key}').json()
    for i in range(len(data)):
        if data[i]['region'] == 'US':
            if data[i]['type'] == 'sub' or 'free':
                if data[i]['name'] == 'Amazon' or 'Netflix' or 'Hulu' or 'HBO MAX' or 'AppleTV' or 'Prime Video' or 'MAX' or 'Peacock' or ' Peacock Premium' or 'Disney+':
                    print(data[i]['name'])
                    print(data[i]['web_url'])
                    
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--movie', type=str)
    parser.add_argument('--tv', type=str)
    parser.add_argument('--stream', type=str)
    parser.add_argument('--full', type=str)
    args=parser.parse_args()
    if args.movie:
        movieSearch(args.movie, type="movie")
    elif args.tv:
        movieSearch(args.tv, type="tv")
    elif args.stream:
        streamSearch(args.stream)
    elif args.full:
        searchFull(args.full)
    else:
        print('no arguments provided')
