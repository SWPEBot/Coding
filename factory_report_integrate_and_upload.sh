#!/bin/sh
# this script is for dome server auto collect and upload factory logs.
# author star.you@quantacn.com
# first release time 20220923

# dome server public key for upload report to google SFTP
PATH_TO_PRIVATE_KEY=/home/sysadmin/pubkey_for_upload_report_to_sftp/quanta_pu4_upload_report_public_key
# upload report to google SFTP account for quanta pu4
PARTNER_UPLOAD_USERNAME="cpfe-quanta@partnerupload.google.com"
# ping vpn network 
VPN_IP="www.google.com"
# get previous day date.
d1=`date -d "1 days ago" +"%Y%m%d"`
# get current time.
currenttime=`date +"%Y%m%d""%H%M%S"`
# logs path 
logpath="/tmp/collect_and_upload_report.log"

compressed_logs() {
  cd /cros_docker/umpire/
  for file_name in *; do
    check_path=/cros_docker/umpire/${file_name}/umpire_data/report
    if [ -d "$check_path" ] && [ "$(ls -A "$check_path")" ]; then
      currenttime=`date +"%Y%m%d""%H%M%S"`
      echo "$currenttime This path is true and not empty!" >> ${logpath}
      cd /cros_docker/umpire/${file_name}/umpire_data/report/
      for logs_folder_name in *; do
        logs_folder_name=`basename $logs_folder_name`
        if expr "${logs_folder_name%}" "<=" "$d1";then
          currenttime=`date +"%Y%m%d""%H%M%S"`
          echo "$currenttime The currently executed folder is $logs_folder_name" >> ${logpath}
          echo "$currenttime Start compressed folder ...." >> ${logpath}
          echo "$currenttime current dome name is ${file_name} and tntercept quanta project model name" >> ${logpath}
          quanta_project_name="${file_name%%_*}" 
          echo "$currenttime This quanta project name is $quanta_project_name" >> ${logpath}
          # If it is a new model 
          # first maintain the google name and quanta name of this model to the following 
          # then login to Google SFTP server and manually create the googlename_report folder
          case ${quanta_project_name} in 
            "0H7")  
              google_name=scout;;
            "GML")  
              google_name=bobba;;
            "0RK")
              google_name=quackingstick;;
            "ZAC")
              google_name=magister;;
            "ZAK")
              google_name=bobba;;
            "ZAN")
              google_name=bobba360;;
            "ZAP")
              google_name=sparky;;
            "ZAQ")
              google_name=sparky360;;
            "ZAR")
              google_name=kindred;;
            "ZAX")
              google_name=magpie;;
            "ZBA")
              google_name=gik;;
            "ZBB")
              google_name=gik360;;
            "ZBC")
              google_name=droid;;
            "ZBD")
              google_name=blorb;;
            "ZBL")
              google_name=ezkinil;;
            "ZBMA")
              google_name=magneto;;
            "ZBM")
              google_name=magma;;
            "ZBN")
              google_name=dewatt;;
            "ZBP")
              google_name=craask;;
            "ZBPA")
              google_name=craaskbowl;;
            "ZBPB")
              google_name=craaskvin;;
            "ZBRA")
              google_name=calus;;
            "ZBR")
              google_name=osiris;;
            "ZBS")
              google_name=volmar;;
            "ZBT")
              google_name=volet;;
            "ZBUB")
              google_name=voxel;;
            "ZBU")
              google_name=volta;;
            "ZBV")
              google_name=zavala;;
            "ZBYA")
              google_name=voema;;
            "ZC5")
              google_name=villager;;
            "ZC8")
              google_name=lazor;;
            "ZC9")
              google_name=limozeen;;
            "ZCAA")
              google_name=magolor;;
            "ZCA")
              google_name=maglia;;
            "ZCE")
              google_name=maglet;;
            "ZCD")
              google_name=maglith;;
            "ZCH")
              google_name=nirwen;;
            "ZDE")
              google_name=juniper;;
            "ZDF")
              google_name=willow;;
            "ZDFB")
              google_name=kenzo;;
            "ZDG")
              google_name=cozmo;;
            "ZDGB")
              google_name=pico;;
            "ZDM")
              google_name=spherion;;
            "ZDN")
              google_name=tomato;;
            "ZSI")
              google_name=kled;;
            "0WEC")
              google_name=faffy;;
            "0WEB")
              google_name=duffy;;
            "0WEA")
              google_name=kaisa;;
            "0H6")
              google_name=karma;;
            "0WJ")
              google_name=jax;;
            "0WNA")
              google_name=endeavour;;
            "0WDB")
              google_name=excelsior;;
            "KU8")
              google_name=atlas;;
            "0WV")
              google_name=kuldax;;
            "ZBW")
              google_name=morthal;;
            "ZBQA")
              google_name=kano;;
            "ZCG")
              google_name=craasneto;;
            "ZCMA")
              google_name=craaskino;;
            "0WVA")
              google_name=kuldax;;
            "0WVB")
              google_name=moxie;;
            "0HA")
              google_name=scout-r;;
            "ZCM")
              google_name=craasula;;
            "0WXA")
              google_name=intrepid;;
            "0WYA")
              google_name=dita;;
            "0WZ")
              google_name=taranza;;
            "ZAZ")
              google_name=rex;;
            "0WX")
              google_name=constitution;;
            "0WY")
              google_name=dexi;;
            "0WYB")
              google_name=deva;;
            "ZCJ")
              google_name=craaskana;;
            "ZBZ")
              google_name=karis;;
            "ZCN")
              google_name=craaswell;;
            "ZCQ")
              google_name=dochi;;
            "ZDH")
              google_name=jubilant;;
            "ZDHA")
              google_name=jubileum;;
            "ZDW")
              google_name=brox;;
            "ZDK")
              google_name=riven;;
            "ZCR")
              google_name=kanix;;
            "ZDKA")
              google_name=rudriks;;
            "ZDKB")
              google_name=rynax;;
            "0W4")
              google_name=dirks;;
            "0WVB")
              google_name=moxie;;
            *)
              echo "$currenttime This quanta project name no match google name define" >> ${logpath}
              exit
              ;;
          esac
          # Use date +%s%N to generate a random string of 10 codes
          random_string=`date +%s%N | md5sum | head -c 10`
          sudo tar -zcvf "$google_name"_"$quanta_project_name"_$logs_folder_name"_"$random_string"_$currenttime".tar.bz2 "$logs_folder_name"
          echo "$currenttime Complete Compressed, start deleting the original file and keep only the compressed file!" >> ${logpath}
          sudo rm -rf "$logs_folder_name"
          echo "$currenttime Complete delete the original file!" >> ${logpath}
        else
          echo "$currenttime This path not need to compressed folder!" >> ${logpath}
        fi
      done
    else
      echo "$currenttime This compressed path is false and is empty!" >> ${logpath}
    fi
  done
}

