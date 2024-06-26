# /bin/bash
# get PR id
pr_id="ALLSYSTEM"

# generate time stamp
current=`date "+%Y-%m-%d %H:%M:%S"`
timeStamp=`date -d "$current" +%s` 
currentTimeStamp=$((timeStamp*1000+10#`date "+%N"`/1000000))

# temporally set to mlu370
card_type="MLU370-S4"

# default repo name
repo_name="mlu-ops"

# repo ci root path
repo_root="~/${repo_name}_ci/"
if [ ! -d $repo_root ];then
    mkdir $repo_root
fi

# repo ci requests path
requests_path="$repo_root/requests"
if [ ! -d $requests_path ];then
    mkdir $requests_path
fi

# gen name of this ci
request_name="${repo_name}_${pr_id}_${currentTimeStamp}_${card_type}"

# gen file and dir for this request
request_root="$repo_root/$request_name/"
sub_logs_path="$request_root/sub_logs/"

if [ ! -d $request_root ];then
    mkdir $request_root
fi

if [ ! -d $sub_logs_path ];then
    mkdir $sub_logs_path
fi

echo "working" > "$request_root/status"
chmod o+w "$request_root/status"

if [ ! -f  "$request_root/log" ];then
	touch "$request_root/log"
fi

chmod o+w "$request_root/log"
  
if [ ! -f "$request_root/log_list" ];then
    touch "$request_root/log_list"
fi

chmod o+w "$request_root/log_list"

# gen request file.
echo "${repo_name},${pr_id},${currentTimeStamp},${card_type}" > "$requests_path/${request_name}"

# start script
python3 .github/ci_script/file_guard.py "$request_root/status" "$request_root/log" &
python3 .github/ci_script/combine_log.py "$request_root/log" "$request_root/log_list" "$request_root/sub_logs" "$request_root/status" &

wait

status=$( head -n +1 ${request_root}/status )

if [ "$status" != "success" ];then
    return_info=$( sed -n 2p ${request_root}/status )
    echo "${return_info}"
    exit -1
else
    return_info=$( sed -n 2p ${request_root}/status )
    echo "${return_info}"
    exit 0
fi
