all: いちご

いちご: src/main.le
	cd src; ellec main.le -o ../いちご -r -t

build-%: examples/%.igo いちご
	./いちご $<

run-%: build-%
	examples/$*

.PHONY: docs
docs:
	./build.le

clean:
	rm -f いちご
	rm -f build
	rm -f examples/*.ssa
