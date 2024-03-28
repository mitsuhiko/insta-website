.PHONY: fetch-installers
fetch-installers:
	curl -LsSf https://github.com/mitsuhiko/insta/releases/latest/download/cargo-insta-installer.sh > static/install.sh
	curl -LsSf https://github.com/mitsuhiko/insta/releases/latest/download/cargo-insta-installer.ps1 > static/install.ps1
