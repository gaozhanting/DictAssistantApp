# DataBases

A description of this package.

## How to add dict into build-in Dictionary App

todo: Make it installed automatically with My App! (Option to install and select in My App)

[ref: https://sspai.com/post/43155#!]

1. Download dictionary files from:

* http://download.huzheng.org/zh_CN/
* https://sites.google.com/site/gtonguedict/home/stardict-dictionaries

2. brew install glib

* step 3 need this

3. Download an App from:
* https://github.com/jjgod/mac-dictionary-kit/files/4176459/DictUnifier.zip

4. Open DictUnifier App, and drag the dictionary tar bz2 format files download from step 1 into DicuUnifier, waiting it to process. When done, reopen built-in Dictionary App, open Perferences, and the dict is located at last

5. My App is always using the first ordered dictionary to do translation, even when running, you can reselect the first dictionary in built-in Dictionary App Preferences.

## About Apple Dictionary Development Kit

[ref: https://apple.stackexchange.com/questions/80099/how-can-i-create-a-dictionary-for-mac-os-x/86065#86065]

Xcode no longer comes with Dictionary Development Kit, but you don't even need Xcode to use it.
1. Register a free developer account and download the auxiliary tools package from developer.apple.com/downloads. It is now called: Additional Tool for Xcode (look for the latest version)
2. Move the Dictionary Development Kit folder to /Applications/Utilities/Dictionary Development Kit/, and copy the project_templates folder to ~/Desktop/
3. Open ~/Desktop/project_templates/Makefile and change DICT_BUILD_TOOL_DIR from /DevTools/Utilities/Dictionary Development Kit to /Applications/Utilities/Dictionary Development Kit
4. cd ~/Desktop/project_templates/; make && make install

The dictionary should show up in Dictionary.app after you quit and reopen it. After that, try editing MyDictionary.xml or MyDictionary.css. The dictionary name is the same as CFBundleName in the Info.plist, and the bundle name is DICT_NAME in the Makefile.

## DictUnifer Replacement (Stardicts -> AppleDict)
https://github.com/ritou11/dictconv

usage for example: 
```sh
cd tempDicts
dictconv convert /Users/gaocong/Downloads/stardict-jmdict-en-ja-2.4.2.tar.bz2 .
```

## More Dict
* https://mdict.org/categories/english-chinese/
* https://github.com/skywind3000/ECDICT/wiki/%E7%AE%80%E6%98%8E%E8%8B%B1%E6%B1%89%E5%AD%97%E5%85%B8%E5%A2%9E%E5%BC%BA%E7%89%88

## About MDict convert to AppleDict
1. search a concise dict, and download it (including mdx, mdd, css, if available) from https://mdx.mdict.org/ or https://downloads.freemdict.com/100G_Super_Big_Collection/
2. open it using GoldenDict, by adding the file into the specified directory
3. play with the dict in GoldenDict.app, if it is suitable, then go to 4; otherwise, discard the dict file
4. convert the MDict into AppleDict source:
```sh
cd try_use_pyglossary # assume the pyglossary here
python3 ./pyglossary-4.0.11/main.py --ui=gtk # to open the pyglossary GUI
# select input file the MDict file, select the output folder name the same, without .mdx.
# when done, cd the folder (maybe need to manually add the dict name by editing the converted plist file CFBundleDisplayName property)
make && make install # this will build the apple dict and install it at ~/Library/Dictionaries
```
5. play with the dict in Apple Dictionary.app
6. try to play with the app
7. upload the dictionary
8. update the app code of dict list