
oci iam dynamic-group create --name servicemeshlog --description "Dynamic group for cluster logging" --matching-rule "ANY {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq'}"

oci iam policy create --compartment-id 'ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq' --name policymesh --description "Policy to allow service mesh to emit logs" --statements '["ALLOW dynamic-group servicemeshlog TO USE log-content IN compartment kubernetes"]'

oci logging log-group create --compartment-id ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq --display-name redis

oci logging log create --log-group-id ocid1.loggroup.oc1.iad.amaaaaaaihuwreya3xahf27rhgz5kmks3rcraqgso4xt6g5fibvvglgqpsxq --display-name redis-logs --log-type custom

oci logging agent-configuration create --compartment-id ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq --is-enabled true --service-configuration '{
  "configurationType": "LOGGING",
    "destination": {
      "logObjectId": "ocid1.log.oc1.iad.amaaaaaaihuwreyalv5cxksbxi7bodufktqer6zuzeq63y4j6r4hswzjkl3q"
    },
    "sources": [
      {
        "name": "proxylogs",
        "parser": {
          "fieldTimeKey": null,
          "isEstimateCurrentEvent": null,
          "isKeepTimeKey": null,
          "isNullEmptyString": null,
          "messageKey": null,
          "nullValuePattern": null,
          "parserType": "NONE",
          "timeoutInMilliseconds": null,
          "types": null
        },
        "paths": [
          "/var/log/containers/*<app-namespace>*oci-sm-proxy*.log"
        ],
        "source-type": "LOG_TAIL"
      }
    ]
}' --display-name redisLoggingAgent --description "Custom agent config for mesh" --group-association '{"groupList": ["servicemeshlog"]}'


