/*

Cleaning Data

*/

Select *
From NashvilleHousing
--------------------------------------------------------------------------
-- Standardize Data Format

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

/* Alternative way if above does not work 
ALter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing
*/
--------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Identify ParcelID=PropertyAddress therefore null values can be updated 

Select one.ParcelID, one.PropertyAddress, two.ParcelID, two.PropertyAddress, ISNULL(one.PropertyAddress,two.PropertyAddress)
From NashvilleHousing one
Join NashvilleHousing two
	On one.ParcelID = two.ParcelID
	and one.[UniqueID] <> two.[UniqueID]
Where one.PropertyAddress is null

Update one
SET PropertyAddress = ISNULL(one.PropertyAddress,two.PropertyAddress)
From NashvilleHousing one
Join NashvilleHousing two
	On one.ParcelID = two.ParcelID
	and one.[UniqueID] <> two.[UniqueID]

--------------------------------------------------------------------------

-- Breaking out Address into Individual Colums (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

--SubString Method

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(propertyAddress)) AS Address
From NashvilleHousing


ALter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALter Table NashvilleHousing
Add PropertySplitCity  Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(propertyAddress))

--PARSENAME Method

Select
PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
From NashvilleHousing

ALter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALter Table NashvilleHousing
Add  OwnerSplitCity  Nvarchar(255);

ALter Table NashvilleHousing
Add  OwnerSplitState  Nvarchar(255);

Update NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

Update NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

Update NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

--------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(soldasvacant), Count(soldasvacant)
from NashvilleHousing
Group by soldasvacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

--------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--After varify you can delete, can check if removed from above

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
From NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
