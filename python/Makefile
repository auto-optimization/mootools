.PHONY : install build test doc clean

install: build
	python3 -m pip install -e .

build:
	python3 -m build

test:
	tox

doc:
	$(MAKE) -C doc clean
	tox -e docs
	$(MAKE) -C doc html

clean:
	$(RM) -r .pytest_cache/ .tox/ build/ src/*.egg-info/
	find . -name '*.so' | xargs $(RM)
	find . -name '__pycache__' | xargs $(RM) -r
	$(MAKE) -C doc clean

