.PHONY: all verify test import inspect extract extract-audio clean
all:
	python3 tools/build.py
verify:
	python3 tools/build.py --verify
test:
	python3 -m unittest discover -s tests -v
inspect: all
	python3 tools/inspect_assets.py
extract: all
	python3 tools/export_game.py
extract-audio: all
	python3 tools/export_game.py --wav-seconds 20
import:
	python3 tools/import_disks.py
clean:
	rm -rf build
