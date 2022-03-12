CFLAGS+=-O2 -g -Wall -Werror -Ifec
LDFLAGS=
LIBS=-lm
CC=gcc

all: uat2avr

%.o: %.c *.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

uat2avr: uat2avr.o uat_decode.o reader.o
	$(CC) -g -o $@ $^ $(LDFLAGS) $(LIBS)

clean:
	rm -f *~ *.o fec/*.o uat2avr
