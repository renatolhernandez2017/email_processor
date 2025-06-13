set heading off;
select
  COALESCE(CDFUN, 'N/A') || ',' ||
  REPLACE(REPLACE(REPLACE(COALESCE(NOMEFUN, 'N/A'), ASCII_CHAR(10), ' '), ASCII_CHAR(13), ' '), ASCII_CHAR(9), ' ') || ',' ||
  COALESCE(BAIRR, 'N/A') || ',' ||
  COALESCE(USERID, 'N/A')
from FC08000 where FC08000.CDCON = '9999';
