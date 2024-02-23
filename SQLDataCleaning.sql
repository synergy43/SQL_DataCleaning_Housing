/*
Cleaning Data in SQL Queries
*/

-------------------------------------
-- Standard Date Format

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


-------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT aN.ParcelID, aN.PropertyAddress, bN.ParcelID, bN.PropertyAddress, ISNULL(aN.PropertyAddress,bN.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing aN
JOIN PortfolioProject.dbo.NashvilleHousing bN
 on aN.ParcelID = bN.ParcelID
 AND aN.[UniqueID ] <> bN.[UniqueID ]
WHERE aN.PropertyAddress IS NULL


UPDATE aN
SET PropertyAddress = ISNULL(aN.PropertyAddress, bN.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing aN
JOIN PortfolioProject.dbo.NashvilleHousing bN
	ON aN.ParcelID =bN.ParcelID
	AND aN.[UniqueID ] <> bN.[UniqueID ]
WHERE aN.PropertyAddress IS NULL


----------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) As Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



----------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing



UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


----------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



------------------------------------------

--Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate