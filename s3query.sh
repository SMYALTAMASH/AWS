#!/usr/bin/bash

noOfBuckets=$(aws s3 ls | wc -l)
count=0
bList=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

echo "---------------------------------------------------------------"

echo "Total number of Buckets: $noOfBuckets"

echo "---------------------------------------------------------------"

for bucket in $bList; do

noOfObjects=0
sizeOfObjects=0

	echo "Bucket Name: $bucket"
	region=$(aws s3api get-bucket-location --bucket $bucket --query "LocationConstraint" --output text)

	if [ "$region" == "None" ]; then
		noOfObjects=( $(aws s3api list-objects --bucket $bucket --output json --query "[length(Contents[])]" --output text) )
		sizeOfObjects=( $(aws s3api list-objects --bucket $bucket --output json --query "[sum(Contents[].Size)]" --output text) )
		bucketCreateTime=$(aws s3api list-buckets --query "Buckets[$count].CreationDate")
		lastChangeDate=$(aws s3 ls $bucket --recursive | sort | tail -n 1 | awk '{print $1}')
		echo "Number Of Objects in Bucket: ${noOfObjects[@]}"
		echo "Total Size Of Objects: ${sizeOfObjects[@]}"
		echo "Bucket Creation Time: $bucketCreateTime"
		echo "Last Access Time: $lastChangeDate"
	else
		noOfObjects=( $(aws s3api list-objects --bucket $bucket --region $region --output json --query "[length(Contents[])]" --output text) )
		sizeOfObjects=( $(aws s3api list-objects --bucket $bucket --region $region --output json --query "[sum(Contents[].Size)]" --output text) )
		bucketCreateTime=$(aws s3api list-buckets --region $region --query "Buckets[$count].CreationDate")
		lastChangeDate=$(aws s3 ls $bucket --recursive --region $region | sort | tail -n 1 | awk '{print $1}')
		echo "Number Of Objects in Bucket: ${noOfObjects[@]}"
		echo "Total Size Of Objects: ${sizeOfObjects[@]}"
		echo "Bucket Creation Time: $bucketCreateTime"
		echo "Last Access Time: $lastChangeDate"
	fi

	echo "---------------------------------------------------------------"

done
