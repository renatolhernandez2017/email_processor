set heading off;
select CDFIL || ',' || NRRQU || ',' || max(DTOPE) || ',' || sum(VRRCB-VRTXA) from FC17100 group by CDFIL, NRRQU;

