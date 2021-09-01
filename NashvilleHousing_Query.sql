/*
This SQL queries cleans the Nashville Housing data. 
Cleaning Data in SQL Queries Project 
Clean the Data to make it more useful 
*/

Select *
from nashvillehousing;
/*
----------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize the Date Format

SELECT saledate, CONVERT(DATE, Saledate)
from portfolioproject.nashvillehousingdata;

UPDATE portfolioproject.nashvillehousingdata
SET saledate = CONVERT (DATE, saledate);

ALTER TABLE portfolioproject.nashvillehousingdata
ADD SaleDateConverted DATE;

UPDATE portfolioproject.nashvillehousingdata
SET SaleDateConverted = CONVERT (DATE, saledate);


*/
----------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM nashvillehousing
ORDER BY ParcelID;

SELECT uniqueid
FROM nashvillehousing;


-- Where Poperty Address is Missing 
SELECT *
FROM nashvillehousing
WHERE PropertyAddress is NULL;


-- Self Join
-- populate NULL propertyaddress where parcelids are same. 
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress) 
FROM nashvillehousing a
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is NULL;

--Create a table with parcelid and address
CREATE TABLE missing_prop_ad AS
SELECT a.parcelid,  COALESCE(a.propertyaddress, b.propertyaddress) as missing_add
FROM nashvillehousing a
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is NULL;


--SHOW missing address
SELECT *
FROM missing_prop_ad;


SELECT propertyaddress
FROM nashvillehousing
WHERE PropertyAddress is NULL;


-- Update the table with the address where it was NULL 
UPDATE nashvillehousing as a
SET propertyaddress =  b.missing_add
FROM missing_prop_ad as b
WHERE a.propertyaddress is NULL;

--##################################################################3

-- Breaking out address into individual columns (Address, City, State)
SELECT propertyaddress
FROM nashvillehousing
-- WHERE propertyaddress is null
--ORDER by parcelID

--split the address using substring ',' starting at index 1 minus poition ',' and substract 1 to remove comma. 
--
SELECT
SUBSTRING(propertyaddress,1, POSITION(',' IN propertyaddress)-1) as Address,
SUBSTRING(propertyaddress,POSITION(',' IN propertyaddress)+2, LENGTH(propertyaddress)) as State
FROM nashvillehousing


--create column for address and city to add the address.
ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(propertyaddress,1, POSITION(',' IN propertyaddress)-1)


ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(propertyaddress,POSITION(',' IN propertyaddress)+2, LENGTH(propertyaddress))

--split ownersaddress into three parts
SELECT
owneraddress,
split_part(owneraddress,', ',1),
split_part(owneraddress,', ',2),
split_part(owneraddress,', ',3)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = split_part(owneraddress,', ',1)
--

ALTER TABLE nashvillehousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = split_part(owneraddress,', ',2)
--

ALTER TABLE nashvillehousing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = split_part(owneraddress,', ',3)

----

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashvillehousing
GROUP BY soldasvacant
ORDER BY 2


-- if you want to change the 'Y' to Yes or 'N' to No
SELECT soldasvacant,
CASE When soldasvacant ='Y' THEN 'Yes'
When soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM nashvillehousing

-- Change N to No and y to Yes
UPDATE nashvillehousing
SET soldasvacant = CASE When soldasvacant ='Y' THEN 'Yes'
When soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END

---------------------
--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	Propertyaddress, 
	Saleprice,
	saledate,
	legalreference
		ORDER BY
		uniqueid
	)row_num
FROM nashvillehousing
--ORDER BY parcelid
),
RowNumCTESubset AS
(
SELECT * FROM RowNumCTE
	WHERE row_num >1
)
DELETE FROM nashvillehousing
USING RowNumCTESubset
WHERE RowNumCTESubset.uniqueid =  nashvillehousing.uniqueid

-- TO VIEW IF THERE ARE DUPLICATES 
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	Propertyaddress, 
	Saleprice,
	saledate,
	legalreference
		ORDER BY
		uniqueid
	)row_num
FROM nashvillehousing)

SELECT *
FROM RowNumCTE
WHERE row_num >1 


-- DELETE UNUSED COLUMNS 
SELECT * 
FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress, 
DROP COLUMN propertyaddress,
DROP COLUMN taxdistrict


