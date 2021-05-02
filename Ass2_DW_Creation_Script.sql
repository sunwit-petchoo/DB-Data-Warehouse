Drop TABLE A2ERROREVENT;
Drop TABLE DWPROD;
Drop TABLE DWCUST;
Drop TABLE DWSALE;
Drop TABLE GENDERSPELLING;
DROP SEQUENCE A2ERROREVENT_SEQ; 
DROP SEQUENCE DWPROD_SEQ;
DROP SEQUENCE DWCUST_SEQ;
DROP SEQUENCE DWSALE_SEQ;
CREATE TABLE A2ERROREVENT(
ERRORID 		integer,
source_rowid     ROWID,
source_table   	VARCHAR2(30),
ERRORCODE       integer,
filterid   		integer,
datetime  	DATE,
action		VARCHAR2(6),
CONSTRAINT				ERROREVENTACTION
CHECK	(ACTION	IN	('SKIP','MODIFY'))
);
/
CREATE SEQUENCE A2ERROREVENT_SEQ; 
/
CREATE TABLE DWPROD(
DWPRODID 		integer,
DWSOURCETABLE   VARCHAR2(30),
DWSOURCEID      NUMBER(38,0),
PRODNAME        VARCHAR2(100),
PRODCATNAME     VARCHAR2(30),
PRODMANUNAME    VARCHAR2(30),
PRODSHIPNAME    VARCHAR2(30)
--CONSTRAINT pk_DWPROD PRIMARY KEY (DWPRODID)
);
/
CREATE SEQUENCE DWPROD_SEQ;
/
CREATE TABLE DWCUST(
DWCUSTID 		integer,
DWSOURCEIDBRIS  NUMBER(38,0),
DWSOURCEIDMELB  NUMBER(38,0),
FIRSTNAME       VARCHAR2(30),
SURNAME         VARCHAR2(30),
GENDER          VARCHAR2(10),
PHONE           VARCHAR2(20),
POSTCODE        NUMBER(4,0),
CITY            VARCHAR2(50),
STATE           VARCHAR2(10),
CUSTCATNAME     VARCHAR2(30)
--CONSTRAINT pk_DWCUST PRIMARY KEY (DWCUSTID)
);
/
CREATE SEQUENCE DWCUST_SEQ;
/
CREATE TABLE DWSALE(
DWSALEID 		integer,
DWCUSTID        integer,
DWPRODID        integer,
DWSOURCEIDBRIS  NUMBER(38,0),
DWSOURCEIDMELB  NUMBER(38,0),
QTY             NUMBER(2,0),
SALE_DWDATEID   NUMBER(38,0),
SHIP_DWDATEID   NUMBER(38,0),
SALEPRICE       NUMBER(7,2)
--CONSTRAINT pk_DWSALE PRIMARY KEY (DWSALEID)
);
/
CREATE SEQUENCE DWSALE_SEQ;
/
CREATE TABLE GENDERSPELLING(
InvalidValue 		VARCHAR2(10),
NewValue        VARCHAR2(5)
);
insert into GENDERSPELLING VALUES ('MAIL','M');
insert into GENDERSPELLING VALUES ('WOMAN','F');
insert into GENDERSPELLING VALUES ('FEM','F');
insert into GENDERSPELLING VALUES ('FEMALE','F');
insert into GENDERSPELLING VALUES ('MALE','M');
insert into GENDERSPELLING VALUES ('GENTLEMAN','M');
insert into GENDERSPELLING VALUES ('MM','M');
insert into GENDERSPELLING VALUES ('FF','F');
insert into GENDERSPELLING VALUES ('FEMAIL','F');
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2PRODUCT',105,1,sysdate,'SKIP'
	FROM              A2PRODUCT p
	WHERE           p.prodname IS NULL;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2PRODUCT',131,2,sysdate,'MODIFY'
	FROM              A2PRODUCT p
	WHERE           p.MANUFACTURERCODE IS NULL;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2PRODUCT',146,3,sysdate,'MODIFY'
	FROM              A2PRODUCT p
	WHERE           p.prodcategory IS NULL 
    OR
    p.prodcategory NOT IN
        (
              SELECT  productcategory
              FROM    a2prodcategory 
        );
INSERT INTO DWPROD (DWPRODID,DWSOURCETABLE,DWSOURCEID,PRODNAME,PRODCATNAME,PRODMANUNAME,PRODSHIPNAME)
	SELECT           DWPROD_SEQ.nextval,'A2PRODUCT',p.PRODID,p.PRODNAME,g.categoryname,m.manuname,s.description
	FROM              A2PRODUCT p
    inner join A2MANUFACTURER m on p.MANUFACTURERCODE = m.manucode
    inner join A2SHIPPING s on p.shippingcode = s.shippingcode
    inner join a2PRODCATEGORY g on p.prodcategory = g.productcategory
	WHERE          
    p.ROWID NOT IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        );
