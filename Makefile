.PHONY: all verify test import clean
all:
	python3 tools/build.py
verify:
	python3 tools/build.py --verify
test:
	python3 -m unittest discover -s tests -v
import:
	python3 tools/import_disks.py
clean:
	rm -rf build
