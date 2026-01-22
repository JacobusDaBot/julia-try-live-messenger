import tkinter as tk
from tkinter import *

from tkinter import ttk
import time
master = tk.Tk()
def start_progress():
    progress.start()

    # Simulate a task that takes time to complete
    for i in range(101):
      # Simulate some work
        time.sleep(0.05)  
        progress['value'] = i
        T.insert(END, i.__str__())
        #master.mainloop()
        # Update the GUI
        master.update_idletasks()  
    progress.stop()
    
def requestFileStruct():
  
master.geometry("800x600")
master.configure(bg="#222222")
lblname=Label(master, text='First Name')
lblnsurname=Label(master, text='Last Name')
lblname.pack()
lblnsurname.pack()
progress = ttk.Progressbar(master, orient="horizontal", length=300, mode="determinate")
progress.pack(pady=20)
T = Text(master, height=25, width=30)
T.pack()
T.insert(END, 'GeeksforGeeks\nBEST WEBSITE\n')
# Button to start progress
start_button = tk.Button(master, text="Start Progress", command=start_progress)
start_button.pack(pady=10)

request_button = tk.Button(master, text="Send Request", command=requestFileStruct)
start_button.pack(pady=10)
master.mainloop()