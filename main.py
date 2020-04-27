import urllib3
import re
import requests
from bs4 import BeautifulSoup
from mechanize import Browser
import sys


with open("textbooks.txt", encoding="utf8") as file:
    readContentFile = file.read().splitlines()

textString = " ".join(readContentFile)
listURL = re.findall(r'(http?://\S+)', textString)
# Insert empty string at the start of the list as indexing in lists cannot be changed from 0 to 1 easily. Hence
# ignore first string
listURL.insert(0, "")

def main_funct():
    for index in inputList:
        getRequests = requests.get(listURL[index])
        mechanizeBrowser = Browser()
        mechanizeBrowser.set_handle_robots(False)
        mechanizeBrowser.open(listURL[index])
        bookTitle = mechanizeBrowser.title()
        replacedBookTitle = bookTitle.replace(' | SpringerLink','')

        # Using BeautifulSoup
        useSoup = BeautifulSoup(getRequests.text, 'html.parser')
        redirectedLink = useSoup.find('link', rel='canonical')['href']

        def file_downloader(url):
            getHTTP = urllib3.PoolManager()
            getResponse = getHTTP.request('GET', url)
            openNewFile = open(replacedBookTitle+".pdf", 'wb')
            openNewFile.write(getResponse.data)
            openNewFile.close()
            print(replacedBookTitle+" has been downloaded")

        file_downloader("https://link.springer.com/content/pdf/" + redirectedLink.split('/', 4)[-1] +".pdf")

    input('Press ENTER to exit')


try:
    print('''
        Textbook downloader for open source books provided by Springer
        
        Author: Vedang Joshi
        Affiliation: University of Bristol
        Email: vedang0401 at gmail dot com
        Created: 27 Apr 2020
            
        Application Use:
                1. This application may be used to download textbooks from a PDF currently circulating 
                       which has links to multiple books hosted by Springer.
                2. We aim to make it easier for the general public to avail of these facilities
                       without having to manually download all the books which takes time and effort.
                3. The directory has 408 books. We have included the original PDF to ease the 
                        search for the serial numbers for any particular book.
                4. Please input the serial numbers for any book you want, separated by spaces, and 
                       these books will be downloaded to the folder from where the user ran this program.
                5. Please allow a minute or two for the books to begin downloading as it has to connect to 
                   the Springer server first as well.
                5. Please refer to the following GitHub web address for the source code.
                   [https://github.com/vedangjoshi2000/pdf_downloader]
                6. Example run:
                        $ Input the serial number(s) of the books to be downloaded separated by spaces: 1 2 3
                        Fundamentals of Power Electronics has been downloaded
                        Handbook of the Life Course has been downloaded
                        All of Statistics has been downloaded
                        Press ENTER to exit
            ''')
    inputBookNumbers = input("Input the serial number(s) of the books to be downloaded separated by spaces: ")
    inputList = inputBookNumbers.split()
    for element in range(0, len(inputList)):
        inputList[element] = int(inputList[element])
        if int(inputList[element])>408:
            print("The database only contains 408 books. Please enter a number between 1 and 408."
                  " Please run the program again.")
            sys.exit()
        elif int(inputList[element])<1:
            print("There is no book that has a serial number of 0. Please enter a number between 1 and 408."
                  " Please run the program again.")
            sys.exit()

except ValueError:
    print("Please enter numeric values only and run the program again.")
    sys.exit()

main_funct()

