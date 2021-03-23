#!/usr/bin/env python3

import json
import sys
with open(sys.argv[1]) as f:
  gen = json.load(f)
  f.close()


gen['app_state']['auth']['accounts'] = sorted(gen['app_state']['auth']['accounts'], key=lambda k: int(k['value'].get('account_number', 0))) 
gen['app_state']['bank']['balances'] = sorted(gen['app_state']['bank']['balances'], key=lambda k: k['address'])

print(json.dumps(gen))

