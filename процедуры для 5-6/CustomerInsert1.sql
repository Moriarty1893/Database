CREATE OR REPLACE FUNCTION CustomerInsert1
(
newname varchar,
newareacode varchar,
newphone varchar,
artistnationality varchar
)
RETURNS void AS $$
DECLARE
rowcount integer :=0;
artistcursor CURSOR FOR
SELECT artistid
FROM artist
WHERE nationality=artistnationality; 

BEGIN
SELECT Count (*) INTO rowcount
FROM customer
WHERE name=newname AND area_code=newareacode AND Phone_Number = newphone;
IF rowcount > 0 THEN
RAISE NOTICE 'Клиент уже есть в базе данных - никаких действий не предпринято';
RETURN;
END IF;
INSERT INTO customer
(customerid, name, area_code, phone_number) VALUES
(nextval('CustID'), newname, newareacode, newphone);
FOR artist IN artistcursor
LOOP
INSERT INTO CUSTOMER_ARTIST_INT
(customerid, artistid)
VALUES
(currval('CustID'), artist.artistid); 
END LOOP;
RAISE NOTICE 'Новый клиент успешно добавлен в базу'; 
END;
$$ LANGUAGE plpgsql;