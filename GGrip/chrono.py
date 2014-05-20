# chrono.py
# make chronological list of all videos in dllist and save
import operator
import pickle
import pafy
import os
import time
import datetime
import re

vidDict = {}

with open('/Users/matthewpherigo/GameGrumps/playlists.txt', 'r') as dllist:
    for line in dllist:
        print("\n")
        if re.match(r'(^\s*$|^#)', line):
            print('Skipping line')
            continue
        playlist = pafy.get_playlist(line) # Get videos
        print('playlist is ', playlist.get('title'))
        for vid in playlist['items']:              # Get pafy object
            vid = vid.get('pafy')
#            print(vid.title + ' was published on ' + vid.published)
            vidDict[vid] = datetime.datetime.strptime(vid.published, '%Y-%m-%d %H:%M:%S')
        time.sleep(10)


# Let's sort that!
sorted_vidDict = sorted(vidDict.items(), key=operator.itemgetter(1))

with open('/Users/matthewpherigo/GameGrumps/vids-chrono.txt', 'w') as vidjar:
    pickle.dump(sorted_vidDict, vidjar, 4)

    #pickle.dump(sorted_vidDict, vidjar)

    #   with open('/Users/matthewpherigo/GameGrumps/chrono.txt', 'r') as text:
    #       for cline in chrono:
    #           found = False
    #           for vidid in list(vidDict):
    #               res = re.search(re.escape(vidid), cline)
    #               if res:
    #                   found = True

