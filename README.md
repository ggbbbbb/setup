# setup
安装工作环境


1.下载

https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-280.0.0-darwin-x86_64.tar.gz?hl=zh_CN




https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-280.0.0-darwin-x86.tar.gz?hl=zh_CN



2.安装

gcloud init

gcloud init --console-only

#防止用web验证

gcloud config list

# 看现在配置

gcloud config configurations list



222.其它工具
#大数据查询#
bq  

#coloud storage命令行#

gsutil    



3.扩展件

gcloud components install beta



gcloud components list



gcloud auth activate-service-account --key-file ./key/ppppproot-bbbbbpage.json



登录:  gcloud auth activate-service-account

运行:
 gsutil ls



gsutil config -f
