TARGET = powernn_data
LIBS = -lgmp -lcrypto
CC = gcc
CFLAGS = -Wall

COMMONDIR     = ../../common
HEADERSCOMMON = $(wildcard $(COMMONDIR)/*.h)
OBJECTSCOMMON = $(patsubst %.c, %.o, $(wildcard $(COMMONDIR)/*.c))

.PHONY: default all clean

default: $(TARGET)
all: default

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -I$(COMMONDIR) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

$(TARGET): $(OBJECTS)
	+$(MAKE) -C $(COMMONDIR)
	$(CC) $(OBJECTS) $(OBJECTSCOMMON) -Wall $(LIBS) -o $@

clean:
	-rm -f *.o
	-rm -f $(TARGET)
	+$(MAKE) -C $(COMMONDIR) clean
