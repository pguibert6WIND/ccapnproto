.PHONY: all clean test

LDFLAGS=-O2 -Wall -Wextra -fPIC
CFLAGS=-O2 -Wall -Wextra -fPIC -I. -Wno-unused-function
GTEST_CFLAGS=-I../gtest/include

all: libcapn.a libcapn.so capnpc-c 
#test

clean:
	rm -f *.o *.so capnpc-c compiler/*.o

%.o: %.c *.h *.inc compiler/*.h
	$(CC) $(CFLAGS) -c $< -o $@

libcapn.a: capn-malloc.o capn-stream.o capn.o
	ar cr $@ $^
	ranlib $@

libcapn.so: capn-malloc.o capn-stream.o capn.o
	$(CC) -shared $(LDFLAGS) $^ -o $@

capnpc-c: compiler/capnpc-c.o compiler/schema.capnp.o compiler/str.o libcapn.a
	$(CC) $(LDFLAGS) $^ -o $@

test: capn-test
	./capn-test

%-test.o: %-test.cpp *.h *.c *.inc
	$(CXX) -g -Wall -Wextra -I. $(GTEST_CFLAGS) -o $@ -c $<

capn-test: capn-test.o capn-stream-test.o compiler/test.capnp.o compiler/schema-test.o compiler/schema.capnp.o gtest-all-test.o
	$(CXX) -g -Wall -Wextra -I. -o $@ $^
