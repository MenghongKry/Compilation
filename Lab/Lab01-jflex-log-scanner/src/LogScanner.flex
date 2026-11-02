/* ==================================================================
 *  LogScanner.flex  -  JFlex spec for a small log format scanner
 *
 *  Declared log format (one entry per line):
 *
 *     [timestamp] [LEVEL] field=value field=value ...
 *
 *     timestamp : YYYY-MM-DD hh:mm:ss        e.g. 2026-11-02 08:15:00
 *     LEVEL     : DEBUG | INFO | WARN | ERROR
 *     value     : integer (200) or quoted message ("Ready")
 *
 *  The scanner only lists tokens; it does not check that the parts
 *  come in the right order, and it does not check that a date is a
 *  real calendar date (only its shape).
 *
 *  Generate:  jflex -d src src/LogScanner.flex   (-> src/Lexer.java)
 * ================================================================== */

/* ---------- 1. User code ---------- */
%%

/* ---------- 2. Options and macros ---------- */
%class Lexer
%public
%unicode
%line            /* yyline   : line number,   counted from 0 */
%column          /* yycolumn : column number, counted from 0 */
%type Token      /* yylex() returns a Token                  */

%{
    /* Build a token; line and column are reported starting from 1. */
    private Token token(TokenType type) {
        return new Token(type, yytext(), yyline + 1, yycolumn + 1, null);
    }

    /* Errors are returned as ERROR tokens so scanning can continue. */
    private Token error(String message) {
        return new Token(TokenType.ERROR, yytext(), yyline + 1, yycolumn + 1, message);
    }
%}

%eofval{
    return new Token(TokenType.EOF, "", yyline + 1, yycolumn + 1, null);
%eofval}

DIGIT      = [0-9]
DATE       = {DIGIT}{4} "-" {DIGIT}{2} "-" {DIGIT}{2}
TIME       = {DIGIT}{2} ":" {DIGIT}{2} ":" {DIGIT}{2}
TIMESTAMP  = {DATE} " " {TIME}
INTEGER    = {DIGIT}+
FIELD      = [a-zA-Z_] [a-zA-Z_0-9]*
MESSAGE    = \" [^\"\r\n]* \"
UNFINISHED = \" [^\"\r\n]*
WHITESPACE = [ \t\f\r\n]+

%%
/* ---------- 3. Lexical rules ----------
 * JFlex always takes the LONGEST match. If two rules match the
 * same length, the rule written FIRST wins.                        */

/* Competing rules #1 (longest match): "2026-11-02 08:15:00" is one
   TIMESTAMP, not INTEGER "2026" followed by other symbols.          */
{TIMESTAMP}    { return token(TokenType.TIMESTAMP); }
{DATE}         { return error("incomplete timestamp '" + yytext() + "' (expected ' hh:mm:ss' after the date)"); }
{INTEGER}      { return token(TokenType.INTEGER); }

/* Competing rules #2 (rule order + longest match):
   "INFO" matches both the level rule and {FIELD} with the same
   length, so the level rule must come FIRST. "INFORMATION" is a
   longer match for {FIELD}, so it becomes a FIELD, not a LEVEL.    */
"DEBUG" | "INFO" | "WARN" | "ERROR"   { return token(TokenType.LEVEL); }
{FIELD}        { return token(TokenType.FIELD); }

/* Competing rules #3 (longest match): a closed message is one
   character longer than the unfinished-message rule, so it wins
   whenever the closing quote is on the same line.                 */
{MESSAGE}      { return token(TokenType.MESSAGE); }
{UNFINISHED}   { return error("unfinished message " + yytext() + " (missing closing \")"); }

"="            { return token(TokenType.ASSIGN); }
"["            { return token(TokenType.LBRACKET); }
"]"            { return token(TokenType.RBRACKET); }

{WHITESPACE}   { /* skip spaces, tabs and newlines */ }

/* Any other character (e.g. @ # $) is an error. */
[^]            { return error("unexpected character '" + yytext() + "'"); }
