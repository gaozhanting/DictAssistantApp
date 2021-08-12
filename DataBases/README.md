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

