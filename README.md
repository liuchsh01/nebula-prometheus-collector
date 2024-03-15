# nebula-prometheus-collector

## 脚本背景
因nebula采集接口返回的数据格式不是标准的falcon、prometheus、influx等格式，众多采集插件无法直接采集数据，特此开发以下脚本。

## 脚本功能
将数据格式转为标准的prometheus格式。

## 脚本使用方法
1. 将脚本放到部署了nebula-metad、nebula-storaged的服务器上
2. nebula-storaged需要开启rocksdb监控采集能力：--enable_rocksdb_statistics=true
3. 执行以下脚本
```bash
sh metricCollector.sh http://localhost:19559/stats
sh metricCollector.sh http://localhost:19779/rocksdb_stats
```
