.PHONY: fetch-installers
fetch-installers:
	curl https://github.com/mitsuhiko/insta/releases/latest/download/cargo-insta-installer.sh > static/install.sh
	curl https://github.com/mitsuhiko/insta/releases/latest/download/cargo-insta-installer.ps1 > static/install.ps1
