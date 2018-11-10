#!/bin/bash

users=$( aws iam list-users --query 'Users[].UserName' --output text )
#users=( demo-1 demo-2 demo-3 )
listcreds="keys/allKeys.csv"
mkdir -p keys
declare -A keys
echo "Name,Access_key,Creation_Date,Age" > $listcreds
for user in ${users[@]}
do	
	echo "-----------------------------------------------------"
	echo "Processing For user $user"
	count=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[].AccessKeyId" --output text| wc -w)
	if [ $count -eq 2 ]
	then
		for run in 0 1
		do
			key=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[$run].AccessKeyId" --output text )
                        key_date=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[$run].CreateDate" --output text | cut -d "T" -f 1)
			key2_date=$(date '+%Y-%m-%d')
                        key_age=$(date -d  "$key_date" '+%s')
                        key2_age=$(date -d  "$key2_date" '+%s')
			#if [ "$key2_age" -gt "$key_age" ]
			#then
			#	finalAge=$(echo "scale=2; ( $key2_age - $key_age )/(60*60*24)" | bc)
			#else
			#	finalAge=$(echo "scale=2; ( $key_age - $key2_age )/(60*60*24)" | bc)	
			#fi
			finalAge=$(echo "scale=2; ( $key2_age - $key_age )/(60*60*24)" | bc)
			keys[id]=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[$run].AccessKeyId" --output text)
			keys[age]=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[$run].CreateDate" --output text | tr "T" "-" | tr -d "Z" )
			echo "$user,${keys[id]},${keys[age]},$finalAge">> $listcreds
		done 
	else
		key=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[0].AccessKeyId" --output text )
                key_date=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[0].CreateDate" --output text | cut -d "T" -f 1)
                key2_date=$(date '+%Y-%m-%d')
                key_age=$(date -d  "$key_date" '+%s')
                key2_age=$(date -d  "$key2_date" '+%s')
                finalAge=$(echo "scale=2; ( $key2_age - $key_age )/(60*60*24)" | bc)
		keys[id]=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[0].AccessKeyId" --output text)
		keys[age]=$(aws iam list-access-keys --user-name $user --query "AccessKeyMetadata[0].CreateDate" --output text | tr "T" "-" | tr -d "Z" )
		echo "$user,${keys[id]},${keys[age]},$finalAge">> $listcreds
	fi
done
