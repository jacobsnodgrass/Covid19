------------------------------------------------------------------------------------------------------------------------
--Cleaning Data in SQL

ALTER TABLE "NashvilleHousingData"
ADD SaleDateConverted Date;

UPDATE "NashvilleHousingData"
SET SaleDateConverted = TO_DATE("SaleDate", 'YYYY-MM0DD');

SELECT "PropertyAddress"
FROM "NashvilleHousingData"
WHERE "PropertyAddress" IS NULL;

SELECT *
FROM "NashvilleHousingData"
ORDER BY "ParcelID"


DELETE FROM "NashvilleHousingData"
WHERE "PropertyAddress" IS NULL;

--Breaking Address into Individual Columns

SELECT
    SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") -1) AS Address,
    SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") +1, LENGTH("PropertyAddress")) AS Town

FROM "NashvilleHousingData";

ALTER TABLE "NashvilleHousingData"
ADD "PropertySplitAddress" VARCHAR(255)

ALTER TABLE "NashvilleHousingData"
ADD "PropertySplitCity" VARCHAR(255)

UPDATE "NashvilleHousingData"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") -1)

UPDATE "NashvilleHousingData"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") +1, LENGTH("PropertyAddress"))


SELECT
    SPLIT_PART("OwnerAddress", ',', 1),
    SPLIT_PART("OwnerAddress", ',', 2),
    SPLIT_PART("OwnerAddress", ',', 3)
FROM "NashvilleHousingData";

ALTER TABLE "NashvilleHousingData"
ADD OwnerPropertyAddress VARCHAR(255);

ALTER TABLE "NashvilleHousingData"
ADD OwnerPropertyCity VARCHAR(255);

ALTER TABLE "NashvilleHousingData"
ADD OwnerPropertyState VARCHAR(255);

UPDATE "NashvilleHousingData"
SET OwnerPropertyAddress = SPLIT_PART("OwnerAddress", ',', 1)

UPDATE "NashvilleHousingData"
SET OwnerPropertyCity = SPLIT_PART("OwnerAddress", ',', 2)

UPDATE "NashvilleHousingData"
SET OwnerPropertyState = SPLIT_PART("OwnerAddress", ',', 3)

--Clean up SoldAsVacant

UPDATE "NashvilleHousingData"
SET "SoldAsVacant" = CASE
    WHEN "SoldAsVacant" LIKE 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" LIKE 'N' THEN 'No'
    ELSE "SoldAsVacant"
END

--Remove Duplicates from Data Set
--Identify columns that when compared together are highly unlikey to be different sales.
WITH RowNumCTE AS (SELECT *,
                          ROW_NUMBER() OVER (
                              PARTITION BY "ParcelID",
                                  "PropertyAddress",
                                  "SalePrice",
                                  "SaleDate",
                                  "LegalReference"
                              ORDER BY
                                  "UniqueID "
                              ) row_num
                   FROM "NashvilleHousingData"
                   ORDER BY "ParcelID"
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY "PropertyAddress";

-- Delete Unused Columns
SELECT *
FROM "NashvilleHousingData";

ALTER TABLE "NashvilleHousingData"
DROP COLUMN "OwnerAddress"

ALTER TABLE "NashvilleHousingData"
DROP COLUMN "TaxDistrict"

ALTER TABLE "NashvilleHousingData"
DROP COLUMN "PropertyAddress"

ALTER TABLE "NashvilleHousingData"
DROP COLUMN "SaleDate"
------------------------------------------------------------------------------------------------------------------------