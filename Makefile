findfiles = $(foreach ext, c cpp m mm x xm xi xmi, $(wildcard $(1)/*.$(ext)))
getobjs = $(foreach ext, c cpp m mm x xm xi xmi, $(filter %.o,$(patsubst %.$(ext),%.o,$(1))))

LEXIS = lexis.pl
TESTS = $(call getobjs, $(call findfiles, tests))

all: $(TESTS)
	@echo ok

%.o: %.c
	@./$(LEXIS) $^

%.o: %.cpp
	@./$(LEXIS) $^

%.o: %.m
	@./$(LEXIS) $^

%.o: %.mm
	@./$(LEXIS) $^

%.o: %.x
	@./$(LEXIS) $^

%.o: %.xm
	@./$(LEXIS) $^

%.o: %.xi
	@./$(LEXIS) $^

%.o: %.xmi
	@./$(LEXIS) $^
