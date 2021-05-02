CREATE OR REPLACE PROCEDURE ADD_CUST_TO_DB (pcustid Number, pcustname Varchar2) AS
    cusid_out_of_range EXCEPTION;
    BEGIN
    IF (pcustid < 1) OR (pcustid > 499) THEN
    RAISE cusid_out_of_range;
    END IF;
    INSERT INTO customer
      VALUES (pcustid, pcustname, 0, 'OK');
    EXCEPTION 
    WHEN dup_val_on_index THEN
             RAISE_APPLICATION_ERROR(-20012, 'Duplicate customer ID.');
    WHEN cusid_out_of_range THEN
             RAISE_APPLICATION_ERROR(-20024, 'Customer ID out of range.');
    WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
    END;
/
CREATE OR REPLACE PROCEDURE ADD_CUSTOMER_VIASQLDEV (pcustid Number, pcustname Varchar2) AS 
    BEGIN
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Customer '||pcustid||' '||pcustname);
    ADD_CUST_TO_DB(pcustid,pcustname);	
    DBMS_OUTPUT.PUT_LINE('ADDED OK');
    commit;
    EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
/    
create or replace function delete_all_customers_from_db return number as 
   vRowCount number;
   begin
   delete from customer;
   vRowCount := sql%rowcount;
   return vRowCount;
   exception when others then 
         RAISE_APPLICATION_ERROR(-20000, SQLERRM);
   end;
/   
create or replace procedure delete_all_customers_viasqldev as 
  vRowCount integer;
  begin
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Deleting all Customer rows');
  vRowCount := delete_all_customers_from_db;
  DBMS_OUTPUT.PUT_LINE(vRowCount||' '||'rows deleted');
  commit;
  EXCEPTION when others then 
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
  end;
/  
create or replace procedure add_product_to_db (pprodid number, pprodname varchar2, pprice number)as 
     pprodid_out_of_range EXCEPTION;
     pprice_out_of_range EXCEPTION;
  begin
    IF (pprodid < 1000) OR (pprodid > 2500) THEN
    RAISE pprodid_out_of_range;
    END IF;
    
    IF (pprice < 0) OR (pprice > 999.99) THEN
    RAISE pprice_out_of_range;
    END IF;
  insert into product values (pprodid,pprodname,pprice,0);
  EXCEPTION 
  when dup_val_on_index then 
    RAISE_APPLICATION_ERROR(-20032, 'Duplicate product ID');
  when pprodid_out_of_range then
    RAISE_APPLICATION_ERROR(-20044, 'Product ID out of range');
  when pprice_out_of_range then
    RAISE_APPLICATION_ERROR(-20056, 'Price out of range');
  when others then
    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  end;
/
create or replace procedure add_product_viasqldev (pprodid number, pprodname varchar2, pprice number) as
  begin
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Adding Product. ID: '||pprodid||' Name: '||pprodname||' Price:'||pprice);
    add_product_to_db(pprodid,pprodname,pprice);
    DBMS_OUTPUT.PUT_LINE('Product Added OK');
    commit;
    EXCEPTION when others then
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
  end;
/  
create or replace function delete_all_products_from_db return number as 
vRowDeleted number;
begin
delete from product;
vRowDeleted := sql%rowcount;
return vRowDeleted;
EXCEPTION when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure delete_all_products_viasqldev as 
vRowCount number;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Product rows');
vRowCount:= delete_all_products_from_db;
DBMS_OUTPUT.PUT_LINE(vRowCount ||' rows deleted');
commit;
EXCEPTION when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function get_cust_string_from_db (pcustid number) return varchar2 as 
vCustDetails varchar2(100);
vName varchar2(100);
vStatus varchar2(100);
vSalesYTD number; 

begin
select custname,status,sales_ytd  into vName, vStatus, vSalesYTD from customer 
where custid = pcustid;
vCustDetails := 'Custid: '||pcustid||' Name: '||vName||' Status: '||vStatus||' SalesYTD: '||vSalesYTD; 
return vCustDetails;

