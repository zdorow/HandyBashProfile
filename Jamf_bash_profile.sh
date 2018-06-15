alias st="~/Documents/ST.sh"

# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH

function jssversion () {
        if [[ ${1} == *"."* ]]; then
                output=$(curl -ks https://${1}:8443 | grep "<title>" | cut -d v -f2 | cut -d\< -f1 | cut -d '-' -f1)
        else
                output=$(curl -ks https://${1}.jamfcloud.com | grep "<title>" | cut -d v -f2 | cut -d\< -f1 | cut -d '-' -f1)
        fi

        #If output was empty, we ran into SSO, go to Failover
        if [[ $output == "" ]]; then
                if [[ ${1} == *"."* ]]; then
                        curl -ks "https://${1}/?failover" | grep "<title>" | cut -d v -f2 | cut -d\< -f1 | cut -d '-' -f1
                else
                        curl -ks "https://${1}.jamfcloud.com/?failover" | grep "<title>" | cut -d v -f2 | cut -d\< -f1 | cut -d '-' -f1
                fi
        else
                echo $output
        fi
}
function unsign () {
        security cms -D -i "${1}" | xmllint --format - > /Users/zach/Desktop/unsigned.mobileconfig
        echo "unsigned.mobileconfig has been placed on the Desktop."
        echo "Make changes and then type 'sign' to sign it again."
        echo "Do not pass any arguments into the 'sign' command"
}
function csr () {
        openssl req -out ~/Desktop/CSR.csr -new -newkey rsa:2048 -nodes -keyout ~/Desktop/privateKey.key
        echo "CSR and Private Key have been placed on the Desktop."
        echo "-Make a new Web Server Certificate from the CSR under PKI in the JSS"
        echo "-Update references in the 'sign' function of the Bash Profile"
}
function sign () {
        echo "Reminder: Signing certificate expires on June 12, 2019."
        echo "Use command csr to create a new one if necessary."
	echo "We can also check the expiration with the command sslexipre."
        openssl smime -sign -signer /Users/zach/Reference-Files/server.pem -inkey /Users/zach/Reference-Files/privateKey.key -nodetach -outform der -in //Users/zach/Desktop/unsigned.mobileconfig -out /Users/zach/Desktop/NEWsigned.mobileconfig
	echo "The new signed profile is on the desktop." 
}
function sslexpire () {
	echo -n "The signing certificate expiration date is: " 
	openssl x509 -enddate -noout -in "${1}" | sed 's/notAfter=//g'

