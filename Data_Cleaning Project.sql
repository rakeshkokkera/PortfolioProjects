/*
Cleaning Data in SQL Queries
*/

select * from
Portfolio_Project.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------

---Standardize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from Portfolio_Project.dbo.NashvilleHousing

update Portfolio_Project.dbo.NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table Portfolio_Project.dbo.NashvilleHousing
add SaleDateConverted Date;


-----------------------------------------------------------------------------

-- Populate Property Address data

Select *
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select *
from Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------

-- Breaking out address into individual Columns(Address, City, State)


select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from Portfolio_Project.dbo.NashvilleHousing

--alter table Portfolio_Project.dbo.NashvilleHousing drop column PropertySplitAddress;

ALTER table Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER table Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select * from 
Portfolio_Project.dbo.NashvilleHousing


select OwnerAddress from 
Portfolio_Project.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.') , 3)
,PARSENAME(replace(OwnerAddress,',','.') , 2)
,PARSENAME(replace(OwnerAddress,',','.') , 1)
from Portfolio_Project.dbo.NashvilleHousing

ALTER table Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') , 3)


ALTER table Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') , 2)

ALTER table Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') , 1)

select * from Portfolio_Project.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


With RowNumCTE As(
Select *,
ROW_NUMBER() over(
Partition By ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by
UniqueID
) row_num

From Portfolio_Project.dbo.NashvilleHousing
-- orderby ParcelID

)
SELECT *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


select *
From Portfolio_Project.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns


select * from
Portfolio_Project.dbo.NashvilleHousing

alter table Portfolio_Project.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio_Project.dbo.NashvilleHousing
drop column SaleDate

