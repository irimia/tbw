import uuid
import requests
from client import ArkClient
from pathlib import Path


class Util:
    def __init__(self, n):
        self.home = str(Path.home())
        net = n.split('_')
        coin, network = net[0], net[1]
    
        self.core = self.home + '/.config/' + coin + '-core/' + network
        self.tbw = self . home + '/core2_tbw'

        if network == "devnet":
            self.dposlib = "d." + coin
        elif network == "testnet":
            self.dposlib = "t." + coin
        else:
            self.dposlib = coin
        
        
    def get_client(self, api_port, ip="localhost"):
        return ArkClient('http://{0}:{1}/api'.format(ip, api_port))


    def track_ga_event(self, event_category, event_action, event_label):
        tracking_id = "UA-91104727-2"
        session_id = str(uuid.uuid4())

        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36"
        }

        tracking_url = 'https://www.google-analytics.com/collect?v=1&t=event&tid=' + tracking_id + '&cid=' + session_id + '&ec=' + event_category + '&ea=' + event_action + '&el=' + event_label + '&aip=1'

        response = requests.post(tracking_url, headers=headers)