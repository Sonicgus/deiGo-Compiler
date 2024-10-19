/* 
2021236921 António Martins
2020217743 Gustavo Lima
*/
%{
    #include <stdio.h>
    #include <ctype.h>
    #include <string.h>
    #include <stdbool.h>

    #define YY_USER_ACTION coluna += yyleng;
    #define ADDLINE linha++; coluna = 1; if(!emcomment) {if(houvealgo) {if (flag) printf("SEMICOLON\n");} houvealgo = false;}

    bool flag = false;
    bool houvealgo = false;
    bool emcomment = false;
    bool houvenlemcomment = false;


    int linha = 1, coluna = 1;
    int linha_aux, coluna_aux;

    void up(char *text, int leng){
        for(int i = 0; i < leng; i++){
            text[i] = toupper(text[i]);
        }
   }
%}

%x COMMENT
%x STRINGLIT

reserved                            break|default|interface|select|case|defer|go|map|struct|chan|goto|switch|const|fallthrough|range|type|continue|import|"--"|"++"
keyword                             func|int|if|else|package|for|var|float32|bool|string
letter                              [a-zA-Z_]
digit                               [0-9]+
expoente                            [eE][+-]?{digit}+
decimal 	                        (\.{0,1}{digit}+({expoente})?)|({digit}+\.{0,1}{digit}*({expoente})?)
nova_linha                          "\n"|"\r"|"\r\n"
blank_spaces                        \t|" "
single_line_comm                    "//"[^\n\r]*
strlit                              \"([^\\\n\r\"]|\\[fnrt\\\"])*\"
identifier                          {letter}({digit}|{letter})*

%%
{reserved}                          { if(flag) printf("RESERVED(%s)\n", yytext); houvealgo = false; }
return                              { if(flag) printf("RETURN\n"); houvealgo = true; }
{keyword} 		                    { if(flag) {up(yytext, yyleng); printf("%s\n", yytext); houvealgo = false; } }
{nova_linha}						{ ADDLINE; }
{blank_spaces}                      { ; }
{single_line_comm}                  { if(houvealgo) {if (flag) printf("SEMICOLON\n");} houvealgo = false; }
"/*"                                { BEGIN COMMENT; coluna_aux = coluna - yyleng; linha_aux = linha; emcomment = true;}
<COMMENT>{nova_linha}               { ADDLINE ;houvenlemcomment = true;}
<COMMENT>"*/"                       { BEGIN 0; if(houvenlemcomment && houvealgo) {if (flag) printf("SEMICOLON\n"); houvealgo = false;}  emcomment = false; houvenlemcomment =false;}
<COMMENT><<EOF>>                    { printf("Line %d, column %d: unterminated comment\n", linha_aux, coluna_aux); yyterminate(); }
<COMMENT>.                          { ; }
{strlit}                            { if(flag) printf("STRLIT(%s)\n", yytext); houvealgo = true; } 
\"                                  { BEGIN STRINGLIT; coluna_aux = coluna - yyleng; linha_aux = linha; houvealgo = false; }
<STRINGLIT><<EOF>>                  { printf("Line %d, column %d: unterminated string literal\n", linha_aux, coluna_aux); if (houvealgo) if (flag) printf("SEMICOLON\n"); yyterminate(); }
<STRINGLIT>{nova_linha}             { printf("Line %d, column %d: unterminated string literal\n", linha_aux, coluna_aux); ADDLINE; BEGIN 0; }
<STRINGLIT>\\{nova_linha}           { printf("Line %d, column %d: invalid escape sequence (\\)\nLine %d, column %d: unterminated string literal\n", linha, coluna - yyleng, linha_aux, coluna_aux); ADDLINE; BEGIN 0; }
<STRINGLIT>\\[fnrt\\\"]             { ; }
<STRINGLIT>\\[^fnrt\\\"]            { printf("Line %d, column %d: invalid escape sequence (%s)\n", linha, coluna - yyleng, yytext); }
<STRINGLIT>\"                       { BEGIN 0; }
<STRINGLIT>.                        { ; }
"fmt.Println"                       { if(flag) printf("PRINT\n"); houvealgo = false; }
"strconv.Atoi"                      { if(flag) printf("PARSEINT\n"); houvealgo = false; }
"os.Args"                           { if(flag) printf("CMDARGS\n"); houvealgo = false; }
"_"                                 { if(flag) printf("BLANKID\n"); houvealgo = false; }
{identifier}	                    { if(flag) printf("IDENTIFIER(%s)\n", yytext); houvealgo = true; }
0[0-7]+                             { if(flag) printf("NATURAL(%s)\n", yytext); houvealgo = true; }
0[0-9]+                             { printf("Line %d, column %d: invalid octal constant (%s)\n", linha, coluna - yyleng, yytext); houvealgo = false; }
0[xX][0-9a-fA-F]+                   { if(flag) printf("NATURAL(%s)\n", yytext); houvealgo = true; }
{digit}+                            { if(flag) printf("NATURAL(%s)\n", yytext); houvealgo = true; }
{decimal} 							{ if(flag) printf("DECIMAL(%s)\n", yytext); houvealgo = true; }
"&&"    					        { if(flag) printf("AND\n"); houvealgo = false; }
"=" 					            { if(flag) printf("ASSIGN\n"); houvealgo = false; }
"*" 					            { if(flag) printf("STAR\n"); houvealgo = false; }
"," 					            { if(flag) printf("COMMA\n"); houvealgo = false; }
"/" 					            { if(flag) printf("DIV\n"); houvealgo = false; }
"=="    						    { if(flag) printf("EQ\n"); houvealgo = false; }
">="	    					    { if(flag) printf("GE\n"); houvealgo = false; }
">"		    					    { if(flag) printf("GT\n"); houvealgo = false; }
"{"	    						    { if(flag) printf("LBRACE\n"); houvealgo = false; }
"<="	    				        { if(flag) printf("LE\n"); houvealgo = false; }
"("	    			                { if(flag) printf("LPAR\n"); houvealgo = false; }
"["		    		            	{ if(flag) printf("LSQ\n"); houvealgo = false; }
"<"		    						{ if(flag) printf("LT\n"); houvealgo = false; }
"-"	    						    { if(flag) printf("MINUS\n"); houvealgo = false; }
"%"		    				        { if(flag) printf("MOD\n"); houvealgo = false; }
"!="	    						{ if(flag) printf("NE\n"); houvealgo = false; }
"!"		    						{ if(flag) printf("NOT\n"); houvealgo = false; }
"||"	    				        { if(flag) printf("OR\n"); houvealgo = false; }
"+"	    						    { if(flag) printf("PLUS\n"); houvealgo = false; }
"}"	    					        { if(flag) printf("RBRACE\n"); houvealgo = true; }
")"	    					        { if(flag) printf("RPAR\n"); houvealgo = true; }
"]"		    						{ if(flag) printf("RSQ\n"); houvealgo = true; }
";" 						        { if(flag) printf("SEMICOLON\n"); houvealgo = false; }
<<EOF>>                             { if (houvealgo) if (flag) printf("SEMICOLON\n"); houvealgo = false; yyterminate(); }
.                                   { printf("Line %d, column %d: illegal character (%s)\n", linha, coluna - yyleng, yytext); }		

%%
extern int yylex();
int main(int argc, char** argv) {
    
    if (argc > 1 && strcmp(argv[1], "-l") == 0) flag = true;

    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}
