-- SQL CLEANING DATA


create database sqlcleaning;
use sqlcleaning;
select * from housing;


-- Standardize Date Format

Select saleDate from housing;

Update housing
set saledate=cast(saledate as date);  
                   -- Syntax : CAST(value AS datatype) : To convert value into specified data type.
                   -- We can use Convert() too. Convert(value,data_type)

-- Populate Property Address data

Select PropertyAddress from housing;

-- Syntax : IFNULL(expression, alt_value) 
-- The IFNULL() function returns a specified value if the expression is NULL.If the expression is NOT NULL, this function returns the expression.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,IFNULL(a.PropertyAddress, b.PropertyAddress) 
From housing as a
JOIN housing as b
on a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID 
Where a.PropertyAddress is null;


UPDATE Housing as a
JOIN Housing as b
on a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is null;


-- breaking out address to address, city for propertyaddress

Select propertyaddress from housing;

-- Syntax : SUBSTRING(string, start, length)
-- The SUBSTRING() function extracts a substring from a string (starting at any position).
Select 
Substring(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as Address,
Substring(Propertyaddress,LOCATE(',',PropertyAddress)+1,char_length(Propertyaddress)) as City
From housing;


Alter table housing
ADD Address nvarchar(255);

Update Housing
set Address=Substring(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

Alter table housing
ADD city nvarchar(255);

Update Housing
set city=Substring(Propertyaddress,LOCATE(',',PropertyAddress)+1,char_length(Propertyaddress));

Select * from housing;

-- breaking out address to address, city for owneraddress
SELECT OwnerAddress
FROM Housing; 

-- SUBSTRING_INDEX(string, delimiter, number)
--  number	Required. The number of times to search for the delimiter. Can be both a positive or negative number. If it is a positive number, this function returns all to the left of the delimiter. If it is a negative number, this function returns all to the right of the delimiter.
-- The SUBSTRING_INDEX() function returns a substring of a string before a specified number of delimiter occurs.
Select 
substring_index(Owneraddress,',',1)as address,
substring_index(substring_index(Owneraddress,',',2),',',-1) as city,
substring_index(Owneraddress,',',-1) as state
from housing;

alter table housing
add oa_address nvarchar(255),
add oa_city nvarchar(255),
add oa_state nvarchar(255);

update housing
set oa_address =substring_index(Owneraddress,',',1),
	oa_city=substring_index(substring_index(Owneraddress,',',2),',',-1),
    oa_state=substring_index(Owneraddress,',',-1);

select * from housing;

-- change Y and N to Yes and No in "Sold as Vacant" field

select distinct(Soldasvacant),count(soldasvacant)
from housing
group by soldasvacant;

/*
SYNTAX:
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END;
*/

/*
The CASE statement goes through conditions and return a value when the first condition is met (like an IF-THEN-ELSE statement). So, once a condition is true, it will stop reading and return the result.

If no conditions are true, it will return the value in the ELSE clause.

If there is no ELSE part and no conditions are true, it returns NULL.
*/


select soldasvacant ,
Case when Soldasvacant ='Y' then 'Yes'
     when soldasvacant ='N' then 'No'
     else ''
     end
from housing;

Update housing
set soldasvacant=Case when Soldasvacant ='Y' then 'Yes'
when soldasvacant ='N' then 'No'
else ''
end;
	
-- remove duplicates

/* Used CTE (Common Table Expression) - with *//*
/* Partition over is used */
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 	ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		     ORDER BY
	             UniqueID
			) row_num
FROM housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 	ParcelID,
		     	PropertyAddress,
		     	SalePrice,
		     	SaleDate,
		     	LegalReference
		     ORDER BY
		     UniqueID
			) row_num
FROM Housing
)
DELETE a
FROM RowNumCTE
JOIN housing as a USING(UniqueID)
WHERE row_num > 1;


-- delete unused columns

SELECT *
FROM Housing;

ALTER TABLE Housing
DROP OwnerAddress, 
DROP TaxDistrict, 
DROP PropertyAddress, 
DROP SaleDate;