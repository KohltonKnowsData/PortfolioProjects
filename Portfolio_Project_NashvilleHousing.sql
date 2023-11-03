/*

Cleaning Data with SQL Queries

*/

Use DataCleaningProject

Select * 
From DataCleaningProject.dbo.NashvilleHousing

--Standardize Sale Date

Select SaleDateConverted, Convert(date, SaleDate)
From DataCleaningProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

--Populate Property Address data

Select PropertyAddress
From DataCleaningProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing a
Join DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing a
Join DataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select PropertyAddress
From DataCleaningProject.dbo.NashvilleHousing
Where PropertyAddress is null
Order By ParcelID

-- Breaking out Address into individual columns (Street, City, State)

Select PropertyAddress
From DataCleaningProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From DataCleaningProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitStreet NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select PropertyAddress, PropertySplitStreet, PropertySplitCity
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitStreet NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitStreet = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select OwnerAddress, OwnerSplitStreet, OwnerSplitCity, OwnerSplitState
From NashvilleHousing

-- Change Y and N in "Sold as vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'y' then 'Yes'
	   when SoldAsVacant = 'n' then 'No'
	   Else SoldAsVacant
	   END	
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant =
CASE when SoldAsVacant = 'y' then 'Yes'
	   when SoldAsVacant = 'n' then 'No'
	   Else SoldAsVacant
	   END	

-- Remove Duplicates

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From DataCleaningProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Select * 
From DataCleaningProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

Alter Table NashvilleHousing
DROP COLUMN SaleDate