INSERT INTO DWPROD (DWPRODID,DWSOURCETABLE,DWSOURCEID,PRODNAME,PRODCATNAME,PRODMANUNAME,PRODSHIPNAME)
	SELECT           DWPROD_SEQ.nextval,'A2PRODUCT',p.PRODID,p.PRODNAME,g.categoryname,'UNKNOWN',s.description
	FROM              A2PRODUCT p
    inner join A2SHIPPING s on p.shippingcode = s.shippingcode
    inner join a2PRODCATEGORY g on p.prodcategory = g.productcategory
	WHERE          
    p.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 2 and action = 'MODIFY'
        );
INSERT INTO DWPROD (DWPRODID,DWSOURCETABLE,DWSOURCEID,PRODNAME,PRODCATNAME,PRODMANUNAME,PRODSHIPNAME)
	SELECT           DWPROD_SEQ.nextval,'A2PRODUCT',p.PRODID,p.PRODNAME,'UNKNOWN',m.manuname,s.description
	FROM              A2PRODUCT p
    inner join A2MANUFACTURER m on p.MANUFACTURERCODE = m.manucode
    inner join A2SHIPPING s on p.shippingcode = s.shippingcode
    
	WHERE          
    p.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 3 and action = 'MODIFY'
        );
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2CUSTBRIS',167,4,sysdate,'MODIFY'
	FROM              A2CUSTBRIS c
	WHERE            
    c.CustCatCode NOT IN
        (
              SELECT  CustCatCode
              FROM    A2CUSTCATEGORY 
        )
    OR c.CustCatCode is null;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2CUSTBRIS',194,5,sysdate,'MODIFY'
	FROM              A2CUSTBRIS c
	WHERE            
    c.phone like '%-%' or 
    c.phone like '% %';
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2CUSTBRIS',219,6,sysdate,'SKIP'
	FROM              A2CUSTBRIS c
	WHERE        
    LENGTH(c.phone) != 10 and c.phone not in (select phone from A2CUSTBRIS where phone like '% %' or phone like '%-%' );
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2CUSTBRIS',227,7,sysdate,'MODIFY'
	FROM              A2CUSTBRIS c
	WHERE  c.gender not in ('M','m','F','f')
    OR c.gender is null
    ;
INSERT INTO DWCUST (DWCUSTID,DWSOURCEIDBRIS,DWSOURCEIDMELB,FIRSTNAME,SURNAME,GENDER,PHONE,POSTCODE,CITY,STATE,CUSTCATNAME)	
	SELECT           DWCUST_SEQ.nextval,b.custid,null,b.fname,b.sname,upper(b.gender),b.phone,b.postcode,b.city,b.state,c.custcatname
	FROM              A2CUSTBRIS b
    inner join A2CUSTCATEGORY c on b.custcatcode = c.custcatcode
	WHERE          
    b.ROWID NOT IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        );
INSERT INTO DWCUST (DWCUSTID,DWSOURCEIDBRIS,DWSOURCEIDMELB,FIRSTNAME,SURNAME,GENDER,PHONE,POSTCODE,CITY,STATE,CUSTCATNAME)	
	SELECT           DWCUST_SEQ.nextval,b.custid,null,b.fname,b.sname,upper(b.gender),b.phone,b.postcode,b.city,b.state,'UNKNOWN'
	FROM              A2CUSTBRIS b
	WHERE          
    b.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 4 and action = 'MODIFY'
        );
INSERT INTO DWCUST (DWCUSTID,DWSOURCEIDBRIS,DWSOURCEIDMELB,FIRSTNAME,SURNAME,GENDER,PHONE,POSTCODE,CITY,STATE,CUSTCATNAME)	
	SELECT           DWCUST_SEQ.nextval,b.custid,null,b.fname,b.sname,upper(b.gender),REPLACE(REPLACE(b.phone, '-', ''),' ',''),b.postcode,b.city,b.state,c.custcatname
	FROM              A2CUSTBRIS b
    inner join A2CUSTCATEGORY c on b.custcatcode = c.custcatcode
	WHERE          
    b.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 5 and action = 'MODIFY'
        );
