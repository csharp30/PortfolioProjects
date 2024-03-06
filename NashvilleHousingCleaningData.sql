
--Cleaning Data in SQL Queries


Select *
From PortfolioProject.dbo.Nashvillehousing


--Standardize Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
Set SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------

--Populate Property Address data


Select *
From PortfolioProject.dbo.Nashvillehousing
--Where PropertyAddress is null
Order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject.dbo.Nashvillehousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address


From PortfolioProject.dbo.Nashvillehousing


ALTER TABLE Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update Nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *

From PortfolioProject.dbo.Nashvillehousing




Select OwnerAddress

From PortfolioProject.dbo.Nashvillehousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.Nashvillehousing





ALTER TABLE Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2

ALTER TABLE Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update Nashvillehousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.Nashvillehousing



--------------------------------------------------------------------------------------
-- Change Y and N to Yes and No "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From PortfolioProject.dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   End
From PortfolioProject.dbo.Nashvillehousing


Update Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   End


-------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From PortfolioProject.dbo.Nashvillehousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress



--------------------------------------------------------------------------------------------
--Delete Unused Columns


Select *
From PortfolioProject.dbo.Nashvillehousing


ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN SaleDate
