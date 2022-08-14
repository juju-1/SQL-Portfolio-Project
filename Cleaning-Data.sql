/*
Cleaning Data in SQL Queries
*/

Select *
From dbo.NashvilleHouse

-- Standardize Date Format

Select SaleDateCoverted, CONVERT(Date, SaleDate)
From NashvilleHouse

Update NashvilleHouse
SET SaleDate = CONVERT(Date, SaleDate)

--It if does not update properly

ALTER TABLE NashvilleHouse
Add SaleDateCoverted Date;

Update NashvilleHouse
SET SaleDateCoverted = CONVERT(Date, SaleDate)


--populate property address data

Select *
From dbo.NashvilleHouse
-- Where PropertyAddress is null
order by ParcelID


Select *
From dbo.NashvilleHouse a
Join dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From dbo.NashvilleHouse a
Join dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHouse a
Join dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHouse a
Join dbo.NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out Address into individual colums (adddress, city, state)

Select PropertyAddress
From dbo.NashvilleHouse
-- Where PropertyAddress is null
--border by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1 ) as Address
From NashvilleHouse


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHouse


ALTER TABLE NashvilleHouse
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1 )

ALTER TABLE NashvilleHouse
Add PropertySplitCity Nvarchar(255);

Update NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From NashvilleHouse





Select OwnerAddress
From NashvilleHouse

Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From NashvilleHouse


ALTER TABLE NashvilleHouse
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHouse
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHouse
Add OwnerSplitState Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)



--Change Y and N to Yes and No in "Sold ad Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHouse
Group by SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 else SoldAsVacant
	     end
From NashvilleHouse


Update NashvilleHouse
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 else SoldAsVacant
	     end




-- Remove Duplicates

Select *, 
	ROW_NUMBER() over (
	PARTITION by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) ROW_NUM
				
From NashvilleHouse

-- use CTE find duplicate

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	PARTITION by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) ROW_NUM
				
From NashvilleHouse)

Select
From RowNumCTE
Where row_num > 1




--remove

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	PARTITION by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) ROW_NUM
				
From NashvilleHouse)

Delete
From RowNumCTE
Where row_num > 1



-- Delete unused columns name

select *
from NashvilleHouse

alter table NashvilleHouse
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

alter table NashvilleHouse
Drop Column SaleDate