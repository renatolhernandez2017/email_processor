set heading off;
select
  COALESCE(CDFUN, 'N/A') || ',' ||
  COALESCE(NOMEFUN, 'N/A') || ',' ||
  COALESCE(BAIRR, 'N/A') || ',' ||
  COALESCE(USERID, 'N/A')
from FC08000 where FC08000.CDCON = '9999';
