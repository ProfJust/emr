#!/usr/bin/env bash
if [ -z "$BASH" ] ; then
   bash  $0
   exit
fi



my_name=$0


function setup_environment {
  bf=""
  n=""
  ORGANISATION="Westfaelische Hochschule Gelsenkirchen Recklinghausen Bocholt"
  URL="account.w-hs.de"
  SUPPORT="support@w-hs.de"
if [ ! -z "$DISPLAY" ] ; then
  if which zenity 1>/dev/null 2>&1 ; then
    ZENITY=`which zenity`
  elif which kdialog 1>/dev/null 2>&1 ; then
    KDIALOG=`which kdialog`
  else
    if tty > /dev/null 2>&1 ; then
      if  echo $TERM | grep -E -q "xterm|gnome-terminal|lxterminal"  ; then
        bf="[1m";
        n="[0m";
      fi
    else
      find_xterm
      if [ -n "$XT" ] ; then
        $XT -e $my_name
      fi
    fi
  fi
fi
}

function split_line {
echo $1 | awk  -F '\\\\n' 'END {  for(i=1; i <= NF; i++) print $i }'
}

function find_xterm {
terms="xterm aterm wterm lxterminal rxvt gnome-terminal konsole"
for t in $terms
do
  if which $t > /dev/null 2>&1 ; then
  XT=$t
  break
  fi
done
}


function ask {
     T="DFN eduroam CAT"
#  if ! [ -z "$3" ] ; then
#     T="$T: $3"
#  fi
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "${1}\n${2}?" --title "$T" ; then
       return 0
     else
       return 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     text=`echo "${1}" | fmt -w60`
     if $ZENITY --no-wrap --question --text="${text}\n${2}?" --title="$T" 2>/dev/null ; then
       return 0
     else
       return 1
     fi
  fi

  yes=Y
  no=N
  yes1=`echo $yes | awk '{ print toupper($0) }'`
  no1=`echo $no | awk '{ print toupper($0) }'`

  if [ $3 == "0" ]; then
    def=$yes
  else
    def=$no
  fi

  echo "";
  while true
  do
  split_line "$1"
  read -p "${bf}$2 ${yes}/${no}? [${def}]:$n " answer
  if [ -z "$answer" ] ; then
    answer=${def}
  fi
  answer=`echo $answer | awk '{ print toupper($0) }'`
  case "$answer" in
    ${yes1})
       return 0
       ;;
    ${no1})
       return 1
       ;;
  esac
  done
}

function alert {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --sorry "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --warning --text="$1" 2>/dev/null
     return
  fi
  echo "$1"

}

function show_info {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --msgbox "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --info --width=500 --text="$1" 2>/dev/null
     return
  fi
  split_line "$1"
}

function confirm_exit {
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "Really quit?"  ; then
     exit 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     if $ZENITY --question --text="Really quit?" 2>/dev/null ; then
        exit 1
     fi
  fi
}



