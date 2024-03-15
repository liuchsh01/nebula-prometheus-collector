#!/bin/bash

# 检查是否提供了 URL 参数
if [ $# -ne 1 ]; then
    echo "#Usage: $0 <INTERFACE_URL>"
    echo "collect_result 0"
    exit 1
fi

# 第一个参数是接口的 URL
INTERFACE_URL=$1

# 使用 curl 获取接口数据
RESPONSE=$(curl -s "$INTERFACE_URL")

# 检查 curl 命令是否成功执行
if [ $? -ne 0 ]; then
    echo "#Error: Failed to fetch data from $INTERFACE_URL"
    echo "collect_result -1"
    exit 1
fi

# 使用 tr 命令替换掉换行符为 '#'
RESPONSE=$(echo "$RESPONSE" | tr '\n' '#')

# 将输入字符串按 # 分隔成数组
IFS='#' read -ra METRICS <<< "$RESPONSE"

# 遍历数组中的每个指标项
for METRIC in "${METRICS[@]}"; do
    # 按等号 = 分隔指标项，获取 metricName 和 metricValue
    IFS='=' read -ra PARTS <<< "$METRIC"
    METRIC_NAME="${PARTS[0]}"
    METRIC_VALUE="${PARTS[1]}"

    # 将 metricName 按点 . 分隔成数组
    IFS='.' read -ra NAMES <<< "$METRIC_NAME"

    NAME=${NAMES[0]}
    MEASURE_TAG=""
    DURATION_TAG=""

    # 数组的长度
    NAMES_LENGTH=${#NAMES[@]}
    
    # 从数组的第二个元素（索引为 1）开始遍历
    for (( i=1; i<$NAMES_LENGTH; i++ )); do
        NAME_PART=${NAMES[$i]}

        # 生成measure tag
        if [[ $NAME_PART =~ ^(min|max|avg|p[0-9]+)$ ]]; then
            MEASURE_TAG=$NAME_PART

        # 生成duration tag
        elif [[ $NAME_PART =~ ^[0-9]+$ ]]; then
            DURATION_TAG=$NAME_PART

        else
            NAME="${NAME}_${NAME_PART}"
        fi
    done

    METRIC_LINE=${NAME}
    if [ -n "$MEASURE_TAG" ] || [ -n "$DURATION_TAG" ]; then
        METRIC_LINE=${METRIC_LINE}'{'
    fi
    if [ -n "$MEASURE_TAG" ]; then
        METRIC_LINE=${METRIC_LINE}'measure="'${MEASURE_TAG}'"'
    fi
    if [ -n "$MEASURE_TAG" ] && [ -n "$DURATION_TAG" ]; then
        METRIC_LINE=${METRIC_LINE}','
    fi
    if [ -n "$DURATION_TAG" ]; then
        METRIC_LINE=${METRIC_LINE}'duration="'${DURATION_TAG}'"'
    fi
    if [ -n "$MEASURE_TAG" ] || [ -n "$DURATION_TAG" ]; then
        METRIC_LINE=${METRIC_LINE}'}'
    fi
    METRIC_LINE=${METRIC_LINE}' '$METRIC_VALUE

    # 输出处理后的指标项
    echo "$METRIC_LINE"
done
echo "collect_result 1"
