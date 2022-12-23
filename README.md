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

	-o <path>	path to output directory to store all the results

	-s		silent output

	-c		filter every response status code while taking screenshots
```
