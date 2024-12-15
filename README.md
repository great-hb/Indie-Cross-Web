# Friday Night Funkin': Indie Cross
<p align="left">
	<img width="128" height="128" src="icons/iconOG.png"> 
</p>

## About
FNF: Indie Cross is a massive community collaboration with the goal of bringing together an ultimate rhythm gaming experience

# Credits
### Team Credits in-game

### Friday Night Funkin'
 - [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programming
 - [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
 - [Kawai Sprite](https://twitter.com/kawaisprite) - Music

This game was made with love to Newgrounds and its community. Extra love to Tom Fulp.'

### Bendy and the Ink Machine
 - [Joey Drew Studios](https://twitter.com/joeydrewstu)

### Cuphead
 - [Studio MDHR](https://twitter.com/studiomdhr)

### Undertale
 - [Toby Fox](https://twitter.com/tobyfox)

### Untitled Goose Game
 - [House House](https://twitter.com/house_house_)

### BINK Video Player
 - [RAD Game Tools](http://www.radgametools.com/)

### Adobe Animate CC - Texture Atlas for OpenFL
 - [mathieuanthoine](https://github.com/mathieuanthoine)


# Installation
1. [Install Haxe](https://haxe.org/download)
2. Install `git`.
	- Windows: install from the [git-scm](https://git-scm.com/downloads) website.
	- Linux: install the `git` package: `sudo apt install git` (ubuntu), `sudo pacman -S git` (arch), etc... (you probably already have it)
3. Install and set up the necessary libraries:
	- `haxelib install lime`
	- `haxelib install openfl`
	- `haxelib install flixel`
	- `haxelib run lime setup`
	- `haxelib run lime setup flixel`
	- `haxelib install flixel-tools`
	- `haxelib run flixel-tools setup`
	- `haxelib install flixel-addons`
	- `haxelib install flixel-ui`
	- `haxelib install linc_luajit`
	- `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`
	- `haxelib git systools https://github.com/haya3218/systools`
	- `haxelib run lime rebuild systools windows`
	- `haxelib git tentools https://github.com/TentaRJ/tentools`

# Installation (if you want to compress assets)
1. [Install Python 3](https://www.python.org/downloads/)
2. Install Pillow: `pip3 install Pillow`
3. Install and add ffmpeg to your PATH (figure it out)

# Build (no compression)
1. Change `_gameSizeBytes` in `CustomPreloader.hx` so the loading bar is correct (idk how to fix)
2. Build with lime: `lime build html5 -clean -final -Dnocompression`

# Build (with compression)
1. Compress the assets: `python compress-assets.py`
	- Feel free to change `OGG_QUALITY` and `VIDEO_CRF` in compress-assets.py to your liking
2. Change `_gameSizeBytes` in `CustomPreloader.hx` so the loading bar is correct (idk how to fix)
3. Build with lime: `lime build html5 -clean -final`