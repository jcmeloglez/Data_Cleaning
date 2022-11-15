#cleaning data in SQL MYSQL#

SELECT * 
FROM projects.nashville_housing;


#Populate Property Address data#
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From projects.nashville_housing a
JOIN projects.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null ;


Update projects.nashville_housing a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From projects.nashville_housing a
JOIN projects.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null

#Breaking out Address into Individual Columns (Address, City, State)#

SELECT substring(PropertyAddress,1,locate(';', PropertyAddress)-1) AS PropertySplitAddress, 
substring(PropertyAddress,locate(';', PropertyAddress)+1)  AS PropertySplitCity
FROM projects.nashville_housing ;

ALTER TABLE projects.nashville_housing
Add PropertySplitAddress Nvarchar(255) AFTER LandUse ;

SET sql_safe_updates=0;

Update projects.nashville_housing
SET PropertySplitAddress = substring(PropertyAddress,1,locate(';', PropertyAddress)-1)
WHERE PropertySplitAddress is NULL ;

ALTER TABLE projects.nashville_housing
Add PropertySplitCity Nvarchar(255) AFTER PropertySplitAddress ;

Update projects.nashville_housing
SET PropertySplitCity = substring(PropertyAddress,locate(';', PropertyAddress)+1)
WHERE PropertySplitCity is NULL ;

#Other way to do it
SELECT substring_index(OwnerAddress,";",1)AS OwnerSplitAddress,
substring_index(OwnerAddress,";",-1) AS OwnerSplitState,
substring_index(substring_index(OwnerAddress,";",-2),";",1) AS OwnerSplitCity
FROM projects.nashville_housing;

ALTER TABLE projects.nashville_housing
Add OwnerSplitAddress Nvarchar(255) AFTER OwnerName ;

Update projects.nashville_housing
SET OwnerSplitAddress = substring_index(OwnerAddress,";",1);

ALTER TABLE projects.nashville_housing
Add OwnerSplitCity Nvarchar(255) AFTER OwnerSplitAddress ;

Update projects.nashville_housing
SET OwnerSplitCity = substring_index(substring_index(OwnerAddress,";",-2),";",1) ;

ALTER TABLE projects.nashville_housing
Add OwnerSplitState Nvarchar(255) AFTER OwnerSplitCity ;

Update projects.nashville_housing
SET OwnerSplitState = substring_index(OwnerAddress,";",-1) ;

# Change Y and N to Yes and No in "Sold as Vacant" field #


SELECT  DISTINCT (SoldAsVacant),  Count(SoldAsVacant)
FROM projects.nashville_housing
Group by SoldAsVacant
order by 2 ;

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = "Y" THEN "Yes"
WHEN SoldAsVacant = "N" THEN "No"
ELSE SoldAsVacant
END
FROM projects.nashville_housing;

Update projects.nashville_housing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = "Y" THEN "Yes"
WHEN SoldAsVacant = "N" THEN "No"
ELSE SoldAsVacant
END;


 #Delete Unused Columns#

ALTER TABLE projects.nashville_housing
DROP COLUMN PropertyAddress,OwnerAddress;