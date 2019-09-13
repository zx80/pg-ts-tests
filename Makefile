# Author: Fabien Coelho
# License: Public Domain

all: clean

fill_pq: fill_pq.c
	gcc -O2 -Wall -I$$(pg_config --includedir) -o $@ $< -L$$(pg_config --libdir) -lpq -lpthread

fill: fill.c
	gcc -O2 -Wall -o $@ $<

.PHONY: clean
clean:
	$(RM) fill_pq fill *~
