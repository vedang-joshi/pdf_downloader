#!/Users/vedangjoshi/opt/anaconda3/bin/python3
from tkinter import *
from tkinter import filedialog
from tkinter import messagebox as mb
from tkinter import font as tkFont
import tkinter as tk
import urllib3
import re
import requests
from bs4 import BeautifulSoup
from mechanize import Browser
import sys
import webbrowser
import os

with open("/Users/vedangjoshi/Documents/Springer Ebooks.txt", encoding="utf8") as file:
    readContentFile = file.read().splitlines()

textString = " ".join(readContentFile)
listURL = re.findall(r'(http?://\S+)', textString)
# Insert empty string at the start of the list as indexing in lists cannot be changed from 0 to 1 easily. Hence
# ignore first string
listURL.insert(0, "")

url_pdf = "https://drive.google.com/open?id=1Zq25tnJi39I6vwFGoSvu-j98Cxk5T7mN"
url_github = "https://github.com/vedangjoshi2000/pdf_downloader"

class downloader:

    def __init__(self, parent):
        top = self.top = Toplevel(parent)
        top.resizable(0, 0)
        times11 = tkFont.Font(family='Times', size=11)
        root.title('PDF downloader for open-source textbooks by Springer')
        top.title('')

        Label(top, text="Input the serial number(s) of the books to be downloaded separated by spaces: ", font=times11).pack(padx=10, pady=5)


        self.e = Entry(top)
        self.e.pack(padx=5)

        Label(top, text="Save textbook(s) to path:", font=times11).pack(padx=10, pady=5)
        self.b = Entry(top)
        self.b.pack(padx=5)

        browseFiles = Button(top, text="Browse file paths", font=times11, command=self.browse_files)
        browseFiles.pack()
        browseFiles.place(relx=0.85, rely=0.6, anchor=CENTER)

        inputButton = Button(top, text="Download", font=times11, command=self.get_input)
        inputButton.pack(padx=50, pady=10)

        pdfButton = Button(root, text="Springer PDF file", font=times11, command=self.open_web)
        pdfButton.pack()
        pdfButton.place(relx=0.35, rely=0.95, anchor=CENTER)

        authorButton = Button(root, text="Author Credentials", font=times11, command=self.open_author_creds)
        authorButton.pack()
        authorButton.place(relx=0.55, rely=0.95, anchor=CENTER)

        githubButton = Button(root, text="GitHub Repository", font=times11, command=self.open_github)
        githubButton.pack()
        githubButton.place(relx=0.75, rely=0.95, anchor=CENTER)


    def get_input(self):
        try:
            self.error_handling_input_books()
            self.error_handling_file_path()
        except ValueError:
            mb.showerror(title="Value Error", message="Please enter numeric values only and try again.")
            sys.exit()
        except AttributeError:
            mb.showerror(title="Invalid directory specified", message="Please enter a valid download directory and try again.")
            sys.exit()
        self.main_funct()
        self.top.destroy()

    def open_web(self):
        webbrowser.open(url_pdf, new=1)

    def open_github(self):
        webbrowser.open(url_github, new=1)

    def open_author_creds(self):
        mb.showinfo(title='Author Credentials', message='''
        Author: Vedang Joshi
        Affiliation: University of Bristol
        Email: vedang0401 at gmail dot com
        Version: 2.0
        Version updated: 04 May 2020''')

    def error_handling_input_books(self):
        for element in range(0, len(self.e.get().split())):
            if int(self.e.get().split()[element]) > 408:
                mb.showerror(title="Index Error", message="The database only contains 408 books. Please enter a number between 1 and 408. "
                                                             "Please try again.")
                sys.exit()
            elif int(self.e.get().split()[element]) < 1:
                mb.showerror(title="Index Error",
                             message="There is no book that has a serial number of 0. Please enter a number between 1 and 408."
                      "Please try again.")
                sys.exit()

    def error_handling_file_path(self):
        try:
            self.main_funct()
        except FileNotFoundError:
            mb.showerror(title="File Path Not Found", message="Please enter a valid file path to download your books and try again.")
            sys.exit()

    def browse_files(self):
        currdir = os.getcwd()
        tempdir = filedialog.askdirectory(parent=root, initialdir=currdir, title='Please select a directory')
        if len(tempdir) > 0:
            self.getDir = tempdir
            new_text = self.getDir
            self.b.delete(0, tk.END)
            self.b.insert(0, new_text)

    def main_funct(self):
        inputList = self.e.get().split()
        if len(self.b.get()) != 0:
            pathGet = self.b.get()
        elif len(self.b.get()) == 0:
            pathGet = self.getDir
        for element in range(0, len(inputList)):
            inputList[element] = int(inputList[element])
        for index in inputList:
            getRequests = requests.get(listURL[index])
            mechanizeBrowser = Browser()
            mechanizeBrowser.set_handle_robots(False)
            mechanizeBrowser.open(listURL[index])
            bookTitle = mechanizeBrowser.title()
            replacedBookTitle = bookTitle.replace(' | SpringerLink', '')

            # Using BeautifulSoup
            useSoup = BeautifulSoup(getRequests.text, 'html.parser')
            redirectedLink = useSoup.find('link', rel='canonical')['href']

            def file_downloader(url):
                getHTTP = urllib3.PoolManager()
                getResponse = getHTTP.request('GET', url)
                os.chdir(pathGet)
                openNewFile = open(replacedBookTitle + ".pdf", 'wb')
                openNewFile.write(getResponse.data)
                openNewFile.close()



            file_downloader("https://link.springer.com/content/pdf/" + redirectedLink.split('/', 4)[-1] + ".pdf")



root = Tk()
root.resizable(0,0)
times11 = tkFont.Font(family='Times', size=11)
Label(root, text='''
        Textbook downloader for open source books provided by Springer

        Application Use:
            1. This application may be used to download textbooks from a PDF currently circulating
                    which has links to multiple books hosted by Springer.
            2. We aim to make it easier for the general public to avail of these facilities
                    without having to manually download all the books which takes time and effort.
            3. The directory has 408 books. We have included a PDF to ease the
                     search for the serial numbers for any particular book. Just click on the button below.
            4. Please input the serial numbers for any book you want, separated by spaces, and specify which 
                      folder you would like the books to be downloaded to.
            5. Please allow a minute or two for the books to begin downloading as it has to connect to
                   the Springer server first as well.
            6. If any error messages pop up, please close the program and try again.
            6. Example input style:
                    $ Input the serial number(s) of the books to be downloaded separated by spaces: 1 2 3

            ''', font=times11).pack()
root.update()
display = downloader(root)
root.wait_window(display.top)