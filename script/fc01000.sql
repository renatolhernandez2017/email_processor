set heading off;
select
  COALESCE(CDFIL, 'N/A') || ',' ||
  COALESCE(BAIRR, 'N/A') || ',' ||
  COALESCE(CTATO, 'N/A')
FROM FC01000;
