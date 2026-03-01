.PHONY: clean build deploy all

clean:
	flutter clean

build:
	flutter build web --release

deploy:
	firebase deploy --project rrt-sos --only hosting

all: clean build deploy