check_vpn_network_status() {
  currenttime=`date +"%Y%m%d""%H%M%S"`
  ping -c 1 "$VPN_IP"
  if [ $? -eq 0 ]; then
    echo "$currenttime Ping google vpn network succes!" >> ${logpath}
  else 
    echo "$currenttime Ping google vpn network fail!" >> ${logpath}
    exit 1
  fi
}

upload_logs() {
  cd /cros_docker/umpire/
  for dome_name in *; do
    dome_path=/cros_docker/umpire/${dome_name}/umpire_data/report
    # Check if path exists and is not empty
    if [ -d "$dome_path" ] && [ "$(ls -A "$dome_path")" ]; then
      currenttime=`date +"%Y%m%d""%H%M%S"`
      echo "$currenttime This dome path ${dome_name} is true and not empty!" >> ${logpath}
      cd /cros_docker/umpire/${dome_name}/umpire_data/report/
      for logs_file_name in *; do
        logs_file_name=`basename $logs_file_name`
        if expr "$logs_file_name" : '.*\.bz2'; then
          currenttime=`date +"%Y%m%d""%H%M%S"`
          echo "$currenttime The currently executed tar.bz2 file is $logs_file_name" >> ${logpath}
          echo "$currenttime Start upload file to Google SFTP....." >> ${logpath}
          upload_google_name="${logs_file_name%%_*}" 	
	  echo "mkdir ${upload_google_name}_report" | sftp -P 19321 -i "$PATH_TO_PRIVATE_KEY" "$PARTNER_UPLOAD_USERNAME"
	  if [ $? -ne 0 ]; then
	    echo "$currenttime Failed to create directory ${upload_google_name}_report" >> ${logpath}
	    exit 1
	  fi
	  echo "cd ${upload_google_name}_report
	  put \"$logs_file_name\"
	  quit" | sftp -P 19321 -i "$PATH_TO_PRIVATE_KEY" "$PARTNER_UPLOAD_USERNAME"

          if [ $? -eq 0 ]; then
            echo "$currenttime Complete tar.ba2 file $logs_file_name upload" >> ${logpath}
            # check stfp same file name
            echo "cd ${upload_google_name}_report
            ls \"$logs_file_name\"
            quit" | sftp -P 19321 -i "$PATH_TO_PRIVATE_KEY" "$PARTNER_UPLOAD_USERNAME" | grep -q "$logs_file_name"

            if [ $? -eq 0 ]; then
              sudo rm "$logs_file_name"
              echo "$currenttime Complete delete the original tar.bz2 file" >> ${logpath}
            else
              echo "$currenttime Remote file not found on SFTP, skip local delete" >> ${logpath}
            fi
          else
            echo "$currenttime Upload log to Google SFTP fail!" >> ${logpath}
            echo "Upload factory logs to Google SFTP fail!"
            exit 1
          fi
        else
          echo "$currenttime This path no *tar.bz2 type file!!!" >> ${logpath}
          echo "This path no *tar.bz2 type file!!!"
        fi
      done
    else
      echo "$currenttime This upload path is false and is empty!" >> ${logpath}
      echo "This path no factory logs!" 
    fi
   done
}

main() {
  compressed_logs
  check_vpn_network_status
  upload_logs
}
main "$@"
