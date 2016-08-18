#!/bin/bash

t_="./ssh-vulnkey"
ne_="./fixtures/nonexistend"


setUp()
{
    export TEST_ORIGINAL_PATH=$PATH
    PATH=$PWD:$PWD/mock:$PATH
}

tearDown()
{
    PATH=$TEST_ORIGINAL_PATH
}

testBasicFunctionality() {
    $t_ ./fixtures/id_rsa.pub
    ret_=$?
    assertEquals 0 $ret_
}

testStrangeKeySizes() {
    for i in 1023 2047; do
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
    ne_=./fixtures/nonexistend
    e_=./fixtures/id_rsa.pub
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
    assertEquals "mocked_in_vulnerable_key IS VULNERABLE - 42fe2d91b99460c84ea0" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyRSA2048() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=RSA2048 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "mocked_in_vulnerable_key IS VULNERABLE - 42fe9c8bc77059a6119d" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyRSA4096() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=RSA4096 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "mocked_in_vulnerable_key IS VULNERABLE - 42fef88961f38cff0f96" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

testBlackBoxVulnerableKeyDSA1024() {
    out_=$(TEST_PRINT_VULNERABLE_KEY=DSA1024 $t_ mocked_in_vulnerable_key 2>&1)
    ret_=$?
    assertEquals "mocked_in_vulnerable_key IS VULNERABLE - 42fe51b48d0339c7d8fd" "$out_"
    assertEquals "$t_ must return an error on vulnerable keys - " 1 "$ret_"
}

. shunit2
