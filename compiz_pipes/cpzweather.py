#!/usr/bin/python2

import sys
import urllib
from string import maketrans
#from xml.sax import make_parser, handler
from xml.sax import handler, parseString
class ElementProcesser(handler.ContentHandler):
    
    def startElement(self, name, attrs):
        
        if name == "city":
            print "<separator name='" + attrs["data"] + "'/>"
        elif name == "current_conditions":
            print "<separator name='Current condidtions'/>"
        elif name == "condition":
            print "<item type=\"launcher\"><name>'Weather: " + attrs["data"] + "</name></item>"
        elif name == "humidity":
            print "<item type=\"launcher\"><name>" + attrs["data"] + "</name></item>"
        elif name == "wind_condition":
            print "<item type=\"launcher\"><name>" + attrs["data"] + "</name></item>"
        elif name == "day_of_week":
            print "<separator name='" + self.getDayOfWeek(attrs["data"]) + "'/>"
            
        #Celsius
        #elif name == "temp_c":
            #print "<item label='Temperature " + attrs["data"] + " C' />"
        #elif name == "low":
            #print "<item label='Minimun " + attrs["data"] + " C' />"
        #elif name == "high":
            #print "<item label='Maximun " + attrs["data"] + " C' />"
        
        #Fahrenheit
        elif name == "temp_f":
            print "<item type=\"launcher\"><name>Temperature " + attrs["data"] + " F'</name></item>"
        elif name == "low":
            print "<item type=\"launcher\"><name>Minimun " + attrs["data"] + " F'</name></item>"
        elif name == "high":
            print "<item type=\"launcher\"><name>Maximun " + attrs["data"] + " F'</name></item>"
        
        
    def endElement(self, name):
        
        if name == "current_conditions":
            print "<separator name='Forecast'/>"
        
    
    def startDocument(self):
        return
    
    def endDocument(self):
       return
    
    def getDayOfWeek(self,day):
        
        #English
        if day == "Mon":
            return "Monday"
        elif day == "Tue":
            return "Tuesday"
        elif day == "Wed":
            return "Wednesday"
        elif day == "Thu":
            return "Thursday"
        elif day == "Sat":
            return "Saturday"
        elif day == "Sun":
            return "Sunday"
        
        else:
            return day

# You should use your local version of google to have the messages in your language and metric system
f = urllib.urlopen("http://www.google.com/ig/api?weather="+sys.argv[1])
xml = f.read()
f.close()

#Avoid problems with non english characters
trans=maketrans("\xe1\xe9\xed\xf3\xfa","aeiou")
xml = xml.translate(trans)

#parser.parse("http://www.google.es/ig/api?weather="+sys.argv[1])
parseString(xml,ElementProcesser())