function prompt_nonempty_string {
  prompt=$2
  if [ ! -z $ZENITY ] ; then
    if [ $1 -eq 0 ] ; then
     H="--hide-text "
    fi
    if ! [ -z "$3" ] ; then
     D="--entry-text=$3"
    fi
  elif [ ! -z $KDIALOG ] ; then
    if [ $1 -eq 0 ] ; then
     H="--password"
    else
     H="--inputbox"
    fi
  fi


  out_s="";
  if [ ! -z $ZENITY ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$ZENITY --entry --width=300 $H $D --text "$prompt" 2>/dev/null`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done
  elif [ ! -z $KDIALOG ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$KDIALOG $H "$prompt" "$3"`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done  
  else
    while [ ! "$out_s" ] ; do
      read -p "${prompt}: " out_s
    done
  fi
  echo "$out_s";
}

function user_cred {
  PASSWORD="a"
  PASSWORD1="b"

  if ! USER_NAME=`prompt_nonempty_string 1 "enter your userid"` ; then
    exit 1
  fi

  while [ "$PASSWORD" != "$PASSWORD1" ]
  do
    if ! PASSWORD=`prompt_nonempty_string 0 "enter your password"` ; then
      exit 1
    fi
    if ! PASSWORD1=`prompt_nonempty_string 0 "repeat your password"` ; then
      exit 1
    fi
    if [ "$PASSWORD" != "$PASSWORD1" ] ; then
      alert "passwords do not match"
    fi
  done
}
setup_environment
show_info "This installer has been prepared for ${ORGANISATION}\n\nMore information and comments:\n\nEMAIL: ${SUPPORT}\nWWW: ${URL}\n\nInstaller created with software from the GEANT project."
if ! ask "This installer will only work properly if you are a member of ${bf}Westfaelische Hochschule Gelsenkirchen Recklinghausen Bocholt${n} and the user group: ${bf}Employees und Students with PEAP.${n}" "Continue" 1 ; then exit; fi
if [ -d $HOME/.cat_installer ] ; then
   if ! ask "Directory $HOME/.cat_installer exists; some of its files may be overwritten." "Continue" 1 ; then exit; fi
else
  mkdir $HOME/.cat_installer
fi
# save certificates
echo "-----BEGIN CERTIFICATE-----
MIIDwzCCAqugAwIBAgIBATANBgkqhkiG9w0BAQsFADCBgjELMAkGA1UEBhMCREUx
KzApBgNVBAoMIlQtU3lzdGVtcyBFbnRlcnByaXNlIFNlcnZpY2VzIEdtYkgxHzAd
BgNVBAsMFlQtU3lzdGVtcyBUcnVzdCBDZW50ZXIxJTAjBgNVBAMMHFQtVGVsZVNl
YyBHbG9iYWxSb290IENsYXNzIDIwHhcNMDgxMDAxMTA0MDE0WhcNMzMxMDAxMjM1
OTU5WjCBgjELMAkGA1UEBhMCREUxKzApBgNVBAoMIlQtU3lzdGVtcyBFbnRlcnBy
aXNlIFNlcnZpY2VzIEdtYkgxHzAdBgNVBAsMFlQtU3lzdGVtcyBUcnVzdCBDZW50
ZXIxJTAjBgNVBAMMHFQtVGVsZVNlYyBHbG9iYWxSb290IENsYXNzIDIwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCqX9obX+hzkeXaXPSi5kfl82hVYAUd
AqSzm1nzHoqvNK38DcLZSBnuaY/JIPwhqgcZ7bBcrGXHX+0CfHt8LRvWurmAwhiC
FoT6ZrAIxlQjgeTNuUk/9k9uN0goOA/FvudocP05l03Sx5iRUKrERLMjfTlH6VJi
1hKTXrcxlkIF+3anHqP1wvzpesVsqXFP6st4vGCvx9702cu+fjOlbpSD8DT6Iavq
jnKgP6TeMFvvhk1qlVtDRKgQFRzlAVfFmPHmBiiRqiDFt1MmUUOyCxGVWOHAD3bZ
wI18gfNycJ5v/hqO2V81xrJvNHy+SE/iWjnX2J14np+GPgNeGYtEotXHAgMBAAGj
QjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBS/
WSA2AHmgoCJrjNXyYdK4LMuCSjANBgkqhkiG9w0BAQsFAAOCAQEAMQOiYQsfdOhy
NsZt+U2e+iKo4YFWz827n+qrkRk4r6p8FU3ztqONpfSO9kSpp+ghla0+AGIWiPAC
uvxhI+YzmzB6azZie60EI4RYZeLbK4rnJVM3YlNfvNoBYimipidx5joifsFvHZVw
IEoHNN/q/xWA5brXethbdXwFeilHfkCoMRN3zUA7tFFHei4R40cR3p1m0IvVVGb6
g1XqfMIpiRvpb7PO4gWEyS8+eIVibslfwXhjdFjASBgMmTnrpMwatXlajRWc2BQN
9noHV8cigwUtPJslJj0Ys6lDfMjIq2SPDqO/nBudMNva0Bkuqjzx+zOAduTNrRlP
BSeOE6Fuwg==
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIFEjCCA/qgAwIBAgIJAOML1fivJdmBMA0GCSqGSIb3DQEBCwUAMIGCMQswCQYD
VQQGEwJERTErMCkGA1UECgwiVC1TeXN0ZW1zIEVudGVycHJpc2UgU2VydmljZXMg
R21iSDEfMB0GA1UECwwWVC1TeXN0ZW1zIFRydXN0IENlbnRlcjElMCMGA1UEAwwc
VC1UZWxlU2VjIEdsb2JhbFJvb3QgQ2xhc3MgMjAeFw0xNjAyMjIxMzM4MjJaFw0z
MTAyMjIyMzU5NTlaMIGVMQswCQYDVQQGEwJERTFFMEMGA1UEChM8VmVyZWluIHp1
ciBGb2VyZGVydW5nIGVpbmVzIERldXRzY2hlbiBGb3JzY2h1bmdzbmV0emVzIGUu
IFYuMRAwDgYDVQQLEwdERk4tUEtJMS0wKwYDVQQDEyRERk4tVmVyZWluIENlcnRp
ZmljYXRpb24gQXV0aG9yaXR5IDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQDLYNf/ZqFBzdL6h5eKc6uZTepnOVqhYIBHFU6MlbLlz87TV0uNzvhWbBVV
dgfqRv3IA0VjPnDUq1SAsSOcvjcoqQn/BV0YD8SYmTezIPZmeBeHwp0OzEoy5xad
rg6NKXkHACBU3BVfSpbXeLY008F0tZ3pv8B3Teq9WQfgWi9sPKUA3DW9ZQ2PfzJt
8lpqS2IB7qw4NFlFNkkF2njKam1bwIFrEczSPKiL+HEayjvigN0WtGd6izbqTpEp
PbNRXK2oDL6dNOPRDReDdcQ5HrCUCxLx1WmOJfS4PSu/wI7DHjulv1UQqyquF5de
M87I8/QJB+MChjFGawHFEAwRx1npAgMBAAGjggF0MIIBcDAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFJPj2DIm2tXxSqWRSuDqS+KiDM/hMB8GA1UdIwQYMBaAFL9Z
IDYAeaCgImuM1fJh0rgsy4JKMBIGA1UdEwEB/wQIMAYBAf8CAQIwMwYDVR0gBCww
KjAPBg0rBgEEAYGtIYIsAQEEMA0GCysGAQQBga0hgiweMAgGBmeBDAECAjBMBgNV
HR8ERTBDMEGgP6A9hjtodHRwOi8vcGtpMDMzNi50ZWxlc2VjLmRlL3JsL1RlbGVT
ZWNfR2xvYmFsUm9vdF9DbGFzc18yLmNybDCBhgYIKwYBBQUHAQEEejB4MCwGCCsG
AQUFBzABhiBodHRwOi8vb2NzcDAzMzYudGVsZXNlYy5kZS9vY3NwcjBIBggrBgEF
BQcwAoY8aHR0cDovL3BraTAzMzYudGVsZXNlYy5kZS9jcnQvVGVsZVNlY19HbG9i
YWxSb290X0NsYXNzXzIuY2VyMA0GCSqGSIb3DQEBCwUAA4IBAQCHC/8+AptlyFYt
1juamItxT9q6Kaoh+UYu9bKkD64ROHk4sw50unZdnugYgpZi20wz6N35at8yvSxM
R2BVf+d0a7Qsg9h5a7a3TVALZge17bOXrerufzDmmf0i4nJNPoRb7vnPmep/11I5
LqyYAER+aTu/de7QCzsazeX3DyJsR4T2pUeg/dAaNH2t0j13s+70103/w+jlkk9Z
PpBHEEqwhVjAb3/4ru0IQp4e1N8ULk2PvJ6Uw+ft9hj4PEnnJqinNtgs3iLNi4LY
2XjiVRKjO4dEthEL1QxSr2mMDwbf0KJTi1eYe8/9ByT0/L3D/UqSApcb8re2z2WK
GqK1chk5
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIFrDCCBJSgAwIBAgIHG2O60B4sPTANBgkqhkiG9w0BAQsFADCBlTELMAkGA1UE
BhMCREUxRTBDBgNVBAoTPFZlcmVpbiB6dXIgRm9lcmRlcnVuZyBlaW5lcyBEZXV0
c2NoZW4gRm9yc2NodW5nc25ldHplcyBlLiBWLjEQMA4GA1UECxMHREZOLVBLSTEt
MCsGA1UEAxMkREZOLVZlcmVpbiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAyMB4X
DTE2MDUyNDExMzg0MFoXDTMxMDIyMjIzNTk1OVowgY0xCzAJBgNVBAYTAkRFMUUw
QwYDVQQKDDxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1dHNjaGVuIEZv
cnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsMB0RGTi1QS0kxJTAjBgNVBAMM
HERGTi1WZXJlaW4gR2xvYmFsIElzc3VpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQCdO3kcR94fhsvGadcQnjnX2aIw23IcBX8pX0to8a0Z1kzh
axuxC3+hq+B7i4vYLc5uiDoQ7lflHn8EUTbrunBtY6C+li5A4dGDTGY9HGRp5Zuk
rXKuaDlRh3nMF9OuL11jcUs5eutCp5eQaQW/kP+kQHC9A+e/nhiIH5+ZiE0OR41I
X2WZENLZKkntwbktHZ8SyxXTP38eVC86rpNXp354ytVK4hrl7UF9U1/Isyr1ijCs
7RcFJD+2oAsH/U0amgNSoDac3iSHZeTn+seWcyQUzdDoG2ieGFmudn730Qp4PIdL
sDfPU8o6OBDzy0dtjGQ9PFpFSrrKgHy48+enTEzNAgMBAAGjggIFMIICATASBgNV
HRMBAf8ECDAGAQH/AgEBMA4GA1UdDwEB/wQEAwIBBjApBgNVHSAEIjAgMA0GCysG
AQQBga0hgiweMA8GDSsGAQQBga0hgiwBAQQwHQYDVR0OBBYEFGs6mIv58lOJ2uCt
sjIeCR/oqjt0MB8GA1UdIwQYMBaAFJPj2DIm2tXxSqWRSuDqS+KiDM/hMIGPBgNV
HR8EgYcwgYQwQKA+oDyGOmh0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvZ2xvYmFsLXJv
b3QtZzItY2EvcHViL2NybC9jYWNybC5jcmwwQKA+oDyGOmh0dHA6Ly9jZHAyLnBj
YS5kZm4uZGUvZ2xvYmFsLXJvb3QtZzItY2EvcHViL2NybC9jYWNybC5jcmwwgd0G
CCsGAQUFBwEBBIHQMIHNMDMGCCsGAQUFBzABhidodHRwOi8vb2NzcC5wY2EuZGZu
LmRlL09DU1AtU2VydmVyL09DU1AwSgYIKwYBBQUHMAKGPmh0dHA6Ly9jZHAxLnBj
YS5kZm4uZGUvZ2xvYmFsLXJvb3QtZzItY2EvcHViL2NhY2VydC9jYWNlcnQuY3J0
MEoGCCsGAQUFBzAChj5odHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290
LWcyLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDANBgkqhkiG9w0BAQsFAAOCAQEA
gXhFpE6kfw5V8Amxaj54zGg1qRzzlZ4/8/jfazh3iSyNta0+x/KUzaAGrrrMqLGt
Mwi2JIZiNkx4blDw1W5gjU9SMUOXRnXwYuRuZlHBQjFnUOVJ5zkey5/KhkjeCBT/
FUsrZpugOJ8Azv2n69F/Vy3ITF/cEBGXPpYEAlyEqCk5bJT8EJIGe57u2Ea0G7UD
DDjZ3LCpP3EGC7IDBzPCjUhjJSU8entXbveKBTjvuKCuL/TbB9VbhBjBqbhLzmyQ
GoLkuT36d/HSHzMCv1PndvncJiVBby+mG/qkE5D6fH7ZC2Bd7L/KQaBh+xFJKdio
LXUV2EoY6hbvVTQiGhONBg==
-----END CERTIFICATE-----

" > $HOME/.cat_installer/ca.pem
function run_python_script {
PASSWORD=$( echo "$PASSWORD" | sed "s/'/\\\'/g" )
if python << EEE1 > /dev/null 2>&1
import dbus
EEE1
then
    PYTHON=python
elif python3 << EEE2 > /dev/null 2>&1
import dbus
EEE2
then
    PYTHON=python3
else
    PYTHON=none
    return 1
fi

$PYTHON << EOF > /dev/null 2>&1
#-*- coding: utf-8 -*-
import dbus
import re
import sys
import uuid
import os

class EduroamNMConfigTool:

    def connect_to_NM(self):
        #connect to DBus
        try:
            self.bus = dbus.SystemBus()
        except dbus.exceptions.DBusException:
            print("Can't connect to DBus")
            sys.exit(2)
        #main service name
        self.system_service_name = "org.freedesktop.NetworkManager"
        #check NM version
        self.check_nm_version()
        if self.nm_version == "0.9" or self.nm_version == "1.0":
            self.settings_service_name = self.system_service_name
            self.connection_interface_name = "org.freedesktop.NetworkManager.Settings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManager/Settings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManager.Settings")
        elif self.nm_version == "0.8":
            #self.settings_service_name = "org.freedesktop.NetworkManagerUserSettings"
            self.settings_service_name = "org.freedesktop.NetworkManager"
            self.connection_interface_name = "org.freedesktop.NetworkManagerSettings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManagerSettings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManagerSettings")
        else:
            print("This Network Manager version is not supported")
            sys.exit(2)

    def check_opts(self):
        self.cacert_file = '${HOME}/.cat_installer/ca.pem'
        self.pfx_file = '${HOME}/.cat_installer/user.p12'
        if not os.path.isfile(self.cacert_file):
            print("Certificate file not found, looks like a CAT error")
            sys.exit(2)

    def check_nm_version(self):
        try:
            proxy = self.bus.get_object(self.system_service_name, "/org/freedesktop/NetworkManager")
            props = dbus.Interface(proxy, "org.freedesktop.DBus.Properties")
            version = props.Get("org.freedesktop.NetworkManager", "Version")
        except dbus.exceptions.DBusException:
            version = "0.8"
        if re.match(r'^1\.', version):
            self.nm_version = "1.0"
            return
        if re.match(r'^0\.9', version):
            self.nm_version = "0.9"
            return
        if re.match(r'^0\.8', version):
            self.nm_version = "0.8"
            return
        else:
            self.nm_version = "Unknown version"
            return

    def byte_to_string(self, barray):
        return "".join([chr(x) for x in barray])


    def delete_existing_connections(self, ssid):
        "checks and deletes earlier connections"
        try:
            conns = self.settings.ListConnections()
        except dbus.exceptions.DBusException:
            print("DBus connection problem, a sudo might help")
            exit(3)
        for each in conns:
            con_proxy = self.bus.get_object(self.system_service_name, each)
            connection = dbus.Interface(con_proxy, "org.freedesktop.NetworkManager.Settings.Connection")
            try:
               connection_settings = connection.GetSettings()
               if connection_settings['connection']['type'] == '802-11-wireless':
                   conn_ssid = self.byte_to_string(connection_settings['802-11-wireless']['ssid'])
                   if conn_ssid == ssid:
                       connection.Delete()
            except dbus.exceptions.DBusException:
               pass

    def add_connection(self,ssid):
        server_alt_subject_name_list = dbus.Array({'DNS:za-rs1-ge.za.w-hs.de','DNS:za-rs2-ge.za.w-hs.de','DNS:za-rs3-ge.za.w-hs.de','DNS:za-rs4-ge.za.w-hs.de','DNS:za-rs5-ge.za.w-hs.de','DNS:za-rs6-ge.za.w-hs.de'})
        server_name = 'za.w-hs.de'
        if self.nm_version == "0.9" or self.nm_version == "1.0":
             match_key = 'altsubject-matches'
             match_value = server_alt_subject_name_list
        else:
             match_key = 'subject-match'
             match_value = server_name
            
        s_con = dbus.Dictionary({
            'type': '802-11-wireless',
            'uuid': str(uuid.uuid4()),
            'permissions': ['user:$USER'],
            'id': ssid 
        })
        s_wifi = dbus.Dictionary({
            'ssid': dbus.ByteArray(ssid.encode('utf8')),
            'security': '802-11-wireless-security'
        })
        s_wsec = dbus.Dictionary({
            'key-mgmt': 'wpa-eap',
            'proto': ['rsn',],
            'pairwise': ['ccmp',],
            'group': ['ccmp', 'tkip']
        })
        s_8021x = dbus.Dictionary({
            'eap': ['peap'],
            'identity': '$USER_NAME',
            'ca-cert': dbus.ByteArray("file://{0}\0".format(self.cacert_file).encode('utf8')),
             match_key: match_value,
            'password': '$PASSWORD',
            'phase2-auth': 'mschapv2',
            'anonymous-identity': 'anonymous@w-hs.de',
        })
        s_ip4 = dbus.Dictionary({'method': 'auto'})
        s_ip6 = dbus.Dictionary({'method': 'auto'})
        con = dbus.Dictionary({
            'connection': s_con,
            '802-11-wireless': s_wifi,
            '802-11-wireless-security': s_wsec,
            '802-1x': s_8021x,
            'ipv4': s_ip4,
            'ipv6': s_ip6
        })
        self.settings.AddConnection(con)

    def main(self):
        self.check_opts()
        ver = self.connect_to_NM()
        self.delete_existing_connections('eduroam')
        self.add_connection('eduroam')
        self.delete_existing_connections('123los')

