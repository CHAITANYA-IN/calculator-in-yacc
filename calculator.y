%{
    #include <stdio.h>
    #include <stdlib.h>
    #ifndef MATH
        #include <math.h>
        #define MATH 1
    #endif
    #ifndef STRING
        #include <string.h>
        #define STRING 1
    #endif

    // #define YYDEBUG 1
    #define STR_EQUATE(x, y) (strcmp(x, y) ? 0 : 1)

    void yyerror(char *s);
    int yylex();

    double symbols[52];
    double symbolVal(char symbol);
    double updateSymbolVal(char symbol, double val);

    double factorial(double a);
%}

%union {
    double num;
    char id;
    char math_constant[8];
}

%start input

%token PRINT TERMINATOR SIGN NEWLINE
%token EXCLAIMER SIN COS TAN ASIN ACOS ATAN LOG LN DASH PLUS ASSIGNMENT CARET MULTIPLY DIVIDE MODULO UNDERSCORE OPENBRACKET CLOSEBRACKET CEIL ROUND FLOOR ABS PIPE ADDRESS COLON LESSERTHAN GREATERTHAN LESSGREAT NOT OR AND SIMILE EQUALTO LESSERTHANEQUALTO GREATERTHANEQUALTO RAISETO BITSHIFTLEFT BITSHIFTRIGHT
%token <num> number
%token <id> identifier
%token <math_constant> constant

%type <num> exp term assignment
/* %type <id> assignment */

%right ASSIGNMENT
%left AND OR
%left PIPE ADDRESS LESSGREAT
%left LESSERTHAN GREATERTHAN LESSERTHANEQUALTO GREATERTHANEQUALTO
%left EQUALTO NOTEQUALTO
%left BITSHIFTLEFT BITSHIFTRIGHT
%left PLUS DASH
%left MULTIPLY DIVIDE MODULO
%right RAISETO 
%right EXCLAIMER
%right SIMILE
%right SIGN
%left OPENBRACKET CLOSEBRACKET
%left CEIL ROUND FLOOR ABS

%%
input:      /* empty */
            | input line
            ;
line        : NEWLINE                                   {printf("> ");}
            | assignment NEWLINE                        {printf("= %g\n> ", $1);}
            | PRINT exp NEWLINE                         {printf("= %g\n> ", $2);}
            | exp NEWLINE                               {printf("= %g\n> ", $1);}
            | TERMINATOR NEWLINE                        {exit(EXIT_SUCCESS);}
            ;
assignment  : identifier ASSIGNMENT exp                   {$$ = updateSymbolVal($1, $3);}
            ;
exp         : term                                      {$$=$1;}
            | OPENBRACKET exp CLOSEBRACKET              {$$=$2;}
            | UNDERSCORE exp UNDERSCORE %prec FLOOR     {$$=floor($2);}
            | CARET exp CARET %prec CEIL                {$$=ceil($2);}
            | COLON exp COLON %prec ROUND               {$$=round($2);}
            | PIPE exp PIPE %prec ABS                   {$$=fabs($2);}
            | exp ADDRESS exp                           {$$=(int)$1&(int)$3;}
            | exp PIPE exp                              {$$=(int)$1|(int)$3;}
            | exp LESSGREAT exp                         {$$=(int)$1^(int)$3;}
            | SIMILE exp                                {$$=~(int)$2;}
            | exp LESSERTHAN exp                        {$$=$1<$3;}
            | exp GREATERTHAN exp                       {$$=$1>$3;}
            | exp LESSERTHANEQUALTO exp                 {$$=$1<=$3;}
            | exp GREATERTHANEQUALTO exp                {$$=$1>=$3;}
            | exp EQUALTO exp                           {$$=$1==$3;}
            | exp NOTEQUALTO exp                        {$$=$1!=$3;}
            | exp RAISETO exp                           {$$=pow($1,$3);}
            | exp BITSHIFTLEFT exp                      {$$=(int)$1<<(int)$3;}
            | exp BITSHIFTRIGHT exp                     {$$=(int)$1>>(int)$3;}
            | exp MULTIPLY exp                          {$$=$1*$3;}
            | exp DIVIDE exp                            {
                                                            if($3) {
                                                                $$=$1/$3;
                                                            } else {
                                                                yyerror("Can't divide by zero");
                                                            }
                                                        }
            | exp MODULO exp                            {
                                                            if($3) {
                                                                $$=(int)$1%(int)$3;
                                                            } else {
                                                                yyerror("Can't divide by zero");
                                                            }
                                                        }
            | exp PLUS exp                              {$$=$1+$3;}
            | exp DASH exp                              {$$=$1-$3;}
            | PLUS exp %prec SIGN                       {$$=$2;}
            | DASH exp %prec SIGN                       {$$=-$2;}
            | SIN OPENBRACKET exp CLOSEBRACKET          {$$=sin($3);}
            | COS OPENBRACKET exp CLOSEBRACKET          {$$=cos($3);}
            | TAN OPENBRACKET exp CLOSEBRACKET          {$$=tan($3);}
            | ASIN OPENBRACKET exp CLOSEBRACKET         {$$=asin($3);}
            | ACOS OPENBRACKET exp CLOSEBRACKET         {$$=acos($3);}
            | ATAN OPENBRACKET exp CLOSEBRACKET         {$$=atan($3);}
            | LOG OPENBRACKET exp CLOSEBRACKET          {$$=log10($3);}
            | LN OPENBRACKET exp CLOSEBRACKET           {$$=log($3);}
            | NOT OPENBRACKET exp CLOSEBRACKET          {$$=!$3;}
            | exp OR exp                                {$$=$1||$3;}
            | exp AND exp                               {$$=$1&&$3;}
            | exp EXCLAIMER                             {
                                                            if(floor($1) == ceil($1)) {
                                                                $$=factorial($1);
                                                            } else {
                                                                yyerror("Factorial is defined over integers");
                                                            }
                                                        }
            ;
term        : number                                    {$$=$1;}
            | identifier                                {$$=symbolVal($1);}
            | constant                                  {
                                                            if(STR_EQUATE("PI", $1)) {
                                                                $$ = M_PI;
                                                            } else if(STR_EQUATE("E", $1)) {
                                                                $$ = M_E;
                                                            } else {
                                                                yyerror("Unknown math_constant");
                                                            }
                                                        }
            ;
%%

double factorial(double x) {
    if (x == 1.0 || x == 0.0)
        return 1;
    if(x < 0)
        yyerror("Factorial of Negative numbers is not defined");
    return (x * factorial(x-1));
}

int isLower(char c) {
    return c <= 90 && c >= 65;
}

int isUpper(char c) {
    return c <= 122 && c >= 65;
}

int computeSymbolIndex(char token) {
    int idx = -1;
    if(isLower(token)) {
        idx = token - 'a' + 26;
    } else if (isUpper(token)) {
        idx = token - 'A';
    }
    return idx;
}

double symbolVal(char symbol) {
    int bucket = computeSymbolIndex(symbol);
    return symbols[bucket];
}

double updateSymbolVal(char symbol, double val) {
    int bucket = computeSymbolIndex(symbol);
    symbols[bucket] = val;
    return symbols[bucket];
}

int main(void) {
    // Debug Flag
    #ifdef YYDEBUG
        yydebug = 1;
    #endif
    int i;
    for(i=0; i<52; i++) {
        symbols[i] = 0;
    }
    printf("> ");
    return yyparse();
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}
