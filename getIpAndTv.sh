#!/bin/bash
geadr(){
    case $# in
	2)
	    n=$2
	;;
	*)
		n="未名"
	;;
	esac
	  
	# url="http://tonkiang.us/9dlist2.php?s=$1&c=%E5%8C%97%E4%BA%AC"
	url="http://tonkiang.us/9dlist2.php?s=$1&c=false"
	# url="https://www.foodieguide.com/iptvsearch/alllist.php?s=$1"
	# url= $getvurl$1
	# echo $file_path
	# exit
	# echo $url
	curl -so $file_path1 $url
	count2=0
	while [ $count2 -lt 120 ]; do
		if [ -e "$file_path1" ]; then
			break
		else
			count2=$((count2 + 1))
		fi
		sleep 1
	done
	if grep -q "暂时失效" $file_path1; then
		return 5
	fi
    # echo "99999999999999"
	result1=`cat $file_path1|grep "float: left"|awk -F ">" '{print $2}'|awk -F "<" '{print $1}'`
	result2=`cat $file_path1|grep 'copyto("'|awk -F '"' '{print $8}'`
	combined_result=$(paste -d',' <(echo "$result1") <(echo "$result2"))
	echo "$n,#genre#" >> $tvfile
	# for i in `paste -d',' <(echo "$result1") <(echo "$result2")`
	# do
		# echo $i
	# done
	# echo ""
	combined_result=$(paste -d',' <(echo "$result1") <(echo "$result2"))
	echo "$combined_result" >> $tvfile
	echo "" >> $tvfile

	rm -f $file_path1
}

address="search=%E5%B9%BF%E8%A5%BF&Submit=+" 
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
		    echo $d >>$$tvfile
		fi
	    c=$b1
		d=$b1","$b2
	fi
done
echo $d >>$tvfile
echo "" >>$tvfile

#获取酒店源央视及卫视
case $# in
0)
	t=""
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
	for i in `paste -d',' <(echo "$ipAport") <(echo "$chanl") <(echo "$status") <(echo "$adr")`
    do
        # echo $i
		if ! echo $i  | grep -q "失效" ; then
		    if echo $i  | grep -q "酒店" ; then
			    
				# name=`echo $i|awk -F"," '{print $4}'|tr -d '\r'`
				name=`echo $i|awk -F"," '{print $4}'|sed 's/\\r//g'`
				# if [ "$t" == "$name" ];then
                if [[ $t =~ $name ]];then
				    continue
				else
				    # t=$t$name
					ipp=`echo $i|awk -F"," '{print $1}'`
					geadr $ipp $name
					if [ $? -eq 0 ];then
					    t=$t$name
					fi
					# echo "$ipp,$name"
				fi
			fi
		fi
    done
	rm $file_path2
;;
1)
	geadr $1
;;
*)
    echo "输入有误，请重新输入......"
    exit
;;
esac
# cat /root/php/tvsource/local.txt $hk $ot $chldir/$fn.txt > /root/php/tvsource/tv.txt

mkdir cfip/cfip
file_path3=cfip
curl -so $file_path3/cfip/tmp.zip https://zip.baipiao.eu.org && unzip $file_path3/cfip/tmp.zip -d $file_path3/cfip
echo -n "" > $file_path3/ip.txt
for i in `ls -l $file_path3/cfip/*8080* |awk -F " " '{print $9}'`
do
  cat $i >> $file_path3/ip.txt
done
for i in `ls -l $file_path3/cfip/*-443* |awk -F " " '{print $9}'`
do
  cat $i >> $file_path3/ip.txt
done

rm -rf $file_path3/cfip/*
