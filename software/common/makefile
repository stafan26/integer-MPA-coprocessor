CC = gcc
CFLAGS = -Wall

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

.PHONY: default all clean

all: default
default: $(OBJECTS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(OBJECTS)

clean:
	-rm -f *.o
	-rm -f $(TARGET)
