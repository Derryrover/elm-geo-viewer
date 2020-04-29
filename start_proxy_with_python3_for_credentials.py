#!/usr/bin/env python

import getpass
import sys
import os

def get_username():
    try:
        username = input("[?] SSO username: ")
    except KeyboardInterrupt:
        print ("\n[!] Aborting...")
        sys.exit(0)

    if username:
        print ("[+] OK, we'll be using '%s' as username for this session." % \
            username)
        return username
    else:
        print ("[!] You have failed to enter a valid username. Please try again.")
        return get_username()


def get_password():
    try:
        password = getpass.getpass('[?] SSO password: ')
    except KeyboardInterrupt:
        print ("\n[!] Aborting...")
        sys.exit(0)

    if password:
        print ("[+] OK, we'll be using %s as password." % (len(password) * '*'))
        return password
    else:
        print ("[!] You have failed to enter a valid password. Please try again.")
        return get_password()


if __name__ == '__main__':
    username = get_username()
    password = get_password()
    os.system(' PROXY_USERNAME=%s PROXY_PASSWORD="%s" node start-proxy.js' % \
        (username, password))
