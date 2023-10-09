#!/data/data/com.termux/files/usr/bin/bash

# Author Bayu Rizky A.M
# Youtube Pejuang Kentang
# price 50k

# framework
source lib/app.sh

# header Std::Main
Namespace: Std::Main
http_proxy=""
https_proxy=""

if grep -o "com.termux" <<< "$(pwd)" &>/dev/null; then true
else {
        cat <<< "[!] Wajib Menggunakan Termux"
        exit
};fi

{
        dpk=("dialog" "curl" "xh" "jq" "figlet" "boxes" "neofetch" "mpv" "screen")
        
        for install_dpk in "${dpk[@]}"; do
                if command -v "$install_dpk" &>/dev/null; then
                        true
                else
                        apt-get install "${install_dpk}" -y &>/dev/null
                fi
        done
}

{ apt-get install ncurses-utils -y &>/dev/null; }
{ apt-get install ossp-uuid -y &>/dev/null; }

# library yang di butuhkan
import.source [io:color.app,io:log.app]
import.source [io:match.app,inquirer:list.app]
import.app ["https://raw.githubusercontent.com/Polygon65/mak_e/main/S/conlig.hs"]

# init
declare -A sig
declare astr=$(tput init)
declare validasi_sniff="${PREFIX}/bin"

# data warna
Wa=(
        [0]=$(__init:color__ ["mode","bold"]; eval color.hitam)
        [1]=$(__init:color__ ["mode","bold"]; eval color.merah)
        [2]=$(__init:color__ ["mode","bold"]; eval color.hijau)
        [3]=$(__init:color__ ["mode","bold"]; eval color.kuning)
        [4]=$(__init:color__ ["mode","bold"]; eval color.biru)
        [5]=$(__init:color__ ["mode","normal"]; eval color.magenta)
        [6]=$(__init:color__ ["mode","bold"]; eval color.cyan)
        [7]=$(__init:color__ ["mode","bold"]; eval color.putih)
        [8]=$(__init:color__ ["mode","reset"])
)

#io.write "$astr"

function animation(){
	local teks="$1"
	local icon="$2"

	frame=("." " .." "  ..." "   ...." "    ....." " ")
	for fru in "${frame[@]}"; do
		tput sc
		printf "$icon ${teks}%-10s" "$fru"
		tput rc
		sleep 0.20
	done
}

#while true; do animation "load" "[=]"; done

function dl(){
        local url="$1"; local uuid=$(uuid|tr -d "-")
        local file="$2"

        curl -sL "https://ytpp3.com/newp" --insecure \
                -H "Accept: application/json" \
                -H "Accept-Language: en-US,en;q=0.9,id;q=0.8" \
                -H "Cache-Control: no-cache" \
                -H "Content-Type: application/x-www-form-urlencoded" \
                -H "Origin: https://ytmp3.cc" \
                -H "Pragma: no-cache" \
                -H "Referer: https://ytmp3.cc/" \
                -H "Sec-Ch-Ua-Mobile: ?0" \
                -H 'Sec-Ch-Ua-Platform: "Windows"' \
                -H "Sec-Fetch-Dest: empty" \
                -H "Sec-Fetch-Mode: cors" \
                -H "Sec-Fetch-Site: cross-site" \
                -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36" \
                -H "Uuid: $uuid" --data-raw "u=$url&c=ID"|jq -r .data.mp4

        
}

#dl "https://www.youtube.com/watch?v=2jzxIOCYzEM&list=TLPQMDgxMDIwMjM8cseOEBhuFA&index=3" 
#exit

