findfiles = $(foreach ext, c cpp m mm x xm xi xmi, $(wildcard $(1)/*.$(ext)))
getobjs = $(foreach ext, c cpp m mm x xm xi xmi, $(filter %.o,$(patsubst %.$(ext),%.o,$(1))))

LEXIS = lexis.pl
TESTS = $(call getobjs, $(call findfiles, tests))

all: $(TESTS)
	@echo ok

clean:
	@rm $(TESTS)

%.o: %.c
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.cpp
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.m
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.mm
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.x
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.xm
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.xi
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"

%.o: %.xmi
	@./$(LEXIS) $^ > $@ && echo -e "\e[33m$@\e[m: \e[32msuccess\e[m" || echo -e "\e[33m$@\e[m: \e[31mfailure\e[m"
