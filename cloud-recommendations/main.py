import sys
import spotipy
import spotipy.util as util

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import numpy as np
from scipy.optimize import minimize

# Data frame for storing all the recommended songs for each user
df_final_standardized = pd.DataFrame(columns = ['username', 'trackid', 'danceability', 'energy', 'speechiness', 'acousticness', 'instrumentalness', 'valence'])

def get_recs(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        String consisting of the recommended songs for the group turned into a Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    
    request_json = request.get_json()
    
    token = request_json['token']

    upvotes_for_user = request_json['upvotes_for_user']
    downvotes_for_user = request_json['downvotes_for_user']

    # make sure each user has between 1 and 5 songs inclusive associated with them
    delete_users_upvote = []
    for key in upvotes_for_user:
        if (len(upvotes_for_user[key]) == 0):
            delete_users_upvote.append(key)
        else:
            upvotes_for_user[key] = upvotes_for_user[key][:5]
    delete_users_downvote = []
    for key in downvotes_for_user:
        if (len(downvotes_for_user[key]) == 0):
            delete_users_downvote.append(key)
        else:
            downvotes_for_user[key] = downvotes_for_user[key][:5]
    for user in delete_users_upvote:
        del upvotes_for_user[user]
    for user in delete_users_downvote:
        del downvotes_for_user[user]

    # we will be treating downvoted songs' inverses as upvotes
    all_upvotes = [[]]

    # upvote usernames are regular
    # downvote usernames have an exclamation mark in front of them
    if (len(downvotes_for_user.keys()) == 0):
        usernames = upvotes_for_user.keys()
    else:
        usernames = list(list(upvotes_for_user.keys()).extend(list(downvotes_for_user.keys())))

    for user, tracks in upvotes_for_user.items():
        if (len(tracks) == 0):
            usernames.remove(user)
        for track in tracks:
            upvote = [user, track]
            all_upvotes.append(upvote)

    for user, tracks in downvotes_for_user.items():
        if (len(tracks) == 0):
            usernames.remove(user)
        for track in tracks:
            upvote = [user, track]
            all_upvotes.append(upvote)

    df = pd.DataFrame(all_upvotes, columns = ['username', 'trackid'])
    df = df.iloc[1:]
    print(df.to_string())
    
    recs = final_list(df, token, usernames)
    return str(recs)

def final_list(input_df, token, usernames):
    users = usernames
    spot = spotipy.Spotify(auth=token)
    df_final = pd.DataFrame(columns = ['username', 'trackid', 'danceability', 'energy', 'speechiness', 'acousticness', 'instrumentalness', 'valence'])
    
    # Now, we can actually get the audio features for the various tracks
    df_final.reset_index()
    
    count = 0
    for index, row in input_df.iterrows():
        track_audio_features = spot.audio_features(row['trackid'])[0] # take first element (which is a dict) since we are only inputting one song into audio features function
        new_row = [row['username'], row['trackid'], track_audio_features['danceability'], track_audio_features['energy'], track_audio_features['speechiness'], track_audio_features['acousticness'], track_audio_features['instrumentalness'], track_audio_features['valence']]
        df_final.loc[count] = new_row
        count = count + 1

    count = 0
    for user in users:
        user_tracks = df_final[df_final.username == user]['trackid'].tolist() # get the user's tracks
        user_5_recs = spot.recommendations(seed_tracks = user_tracks, limit = 5) # get 5 recommendations for the tracks
        user_5_recs_output = [user_5_recs['tracks'][i]['uri'] for i in range (5)] # get the recommendations' track URI's
        user_5_recs_audio_features = spot.audio_features(user_5_recs_output)
        for i in range (5):
            # if it's a downvote
            if (user[0] == '!'):
                new_standard_row = [user, user_5_recs_output[i], 1 - user_5_recs_audio_features[i]['danceability'], 1 - user_5_recs_audio_features[i]['energy'], 1 - user_5_recs_audio_features[i]['speechiness'], 1 - user_5_recs_audio_features[i]['acousticness'], 1 - user_5_recs_audio_features[i]['instrumentalness'], 1 - user_5_recs_audio_features[i]['valence']]
                print("Song inverted")
            else:
                new_standard_row = [user, user_5_recs_output[i], user_5_recs_audio_features[i]['danceability'], user_5_recs_audio_features[i]['energy'], user_5_recs_audio_features[i]['speechiness'], user_5_recs_audio_features[i]['acousticness'], user_5_recs_audio_features[i]['instrumentalness'], user_5_recs_audio_features[i]['valence']]
            df_final_standardized.loc[count] = new_standard_row
            count = count + 1

    # get averages for different audio features
    avg_danceability = df_final_standardized['danceability'].mean()
    avg_energy = df_final_standardized['energy'].mean()
    avg_speechiness = df_final_standardized['speechiness'].mean()
    avg_acousticness = df_final_standardized['acousticness'].mean()
    avg_instrumentalness = df_final_standardized['instrumentalness'].mean()
    avg_valence = df_final_standardized['valence'].mean()

    avg_song_features = [avg_danceability, avg_energy, avg_speechiness, avg_acousticness, avg_instrumentalness, avg_valence]

    res = minimize(vote_error, avg_song_features, method='nelder-mead', options={'xtol': 1e-8, 'disp': True})

    target_vars = res.x

    # randomly select 5 tracks as seeds from the dataframe
    seeds = df_final_standardized['trackid'].sample(5).tolist()

    # get the recommendations
    num_recs = 100
    recommendations_model_2 = spot.recommendations(seed_tracks = seeds, target_danceability = target_vars[0], target_energy = target_vars[1], target_speechines = target_vars[2], target_acousticness = target_vars[3], target_instrumentalness = target_vars[4], target_valence = target_vars[5],  limit = num_recs)
    recommendations_model_2_output = [recommendations_model_2['tracks'][i]['uri'] for i in range (num_recs)]

    return recommendations_model_2_output

def vote_error(song_features):    
    danceability = song_features[0]
    energy = song_features[1]
    speechiness = song_features[2]
    acousticness = song_features[3]
    instrumentalness = song_features[4]
    valence = song_features[5]

    danceability_error = np.sum([(k-danceability)**2 for k in df_final_standardized['danceability']])
    energy_error = np.sum([(k-energy)**2 for k in df_final_standardized['energy']])
    speechiness_error = np.sum([(k-speechiness)**2 for k in df_final_standardized['speechiness']])
    acousticness_error = np.sum([(k-acousticness)**2 for k in df_final_standardized['acousticness']])
    instrumentalness_error = np.sum([(k-instrumentalness)**2 for k in df_final_standardized['instrumentalness']])
    valence_error = np.sum([(k-valence)**2 for k in df_final_standardized['valence']])

    error = danceability_error + energy_error + speechiness_error + acousticness_error + instrumentalness_error + valence_error

    return error
