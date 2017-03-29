#!/bin/bash

CARRIER=$1
DEST_S3=$2
LOCK_FILE=/tmp/running_hdfs_to_s3.lock.${CARRIER}
if [ -f ${LOCK_FILE} ]
then
    echo "There is already a moving script running"
    exit
fi
touch ${LOCK_FILE}
SUCCESS=2
export AWS_DEFAULT_REGION=us-east-1
echo "`date "+%Y-%m-%d %H:%M:%S"`: Started ..."
aws cloudwatch put-metric-data --metric-name hdfsToS3.Running --namespace CWMETRIC --unit Count --value 1 --dimensions Carrier=${CARRIER} --timestamp `date -u "+%Y-%m-%dT%H:%M:%S"`
for i in  `hdfs dfs -ls /streaming/${CARRIER}/  | sort -k6,7 | head -n -1 | tail -n -1 | awk '{ print $8 }'`
do
    if [ -z $i ];
    then
       continue
    fi
    SUCCESS=0
    echo "hdfs directory = $i"
    hadoop jar /usr/share/aws/emr/s3-dist-cp/lib/s3-dist-cp.jar --src hdfs:///$i/ --dest "${DEST_S3}" --deleteOnSuccess
    if [ $? -gt 0 ];
    then
	SUCCESS=0
        break
    fi	
    if [ `hdfs dfs -ls -R $i  | grep -v ^d | wc -l` -eq 0 ]
    then
        echo "DELETING DIRECTORY"
        hdfs dfs -rm -r $i
    fi
    SUCCESS=1
done
rm ${LOCK_FILE}
echo "`date "+%Y-%m-%d %H:%M:%S"`: Completed with SUCCESS=${SUCCESS}"
CARRIER=`echo ${CARRIER} | awk '{print toupper($0)}' `
if [ ${SUCCESS} -eq 1 ];
then
  aws cloudwatch put-metric-data --metric-name hdfsToS3.Success --namespace CWMETRIC --unit Count --value 1 --dimensions Carrier=${CARRIER} --timestamp `date -u "+%Y-%m-%dT%H:%M:%S"`
elif [ ${SUCCESS} -eq 0 ];
then
  aws cloudwatch put-metric-data --metric-name hdfsToS3.Failed --namespace CWMETRIC --unit Count --value 1 --dimensions Carrier=${CARRIER} --timestamp `date -u "+%Y-%m-%dT%H:%M:%S"`
fi

