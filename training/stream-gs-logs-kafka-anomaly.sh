#!/bin/bash
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo "         ________  __  ___     ___    ________       "     
echo "        /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "        / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "      _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "     /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                           /_/            "
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""
echo " 🚀  IBMAIOPS Inject Anomalous Logs through Kafka - BIG DATA SET"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"



export LOG_TYPE=lags   
export INDEX_TYPE=lags-anomaly
export DATE_FORMAT_LOGS="+%Y-%m-%dT%H:%M:%S.000000+00:00"

cd /ibm-concert-trainingdata

echo "   "
echo "   "

if [[  $VERSION == "" ]]; then
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🔬 Setting Version to default latest"
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    export VERSION=latest
fi


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

export AIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - IBMAIOps:    $AIOPS_NAMESPACE"

echo " "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Initializing..."
echo "   ------------------------------------------------------------------------------------------------------------------------------"

echo "     📥 Get Working Directories"
export WORKING_DIR_LOGS="./training-data/$VERSION/$INDEX_TYPE/"
echo $WORKING_DIR_LOGS

#------------------------------------------------------------------------------------------------------------------------------------
#  Get the cert for kafkacat
#------------------------------------------------------------------------------------------------------------------------------------
echo "     🥇 Getting Kafka Cert"
oc extract secret/kafka-secrets -n $AIOPS_NAMESPACE --keys=ca.crt --confirm| sed 's/^/            /'
echo ""
echo ""


export my_date=$(date "+%Y-%m-%dT")



#------------------------------------------------------------------------------------------------------------------------------------
#  Get Kafkacat executable
#------------------------------------------------------------------------------------------------------------------------------------
echo "     📥  Getting Kafkacat executable"
if [ -x "$(command -v kafkacat)" ]; then
      export KAFKACAT_EXE=kafkacat
else
      if [ -x "$(command -v kcat)" ]; then
            export KAFKACAT_EXE=kcat
      else
            echo "     ❗ ERROR: kafkacat is not installed."
            echo "     ❌ Aborting..."
            exit 1
      fi
fi
echo " "

echo "     🔐 Get Kafka Password"
export KAFKA_SECRET=$(oc get secret -n $AIOPS_NAMESPACE |grep 'aiops-kafka-secret'|awk '{print$1}')
export SASL_USER=$(oc get secret $KAFKA_SECRET -n $AIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export SASL_PASSWORD=$(oc get secret $KAFKA_SECRET -n $AIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $AIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443





echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🔎  Parameters for Incident Simulation for $APP_NAME"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     "
echo "       🗂  Log Topic                   : $KAFKA_TOPIC_LOGS"
echo "       🌏 Kafka Broker URL            : $KAFKA_BROKER"
echo "       🔐 Kafka User                  : $SASL_USER"
echo "       🔐 Kafka Password              : $SASL_PASSWORD"
echo "       🖥️  Kafka Executable            : $KAFKACAT_EXE"
echo "     "
echo "       📝 Log Type                    : $LOG_TYPE"
echo "     "
echo "       📂 Directory for Logs          : $WORKING_DIR_LOGS"
echo "   "
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
echo "     🗄️  Log Files to be loaded"
echo "   ----------------------------------------------------------------------------------------------------------------------------------------"
ls -1 $WORKING_DIR_LOGS | grep "json"| sed 's/^/          /'
echo "     "




echo "   "
echo "      ----------------------------------------------------------------------------------------------------------------------------------------"
echo "       🚀  Inject Log Files"
echo "      ----------------------------------------------------------------------------------------------------------------------------------------"

#------------------------------------------------------------------------------------------------------------------------------------
#  Inject the Data
#------------------------------------------------------------------------------------------------------------------------------------
echo "         -------------------------------------------------------------------------------------------------------------------------------------"
echo "          🌏  Injecting Log Data" 
echo "              Quit with Ctrl-Z"
echo "         -------------------------------------------------------------------------------------------------------------------------------------"
ITERATIONS_COUNT=0
((ITERATIONS_COUNT++))
my_date=$(date "$DATE_FORMAT_LOGS")

while [[ ITERATIONS_COUNT -lt ITERATIONS_MAX ]];
do
    ((ITERATIONS_COUNT++))
    for FILE in $WORKING_DIR_LOGS/*; do 
        if [[ $FILE =~ "json"  ]]; then
            echo "      ----------------------------------------------------------------------------------------------------------------------------------------"
            echo "      ----------------------------------------------------------------------------------------------------------------------------------------"
            echo "           📦  Inject Log File $FILE  - ($ITERATIONS_COUNT/$ITERATIONS_MAX)"
            echo "               $my_date"

            echo "" > /tmp/log_stream.json
            while IFS= read -r line
            do
                export my_date=$(date "$DATE_FORMAT_LOGS")
                echo "$line" | sed -e "s/@MY_TIMESTAMP/$my_date/g" >> /tmp/log_stream.json
                sleep 0.01
            done < "$FILE"
            #cat /tmp/log_stream.json
            ${KAFKACAT_EXE} -v -X security.protocol=SASL_SSL -X ssl.ca.location=./ca.crt -X sasl.mechanisms=SCRAM-SHA-512  -X sasl.username=$SASL_USER -X sasl.password=$SASL_PASSWORD -b $KAFKA_BROKER -P -t $KAFKA_TOPIC_LOGS -l /tmp/log_stream.json
            echo "      ----------------------------------------------------------------------------------------------------------------------------------------"
            sleep 5
        fi
    done
done