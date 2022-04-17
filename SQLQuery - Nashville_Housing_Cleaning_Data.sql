-- Data from https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

SELECT * 
FROM PortfolioProject..NashvilleHousing;



--Standardize Date Format



SELECT SaleDate
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);
--This didn't seem to work

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT SaleDateConverted 
FROM PortfolioProject..NashvilleHousing;
--Worked!



--Populate property address data



SELECT * 
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null;
ORDER BY ParcelID;

--Use self JOIN to see which property address isn't populated and solve that

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is Null;

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is Null;



--Breaking address into individual columns Address, City, State



SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing;

--Take address before the comma (-1 and +1 to exclude the comma)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertyPlitCity VARCHAR(225);

UPDATE NashvilleHousing
SET PropertyPlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--Now the address can be used more easily separated out

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

--Different, easier, way to break address into columns

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT * 
FROM PortfolioProject..NashvilleHousing;



--Change Y and N to Yes and No in 'Sold as Vacant' column



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant;

--Use CASE statement to change the values

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'y' THEN 'Yes'	
	 WHEN SoldAsVacant = 'n' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'	
	 WHEN SoldAsVacant = 'n' THEN 'No'
	 ELSE SoldAsVacant
	 END



--Remove Duplicates



WITH Row_NumCTE AS (
SELECT *, ROW_NUMBER() OVER(
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM Row_NumCTE
WHERE row_num >1;

SELECT * 
FROM PortfolioProject..NashvilleHousing;



--Delete unused Columns in table



SELECT * 
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate;