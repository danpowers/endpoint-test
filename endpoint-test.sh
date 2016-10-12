#!/bin/bash
EP_SRC_NAME="go#ep1"
EP_SRC_PATH="/~/"
EP_DST_NAME="go#ep2"
EP_DST_PATH="/~/"

TRANSFER_TOKEN="$(globus config show transfer_token)"
AUTH_TOKEN="$(globus config show auth_token)"

if [ "$TRANSFER_TOKEN" = "transfer_token not set" -o "$AUTH_TOKEN" = "auth_token not set" ]
then
 echo "Globus CLI not properly configured."
 echo "Please generate config with:"
 echo "globus login"
 exit
fi

function gen_sub_id() {
 local __sub_id_var="$1"
 local sub_id=$(globus transfer task generate-submission-id)
 eval $__sub_id_var="'$sub_id'"
}

function submit_transfer() {
 local sub_id=$1
 local src_ep="$2"
 local src_path="$3"
 local dst_ep="$4"
 local dst_path="$5"
 local __result_var="$6"
 local result=$(globus transfer async-transfer --format json --submission-id $sub_id --source-endpoint $src_ep --source-path $src_path --dest-endpoint $dst_ep --dest-path $dst_path --recursive --sync-level checksum)
 eval $__result_var="'$result'"
}

function get_task_id_from_submit_result() {
 local submit_result="$1"
 local __task_id_var="$2"
 local task_id=$(echo "$submit_result" | grep "\"task_id\":" | cut -d "\"" -f4)
 eval $__task_id_var="'$task_id'"
}

function get_task_status() {
 local task_id="$1"
 local __task_status_var="$2"
 local task_result=$(globus transfer task show --task-id $TASK_ID)
 local task_status=$(echo "$task_result" | grep "\"status\":" | cut -d"\"" -f4)
 eval $__task_status_var="'$task_status'"
}

gen_sub_id SUBMISSION_ID

submit_transfer "$SUBMISSION_ID" "$EP_SRC_NAME" "$EP_SRC_PATH" "$EP_DST_NAME" "$EP_DST_PATH" SUBMIT_RESULT

get_task_id_from_submit_result "$SUBMIT_RESULT" TASK_ID

globus transfer task wait --heartbeat --polling-interval 10 --timeout 600 --task-id $TASK_ID

get_task_status "$TASK_ID" TASK_STATUS

if [ "$TASK_STATUS" != "SUCCEEDED" ]
then
 echo "Task did not complete successfully:"
 echo status = "$TASK_STATUS"
 exit 1
fi

echo Test job completed successfully.
