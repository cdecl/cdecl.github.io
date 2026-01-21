---
title: Makefile Simple Template
tags:
  - c++
  - makefile
---
Makefile 간단한 범용 버전 

## Makefile
- 현재 디렉토리 모든 .cpp 파일 빌드

```makefile
CC = g++
CC_FLAGS = -std=c++11 -pedantic -Wall -O2 
LD_LIBS = 

EXEC = main
SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)

# Main target
$(EXEC): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXEC) $(LD_LIBS)

%.o: %.cpp
	$(CC) -c $(CC_FLAGS) $< -o $@

clean:
	rm -f $(EXEC) $(OBJECTS)
```
	