if __name__ == "__main__":
    ENMCT = EduroamNMConfigTool()
    ENMCT.main()
EOF
}
function create_wpa_conf {
cat << EOFW >> $HOME/.cat_installer/cat_installer.conf

network={
  ssid="eduroam"
  key_mgmt=WPA-EAP
  pairwise=CCMP
  group=CCMP TKIP
  eap=PEAP
  ca_cert="${HOME}/.cat_installer/ca.pem"
  identity="${USER_NAME}"
  domain_suffix_match="za.w-hs.de"
  phase2="auth=MSCHAPV2"
  password="${PASSWORD}"
  anonymous_identity="anonymous@w-hs.de"
}
EOFW
chmod 600 $HOME/.cat_installer/cat_installer.conf
}
#prompt user for credentials
  user_cred
  if run_python_script ; then
   show_info "Installation successful"
else
   show_info "Network Manager configuration failed, generating wpa_supplicant.conf"
   if ! ask "Network Manager configuration failed, but we may generate a wpa_supplicant configuration file if you wish. Be warned that your connection password will be saved in this file as clear text." "Write the file" 1 ; then exit ; fi

if [ -f $HOME/.cat_installer/cat_installer.conf ] ; then
  if ! ask "File $HOME/.cat_installer/cat_installer.conf exists; it will be overwritten." "Continue" 1 ; then confirm_exit; fi
  rm $HOME/.cat_installer/cat_installer.conf
  fi
   create_wpa_conf
   show_info "Output written to $HOME/.cat_installer/cat_installer.conf"
fi
