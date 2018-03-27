findfiles = $(foreach ext, x xm xi xmi, $(wildcard $(1)/*.$(ext)))
getobjs = $(foreach ext, x xm xi xmi, $(filter %.o,$(patsubst %.$(ext),%.o,$(1))))

LEXIS = lexis.pl
TESTS = $(call getobjs, $(call findfiles, tests))

all: $(TESTS)
	@echo ok

clean:
	@rm -f $(TESTS)

# .SECONDEXPANSION:
# %.o: $(call findfiles, tests)
# 	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.c
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.cpp
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.m
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.mm
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.x
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.xm
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.xi
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"

%.o: %.xmi
	@./$(LEXIS) $^ > $@ && echo "\033[33m$@\033[m: \033[32msuccess\033[m" || echo "\033[33m$@\033[m: \033[31mfailure\033[m"
