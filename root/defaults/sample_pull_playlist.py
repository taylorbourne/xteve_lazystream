import urllib.request
import hashlib
import os

#Provider URL to download M3U file
url = 'http://provider.com/playlist.m3u'
#File path where to save the newly create M3U file.
filePath = '/playlists/playlist.m3u'

# Get M3U file from provider
response = urllib.request.urlopen(url)
data = response.read()
providerM3uFile = data.decode('utf-8')

#Open and overwrites the file if it exist, if it doesnt exist it creates a new one
fo = open(filePath, 'w', encoding='utf-8')

#Adds CUID to every line. CUID = MD5 hash of the channel URL
m3uLines = providerM3uFile.split('#EXTINF:-1')
#Delete #EXTM3U line
del m3uLines[0]
newM3uFile = '#EXTM3U' + '\n'
for m3uLine in m3uLines:
    #Filter channels that you want to include by group title. 
    #This assumes that your provider uses the group-title= property to identify gropus, if not change it
    if ('group-title="USA ENTERTAINMENT"' in m3uLine) or ('group-title="USA LOCAL SPORTS"' in m3uLine) or ('group-title="USA LOCALS"' in m3uLine) or ('group-title="USA MOVIES"' in m3uLine) or ('group-title="USA ESPN"' in m3uLine) or ('group-title="USA NEWS"' in m3uLine) or ('group-title="USA KIDS"' in m3uLine) or ('group-title="USA SPORTS"' in m3uLine):
        channelInfo = m3uLine.splitlines()[0].strip()
        channelUrl = m3uLine.splitlines()[1].strip()
        hash = hashlib.md5(channelUrl.encode('utf-8')).hexdigest()
        newM3uLine = f"#EXTINF:-1 CUID=\"{hash}\" {channelInfo.strip()}\n{channelUrl.strip()}\n"
        newM3uFile = newM3uFile + newM3uLine

#Write newly create file to a file in the OS
fo.write(newM3uFile)
fo.close