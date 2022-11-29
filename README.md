# web-screenshot

It's a tool that uses [gowitness](https://github.com/sensepost/gowitness) to take screenshots to websites and has other features for organising results or reporting stuff. 

## Install

```
sudo wget https://raw.githubusercontent.com/nahuelrm/web-screenshot/main/web-screenshot.sh -O /bin/web-screenshot && sudo chmod +x /bin/web-screenshot
```

## Usage

```
Usage: web-screenshot [options] 

Options:
	-f <file>	perform web screeshots for domains in file

	-d <domain>	perform web screeshots for single domain

	-P <path>	path to directory to save screenshots

	-r		make report in markdown format

	-H		save reponse headers

	-t		save web technologies details

	-l		save gowitness log

	-s		silent output

	-c <number/s>	status codes to filter while taking screenshots
			For example you can save 500 status codes domains in a
			separated file like this: -c 500
			You can also filter by more than one status code like 
			this: -c 500,403 separating status codes with a comma ','
			without a space between them.
```
