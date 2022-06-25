%{
    #ifndef MATH
        #include <math.h>
        #define MATH 1
    #endif
    #ifndef STRING
        #include <string.h>
        #define STRING 1
    #endif

    #ifdef BISON
        #include "calculator.tab.h"
    #endif
    #ifdef YACC
        #include "y.tab.h"
    #endif

    void yyerror(char *s);
%}

%%

print               {return PRINT;}
exit|quit           {return TERMINATOR;}
sin                 {return SIN;}
cos                 {return COS;}
tan                 {return TAN;}
asin                {return ASIN;}
acos                {return ACOS;}
atan                {return ATAN;}
log                 {return LOG;}
ln                  {return LN;}
not                 {return NOT;}
-                   {return DASH;}
\+                  {return PLUS;}
=                   {return ASSIGNMENT;}
==                  {return EQUALTO;}
!=                  {return NOTEQUALTO;}
\<=                 {return LESSERTHANEQUALTO;}
\>=                 {return GREATERTHANEQUALTO;}
\^                  {return CARET;}
\*                  {return MULTIPLY;}
\/                  {return DIVIDE;}
%                   {return MODULO;}
\(                  {return OPENBRACKET;}
\)                  {return CLOSEBRACKET;}
\!                  {return EXCLAIMER;}
_                   {return UNDERSCORE;}
\|                  {return PIPE;}
&                   {return ADDRESS;}
~                   {return SIMILE;}
:                   {return COLON;}
\*\*                {return RAISETO;}
\<\<                {return BITSHIFTLEFT;}
\>\>                {return BITSHIFTRIGHT;}
\<\>                {return LESSGREAT;}
\<                  {return LESSERTHAN;}
\>                  {return GREATERTHAN;}
\|\|                {return OR;}
&&                  {return AND;}
[a-zA-Z]            {
                        yylval.id=yytext[0];
                        return identifier;
                    }
\{[A-Za-z]+\}       {
                        strcpy(yylval.math_constant, yytext+1);
                        yylval.math_constant[strlen(yylval.math_constant)-1] = '\0';
                        return constant;
                    }
[0-9]+\.?[0-9]*     {
                        yylval.num=atof(yytext);
                        return number;
                    }
[ \t]               {;}
[\n]                {return NEWLINE;}
.                   {
                        ECHO;
                        yyerror("unexpected character");
                    }

%%

int yywrap(void) {
    return 1;
}