function dl2(){
        local url="$1"

        local req=$(curl -sL --insecure "$url" --compressed|grep -Po '(?<=ytInitialPlayerResponse\s=\s)(.*?)(?=;(?:var\smeta|<\/script>))')
        # cek status
        if (test $(echo "$req"|jq -r .playabilityStatus.status) == "OK"); then
                #echo p
                data[0]=$(echo "$req"|jq -r .videoDetails)
                data[1]=$(echo "${data[0]}"|jq -r .videoId)
                data[2]=$(echo "${data[0]}"|jq -r .title)
                data[3]=$(echo "${data[0]}"|jq -r .viewCount)
                data[4]=$(echo "${data[0]}"|jq -r .author)

                #echo "${data[0]}"

                # download mode
                dl_set[0]=$(echo "$req"|jq -r .streamingData)
                while true; do animation "Mencari Resolusi" "[?]"; done &
                sig1=$!
                let short_resolusi=0
                mp4_c=0
                mp3_c=0
                while true; do
                        res=$(echo "${dl_set[0]}"|jq -r ."formats[$short_resolusi]")
                        type=$(echo "${res}"|jq -r .mimeType|grep -Eo "mp[3-4]"|head -1)
                        if test "$type" == "mp3"; then {
                                mp3[$mp3_c]="$short_resolusi"
                                ((mp3_c++))
                        }
                        elif test "$type" == "mp4"; then {
                                mp4[$mp4_c]="$short_resolusi"
                                mp4_fps[$mp4_c]=$(echo "${dl_set[0]}"|jq -r .formats[${mp4[$mp4_c]}].fps)
                                mp4_res[$mp4_c]="${mp4_c}. $(echo "${dl_set[0]}"|jq -r .formats[${mp4[$mp4_c]}].qualityLabel) (fps: ${mp4_fps[$mp4_c]})"
                                mp4_url[$mp4_c]="$(echo "${dl_set[0]}"|jq -r .formats[${mp4[$mp4_c]}].url)"
                                ((mp4_c++))
                        }
                        else { break; }; fi
                        
                        let short_resolusi++
                        #break
                done
                sleep 9
                #echo "${dl_set[0]}"|jq -r .formats
                #echo "3:[${mp3[@]}],4:[${mp4[@]}]"
                #echo "4: [${mp4_res[@]}] & fps: $mp4_fps"
                kill "$sig1" 2>/dev/null 1>/dev/null
                tput ed

                if ! (test "$?" == 0); then
                        echo "[!] Connection Error"
                        echo "[+] Failed 0xfffffff"
                        exit
                fi
                # part 2
        fi
}

#dl2 "https://youtu.be/9kBCyc-qsFA?si=5m8_86dmfLPl2DH"
#dl2 "https://youtube.com/shorts/XpbxqMg0pzQ?si=WWmx_zIbVHTpwIin"