EXCEPTION 
when no_data_found THEN
RAISE_APPLICATION_ERROR(-20062,'Customer ID not found');
when others then
RAISE_APPLICATION_ERROR(-20000, SQLERRM);
end;
/
create or replace procedure get_cust_string_viasqldev (pcustid number) as 
vCustDetail varchar2(100);
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Getting Details for CustId '||pcustid);
vCustDetail := get_cust_string_from_db(pcustid);
DBMS_OUTPUT.PUT_LINE(vCustDetail);
EXCEPTION 
when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure upd_cust_salesytd_in_db (pcustid number, pamt number) as 

no_rows_update exception;
pamt_outside_range exception;
begin
if(pamt < -999.99) or (pamt >999.99) then
raise pamt_outside_range;
end if;
update customer set sales_ytd = pamt where custid = pcustid;
if(sql%notfound) then 
raise no_rows_update;
end if;
exception 
when no_rows_update then 
RAISE_APPLICATION_ERROR(-20072,'Customer ID not found');
when pamt_outside_range then
RAISE_APPLICATION_ERROR(-20084,'Amount out of range');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure upd_cust_salesytd_viasqldev (pcustid number, pamt number) as 

begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Updating SalesYTD. Customer Id: '||pcustid||' Amount: '||pamt);
upd_cust_salesytd_in_db(pcustid,pamt);
DBMS_OUTPUT.PUT_LINE('Update OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function get_prod_string_from_db (pprodid number) return varchar2 as 
vName varchar2(100);
vPrice number;
vSalesYTD number;
vDetails varchar(200);
begin
select prodname,selling_price,sales_ytd into vName,vPrice,vSalesYTD from product where prodid = pprodid;
vDetails := 'Prodid: '||pprodid||' Name: '||vName||' Price: '||vPrice||' SalesYTD: '||vSalesYTD;
return vDetails;
exception 
when no_data_found then
RAISE_APPLICATION_ERROR(-20092,'Product ID not found');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure get_prod_string_viasqldev (pprodid number) as

begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Getting Details for Prod Id '||pprodid);
DBMS_OUTPUT.PUT_LINE(get_prod_string_from_db(pprodid));
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure upd_prod_salesytd_in_db (pprodid number, pamt number) as 
no_rows_update exception;
pamt_outside_range exception;
begin
if(pamt < -999.99) or (pamt >999.99) then
raise pamt_outside_range;
end if;
update product set sales_ytd = pamt where prodid = pprodid;
if(sql%notfound) then 
raise no_rows_update;
end if;
exception 
when no_rows_update then 
RAISE_APPLICATION_ERROR(-20102,'Product ID not found');
when pamt_outside_range then
RAISE_APPLICATION_ERROR(-20114,'Amount out of range');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure upd_prod_salesytd_viasqldev (pprodid number, pamt number) as 

begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Updating SalesYTD. Product Id: '||pprodid||' Amount: '||pamt);
upd_prod_salesytd_in_db(pprodid,pamt);
DBMS_OUTPUT.PUT_LINE('Update OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure upd_cust_status_in_db (pcustid number, pstatus varchar2) as 
no_rows_update exception;
invalid_status exception;
begin
if(pstatus != 'OK') and (pstatus !='SUSPEND') then
raise invalid_status;
end if;
update customer set status = pstatus where custid = pcustid;
if(sql%notfound) then 
raise no_rows_update;
end if;
exception 
when no_rows_update then 
RAISE_APPLICATION_ERROR(-20122,'Customer ID not found');
when invalid_status then
RAISE_APPLICATION_ERROR(-20134,'Invalid Status value');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure upd_cust_status_viasqldev (pcustid number, pstatus varchar2) as 

begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Updating status.  Id: '||pcustid||' New Status: '||pstatus);
upd_cust_status_in_db(pcustid,pstatus);
DBMS_OUTPUT.PUT_LINE('Update OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure add_simple_sale_to_db (pcustid number, pprodid number, pqty number) as 
invalid_cus_status exception;
saleQty_out_of_range exception;
cus_not_found exception;
prod_not_found exception;
vStatus varchar(10);
vCountCus number;
vCountProd number;
vPrice number;
vNewSalesYTD number;
begin
if(pqty <1) or (pqty > 999) then
raise saleQty_out_of_range;
end if;

SELECT COUNT(*) INTO vCountCus
FROM customer
WHERE custid = pcustid;

SELECT COUNT(*) INTO vCountProd
FROM product
WHERE prodid = pprodid;

if(vCountCus >0 ) and (vCountProd >0) then
select status into vStatus from customer where custid = pcustid;
    if(vStatus = 'OK') then
        select selling_price into vPrice from product where prodid = pprodid;
        vnewsalesytd := pqty*vprice;
        upd_cust_salesytd_in_db(pcustid,vnewsalesytd);
        upd_prod_salesytd_in_db(pprodid,vnewsalesytd);
    else
    raise invalid_cus_status;
    end if;

elsif(vCountCus <=0) then
raise cus_not_found;
else
raise prod_not_found;
end if;
EXCEPTION 
when saleQty_out_of_range then
RAISE_APPLICATION_ERROR(-20142,'Sale quantity outside valid range');
when invalid_cus_status then
RAISE_APPLICATION_ERROR(-20154,'Customer status is not OK');
when cus_not_found then 
RAISE_APPLICATION_ERROR(-20166,'Customer ID not found');
when prod_not_found then
RAISE_APPLICATION_ERROR(-20178,'Product ID not found');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure add_simple_sale_viasqldev (pcustid number, pprodid number, pqty number) as 
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Simple Sale. Cust Id: '||pcustid||' Prod Id: '||pprodid||' Qty: '||pqty);
add_simple_sale_to_db(pcustid,pprodid,pqty);
DBMS_OUTPUT.PUT_LINE('Added Simple Sale OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function sum_cust_salesytd return number as 
vTotalSalesYTD number;
begin
select sum(sales_ytd) into vTotalSalesYTD from customer;
if (vTotalSalesYTD is not null) then
return vTotalSalesYTD;
else
return 0;
end if;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure sum_cust_sales_viasqldev as 
vTotal number;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Summing Customer SalesYTD');
vTotal := sum_cust_salesytd;
DBMS_OUTPUT.PUT_LINE('All Customer Total: '||vTotal);
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function sum_prod_salesytd_from_db return number as 
vTotalSalesYTD number;
begin
select sum(sales_ytd) into vTotalSalesYTD from product;
if (vTotalSalesYTD is not null) then
return vTotalSalesYTD;
else
return 0;
end if;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure sum_prod_sales_viasqldev as 
vTotal number;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Summing Product SalesYTD');
vTotal := sum_cust_salesytd;
DBMS_OUTPUT.PUT_LINE('All Product Total: '||vTotal);
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function get_allcust return sys_refcursor as 
cuscursor sys_refcursor;
begin
open cuscursor for select * from customer;
return cuscursor;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure get_allcust_viasqldev as 
rv_sysrefcur SYS_REFCURSOR;
cusrec customer%rowtype;
nodatafound exception;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Listing All Customer Details');
rv_sysrefcur:= get_allcust;

loop
fetch rv_sysrefcur into cusrec;
if (rv_sysrefcur%rowcount = 0) then
close rv_sysrefcur;
raise nodatafound;
end if;
exit when rv_sysrefcur%notfound;
DBMS_OUTPUT.PUT_LINE('Custid: '||cusrec.custid||' Name: '||cusrec.custname||' Status: '||cusrec.status||' SalesYTD: '||cusrec.sales_ytd);
end loop;
close rv_sysrefcur;
exception when nodatafound then
DBMS_OUTPUT.PUT_LINE('No rows found');
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function get_allprod_from_db return sys_refcursor as 
prodcursor sys_refcursor;
begin
open prodcursor for select * from product;
return prodcursor;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure get_allprod_viasqldev as 
rv_sysrefcur SYS_REFCURSOR;
prodrec product%rowtype;
nodatafound exception;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Listing All Product Details');
rv_sysrefcur:= get_allprod_from_db;

loop
fetch rv_sysrefcur into prodrec;
if (rv_sysrefcur%rowcount = 0) then
close rv_sysrefcur;
raise nodatafound;
end if;
exit when rv_sysrefcur%notfound;
DBMS_OUTPUT.PUT_LINE('Prodid: '||prodrec.prodid||' Name: '||prodrec.prodname||' Price: '||prodrec.selling_price||' SalesYTD: '||prodrec.sales_ytd);
end loop;
close rv_sysrefcur;
exception when nodatafound then
DBMS_OUTPUT.PUT_LINE('No rows found');
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
CREATE OR REPLACE FUNCTION strip_constraint(pErrmsg VARCHAR2 )
                                  RETURN VARCHAR2 AS
rp_loc NUMBER; 
dot_loc NUMBER;

BEGIN
   dot_loc := INSTR(pErrmsg , '.');  	
   rp_loc  := INSTR(pErrmsg , ')'); 
   IF (dot_loc = 0 OR rp_loc = 0 ) THEN 	
      RETURN NULL ;
   ELSE  
      RETURN UPPER(SUBSTR(pErrmsg,dot_loc+1,rp_loc-dot_loc-1));
   END IF;
END;
/
create or replace procedure add_location_to_db (ploccode varchar2, pminqty number, pmaxqty number) as 
dbms_constraint_name	VARCHAR2(240);
CHECK_LOCID_LENGTH EXCEPTION;
PRAGMA EXCEPTION_INIT(CHECK_LOCID_LENGTH, -12899);
begin
insert into location values (ploccode,pminqty,pmaxqty);
exception 
when dup_val_on_index then 
RAISE_APPLICATION_ERROR(-20182,'Duplicate location ID');
when CHECK_LOCID_LENGTH then
RAISE_APPLICATION_ERROR(-20194,'Location Code length invalid');
when others then 
dbms_constraint_name:=strip_constraint(SQLERRM);
IF dbms_constraint_name='CHECK_LOCID_LENGTH' THEN
     RAISE_APPLICATION_ERROR(-20194,'Location Code length invalid');
  ELSIF dbms_constraint_name='CHECK_MINQTY_RANGE' THEN
     RAISE_APPLICATION_ERROR(-20206,'Minimum Qty out of range');
  ELSIF dbms_constraint_name='CHECK_MAXQTY_RANGE' THEN
     RAISE_APPLICATION_ERROR(-20218,'Maximum Qty out of range');
  ELSIF dbms_constraint_name='CHECK_MAXQTY_GREATER_MIXQTY' THEN
     RAISE_APPLICATION_ERROR(-20229,'Minimum Qty larger than Maximum Qty'); 
  ELSE
     RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END IF;
end;
/
create or replace procedure add_location_viasqldev (ploccode varchar2,pminqty number,pmaxqty number) as 
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Location LocCode: '||ploccode||' MinQty: '||pminqty||' MaxQty: '||pmaxqty);
add_location_to_db(ploccode,pminqty,pmaxqty);
DBMS_OUTPUT.PUT_LINE('Location Added OK');
commit;
exception when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure add_complex_sale_to_db (pcustid number,pprodid number, pqty number, pdate varchar2) as 
vStatus varchar2 (10);
invalid_status exception;
qty_out_of_range exception;
err_date exception;
cus_not_found exception;
prod_not_found exception;
vDate DATE;
vSalesid number;
vCountCus number;
vCountProd number;
vPrice number;
vSalesytd number;
begin
SELECT COUNT(*) INTO vCountCus
FROM customer
WHERE custid = pcustid;

if(vCountCus <1) then
raise cus_not_found;
end if;

SELECT COUNT(*) INTO vCountProd
FROM product
WHERE prodid = pprodid;

if(vCountProd <1) then
raise prod_not_found;
end if;

select status into vStatus from customer where custid = pcustid;
if(vStatus = 'OK') then
    if(pqty >= 1) and (pqty <=999) then
    BEGIN
      vDate := to_date(pdate,'yyyymmdd');
      
      EXCEPTION
        WHEN OTHERS THEN
          RAISE err_date;
    END;
    select sale_seq.nextval into vSalesid from dual;
    select selling_price into vPrice from product where prodid = pprodid;
    vSalesytd := vPrice * pqty;
    DBMS_OUTPUT.PUT_LINE('Adding Complex Sale Cust Id: '||pcustid||' Prod Id: '||pprodid||' Date: '||pdate||' Amt: '||vSalesytd);
    insert into sale values (vSalesid,pcustid,pprodid,pqty,vPrice,vDate);
    upd_cust_salesytd_in_db(pcustid,vSalesytd);
    upd_prod_salesytd_in_db(pprodid,vSalesytd);
    else
    raise qty_out_of_range;
    end if;
else
raise invalid_status;
end if;
exception 
when cus_not_found then
 RAISE_APPLICATION_ERROR(-20268,'Customer ID not found');
when prod_not_found then
 RAISE_APPLICATION_ERROR(-20279,'Product ID not found');
when invalid_status then 
 RAISE_APPLICATION_ERROR(-20244,'Customer status is not OK');
when qty_out_of_range then
 RAISE_APPLICATION_ERROR(-20232,'Sale Quantity outside valid range');
when err_date then
 RAISE_APPLICATION_ERROR(-20256,'Date not valid');
when others then
 RAISE_APPLICATION_ERROR(-20000, SQLERRM);
end;
/
create or replace procedure add_complex_sale_viasqldev (pcustid number,pprodid number, pqty number, pdate varchar2) as 
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
add_complex_sale_to_db(pcustid,pprodid,pqty,pdate);
DBMS_OUTPUT.PUT_LINE('Added Complex Sale OK');
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function get_allsales_from_db return sys_refcursor as 
salecursor sys_refcursor;
begin
open salecursor for select * from sale;
return salecursor;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure get_allsales_viasqldev as 
rv_sysrefcur SYS_REFCURSOR;
salerec sale%rowtype;
nodatafound exception;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Listing All Complex Sales Details');
rv_sysrefcur:= get_allsales_from_db;

loop
fetch rv_sysrefcur into salerec;
if (rv_sysrefcur%rowcount = 0) then
close rv_sysrefcur;
raise nodatafound;
end if;
exit when rv_sysrefcur%notfound;
DBMS_OUTPUT.PUT_LINE('Saleid: '||salerec.saleid||' Custid: '||salerec.custid||' Prodid: '||salerec.prodid||' Date '||to_char(salerec.saledate,'dd mon yyyy')||' Amount: '||salerec.qty);
end loop;
close rv_sysrefcur;
exception when nodatafound then
DBMS_OUTPUT.PUT_LINE('No rows found');
when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function count_product_sales_from_db (pdays number) return number as
vCount number;
vDate date;
begin
vDate := to_date(to_char(sysdate-pdays, 'yyyymmdd'),'yyyymmdd');
select count(*) into vCount from sale where saledate > vDate;
return vCount;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure count_product_sales_viasqldev (pdays number) as 
vSalesTotal number;

begin

DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Counting sales within '||pdays||' days');
vSalesTotal := count_product_sales_from_db(pdays);
DBMS_OUTPUT.PUT_LINE('Total number of sales: '||vSalesTotal);
exception when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace function delete_sale_from_db return number as 
vMinSaleId number;
no_sale_rows_found exception;
vcustid number;
vprodid number;
vqty number;
vprice number;
vsubstractsale number;
vcussalesytd number;
vprodsaleytd number;
begin 
select min(saleid) into vMinSaleId from sale;
if(vMinSaleId is null) then
raise no_sale_rows_found; 
end if;
select custid,prodid,qty,price into vcustid,vprodid,vqty,vprice from sale where saleid = vMinSaleId;
delete from sale where saleid = vMinSaleId;
vsubstractsale := vqty * vprice;
select sales_ytd into vcussalesytd from customer where custid = vcustid;
select sales_ytd into vprodsaleytd from product where prodid = vprodid;
vcussalesytd := vcussalesytd - vsubstractsale;
vprodsaleytd := vprodsaleytd - vsubstractsale;
upd_cust_salesytd_in_db(vcustid,vcussalesytd);
upd_prod_salesytd_in_db(vprodid,vprodsaleytd);
return vMinSaleId;
exception 
when no_sale_rows_found then 
RAISE_APPLICATION_ERROR(-20282,'No Sale Rows Found');
when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure delete_sale_viasqldev as 
vDeletedSaleId number;
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting Sale with smallest SaleId value');
vDeletedSaleId:= delete_sale_from_db;
DBMS_OUTPUT.PUT_LINE('Deleted Sale OK. SaleId: '||vDeletedSaleId);
exception when others then 
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure delete_all_sales_from_db as 
salecursor sys_refcursor;
salerec sale%rowtype;
begin
open salecursor for select * from sale;

loop
fetch salecursor into salerec;
exit when salecursor%notfound;
update customer set sales_ytd = 0 where custid = salerec.custid;
update product set sales_ytd = 0 where prodid = salerec.prodid;
end loop;
delete from sale;
exception when others then 
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure delete_all_sales_viasqldev as  
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Sales data in Sale, Customer, and Product tables');
delete_all_sales_from_db;
DBMS_OUTPUT.PUT_LINE('Deletion OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure delete_customer (pCustid number) as 
child_rec_found exception;
no_matching_cus exception;
vCountChild number;
vCount number;
begin
select count(*) into vCount from customer where custid = pCustid;
if(vCount <1) then
raise no_matching_cus;
else
   select count(*) into vCountChild from sale where custid = pCustid;
   if(vCountChild >0) then
        raise child_rec_found;
    else
        delete from customer where custid = pCustid;
    end if;
end if;
exception 
when no_matching_cus then
RAISE_APPLICATION_ERROR(-20292,'Customer ID not found');
when child_rec_found then
RAISE_APPLICATION_ERROR(-20304,'Customer cannot be deleted as sales exist');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure delete_customer_viasqldev (pCustid number) as
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting Customer. Cust Id: '||pCustid);
delete_customer(pCustid);
DBMS_OUTPUT.PUT_LINE('Deleted Customer OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
create or replace procedure delete_prod_from_db (pProdid number) as 
child_rec_found exception;
no_matching_prod exception;
vCountChild number;
vCount number;
begin
select count(*) into vCount from product where prodid = pProdid;
if(vCount <1) then
raise no_matching_prod;
else
   select count(*) into vCountChild from sale where prodid = pProdid;
   if(vCountChild >0) then
        raise child_rec_found;
    else
        delete from product where prodid = pProdid;
    end if;
end if;
exception 
when no_matching_prod then
RAISE_APPLICATION_ERROR(-20312,'Product ID not found');
when child_rec_found then
RAISE_APPLICATION_ERROR(-20324,'Product cannot be deleted as sales exist');
when others then
RAISE_APPLICATION_ERROR(-20000,SQLERRM);
end;
/
create or replace procedure delete_prod_viasqldev (pProdid number) as
begin
DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting Product. Product Id: '||pProdid);
delete_prod_from_db(pProdid);
DBMS_OUTPUT.PUT_LINE('Deleted Product OK');
commit;
exception when others then
DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;