INSERT INTO DWCUST (DWCUSTID,DWSOURCEIDBRIS,DWSOURCEIDMELB,FIRSTNAME,SURNAME,GENDER,PHONE,POSTCODE,CITY,STATE,CUSTCATNAME)	
	SELECT            DWCUST_SEQ.nextval,b.custid,null,b.fname,b.sname,
    
    CASE WHEN upper(b.gender) IN(SELECT invalidvalue FROM GENDERSPELLING) 
    Then ( 
                SELECT GS.newvalue
                FROM GENDERSPELLING GS
                WHERE upper(b.gender) = gs.invalidvalue
         ) 
    else 'U' 
    end ,
    b.phone,b.postcode,b.city,b.state,c.custcatname
	FROM              A2CUSTBRIS b
    inner join A2CUSTCATEGORY c on b.custcatcode = c.custcatcode
	WHERE          
    b.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 7 and action = 'MODIFY'
        );
MERGE INTO DWCUST c 
USING 	(select m.custid,m.fname,m.sname,m.gender,m.phone,m.postcode,m.city,m.state,cat.custcatname from A2CUSTMELB m inner join A2CUSTCATEGORY cat on m.custcatcode = cat.custcatcode ) tmpTable
ON (c.FIRSTNAME = tmpTable.fname AND c.SURNAME = tmpTable.sname AND c.POSTCODE = tmpTable.postcode)
WHEN MATCHED THEN UPDATE SET c.DWSOURCEIDMELB = tmpTable.custid
WHEN NOT MATCHED THEN 
INSERT (c.DWCUSTID,c.DWSOURCEIDBRIS,c.DWSOURCEIDMELB,c.FIRSTNAME,c.SURNAME,c.GENDER,c.PHONE,c.POSTCODE,c.CITY,c.STATE,c.CUSTCATNAME)
VALUES 
(
    DWCUST_SEQ.nextval,null,tmpTable.custid,tmpTable.fname,tmpTable.sname,upper(tmpTable.gender),tmpTable.phone,tmpTable.postcode,tmpTable.city,tmpTable.state,tmpTable.custcatname
);
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEBRIS',258,8,sysdate,'SKIP'
	FROM              A2SALEBRIS s
	WHERE           s.prodid not in (select DWSOURCEID from dwprod) or s.prodid is null;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEBRIS',262,9,sysdate,'SKIP'
	FROM              A2SALEBRIS s
	WHERE           s.custid not in (select DWSOURCEIDBRIS from dwcust where DWSOURCEIDBRIS is not null) or s.custid is null;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEBRIS',294,10,sysdate,'MODIFY'
	FROM              A2SALEBRIS s
	WHERE           s.shipdate < s.saledate;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEBRIS',312,11,sysdate,'MODIFY'
	FROM              A2SALEBRIS s
	WHERE           s.unitprice is null;
INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)	
	SELECT           DWSALE_SEQ.nextval,dc.dwcustid,dp.dwprodid,br.saleid,null,br.qty,dd.datekey,dd2.datekey,br.unitprice
	FROM            A2SALEBRIS br
    inner join dwcust dc on br.custid = dc.DWSOURCEIDBRIS
    inner join dwprod dp on br.prodid = dp.DWSOURCEID
    inner join dwdate dd on br.saledate = dd.datevalue
    inner join dwdate dd2 on br.shipdate = dd2.datevalue 
    where br.ROWID NOT IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        );
INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)
	SELECT           DWSALE_SEQ.nextval,dc.dwcustid,dp.dwprodid,br.saleid,null,br.qty,dd.datekey,dd.datekey+2,br.unitprice
	FROM            A2SALEBRIS br
    inner join dwcust dc on br.custid = dc.DWSOURCEIDBRIS
    inner join dwprod dp on br.prodid = dp.DWSOURCEID
    inner join dwdate dd on br.saledate = dd.datevalue
	WHERE          
    br.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 10 and action = 'MODIFY'
        );
INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)
select DWSALE_SEQ.nextval,dwcustid,dwprodid,saleid,null,qty,SALE_DWDATEID,SHIP_DWDATEID,MaxUnitPrice from 
(
SELECT          dc.dwcustid,dp.dwprodid,br.saleid,null,br.qty,dd.datekey as SALE_DWDATEID,dd2.datekey as SHIP_DWDATEID,br.prodid
	FROM            A2SALEBRIS br
    inner join dwcust dc on br.custid = dc.DWSOURCEIDBRIS
    inner join dwprod dp on br.prodid = dp.DWSOURCEID
    inner join dwdate dd on br.saledate = dd.datevalue
    inner join dwdate dd2 on br.shipdate = dd2.datevalue 
	WHERE          
    br.ROWID IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        where filterid = 11 and action = 'MODIFY'
        ) 
) x inner join 
(
SELECT prodid,unitprice as MaxUnitPrice
FROM (
  SELECT br.prodid,br.unitprice,
  MAX(br.unitprice) OVER (PARTITION BY br.prodid) AS maxunitprice
  FROM A2SALEBRIS br
    
)
WHERE unitprice = maxunitprice group by prodid,unitprice
) y on x.prodid = y.prodid;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEMELB',328,12,sysdate,'SKIP'
	FROM              A2SALEMELB mb
	WHERE           mb.prodid not in (select DWSOURCEID from dwprod) or mb.prodid is null;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEMELB',349,13,sysdate,'SKIP'
	FROM              A2SALEMELB mb
	WHERE           mb.custid not in (select DWSOURCEIDMELB from dwcust where DWSOURCEIDMELB is not null) or mb.custid is null;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEMELB',371,14,sysdate,'MODIFY'
	FROM              A2SALEMELB mb
	WHERE           mb.shipdate < mb.saledate;
INSERT INTO A2ERROREVENT (ERRORID,source_rowid, source_table,ERRORCODE, filterid,datetime, action)
	SELECT           A2ERROREVENT_SEQ.nextval, ROWID,'A2SALEMELB',393,15,sysdate,'MODIFY'
	FROM              A2SALEMELB mb
	WHERE           mb.unitprice is null; 

INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)	
	SELECT           DWSALE_SEQ.nextval,dc.dwcustid,dp.dwprodid,null,ml.saleid,ml.qty,dd.datekey,dd2.datekey,ml.unitprice
	FROM            A2SALEMELB ml
    inner join dwcust dc on ml.custid = dc.DWSOURCEIDMELB
    inner join dwprod dp on ml.prodid = dp.DWSOURCEID
    inner join dwdate dd on ml.saledate = dd.datevalue
    inner join dwdate dd2 on ml.shipdate = dd2.datevalue 
    where ml.ROWID NOT IN
        (
        SELECT  source_rowid
        FROM    A2ERROREVENT 
        );
INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)	
	SELECT           DWSALE_SEQ.nextval,dc.dwcustid,dp.dwprodid,null,ml.saleid,ml.qty,dd.datekey,dd.datekey+2,ml.unitprice
	FROM            A2SALEMELB ml
    inner join dwcust dc on ml.custid = dc.DWSOURCEIDMELB
    inner join dwprod dp on ml.prodid = dp.DWSOURCEID
    inner join dwdate dd on ml.saledate = dd.datevalue
	WHERE          
    ml.ROWID IN
        (
         select   source_rowid from 
        (  
            SELECT  source_rowid FROM    A2ERROREVENT where filterid = 14 and action = 'MODIFY'
        ) x inner join
        (
            select rowid from A2SALEMELB  WHERE shipdate < saledate and unitprice is not null
        ) y on x.source_rowid = y.rowid
        );
INSERT INTO DWSALE (DWSALEID,DWCUSTID,DWPRODID,DWSOURCEIDBRIS,DWSOURCEIDMELB,QTY,SALE_DWDATEID,SHIP_DWDATEID,SALEPRICE)
select DWSALE_SEQ.nextval,dwcustid,dwprodid,null,saleid,qty,SALE_DWDATEID,SHIP_DWDATEID,MaxUnitPrice from 
(
SELECT          dc.dwcustid,dp.dwprodid,ml.saleid,null,ml.qty,dd.datekey as SALE_DWDATEID,dd2.datekey as SHIP_DWDATEID,ml.prodid
	FROM            A2SALEMELB ml
    inner join dwcust dc on ml.custid = dc.DWSOURCEIDMELB
    inner join dwprod dp on ml.prodid = dp.DWSOURCEID
    inner join dwdate dd on ml.saledate = dd.datevalue
    inner join dwdate dd2 on ml.shipdate = dd2.datevalue 
	WHERE          
    ml.ROWID IN
        (
        select   source_rowid from 
        (  
            SELECT  source_rowid FROM    A2ERROREVENT where filterid = 15 and action = 'MODIFY'
        ) x inner join
        (
            select rowid from A2SALEMELB  WHERE unitprice is null and shipdate > saledate
        ) y on x.source_rowid = y.rowid
        ) 
) x inner join 
(
SELECT prodid,unitprice as MaxUnitPrice
FROM (
  SELECT ml.prodid,ml.unitprice,
  MAX(ml.unitprice) OVER (PARTITION BY ml.prodid) AS maxunitprice
  FROM A2SALEMELB ml
    
)
WHERE unitprice = maxunitprice group by prodid,unitprice
) y on x.prodid = y.prodid;

