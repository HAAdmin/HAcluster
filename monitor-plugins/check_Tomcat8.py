#!/usr/bin/env python    
# -*- coding: utf-8 -*-    
import commands
import os
import sys
try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3
STATE_ERR_ARGS = 4



#root = tree.getroot()  

def getPort(tree):
    root = tree.getroot()
    for childroot in root:
        if childroot.tag == "Service":
            for child in childroot:
                if child.tag == "Connector" and child.attrib["protocol"] == "AJP/1.3":
                    break
                Connector = child.attrib                  
    
    port = Connector["port"]
    return port

def getPid(tree):
    port = getPort(tree)
    #cmd = "sudo netstat -antp | grep %s | awk '{print $7}' | cut -d '/' -f1" % port
    cmd = "sudo netstat -antp | grep 1016 | awk '{print $7}' | cut -d '/' -f1"
    #print cmd
    (status, output)=commands.getstatusoutput(cmd)
    return output
    
    
    
if __name__ == '__main__': 
    cmd = "sudo chmod o+r /opt/apache-tomcat-8.0.5/conf/server.xml"
    output = commands.getoutput(cmd)
    try:
        tree = ET.ElementTree(file='/opt/apache-tomcat-8.0.5/conf/server.xml')
    except IOError:
        print "No such file or denied access.Please make sure tomcat8.0.5 is installed"
        sys.exit(STATE_CRITICAL) 
    PID = getPid(tree)
    PidDir = '/proc/%s' % PID
    if PID:
        if os.path.isdir(PidDir):
            print "Tomcat8(PID:%s) is running.|state=0" % PID
            sys.exit(STATE_OK)
        else:
            print "The pid exists but the process is not running.|state=1"
            sys.exit(STATE_CRITICAL)
    else:
        print "Tomcat8 is not running.|state=1"
        sys.exit(STATE_CRITICAL)
