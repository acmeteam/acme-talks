import json
import codecs
import urllib.request as req


################## checking version of local masterlist against cloud ml ##################
#(masterlist.json file needed in the working dir for this to work)

#get cloud masterlist
url = "http://www.plantronics.com/services/mobile/ios_stage/hub/3.8/masterlist.json"
resp = req.urlopen(url).read().decode("utf8")

#get local masterlist
ml_file = codecs.open("masterlist.json", "r", "utf8")

#parse local ml
ml = json.load(ml_file)
mlv = ml['masterlist_schema_version']

#parse downloaded ml
cml = json.loads(resp)
cmlv = cml['masterlist_schema_version']


#check differances (and print them)
print("\n\n\n")

if mlv == cmlv:
    print("OK!")
else:
    print("WRONG Version!!! - l:{} != c:{}".format(mlv, cmlv))
    
print("\n\n\n")