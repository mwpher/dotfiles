# ECHHHH
import pafy
import pickle
import os
import time
import re

dllist = open('/Users/matthewpherigo/GameGrumps/playlists.txt', 'r')

for line in dllist:
    # Open logfile
    log = open('/Users/matthewpherigo/GameGrumps/.log', 'a' )
    log.write('Starting playlist ', playlist.get('playlist_id'))
    playlist = pafy.get_playlist(line)  # Get playlist
    vids = playlist.get('items')        # Get contents
    for vid in vids.pop():      # Get pafy object
        vid = vid['pafy']
        RecordDate(vid)
        dl = vid.getbest                # Get downloadable object
        path = GetPlace(dl.filename)

def RecordDate(vidobj):
    chrono = open('/Users/matthewpherigo/GameGrumps/chrono.txt', 'r')
    

def GetPlace(title):
    return re.sub(r'(.*): (.*) - P[Aa][Rr][Tt] (\d*) .*\.mp4',
           r'/Users/matthewpherigo/GameGrumps/\1/\3 - \2 - \1.mp4',
           title)
