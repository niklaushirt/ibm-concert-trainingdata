#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# LOAD EVENTS DIRECTLY INTO CASSANDRA
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ADAPT VALUES
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo " ------------------------------------------------------------------------------------------------------------------------------"
echo " 🚀 Starting Load (>=5.2)"
echo " ------------------------------------------------------------------------------------------------------------------------------"
echo "  "
echo "  "


# Get Namespace from Cluster 
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

export AIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - IBMAIOps:    $AIOPS_NAMESPACE"

oc project $AIOPS_NAMESPACE  >/tmp/demo.log



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔎  Get REST Authentication"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"


export AIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export CONSOLE_ROUTE=$(oc get route -n $AIOPS_NAMESPACE cp-console  -o jsonpath={.spec.host})          
export CPD_ROUTE=$(oc get route -n $AIOPS_NAMESPACE cpd  -o jsonpath={.spec.host})          
export CPADMIN_PWD='{{global_config.global_password}}'
export CPADMIN_USER="demo"
export ACCESS_TOKEN=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=password&username=$CPADMIN_USER&password=$CPADMIN_PWD&scope=openid" https://$CONSOLE_ROUTE/idprovider/v1/auth/identitytoken|jq -r '.access_token')
export ZEN_API_HOST=$(oc get route -n $AIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
export ZEN_TOKEN=$(curl -k -XGET https://$ZEN_API_HOST/v1/preauth/validateAuth \
-H "username: $CPADMIN_USER" \
-H "iam-token: $ACCESS_TOKEN"|jq -r '.accessToken')
echo $ZEN_TOKEN

export ROUTE=$(oc get route -n $AIOPS_NAMESPACE cpd -o jsonpath={.spec.host})




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-1 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-2 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-3 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-4 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "





echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-5 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-6 day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data Today"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest-520.json /tmp/events-training-rest.json
export current_date=$(date --date='-7day' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json

while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}


      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "







echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data 1 Month ago"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest.json /tmp/events-training-rest.json
export current_date=$(date --date='-1 month' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json


while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}

      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data 2 Month ago"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest.json /tmp/events-training-rest.json
export current_date=$(date --date='-2 month' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json


while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}

      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data 3 Month ago"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest.json /tmp/events-training-rest.json
export current_date=$(date --date='-3 month' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json


while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}

      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀 Update Training Data 4 Month ago"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
cp ./training-data/latest/events-rest/events-training-rest.json /tmp/events-training-rest.json
export current_date=$(date --date='-4 month' +'%Y-%m-%d')
echo "      🕰️ For Date: $current_date"
sed -i "s/2026-01-01/$current_date/g" /tmp/events-training-rest.json
head -n 3 /tmp/events-training-rest.json


while IFS= read -r line
do      
      #echo "              line:$"
      line=${line//\"/\\\"}

      export c_string=$(echo "curl -X POST \"https://$ROUTE/aiops/api/v2/events\" --insecure -s -H 'accept: application/json' -H 'x-tenant-id: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' -H \"Authorization: Bearer ${ZEN_TOKEN}\" -H 'Content-Type: application/json'  -d \"${line}\"")
      #echo "       Q:$c_string"
      #echo ""
      export result=$(eval $c_string)
      #export result=$(curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/events" --insecure --silent -X POST -u "${USER_PASS}" -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" -d "${line}")
      echo $result

done < "/tmp/events-training-rest.json"
echo "              ✅ OK"
echo " "




echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"
