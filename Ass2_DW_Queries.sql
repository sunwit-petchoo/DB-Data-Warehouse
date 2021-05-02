SELECT dd.dayname AS weekday,SUM(S.qty*S.saleprice) AS totalsales  FROM dwsale S INNER JOIN dwdate dd ON S.sale_dwdateid = dd.datekey GROUP BY dayname ORDER BY totalsales DESC;
SELECT C.custcatname,SUM(S.qty*S.saleprice) AS totalsales FROM dwsale S INNER JOIN dwcust C ON S.dwcustid = C.dwcustid GROUP BY C.custcatname ORDER BY totalsales ASC;
SELECT P.prodmanuname,SUM(S.qty) AS totalqtysold FROM dwsale S NATURAL JOIN dwprod P GROUP BY P.prodmanuname ORDER BY totalqtysold DESC;
SELECT C.dwcustid,C.firstname,C.surname,SUM(S.qty*S.saleprice) AS totalsales FROM dwsale S INNER JOIN dwcust C ON S.dwcustid = C.dwcustid GROUP BY C.dwcustid,C.firstname,C.surname ORDER BY totalsales DESC FETCH NEXT 10 ROWS WITH TIES;
SELECT dwprodid,prodname,SUM(S.qty) AS totalsales FROM dwsale S NATURAL JOIN dwprod P GROUP BY dwprodid,prodname ORDER BY totalsales ASC FETCH NEXT 10 ROWS WITH TIES;
SELECT STATE,city,totalsales
FROM (
  SELECT C.STATE,C.city,SUM(S.qty*S.saleprice) AS citytotalsales,
  MAX(SUM(S.qty*S.saleprice)) OVER (PARTITION BY C.STATE) AS totalsales
  FROM dwsale S
  INNER JOIN dwcust C ON S.dwcustid = C.dwcustid  
  GROUP BY  C.STATE,C.city
)
WHERE citytotalsales = totalsales ORDER BY STATE ASC;