
--cleaning the data in sql queries

select * 
from portfolioproject3..nashvillehousing

-- standrize Date format
select saledate,convert(Date,saledate)
from portfolioproject3..nashvillehousing

update nashvillehousing
set SaleDate = convert(date,SaleDate)

ALTER TABLE nashvillehousing
ADD saledateconverted date

update nashvillehousing
set saledateconverted = CONVERT(date,SaleDate)

select SaleDate, saledateconverted
from portfolioproject3..nashvillehousing

--Populate popular address data
select *
from portfolioproject3..nashvillehousing
--where PropertyAddress is  not null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject3..nashvillehousing a
join portfolioproject3..nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject3..nashvillehousing a
join portfolioproject3..nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns(address,state,city)
--The CHARINDEX() function searches for a substring in a string, and returns the position.
--If the substring is not found, this function returns 0.

select 
SUBSTRING(Propertyaddress,1,CHARINDEX(',',Propertyaddress) -1) as address 
, SUBSTRING(Propertyaddress,CHARINDEX(',',Propertyaddress) +1,LEN(Propertyaddress)) as address 
from portfolioproject3..nashvillehousing 

--select PropertyAddress
--from portfolioproject3..nashvillehousing 


ALTER TABLE nashvillehousing
ADD Propertysplitaddress varchar(255)

update nashvillehousing
set Propertysplitaddress = SUBSTRING(Propertyaddress,1,CHARINDEX(',',Propertyaddress) -1)

ALTER TABLE nashvillehousing
ADD Propertycityaddress varchar(255)

update nashvillehousing
set Propertycityaddress = SUBSTRING(Propertyaddress,CHARINDEX(',',Propertyaddress) +1,LEN(Propertyaddress))

select * 
from portfolioproject3..nashvillehousing



select 
PARSENAME(REPLACE(Owneraddress,',','.'),3) 
,PARSENAME(REPLACE(Owneraddress,',','.'),2)
,PARSENAME(REPLACE(Owneraddress,',','.'),1)
from portfolioproject3..nashvillehousing

ALTER TABLE nashvillehousing
ADD ownersplitaddress varchar(255)

update nashvillehousing
set ownersplitaddress = PARSENAME(REPLACE(Owneraddress,',','.'),3)

ALTER TABLE nashvillehousing
ADD ownersplitcity varchar(255)

update nashvillehousing
set ownersplitcity = PARSENAME(REPLACE(Owneraddress,',','.'),2)

ALTER TABLE nashvillehousing
ADD ownersplitstate varchar(255)

update nashvillehousing
set ownersplitstate = PARSENAME(REPLACE(Owneraddress,',','.'),1) 

select *
from portfolioproject3..nashvillehousing



--change Y and N to yes and no in "sold as vacant" field

select DISTINCT soldasvacant,COUNT(soldasvacant)
from portfolioproject3..nashvillehousing
GROUP BY soldasvacant
ORDER BY 2


select SoldAsVacant
,CASE WHEN soldasvacant = 'Y' THEN 'YES'
      WHEN soldasvacant = 'N' THEN 'NO'
	  ELSE soldasvacant
	  END
from portfolioproject3..nashvillehousing


UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'YES'
      WHEN soldasvacant = 'N' THEN 'NO'
	  ELSE soldasvacant
	  END
from portfolioproject3..nashvillehousing



--REMOVE Duplicates
-- ROW_NUMBER() is a window function used to assign a unique sequential number to each row in the result set based on the specified ordering criteria. 
--It is often used in conjunction with the OVER clause to partition and order the rows for numbering.


WITH Row_numCTE AS (
select *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 Propertyaddress,
				 SalePrice,
				 Saledate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
from portfolioproject3..nashvillehousing
--where row_num > 1
--ORDER BY ParcelID
)
--DELETE 
--from Row_numCTE
--where row_num > 1

select *
from Row_numCTE
where row_num > 1


--Deleting unused columns
select *
from portfolioproject3..nashvillehousing

ALTER TABLE portfolioproject3..nashvillehousing
DROP COLUMN Owneraddress,Propertyaddress,TaxDistrict

ALTER TABLE portfolioproject3..nashvillehousing
DROP COLUMN Saledate
