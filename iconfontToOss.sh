#!/bin/bash
# 先删除旧文件
rm -rf ./iconfont
rm -rf ./iconfont.zip
# iconfont.cn 的项目下载链接
url="https://www.iconfont.cn/api/project/download.zip?***"
# iconfont.cn cookie
# 下载 iconfont.zip
curl -o iconfont.zip -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36" \
    -b "这里替换为cookie"
	${url}

# 解压 
unzip -o -d iconfont iconfont.zip

# 获取解压后的文件目录
absDir=`pwd`
dirname=`find ${absDir} -name font_*`
cd ${dirname}

# 上传到 oss
host="oss-cn-******.aliyuncs.com"
bucket="me***age"
Id="L***********X"
Key="N********k"
osshost="${bucket}.${host}"
upload()
{
	# 传入参数
	source="${1}/${2}"
	#dest="目录/文件名"
    dest="iconfont/${2}"
	resource="/${bucket}/${dest}"
	
	#contentType=`file -ib ${source} |awk -F ";" '{print $1}'`
	contentType=`file -b --mime-type ${source}`
	dateValue="`TZ=GMT env LANG=en_US.UTF-8 date +'%a, %d %b %Y %H:%M:%S GMT'`"
	stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
	signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${Key} -binary | base64`
	
	url=http://${osshost}/${dest}
	echo "upload ${source} to ${url}"
	echo -e "\
	\nHost: ${osshost} \
	\nDate: ${dateValue} \
	\nContent-Type: ${contentType} \
	\nAuthorization: OSS ${Id}:${signature}"
	
	curl -i -q -X PUT -T "${source}" \
	    -H "Host: ${osshost}" \
	    -H "Date: ${dateValue}" \
	    -H "Content-Type: ${contentType}" \
	    -H "Authorization: OSS ${Id}:${signature}" \
	    ${url}
}
for i in `ls`
do
upload ${dirname} $i
done