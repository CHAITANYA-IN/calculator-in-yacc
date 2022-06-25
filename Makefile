PROGRAM_NAME="calculator"
Y_NAME="y"
parser?=bison
debug?=false

all: compile

lexer:
	flex ${PROGRAM_NAME}.l
ifeq ($(parser), bison)
	cc -c lex.yy.c -o lex.o -D BISON=1
endif
ifeq ($(parser), yacc)
	cc -c lex.yy.c -o lex.o -D YACC=1
endif

parser-normal:
ifeq ($(parser), bison)
	bison -d ${PROGRAM_NAME}.y
	cc -c ${PROGRAM_NAME}.tab.c -o ${Y_NAME}.o
endif
ifeq ($(parser), yacc)
	yacc -d ${PROGRAM_NAME}.y
	cc -c ${Y_NAME}.tab.c -o ${Y_NAME}.o
endif

parser-debug:
ifeq ($(parser), bison)
		bison -d -t ${PROGRAM_NAME}.y
		cc -c ${PROGRAM_NAME}.tab.c -o ${Y_NAME}.o -D YYDEBUG=1
endif
ifeq ($(parser), yacc)
		yacc -d -t ${PROGRAM_NAME}.y
		cc -c ${Y_NAME}.tab.c -o ${Y_NAME}.o -D YYDEBUG=1
endif

ifeq ($(debug), true)
compile: parser-debug lexer
else
compile: parser-normal lexer
endif
	cc ${Y_NAME}.o lex.o -o ${PROGRAM_NAME} -ll -lm

clean:
	rm -rf lex.yy.* *.out ${PROGRAM_NAME} *.tab.* *.o