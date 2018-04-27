#!/bin/bash
echo $PATH
export Here_PATH=/home/WORK/ecens
export rawdata_PATH=${Here_PATH}/rawdata
export PATH=$PATH:${Here_PATH}/bin
echo $PATH
#日期计算
today=`date -d "today"  +%d`
today_mmdd=`date -d "today"  +%m%d`
today_yymmdd=`date -d "today"  +%y%m%d`
today_yyyymmdd=`date -d "today"  +%Y%m%d`
echo 今天是：${today}日${today_yyyymmdd}
yesterday=`date -d "yesterday"  +%d`
yesterday_mmdd=`date -d "yesterday"  +%m%d`
yesterday_yymmdd=`date -d "yesterday"  +%y%m%d`
yesterday_yyyymmdd=`date -d "yesterday"  +%Y%m%d`
echo 昨天是：${yesterday}日${yesterday_yyyymmdd}
thedaybefor=`date -d " -2 day"  +%d`
thedaybefor_mmdd=`date -d " -2 day"  +%m%d`
thedaybefor_yymmdd=`date -d " -2 day"  +%y%m%d`
thedaybefor_yyyymmdd=`date -d " -2 day"  +%Y%m%d`
echo 前天是：${thedaybefor}日${thedaybefor_yyyymmdd}

sc='12'
echo ${sc}
if [ "${sc}" = "18" ] || [ "${sc}" = "12" ]
then
mmdd=${yesterday_mmdd}
yyyymmdd=${yesterday_yyyymmdd}
fi

if [ "${sc}" = "00" ] || [ "${sc}" = "06" ]
then
mmdd=${today_mmdd}
yyyymmdd=${today_yyyymmdd}
fi
echo 模式初始日期：${yyyymmdd} ${mmdd}

