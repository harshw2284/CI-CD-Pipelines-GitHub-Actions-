#!/bin/bash

log_dir=$1
total_lines=$(wc -l < "$log_dir")

check_argument() {

        if [ $# -eq 0 ]
    then
        echo "Usage: $0 <log_file>" >&2
        exit 1
    fi
}

check_file () {
        if [ ! -f "${log_file}" ];then
                echo "File does'nt exist"
                exit 1
        fi
}

Error_count() {
        echo "--- Error Events ---"
        echo "Total error count is $(grep -ci error ${log_dir})"


}

#Defining Variables
critical_line_no=$(grep -ni CRITICAL ${log_dir} | cut -d: -f1)
time=$(awk '{print -n $1,$2}' ${log_dir})
critical_line=$(awk '/CRITICAL/ {print}' ${log_dir})


Critical_count () {
    echo "--- Critical Events ---"

    grep -ni "critical" "$log_dir" | while IFS=: read -r critical_line_no line
    do
        echo "Line $critical_line_no : $line"
    done
}

show_error_line () {
	echo "--- Top 5 Error Messages ---"
	grep "ERROR" ${log_dir} | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
}

Error_count
echo " "
Critical_count
echo " "
show_error_line
echo " "
echo "log report created with name : Log_report-$(date +%Y-%m-%d).txt"

report() {
echo "======================================================="
echo " "
echo "Date of analysis : $(date +%Y-%m-%d)"
echo " "
echo "Log file name :${log_dir}"
echo " "
echo "Total lines processed : ${total_lines}"
echo " "
echo "$(Error_count)"
echo " "
echo "$(show_error_line)"
echo " "
echo "$(Critical_count)"
echo "======================================================="
}
report > Log_report-$(date +%Y-%m-%d).txt
