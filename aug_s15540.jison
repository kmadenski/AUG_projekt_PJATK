/* lexical grammar */
%lex
%%
/* keywords */
SELECT { return 'SELECT'; }
FROM { return 'FROM'; }
WHERE { return 'WHERE'; }

JOIN { return 'JOIN'; }
INNER { return 'INNER'; }
LEFT { return 'LEFT'; }
RIGHT { return 'RIGHT'; }
ON { return 'ON'; }

DISTINCT { return 'DISTINCT'; }

ASC { return 'ASC'; }
DESC { return 'DESC'; }

ORDER { return 'ORDER'; }
GROUP { return 'GROUP'; }
BY { return 'BY'; }

IS { return 'IS'; }
LIKE { return 'LIKE'; }
NOT { return 'NOT'; }
NULL { return 'NULLX'; }

OR { return 'OR'; }
AND { return 'ANDOP'; }

/* booleans */
TRUE { return 'BOOL'; }
UNKNOWN { return 'BOOL'; }
FALSE {return 'BOOL'; }

";" {return 'SEMICOLON'; }


/* numbers */

\-?[0-9]+ { return 'INTNUM'; } 

/* strings */

\'(\\.|\'\'|[^'\n])*\' { return 'STRING'; }
\"(\\.|\"\"|[^"\n])*\" { return 'STRING'; }

/* operators */
[-+&~|^/%*(),.;!] { return yytext[0]; }

"&&" { return 'ANDOP'; }
"||" { return 'OR'; }

"=" { return 'COMPARISON'; }
"<=>" { return 'COMPARISON'; }
">=" { return 'COMPARISON'; }
">" { return 'COMPARISON'; }
"<=" { return 'COMPARISON'; }
"<" { return 'COMPARISON'; }
"!=" { return 'COMPARISON'; }
"<>" { return 'COMPARISON'; }

/* Aliases */
[A-Za-z][A-Za-z0-9_]* { return 'NAME'; }

/* everything else */
/* white space */
[ \t] {}
\n {}
. {}


/lex

/* operator associations and precedence */
%start select_stmt

/* language grammar */
%% 
select_stmt: SELECT select_opts select_expr_list
     FROM table_references
     opt_where opt_groupby opt_orderby SEMICOLON
   ;

opt_where: /* nil */ 
   | WHERE expr
   ;

opt_groupby: /* nil */ 
   | GROUP BY groupby_list
   ;

groupby_list: expr opt_asc_desc 
   | groupby_list ',' expr opt_asc_desc
   ;

opt_asc_desc: /* nil */ 
   | ASC                
   | DESC       
   ;

opt_orderby: /* nil */ 
   | ORDER BY groupby_list
   ;

select_opts:
   | select_opts DISTINCT
   ;

select_expr_list: select_expr
   | select_expr_list ',' select_expr
   | '*'
   ;

select_expr: expr opt_as_alias 
   ;

table_references: table_reference
   | table_references ',' table_reference
   ;

table_reference: table_factor
   | join_table
   ;

table_factor: NAME opt_as_alias
   | NAME '.' NAME opt_as_alias
   | table_subquery opt_as NAME
   | '(' table_references ')'
   ;

opt_as: AS 
   | /* nil */
   ;

opt_as_alias: AS NAME
   | NAME
   | /* nil */
   ;

join_table:
   | table_reference opt_inner JOIN table_factor opt_join_condition
   | table_reference JOIN table_factor opt_join_condition
   | table_reference left_or_right opt_outer JOIN table_factor join_condition
   ;
opt_inner: /* nil */
   | INNER
;
opt_outer: /* nil */
   | OUTER
   ;

left_or_right: LEFT
   | RIGHT
   ;

opt_left_or_right_outer: LEFT opt_outer
   | RIGHT opt_outer 
   | /* nil */ 
   ;

opt_join_condition: 
   join_condition 
   | /* nil */ ;

join_condition:
   ON expr
   ;

table_subquery: 
   '(' select_stmt ')'
   ;

/**** expressions ****/

expr: NAME         
   | NAME '.' NAME 
   | STRING        
   | INTNUM
   | BOOL          
   ;

expr: expr '+' expr
   | expr '-' expr 
   | expr '*' expr 
   | expr '/' expr 
   | expr '%' expr
   | expr ANDOP expr
   | expr OR expr
   | expr COMPARISON expr
   | expr COMPARISON '(' select_stmt ')'
   | expr '|' expr 
   | expr '&' expr
   | expr '^' expr
   | NOT expr
   | '!' expr 
   ;    

expr: expr IN '(' val_list ')'       
   | expr NOT IN '(' val_list ')'    
   | expr IN '(' select_stmt ')'    
   | expr NOT IN '(' select_stmt ')'
   ;
val_list: expr 
   | expr ',' val_list 
   ;
expr: expr LIKE expr
   | expr NOT LIKE expr
   ;
expr: expr IS NULLX     
   | expr IS NOT NULLX 
   | expr IS BOOL      
   | expr IS NOT BOOL 
   ;