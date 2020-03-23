PROJECT_NAME             := elixlists
MIX_TEST_OPTIONS         := --trace

COL_YEL                  := \033[1;33m
COL_RED                  := \033[0;33m
COL_RST                  := \033[0m
MSG_PORT_REMINDER        := "$(COL_YEL)-> port should be $(PORT).$(COL_RST)"

help:
	@echo "USAGE: \n\
$(COL_YEL)make b(uild):$(COL_RST)         builds a small binary using escript \n\
$(COL_YEL)make c(ompile):$(COL_RST)       recompiles the project (all warnings on) \n\
$(COL_YEL)make compile-all:$(COL_RST)     recompiles the project and all deps (all warnings on) \n\
$(COL_YEL)make cr(edo):$(COL_RST)         launches credo (strict mode) \n\
$(COL_YEL)make f(ormat):$(COL_RST)        checks style inconsistencies (dry-run) \n\
$(COL_YEL)make ff(orce-ormat):$(COL_RST)  formats everything (force) \n\
$(COL_YEL)make g(et):$(COL_RST)           gets dependencies \n\
$(COL_YEL)make i(ex):$(COL_RST)           launches an interactive elixir shell in a Phoenix context \n\
$(COL_YEL)make info:$(COL_RST)            prints Elixir/OTP version \n\
$(COL_YEL)make o(bserver):$(COL_RST)      starts the GenServer observer \n\
$(COL_YEL)make t(est):$(COL_RST)          launches all tests \n\
h: help

build:
	mix escript.build
b: build

compile:
	mix compile --all-warnings
c: compile

compile-all:
	mix deps.compile && mix compile --all-warnings
cc: compile-all

credo:
	mix credo --strict
cr: credo

format:
	mix format --check-formatted --dry-run
f: format

force-format:
	mix format
ff: force-format

get:
	mix deps.get
g: get

iex:
ifeq ($(DEV_APP),$(PROJECT_NAME))
	iex -S mix
else
	@echo $(ERR_ENV_FILE_NOT_SOURCED)
endif
i: iex

info:
	elixir -v

observer:
	iex -S mix run -e ":observer.start()"
o: observer

test:
	MIX_ENV=test mix test $(MIX_TEST_OPTIONS)
t: test

# these commands match rules and not files/directories (always "out-of-date")
.PHONY: help h compile c format credo f force-format ff get g iex i info observer o test t

.DEFAULT: help