function main(){
ctr(){
        rm -rf "$dl_filename" >/dev/null 2>/dev/null
        tput ed cnorm
        echo
        kill 0
        exit
}

trap "ctr" EXIT

        #trap "break 2>/dev/null 1>/dev/null; kill ${sig5} 2>/dev/null 1>/dev/
        figlet -f slant "YT-DL"
        echo
        sleep 0.1
        echo "-----------------------------------"
        sleep 0.1
        echo "[+] Author : Pejuang Kentang"
        sleep 0.1
        echo "[+] Yutub  : Pejuang kentang termux"
        sleep 0.1
        echo "[+] Github : Bayu12345677"
        sleep 0.1
        echo "------------------------------------"
        sleep 0.1
        echo "-           Versi 0.01             -"
        echo
        echo "[!] Exit ctrl + c"
        echo
        read -p "Youtube (Url) -> " urls; echo

        if { test -z "$urls"; } || ! { echo "$urls" | grep -Eo "(http|https)://" &>/dev/null; }; then
                echo "[!] Url Tidak Valid"
                echo
                read -p "enter"
                clear
                tput cnorm
                main
        fi; tput civis

        dl2 "$urls"
        echo "[->] videoID    : ${data[1]}"
        echo "[->] title      : ${data[2]}"
        echo "[->] viewCount  : $(if test "${data[3]}" == "null"; then printf "shorts video"; else printf "${data[3]}"; fi)"
        echo "[->] author     : ${data[4]}"
        echo
        list.input ["resolusi",mp4_res,get_input]
        inputs=$(echo "$get_input"|grep -Eo "[0-9]\."|tr -d ".")
        tput cnorm
        read -p "(?) nama file -> " namefile
        tput civis
        
        sizee=$(curl -sL "${mp4_url[$inputs]}" --insecure -I|grep "Content-Length: "|cut -d " " -f 2|awk '{printf "%d%s\n", $1 >= 1000000 ? $1 / 1000000 : $1 >= 1000 ? $1 / 1000 : $1, $1 >= 1000000 ? "M" : $1 >= 1000 ? "k" : ""}'|tr -d "\n")
        for dds in {1..4}; do
                Sizee=$(curl -sL "${mp4_url[$inputs]}" --insecure -I|grep "Content-Length: "|grep -o "[0-9]*"|tr -d "\n"|sed 's/00//')
        done
        #Sizee=$(echo "$Sizee"|grep -o "[0-9]"|sort|sed 's/0/1/'|tr -d "\n")
        if Sozee=$((Sizee / 1024)) 2>/dev/null; then # konvert ke kilobyte mek
                true
        else
                echo
                echo "[!] Connections Error"
                echo "[?] Slow speed"
                tput cnorm ed
                exit
        fi
        
        namefile=$(echo "$namefile"|sed 's/\.mp4//g')
        if test -z "$namefile"; then namefile="${RANDOM}_${RANDOM}"; fi
        mkdir /sdcard/Yt-DLv2 2>/dev/null 1>/dev/null
        if (ls /sdcard/Yt-DLv2|grep -o "${namefile}.mp4" &>/dev/null); then namefile="${namefile}_${RANDOM}"; fi

        dl_filename="${namefile}.mp4"
        echo
        if ! (curl -sL "${mp4_url[$inputs]}" --insecure -I &>/dev/null); then
                new="https://ytpp3.com$(dl "$urls")"

                curl -L "${new}" --insecure -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36" \
                -H "referer: https://ytmp3.cc/" \
                -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" --insecure --compressed -o "/sdcard/Yt-DLv2/${dl_filename}" --http1.1 \
                -H "Accept-Encoding: gzip, deflate, br"
                if ! test "$?" == "0"; then
                        tput cnorm
                        echo "[%] Download Fail"
                        echo "[!] Forbiden Connections"
                        exit
                else
                        tput cnorm
                        echo "[>] Download Sukses"
                        echo "[?] Save video in /sdcard/Yt-DLv2/$dl_filename"
                        exit
                fi
        fi
        touch /sdcard/Yt-DLv2/$dl_filename 2>/dev/null 1>/dev/null
        (curl -sL "${mp4_url[$inputs]}" --insecure --compressed -o "/sdcard/Yt-DLv2/${dl_filename}" 2>/dev/null 1>/dev/null &) &
        curl_pid=$!
        #echo "[->] size video : ${sizee}"
        #while true; do animation "Downloading [${data[1]}]" "[=]";done &
        #sig5=$!
        framess=("/" "_" "\\" "|")
        let runframes=0
        while true;do
                #dl_pr=$(p_cok=$(cat "/sdcard/Yt-DLv2/${dl_filename}" 2>/dev/null|wc -c|cut -d " " -f 1 ); if ! test -z "$p_cok";then { cat "/sdcard/Yt-DLv2/${dl_filename}"|wc -c |cut -d " " -f 1; } || { true; };else echo 0;fi)
                dl_pross=$(du -k "/sdcard/Yt-DLv2/${dl_filename}" 2>/dev/null|cut -f 1)
                #pro=$(($dl_pr * 100 / $Sizee)) || { true; 
                #echo "$dl_pr * 100 / $Sizee"
                pro=$(echo "scale=2; ${dl_pross} / $Sozee * 100"|bc|cut -d "." -f 1)
                #echo "${dl_pross} * 100 / $Sozee"
                #echo ${mp4_url[$inputs]}
                #echo $pro
                #sleep 99
                bar_pr="["
                for ((i=0; i<pro; i+=2)); do
                        bar_pr+="="
                done
                for ((i=pro; i<100; i+=2)); do
                        bar_pr+=" "
                done
                bar_pr+="]"

                # kaki gua
                tput sc
                printf "[%-1s] Download (Size: ${sizee}) %s %d%% " "${framess[$runframes]}" "$bar_pr" "$pro" 2>/dev/null
                tput rc
                sleep 01

        #if (curl -sL "${mp4_url[$inputs]}" --insecure --compressed -o "/sdcard/Yt-DLv2/${dl_filename}" 2>/dev/null 1>/dev/null); then
        if ! (curl -sL "${mp4_url[$inputs]}" --insecure -I > /dev/null 2>&1); then
                kill "$curl_pid" >/dev/null 2>&1
                tput ed cnorm
                echo "[%] Download Fail"
                echo "[!] Forbiden Connections"
                break
        fi

        if ((pro == 100)); then
                kill "$curl_pid" 2>/dev/null 1>/dev/null
                tput ed ed cnorm
                echo
                echo "[%] Download Sukses"
                echo "[+] save into location -> /sdcard/Yt-DLv2"
                break
        fi

        if ((runframes > 2)); then
                runframes=0
        fi
        
        let runframes++
        done

        wait "$curl_pid" 2>/dev/null 1>/dev/null
        
#                kill "$sig5" 2>/dev/null 1>/dev/null
#                tput ed
#                echo "[%] Download Fail"
#                echo "[!] Forbiden Connections"
#        fi
}

ctr(){
        rm -rf "$dl_filename" >/dev/null 2>/dev/null
        tput ed cnorm
        echo
        kill 0
        exit
}

trap "ctr" EXIT INT

clear
main
#dl ""
