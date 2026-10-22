#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# LOAD EVENTS VIA REST
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


echo " ------------------------------------------------------------------------------------------------------------------------------"
echo " 🚀 Starting Load (>=5.2.0)"
echo " ------------------------------------------------------------------------------------------------------------------------------"
echo "  "
echo "  "
USERNAME=${USERNAME_FOR_KEY:-cpadmin}          # the user the API key belongs to
TENANT=cfd95b7e-3bc7-4006-a4a8-a73a79c71255


echo "  "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Checking Training Data"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
F="/ibm-concert-trainingdata/training-data/latest/events-rest/events-training-rest-520.json"
echo "      Training file: $(wc -l < "$F" | tr -d ' ') events"


echo "  "
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "    🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
export AIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
echo "       ✅ OK - IBMAIOps:    $AIOPS_NAMESPACE"

oc project $AIOPS_NAMESPACE  >/tmp/demo.log



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔎  Get ZEN Authentication"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
export CONSOLE_ROUTE=$(oc get route -n $AIOPS_NAMESPACE cp-console  -o jsonpath={.spec.host})          
export CPD_ROUTE=$(oc get route -n $AIOPS_NAMESPACE cpd  -o jsonpath={.spec.host})          
export CPADMIN_PWD=$(oc -n $AIOPS_NAMESPACE get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo)
export CPADMIN_USER="cpadmin"
export ACCESS_TOKEN=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=password&username=$CPADMIN_USER&password=$CPADMIN_PWD&scope=openid" https://$CONSOLE_ROUTE/idprovider/v1/auth/identitytoken|jq -r '.access_token')
export ZEN_API_HOST=$(oc get route -n $AIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
export AUTH=$(curl -k -XGET https://$ZEN_API_HOST/v1/preauth/validateAuth \
-H "username: $CPADMIN_USER" \
-H "iam-token: $ACCESS_TOKEN"|jq -r '.accessToken')
echo "       🔐 AUTH : $AUTH"

export ROUTE=$(oc get route -n $AIOPS_NAMESPACE cpd -o jsonpath={.spec.host})
echo $ROUTE
API="https://$ROUTE/aiops/api/v2"
echo "       🌐 API   : $API"

H=(-H "Authorization: Bearer: $AUTH" -H "x-tenant-id: $TENANT" -H "Content-Type: application/json")
code=$(curl -sk -o /dev/null -w "%{http_code}" "${H[@]}" "$API/alerts?limit=1")
[ "$code" = "200" ] || { echo "API test failed (HTTP $code). Check the API key and username."; exit 1; }
echo "       ✅ Connected to $API"


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔎  Definitions"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
# Works on Linux (GNU date) and Mac (BSD date)
days_ago () { date -u --date="-$1 day" +%Y-%m-%d 2>/dev/null || date -u -v-"$1"d +%Y-%m-%d; }

# Close every open alert on the training resources
close_all () {
  echo "    🛠️ Closing Alerts"
  for r in $(jq -r '.resource.name' "$F" | sort -u); do
    q=$(jq -rn --arg f "resource.name = '$r' and state != 'closed'" '$f|@uri')
    #echo "    🛠️ $q"
    curl -sk -o /dev/null -X PATCH "${H[@]}" "$API/alerts?filter=$q" -d '{"state":"closed"}'
  done
}


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Load and Close Alerts Data for the past 85 60 30 7 6 5 4 3 2 1 Days"	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "     🧻  Closing anything already open on the training resources..."	
echo "   ------------------------------------------------------------------------------------------------------------------------------"
close_all; sleep 10
fail=0
for ago in 85 60 30 7 6 5 4 3 2 1; do
  echo " "
  echo "    🛠️ Loading Alerts $ago days ago"
  D=$(days_ago $ago)
  sent=0
  while read -r ev; do
    c=$(curl -sk -o /dev/null -w "%{http_code}" -X POST "${H[@]}" "$API/events" -d "$ev")
    if [[ "$c" == 2* ]]; then sent=$((sent+1)); else fail=$((fail+1)); fi
  done < <(jq -c --arg d "$D" '{sender,resource,type,severity,summary,details,occurrenceTime:($d+(.occurrenceTime[10:]))}' "$F")
  sleep 10; close_all; sleep 10
  echo "    ✅ $D: $sent events sent and closed"
done


echo " "
echo "*****************************************************************************************************************************"
echo " ✅ Data Load DONE"
echo "*****************************************************************************************************************************"
echo " "