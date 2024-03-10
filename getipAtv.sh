#!/bin/bash
# address="search=%E5%B9%BF%E8%A5%BF&Submit=+" 
getipurl="http://tonkiang.us/hoteliptv.php"
# getipurl="https://www.foodieguide.com/iptvsearch/hoteliptv.php"
# getvurl="http://tonkiang.us/9dlist2.php?s="
# getvurl="https://www.foodieguide.com/iptvsearch/alllist.php?s=$1"
file_path1=tv/tmp1.txt
file_path2=tv/tmp2.txt
# file_path2=/root/php/tvsource/tmp2.txt
chldir=tv
tvfile=tv/rm.txt
fn=`date +%m%d`

mkdir tv
#获取香港节目
curl -so $file_path2 https://epg.pw/test_channels.m3u
tvgc=`cat $file_path2|grep "EXTINF:"|awk -F '"' '{print $6}'|sed 's/ //g'`
tvgn=`cat $file_path2|grep "EXTINF:"|awk -F '"' '{print $2}'|sed 's/ //g'`
tvgu=`cat $file_path2|grep -v "^#"|grep ":"`
c=""
d=""
echo "香港,#genre#">$tvfile
for i in $(paste -d',' <(echo "$tvgc") <(echo "$tvgn") <(echo "$tvgu")|grep "香港")
do
    b1=`echo $i|awk -F ',' '{print $2}'`
    b2=`echo $i|awk -F ',' '{print $3}'`
    if [ "$c" == "$b1" ];then
        d=$d"#"$b2
        # echo "$d"
    else
        if [ "$c" != "" ];then
            echo $d >>$tvfile
        fi
        c=$b1
        d=$b1","$b2
    fi
done
echo $d >>$tvfile
echo "" >>$tvfile

#获取其他节目
flag=0
curl -so $file_path2 https://raw.githubusercontent.com/ssili126/tv/main/itvlist.txt
# sed -i 's/\?.*//g' $file_path1
for i in `cat $file_path2|sed 's/\?.*//g'`
do
    b1=`echo $i|awk -F ',' '{print $1}'`
    b2=`echo $i|awk -F ',' '{print $2}'`
    if [ "$b1" == "其他频道" ];then
        flag=1
    fi
    if [ $flag -eq 0 ];then
        continue
    fi
    if [ "$c" == "$b1" ];then
        d=$d"#"$b2
        # echo "$d"
    else
        # if [ "$c" != "" ];then
        if [ "$b1" != "其他频道" ];then
            echo $d >>$tvfile
        fi
        c=$b1
        d=$b1","$b2
    fi
done
echo $d >>$tvfile
echo "" >>$tvfile

cat tvtmpl.txt >> $tvfile
city=("%E8%B4%B5%E6%B8%AF" "%E7%8E%89%E6%9E%97")
for cy in "${city[@]}"
do
    address="search=$cy&Submit=+"
    curl -so $file_path2 -X POST -d $address $getipurl
    count1=0
    while [ $count1 -lt 120 ]; do
        if [ -e "$file_path2" ]; then
            break
        else
            count1=$((count1 + 1))
        fi
        sleep 1
    done
    ipAport=`cat $file_path2|grep -v "盗链"|grep 'hotellist'|awk -F "<" '{print $4}'|awk -F ">" '{print $2}'`
    chanl=`cat $file_path2|grep '频道数'|awk -F "<" '{print $3}'|awk -F ">" '{print $2}'`
    status=`cat $file_path2|grep '<div style="color'|awk -F "<" '{print $2}'|awk -F ">" '{print $2}'`
    adr=`cat $file_path2|grep -E '电信|联通|移动|adsl'|sed 's/ //g'`
    undt=-1
    unip="1.1.1.1"
    tldt=-1
    tlip="1.1.1.1"
    for i in `paste -d',' <(echo "$ipAport") <(echo "$chanl") <(echo "$status") <(echo "$adr")`
    do
        # echo $i
        if ! echo $i  | grep -Eq "失效|adsl" ; then
            if echo $i  | grep -q "酒店" ; then
                name=`echo $i|awk -F"," '{print $4}'|sed 's/\\r//g'`
                alive=`echo $i|awk -F"," '{print $3}'|awk -F"活" '{print $2}'|awk -F"天" '{print $1}'|awk '{print int($1)}'`
                ipp=`echo $i|awk -F"," '{print $1}'`
                if [[ $name =~ "联通" ]];then
                    if [[ $alive -gt $undt ]];then
                        unip=$ipp
                        undt=$alive
                    fi
                elif [[ $name =~ "电信" ]];then
                    if [[ $alive -gt $tldt ]];then
                        tlip=$ipp
                        tldt=$alive
                    fi
                else
                    :
                fi
            fi
        fi
    done
    if [ $cy == "%E8%B4%B5%E6%B8%AF" ];then
        if [ $unip != "1.1.1.1" ];then
            sed -i "s/110\.72\.79\.71\:808/$unip/g" $tvfile
        fi
        if [ $tlip != "1.1.1.1" ];then
            sed -i "s/171\.108\.239\.8\:8181/$tlip/g" $tvfile
        fi
    else
        if [ $unip != "1.1.1.1" ];then
            sed -i "s/171\.38\.41\.71\:8181/$unip/g" $tvfile
        fi
        if [ $tlip != "1.1.1.1" ];then
            sed -i "s/180\.142\.87\.159\:8181/$tlip/g" $tvfile
        fi
    fi
    rm $file_path2
done

mkdir cfip
mkdir cfip/cfip
file_path3=cfip
curl -so $file_path3/cfip/tmp.zip https://zip.baipiao.eu.org && unzip $file_path3/cfip/tmp.zip -d $file_path3/cfip
echo -n "" > $file_path3/ip.txt
for i in `ls -l $file_path3/cfip/*8080* |awk -F " " '{print $9}'`
do
  cat $i >> $file_path3/ip.txt
done
rm -rf $file_path3/cfip/*
