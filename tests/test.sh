sshenc=../sshenc.sh
#to test the pre OpenSSL 1.1.1 script, uncomment the line below:
#sshenc=../sshenc-pre1.1.1.sh

cleanup() {
    rm -rf "$temp_dir"
}

trap cleanup EXIT

temp_dir="$(mktemp -d -t "sshenc.sh.XXXXXX")"
tempfile="$(mktemp "$temp_dir/sshenc.sh.XXXXXX.cypher")"
plaintext=$(cat sometext)

echo -n 'testing multiple pubkeys: '
$sshenc -p id_rsa-1.pub -p id_rsa-2.pub -p id_rsa-3.pub < sometext > $tempfile

for i in {1..3}; do
    cyph=$($sshenc -s id_rsa-$i < $tempfile)
    if [ "$cyph" == "$plaintext" ]; then
        echo -n "key$i: ✓ "
    else
        echo -n "key$i: ⛝ "
    fi
done
echo

echo -n 'testing encryption with a single key: '
$sshenc -p id_rsa-1.pub < sometext > $tempfile
cyph=$($sshenc -s id_rsa-1 < $tempfile)
if [ "$cyph" == "$plaintext" ]; then
    echo -n "✓"
else
    echo -n "⛝"
fi
echo

echo -n 'testing encryption of a binary file: '
$sshenc -p id_rsa-1.pub < ../logo.png > $tempfile
$sshenc -s id_rsa-1 < $tempfile > $temp_dir/binary
diff ../logo.png $temp_dir/binary
retval=$?
if [ $retval -eq 0 ]; then
    echo -n "✓"
else
    echo -n "⛝"
fi
echo

echo
echo done.
