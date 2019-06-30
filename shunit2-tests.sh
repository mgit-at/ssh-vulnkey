#!/bin/bash

t_="./ssh-vulnkey"

# prefixed by SHUNIT_TMPDIR
e_="id_rsa.pub"
ne_="nonexistend.pub"


oneTimeSetUp() {
    # prefix variables because SHUNIT_TMPDIR is empty before shunit2 is sourced at the end of this file
    e_="$SHUNIT_TMPDIR/$e_"
    ne_="$SHUNIT_TMPDIR/$ne_"

    # create one working key to test with
    ssh-keygen -t rsa -b 1024 -C user@host -N "" -f $e_ >/dev/null
    ret_=$?
    assertEquals "problem creating test input keys for rsa 1024 bit" 0 $ret_
}

setUp() {
    export TEST_ORIGINAL_PATH=$PATH
    PATH=$PWD:$PWD/mock:$PATH
}

tearDown()
{
    PATH=$TEST_ORIGINAL_PATH
}

testBasicFunctionality() {
    $t_ $e_
    ret_=$?
    assertEquals 0 $ret_
}

testStrangeKeySizes() {
    for i in 1025 2047; do
        ssh-keygen -t rsa -b $i -C user@host -N "" -f $SHUNIT_TMPDIR/id_rsa${i}.pub >/dev/null
        ret_=$?
        assertEquals "problem creating test input keys rsa $i bits" 0 $ret_
        $t_ $SHUNIT_TMPDIR/id_rsa${i}.pub 2>/dev/null
        ret_=$?
        assertEquals 0 $ret_
    done
}

_testFailsWhenKeyFileDoesNotExist() {
    local orig_args_="$@"
    local ret_expected_=$1
    shift
    [[ $# == 3 ]] || fail "internal error, expected only 3 args but got $# (+1): $orig_args_"
    $t_ "$@" &>/dev/null
    ret_=$?
    assertEquals "$t_ $* -" $ret_expected_ $ret_
}

testFailsWhenKeyFileDoesNotExist() {
    [ -e $ne_ ] && fail "file $ne_ must not exist"

    fixture_=('a=(1 $ne_ $ne_ $e_)' 'a=(1 $ne_ $e_ $ne_)' 'a=(1 $e_ $ne_ $ne_)' 'a=(0 $e_ $e_ $e_)')
    for i in "${fixture_[@]}"; do
        eval $i
        _testFailsWhenKeyFileDoesNotExist ${a[@]}
    done
}

testBlackBoxVulnerableKeyRSA1024() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=RSA1024 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "AA:AA:AA:AA:AA:AA:42:fe:2d:91:b9:94:60:c8:4e:a0 mocked_in_vulnerable_key IS VULNERABLE" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyRSA2048() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=RSA2048 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "AA:AA:AA:AA:AA:AA:42:fe:9c:8b:c7:70:59:a6:11:9d mocked_in_vulnerable_key IS VULNERABLE" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyRSA4096() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=RSA4096 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "AA:AA:AA:AA:AA:AA:42:fe:f8:89:61:f3:8c:ff:0f:96 mocked_in_vulnerable_key IS VULNERABLE" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyDSA1024() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=DSA1024 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "AA:AA:AA:AA:AA:AA:42:fe:51:b4:8d:03:39:c7:d8:fd mocked_in_vulnerable_key IS VULNERABLE" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

. shunit2
