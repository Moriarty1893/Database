CREATE OR REPLACE FUNCTION NewCustomerWithTransaction2( 
	newname char, 
	newstreet char,
	newcity char,
	newzip char,
	newareacode char, 
	newphone char,
	newscondame char,
	artistname char,
	worktitle char,
	workcopy char,
	price numeric
)
RETURNS void AS $$
DECLARE
rowcount integer := 0;
tid int;
aid int;
transcursor CURSOR FOR
SELECT transaction.transactionid, artist.artistid 
FROM artist, work, transaction
WHERE Name=artistname AND Title=worktitle AND
Copy=workcopy AND
transaction.customerid IS NOT NULL AND
artist.artistid = work.artistid AND work.workid = transaction.workid;
BEGIN
--Are client in bd?
SELECT Count (*) INTO rowcount 
FROM CUSTOMER
WHERE name=newname AND area_code=newareacode AND
phone_number = newphone;
IF rowcount > 0 THEN
-- We need call procedure
RAISE NOTICE 'Customer Already Exists - No Action Taken'; 
RETURN; 
END IF;
-- Add new client
INSERT INTO CUSTOMER
(customerid, name, area_code, phone_number) VALUES
(nextval('CustID'), newname, newareacode, newphone); 
-- Only 1 

rowcount := 0;

FOR trans IN transcursor
LOOP
tid := trans.transactionid;
aid := trans.artistid;
rowcount := rowcount + 1;
END LOOP;
IF rowcount > 1 THEN

RAISE EXCEPTION 'Неверные данные в Tаблицах ARTIST/WORK/TRANSACTION - - никаких действ RETURN';
END IF;
IF rowcount = 0 THEN

RAISE EXCEPTION 'Ni odnoi cvobod stroki v tablicada TRANSACTION -- никаких действий RETURN';
END IF;

RAISE NOTICE 'Transaction ID: %', tid;
UPDATE TRANSACTION
SET Customerid = currval('CustID'), Sales_price = price, Purchase_Date = CURRENT_DATE WHERE transactionid = tid;
RAISE NOTICE 'Клиент добавлен в базу данных, данные транзакций обновлены'; 
--Теперь регистрируем интерес данного клиента к данному художнику

INSERT INTO CUSTOMER_ARTIST
(Artist_ID, Customer_ID) VALUES
(aid, currval('CustID'));
END;
$$ LANGUAGE plpgsql;