/*
Cleaning Data in SQL Queries
*/
use DA_Portfolio_Project_4_SQL_DataCleaning

Select *
From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,Saledate)
From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date,Saledate)




-- If it doesn't Update properly

--Select SaleDate, CONVERT(Date,Saledate)
--From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted date

update NashvilleHousing
SET SaleDateConverted = CONVERT(date,Saledate)


Select SaleDateConverted, CONVERT(Date,Saledate)
From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select  a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing a
join DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update  a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DA_Portfolio_Project_4_SQL_DataCleaning.dbo.NashvilleHousing a
join DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null







--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


  
--select PropertyAddress
--from DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City

from DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing

Alter Table NashvilleHousing
Add BrokeAddress nvarchar(255)

update NashvilleHousing
SET BrokeAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add City nvarchar(255)

update NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--select BrokeAddress, City
--from NashvilleHousing




select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing




Alter Table NashvilleHousing
Add BrokeOwnerAddress nvarchar(255)

update NashvilleHousing
SET BrokeOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerCity nvarchar(255)

update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerState nvarchar(255)

update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select BrokeOwnerAddress, OwnerCity,  OwnerState
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

--Select Distinct(SoldASVacant), COUNT(SoldAsVacant)
--From DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing
--Group by SoldAsVacant
--Order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' Then 'Yes' 
	 WHEN SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' Then 'Yes' 
	 WHEN SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END


--Select Distinct(SoldASVacant), COUNT(SoldAsVacant)
--From DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing
--Group by SoldAsVacant
--Order by 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE as (
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) as Row_Num

--Find Duplicates
From DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing)


DELETE
from RowNumCTE
Where Row_Num>1



--Check the result

--With RowNumCTE as (
--select *,
--	ROW_NUMBER() over(
--	PARTITION BY ParcelID,
--				 PropertyAddress, 
--				 SalePrice,
--				 SaleDate,
--				 LegalReference
--				 ORDER BY
--					UniqueID) as Row_Num

----Find Duplicates
--From DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing)


--SELECT *
--from RowNumCTE
--Where Row_Num>1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing
Drop COLUMn OwnerAddress,Taxdistrict, PropertyAddress


select *
From DA_Portfolio_Project_4_SQL_DataCleaning..NashvilleHousing