cd ${rawdata_PATH}
rm -f ${rawdata_PATH}/*
cp /home/WORK/EC/rawdata/cbar.gs ${rawdata_PATH}
cp /home/WORK/EC/rawdata/rgbset.gs ${rawdata_PATH}
#取当前文件名
current_filename=ECENS_${yyyymmdd}${sc}
rm -f *${thedaybefor_yyyymmdd}${sc}*
rm -f *${yesterday_yyyymmdd}${sc}*
rm -f *${yyyymmdd}${sc}*
echo "current_filename="${current_filename}
rm -f W_NAFP_C_ECMF_*_P_C1D${thedaybefor_mmdd}${sc}00*.bin
rm -f W_NAFP_C_ECMF_*_P_C1D${yesterday_mmdd}${sc}00*.bin
rm -f W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00*.bin

declare -i rmybh
for k in {1..2}
do
let rmybh=rmybh+12
rmyb_yyyymmddhh=`/home/WORK/ecthin/etc/newdate ${thedaybefor_yyyymmdd}${sc} +${rmybh}`
echo "rmyb_yyyymmddhh="${rmyb_yyyymmddhh}
rmyb_mmddhh=${rmyb_yyyymmddhh:4:6}
echo "rmyb_mmddhh="${rmyb_mmddhh}
rm -f *${thedaybefor_yyyymmdd}${sc}_${rmyb_mmddhh}.grib
done 

for k in {1..2}
do
let rmybh=rmybh+12
rmyb_yyyymmddhh=`/home/WORK/ecthin/etc/newdate ${yesterday_yyyymmdd}${sc} +${rmybh}`
echo "rmyb_yyyymmddhh="${rmyb_yyyymmddhh}
rmyb_mmddhh=${rmyb_yyyymmddhh:4:6}
echo "rmyb_mmddhh="${rmyb_mmddhh}
rm -f *${yesterday_yyyymmdd}${sc}_${rmyb_mmddhh}.grib
done 
rm -f ECENS_${yyyymmdd}${sc}_TP_24.grib1
declare k ybh
for k in {1..5}
do
	let ybh=6+${k}*6
	echo "ybh="$ybh
	yb_yyyymmddhh=`/home/WORK/ecthin/etc/newdate ${yyyymmdd}${sc} +${ybh}`
	echo "yb_yyyymmddhh="${yb_yyyymmddhh}
    yb_mmddhh=${yb_yyyymmddhh:4:6}
	echo "yb_mmddhh="${yb_mmddhh}
	echo wget -q -nv wget -q -nv ftp://raw:raw1@10.56.5.13//down/nafp/ecmf_ens/W_NAFP_C_ECMF_*_P_C3E${mmdd}${sc}00${yb_mmddhh}001-ACHN.bin
	wget -q -nv ftp://raw:raw1@10.56.5.13//down/nafp/ecmf_ens/W_NAFP_C_ECMF_*${mmdd}${sc}00${yb_mmddhh}001-ACHN.bin
    ls W_NAFP_C_ECMF_*_P_C3E${mmdd}${sc}00${yb_mmddhh}001-ACHN.bin| while read line
	do
        eval $(echo $line|awk -F"_" '{for ( x = 1; x <= NF; x++ ) { print "arrfold["x"]="$x}}')
        mscs_mmddhh=${arrfold[7]:3:6}
        echo "mscs_mmddhh="${mscs_mmddhh} "current_mmddsc="${yyyymmdd}${sc}
        ybsx_mmddhh=${arrfold[7]:11:6}
        echo "ybsx_mmddhh="${ybsx_mmddhh} "yb_yyyymmddhh="${yb_yyyymmddhh}
		fname=ECENS_${yyyymmdd}${sc}_${ybsx_mmddhh}
		/usr/local/bin/grib_set -r -s packingType=grid_simple $line ${fname}.grib
		wgrib -s ${fname}.grib|wgrib ${fname}.grib -i -grib -o ${fname}.grib1
		# wgrib2 -s ${fname}.grib|wgrib2 ${fname}.grib -grib_out ${fname}.grib2
		# g2ctl.pl -verf ${fname}.grib2 > ${fname}.grib2.ctl
		# gribmap -i ${fname}.grib2.ctl
		wgrib -s ${fname}.grib1|grep ":TP:"|wgrib ${fname}.grib1 -i -grib -append -o ECENS_${yyyymmdd}${sc}_TP_24.grib1
		grib2ctl.pl -verf ECENS_${yyyymmdd}${sc}_TP_24.grib1 > ECENS_${yyyymmdd}${sc}_TP_24.grib1.ctl
		gribmap -i ECENS_${yyyymmdd}${sc}_TP_24.grib1.ctl
		wgrib -s ${fname}.grib1|grep "forecast 0:"|grep ":TP:"|wgrib ${fname}.grib1 -i -grib -append -o ECENS_${yyyymmdd}${sc}_24_6_tp_c0.grib1
		for num in {1..50}
		do
		wgrib -s ${fname}.grib1|grep "forecast ${num}:"|grep ":TP:"|wgrib ${fname}.grib1 -i -grib -append -o ECENS_${yyyymmdd}${sc}_24_6_tp_p${num}.grib1
		done 
	done
	 
	echo wget -q -nv ftp://getdata:getdata@172.18.73.19//cmacastdata/nafp/ecmf/W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin
	wget -q -nv ftp://getdata:getdata@172.18.73.19//cmacastdata/nafp/ecmf/W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin
    ls W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin| while read line
	do
        eval $(echo $line|awk -F"_" '{for ( x = 1; x <= NF; x++ ) { print "arrfold["x"]="$x}}')
        mscs_mmddhh=${arrfold[7]:3:6}
        echo "mscs_mmddhh="${mscs_mmddhh} "current_mmddsc="${yyyymmdd}${sc}
        ybsx_mmddhh=${arrfold[7]:11:6}
        echo "ybsx_mmddhh="${ybsx_mmddhh} "yb_yyyymmddhh="${yb_yyyymmddhh}
		fname=ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}
		/usr/local/bin/grib_set -r -s packingType=grid_simple $line ${fname}.grib
		wgrib -s ${fname}.grib|grep ":TP:"|wgrib ${fname}.grib -i -grib -append -o ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.grib1
		
	done
done

grib2ctl.pl -verf ECENS_${yyyymmdd}${sc}_24_6_tp_c0.grib1 > ECENS_${yyyymmdd}${sc}_24_6_tp_c0.grib1.ctl
gribmap -i ECENS_${yyyymmdd}${sc}_24_6_tp_c0.grib1.ctl
	
for num in {1..50}
do
	grib2ctl.pl -verf ECENS_${yyyymmdd}${sc}_24_6_tp_p${num}.grib1 > ECENS_${yyyymmdd}${sc}_24_6_tp_p${num}.grib1.ctl
	gribmap -i ECENS_${yyyymmdd}${sc}_24_6_tp_p${num}.grib1.ctl
done

grib2ctl.pl -verf ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.grib1 > ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.grib1.ctl
gribmap -i ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.grib1.ctl
cat > ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.gs << EOF
'reinit'
'c'
'open ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.grib1.ctl'
'set display color white'
'set map 4 1 10'
'set mpdset cnworld cnriver shanxi shanxi_q'
'set parea 1 7.7 1 10'
'set lon 108 116'
'set lat 34 43'
'set csmooth on' 
*24小时降水量
j=1
while(j<5)
'set t 'j
'q time'
say j' 'result
in_time1= subwrd(result,3)
in_time_hour= substr(in_time1,1,2)
in_time_day= substr(in_time1,4,2)
in_time_mon= substr(in_time1,6,3)
in_time_year= substr(in_time1,9,4)
year.1=subwrd(in_time_year,1)  
day.1=subwrd(in_time_day,1)  
hour.1=subwrd(in_time_hour,1)
  if(in_time_mon='JAN')
  month.1=01
  endif
  if(in_time_mon='FEB')
  month.1=02
  endif
  if(in_time_mon='MAR')
  month.1=03
  endif
  if(in_time_mon='APR')
  month.1=04
  endif
  if(in_time_mon='MAY')
  month.1=05
  endif
  if(in_time_mon='JUN')
  month.1=06
  endif
  if(in_time_mon='JUL')
  month.1=07
  endif
  if(in_time_mon='AUG')
  month.1=08
  endif
  if(in_time_mon='SEP')
  month.1=09
  endif
  if(in_time_mon='OCT')
  month.1=10
  endif
  if(in_time_mon='NOV')
  month.1=11
  endif
  if(in_time_mon='DEC')
  month.1=12
  endif
say year.1 month.1 day.1 hour.1
'set t 'j+1
'q time'
say j' 'result
in_time1= subwrd(result,3)
in_time_hour= substr(in_time1,1,2)
in_time_day= substr(in_time1,4,2)
in_time_mon= substr(in_time1,6,3)
in_time_year= substr(in_time1,9,4)
year.2=subwrd(in_time_year,1)  
day.2=subwrd(in_time_day,1)  
hour.2=subwrd(in_time_hour,1)
  if(in_time_mon='JAN')
  month.2=01
  endif
  if(in_time_mon='FEB')
  month.2=02
  endif
  if(in_time_mon='MAR')
  month.2=03
  endif
  if(in_time_mon='APR')
  month.2=04
  endif
  if(in_time_mon='MAY')
  month.2=05
  endif
  if(in_time_mon='JUN')
  month.2=06
  endif
  if(in_time_mon='JUL')
  month.2=07
  endif
  if(in_time_mon='AUG')
  month.2=08
  endif
  if(in_time_mon='SEP')
  month.2=09
  endif
  if(in_time_mon='OCT')
  month.2=10
  endif
  if(in_time_mon='NOV')
  month.2=11
  endif
  if(in_time_mon='DEC')
  month.2=12
  endif
say year.2 month.2 day.2 hour.2
'set grads off'
'set grid off'
'set gxout shaded'
'run rgbset.gs'
'set clevs 0 0.5 1 1.5 2 2.5 5 10 20 25 50 80 100'
'set ccols 0 42 43 44 45 46 47 48 49 56 58 59 65 9'
'd TPsfc*1000(t=j+1)-TPsfc*1000(t=j)'
'run cbar.gs'
'set gxout contour'
'set cint 5'
'set clab on'
'd TPsfc*1000(t=j+1)-TPsfc*1000(t=j)'
'draw title   ECthin rain year.1 month.1 day.1 - hour.1 year.2 month.2 day.2 hour.2'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_9_rain_${yyyymmdd}${sc}_${ybsx_mmddhh}.gif gif'
j=j+1
endwhile
'quit'
EOF
grads -pbc "ECTHIN_${yyyymmdd}${sc}_24_6_tp_thin.gs"

 for k in {1..4}
 do
	let ybh=36+${k}*12
	echo "ybh="$ybh
	yb_yyyymmddhh=`/home/WORK/ecthin/etc/newdate ${yyyymmdd}${sc} +${ybh}`
	echo "yb_yyyymmddhh="${yb_yyyymmddhh}
	yb_mmddhh=${yb_yyyymmddhh:4:6}
	echo "yb_mmddhh="${yb_mmddhh}
	echo wget -q -nv ftp://raw:raw1@10.56.5.13//down/nafp/ecmf_ens/W_NAFP_C_ECMF_20150715084850_P_C3E07150000071712001-ACHN.bin
	wget -q -nv ftp://raw:raw1@10.56.5.13//down/nafp/ecmf_ens/W_NAFP_C_ECMF_*_P_C3E${mmdd}${sc}00${yb_mmddhh}001-ACHN.bin
	ls W_NAFP_C_ECMF_*_P_C3E${mmdd}${sc}00${yb_mmddhh}001-ACHN.bin| while read line
	do
		eval $(echo $line|awk -F"_" '{for ( x = 1; x <= NF; x++ ) { print "arrfold["x"]="$x}}')
		mscs_mmddhh=${arrfold[7]:3:6}
		echo "mscs_mmddhh="${mscs_mmddhh} "current_mmddsc="${yyyymmdd}${sc}
		ybsx_mmddhh=${arrfold[7]:11:6}
		echo "ybsx_mmddhh="${ybsx_mmddhh} "yb_yyyymmddhh="${yb_yyyymmddhh}
		fname=ECENS_${yyyymmdd}${sc}_${ybsx_mmddhh}
		/usr/local/bin/grib_set -r -s packingType=grid_simple $line ${fname}.grib
		wgrib -s ${fname}.grib|wgrib ${fname}.grib -i -grib -o ${fname}.grib1
		wgrib2 -s ${fname}.grib -grib_out ${fname}.grib2
		g2ctl.pl -verf ${fname} > ${fname}.grib2.ctl
		gribmap -i ${fname}.grib2.ctl
		
		wgrib -s ${fname}.grib1|grep "forecast 0:"|wgrib ${fname}.grib1 -i -grib -o ${fname}_c0.grib1
		for num in {1..50}
		do
		wgrib -s $fname.grib1|grep "forecast ${num}:"|wgrib $fname.grib1 -i -grib -o ${fname}_p${num}.grib1
		wgrib -s ${fname}_p${num}.grib1|grep ":sfc:"|wgrib ${fname}_p${num}.grib1 -i -grib -o ${fname}_p${num}_sfc.grib1
		grib2ctl.pl -verf ${fname}_p${num}_sfc.grib1 > ${fname}_p${num}_sfc.grib1.ctl
		gribmap -i ${fname}_p${num}_sfc.grib1.ctl
		wgrib -s ${fname}_p${num}.grib1|grep "mb:"|wgrib ${fname}_p${num}.grib1 -i -grib -o ${fname}_p${num}_high.grib1
		grib2ctl.pl -verf ${fname}_p${num}_high.grib1 > ${fname}_p${num}_high.grib1.ctl
		gribmap -i ${fname}_p${num}_high.grib1.ctl
		done 		
	done
	
	# echo wget -q -nv ftp://getdata:getdata@172.18.73.19//cmacastdata/nafp/ecmf/W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin
	# wget -q -nv ftp://getdata:getdata@172.18.73.19//cmacastdata/nafp/ecmf/W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin
    # ls W_NAFP_C_ECMF_*_P_C1D${mmdd}${sc}00${yb_mmddhh}001.bin| while read line
	# do
        # eval $(echo $line|awk -F"_" '{for ( x = 1; x <= NF; x++ ) { print "arrfold["x"]="$x}}')
        # mscs_mmddhh=${arrfold[7]:3:6}
        # echo "mscs_mmddhh="${mscs_mmddhh} "current_mmddsc="${yyyymmdd}${sc}
        # ybsx_mmddhh=${arrfold[7]:11:6}
        # echo "ybsx_mmddhh="${ybsx_mmddhh} "yb_yyyymmddhh="${yb_yyyymmddhh}
		# /usr/local/bin/grib_set -r -s packingType=grid_simple $line ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.grib
		# wgrib ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.grib | grep ":sfc:" | wgrib ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.grib -i -grib -append -o ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc
		# grib2ctl.pl -verf ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc > ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc.ctl
		# gribmap -i ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc.ctl
		
		cat > ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc.gs << EOF
'reinit'
'c'
'open ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc.ctl'
'set display color white'
'set map 4 1 10'
'set mpdset cnworld cnriver shanxi shanxi_q'
'set parea 1 7.7 1 10'
'set lon 108 115'
'set lat 33 42'
*综合图7 Temperature at 2M
'c'
'set grads off'
'set grid off'
'run rgbset.gs'
'set clevs -20 -16 -12 -8 -4 0 4 8 12 16 20 24 28 32'
'set ccols 46 45 44 43 42 41 61 62 63 64 65 66 67 68 69'
'set gxout shaded'
'd no2Tsfc-273.16'
'run cbar.gs'
'set gxout contour'
'set cint 4'
'set clab on'
'd no2Tsfc-273.16'
'draw title  ECthin Temperature at 2M ${ybsx_mmddhh}'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_7_TMP2m_surf_${yyyymmdd}${sc}_${ybsx_mmddhh}.gif gif'
*综合图8 surface Total cloud cover [(0 - 1)]
'c'
'set grads off'
'set grid off'
'set gxout shaded'
'run rgbset.gs'
'set clevs 10 20 30 40 50 60 70 80 90 100'
'set ccols 42 44 46 48 52 53 54 55 56 57 59'
'd TCCsfc*100'
'run cbar.gs'
'set gxout contour'
'set cint 20'
'set clab on'
'd TCCsfc*100'
'draw title  ECthin surface Total cloud cover ${ybsx_mmddhh}'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_8_TCCsfc_surf_${yyyymmdd}${sc}_${ybsx_mmddhh}.gif gif'
*综合图10_surface Skin temperature [K]
'c'
'set grads off'
'set grid off'
'run rgbset.gs'
'set clevs -12 -8 -4 0 4 8 12 16 20 24 28 32'
'set ccols  44 43 42 41 61 62 63 64 65 66 67 68 69'
'set gxout shaded'
'd SKTsfc-273.16'
'run cbar.gs'
'set gxout contour'
'set cint 4'
'set clab on'
'd SKTsfc-273.16'
'draw title  ECthin surface Skin temperature ${ybsx_mmddhh}'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_10_SKTsfc_surf_${yyyymmdd}${sc}_${ybsx_mmddhh}.gif gif'
*综合图12 surface 2 metre dewpoint temperature [K]
'c'
'set grads off'
'set grid off'
'run rgbset.gs'
'set clevs -12 -8 -4 0 4 8 12 16 20 24 28 32'
'set ccols 44 43 42 41 61 62 63 64 65 66 67 68 69'
'set gxout shaded'
'd no2Dsfc-273.16'
'run cbar.gs'
'set gxout contour'
'set cint 4'
'set clab on'
'd no2Dsfc-273.16'
'draw title  ECthin surface 2m dewpoint temperature ${ybsx_mmddhh}'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_12_no2Dsfc_surf_${yyyymmdd}${sc}_${ybsx_mmddhh}.gif gif'
'quit'
EOF
	#	grads -pbc "${current_filename}_${ybsx_mmddhh}.sfc.gs"
		cat > ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}_Rain.gs << EOF
'reinit'
'c'
'open ECTHIN_${yyyymmdd}${sc}_${ybsx_mmddhh}.sfc.ctl'
'set display color white'
'set map 4 1 10'
'set mpdset cnworld cnriver shanxi shanxi_q'
'set parea 1 7.7 1 10'
'set lon 108 116'
'set lat 34 43'
'set csmooth on' 
*24小时降水量
'set grads off'
'set grid off'
'set gxout shaded'
'run rgbset.gs'
'set clevs 0 0.5 1 1.5 2 2.5 5 10 20 25 50 80 100'
'set ccols 0 42 43 44 45 46 47 48 49 56 58 59 65 9'
'd TPsfc*1000'
'run cbar.gs'
'set gxout contour'
'set cint 5'
'set clab on'
'd TPsfc*1000'
'draw title   ECthin rain _${ybsx_mmddhh}'
'draw string 6.0 0.2 ${yyyymmdd}${sc}(CST)'
'printim ECthin_9_rain_${yyyymmdd}${sc}__${ybsx_mmddhh}.gif gif'
'quit'
EOF
	#	grads -pbc "${current_filename}_${ybsx_mmddhh}_Rain.gs"
	#done
 done

ftpsrc='ecens_'${sc}'_gif_put'
cat > ${ftpsrc} << EOF
user  admin admin
bi
prompt
pass
cd /Download/data/
mkdir /Download/data/ecens/${yyyymmdd}
cd /Download/data/ecens/${yyyymmdd}
mput ECthin_1*.gif
mput ECthin_2*.gif
mput ECthin_3*.gif
mput ECthin_4*.gif
mput ECthin_5*.gif
mput ECthin_6*.gif
mput ECthin_7*.gif
mput ECthin_8*.gif
mput ECthin_9*.gif
mput ECthin_10*.gif
mput ECthin_11*.gif
mput ECthin_12*.gif
mput ECthin_13*.gif
bye
EOF
ftp -nv 172.18.73.101 < ${ftpsrc}
find /home/WORK/data/ecens/ecens${sc} -name "*.gif" -exec rm -rf {} \;
test -d /home/WORK/data/ecens/ecens${sc} || mkdir -p /home/WORK/data/ecens/ecens${sc}
find . -name "*.gif" -exec mv {} /home/WORK/data/ecens/ecens${sc} \;
exit