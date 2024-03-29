from datetime import datetime
def get_date(val):
  timestamp = val / 1000  + 7200 # converting milliseconds to seconds
  date = datetime.utcfromtimestamp(timestamp)
  return date.strftime('%d/%m/%Y %H:%M:%S')

import requests
from bs4 import BeautifulSoup
license_plates = ['SB40DAP']

base_url = 'https://inspectorulpadurii.ro/api/aviz'

for plate in license_plates:
  response = requests.get(f'{base_url}/locations?nr={plate}').json()
  codes = response['codAviz']
  if not codes:
    print("Legal Notice not found")
  for code in codes:
    resp_2 = requests.get(f'{base_url}/{code}').json()
    # getting volume
    volume = resp_2['volum']['total']

    # getting valdity
    valid_from = get_date(resp_2['valabilitate']['emitere'])
    valid_to = get_date(resp_2['valabilitate']['finalizare'])
    print({'Code': code, 'Volume': volume, 'Validity': f'{valid_from} - {valid_to}'})