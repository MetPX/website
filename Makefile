.SUFFIXES: .1.rst .5 .7 .dia .png .pdf .html

MAKE = make
GIT = git
# VERSION = $(shell grep __version__ ../sarracenia/sarra/__init__.py | sed -e 's/"//g' | cut -c14-)
# DATE = $(shell date "+%B %Y")

# SOURCES = $(wildcard ../sarracenia/doc/*.rst)
# TARGETS = $(patsubst ../sarracenia/doc/%.rst,htdocs/%.html,$(SOURCES))

# default: $(TARGETS)

# all: bootstrap anchorjs svg img index $(TARGETS)
all: dirs bootstrap anchorjs index sarra sundew

html: $(TARGETS)

dirs:
	mkdir -p htdocs/css
	mkdir -p htdocs/fonts
	mkdir -p htdocs/js

sarra:
	[ -d sarracenia ] || $(GIT) clone git://git.code.sf.net/p/metpx/sarracenia sarracenia
	@cd sarracenia && git pull
	@cd ..
	$(MAKE) TEMPLATE=--template=../../../template-en.txt -C sarracenia/doc/html
	cp sarracenia/doc/html/*.html htdocs
	-cp sarracenia/doc/html/*.svg htdocs
	-cp sarracenia/doc/*.gif htdocs
	-cp sarracenia/doc/html/*.jpg htdocs

sundew:
	[ -d sundew ] || $(GIT) clone git://git.code.sf.net/p/metpx/sundew sundew
	@cd sundew && git pull
	@cd ..
	$(MAKE) TEMPLATE=--template=../../../template-en.txt -C sundew/doc/user
	$(MAKE) TEMPLATE=--template=../../../template-en.txt -C sundew/doc/dev
	$(MAKE) -C sundew/doc/html
	cp sundew/doc/html/*.html htdocs
	cp sundew/doc/html/*.png htdocs
	cp sundew/doc/html/WMO-386.pdf htdocs

index:
	cp index-e.html htdocs
	cp index-f.html htdocs
	ln -s index-e.html htdocs/index.html

# Get twitter bootstrap 3.3.6
bootstrap:
	curl -O -J -L https://github.com/twbs/bootstrap/releases/download/v3.3.6/bootstrap-3.3.6-dist.zip
	unzip -q bootstrap-3.3.6-dist.zip
	cp -ap bootstrap-3.3.6-dist/js/* htdocs/js
	cp -ap bootstrap-3.3.6-dist/css/* htdocs/css
	cp -ap bootstrap-3.3.6-dist/fonts/* htdocs/fonts
	cp -p css/* htdocs/css
	rm -rf bootstrap-3.3.6-dist
	rm bootstrap-3.3.6-dist.zip

# Get anchor.js 2.0.0
anchorjs:
	curl -O -J -L https://github.com/bryanbraun/anchorjs/archive/3.2.1.tar.gz
	tar -zxvf *3.2.1.tar.gz anchorjs-3.2.1/anchor.js
	cp anchorjs-3.2.1/anchor.js htdocs/js
	rm -rf anchorjs-3.2.1
	rm *3.2.1.tar.gz

css:
	cp -p css/* ./htdocs/css

# NOTE: In order to deploy the site to sourceforge, run the following commands:
# 1. make all
# 2. make SFUSER=<username> deploy
deploy:
	rsync -avP htdocs/ -e ssh $(SFUSER),metpx@web.sourceforge.net:htdocs/

clean:
	rm -f $(TARGETS)
	rm -rf htdocs/fonts htdocs/js htdocs/css
	rm -f htodcs/*.svg
	rm -f htdocs/*.jpg
	rm -f htdocs/*.gif
	rm -f htdocs/*.html
	$(MAKE) -C sarracenia/doc/html clean
	$(MAKE) -C sundew/doc/html clean
	$(MAKE) -C sundew/doc/user clean
	$(MAKE) -C sundew/doc/dev clean

wipe: clean
	rm -rf htdocs
	-rm -rf sarracenia
	-rm -rf sundew
