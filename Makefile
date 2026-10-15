.PHONY: all verify test import inspect clean
all:
	python3 tools/build.py
verify:
	python3 tools/build.py --verify
test:
	python3 -m unittest discover -s tests -v
inspect: all
	python3 tools/inspect_assets.py
import:
	python3 tools/import_disks.py
clean:
	rm -rf build
