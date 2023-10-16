--Nashville Housing
Select * 
From PortfolioProject.dbo.NashvilleHousing

-- Stadartize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted from NashvilleHousing


-- Populate Property Address data

select PropertyAddress from NashvilleHousing

select * from NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select * from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress NVarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity NVarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState NVarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant,
Case When SoldAsvacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case When SoldAsvacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


----------------------------------------------------------------------------------------


--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
				UniqueID
				) row_num

from NashvilleHousing
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress
--------------------------------------
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
				UniqueID
				) row_num

from NashvilleHousing
)

delete 
from RowNumCTE
where row_num > 1

------------------------------
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
				UniqueID
				) row_num

from NashvilleHousing
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress
-------------------------------------------------------------------------

-- Delete Unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * 
FROM NashvilleHousing
