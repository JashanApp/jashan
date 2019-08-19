import sys
import spotipy
import spotipy.util as util

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
    
def get_recs(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    
    request_json = request.get_json()
    
    token = request_json['token']

    upvotes_for_user = request_json['upvotes_for_user']

    all_upvotes = [[]]
    usernames = upvotes_for_user.keys()
    for user, tracks in upvotes_for_user.items():
        for track in tracks:
            upvote = [user, track]
            all_upvotes.append(upvote)

    df = pd.DataFrame(all_upvotes, columns = ['username', 'trackid'])
    df = df.iloc[1:]
    print(df.to_string())
    
    recs = final_list(df, token, usernames)
    return str(recs)
    '''

    if request.args and 'message' in request.args:
        return request.args.get('message')
    elif request_json and 'message' in request_json:
        return request_json['message']
    else:
        return f'Hello World!'
    '''

def final_list(input_df, token, usernames):
    users = usernames
    spot = spotipy.Spotify(auth=token)
    df_final = pd.DataFrame(columns = ['username', 'trackid', 'danceability', 'energy', 'speechiness', 'acousticness', 'instrumentalness', 'valence'])
    
    # Now, we can actually get the audio features for the various tracks
    df_final.reset_index() # safety first!
    count = 0
    for index, row in input_df.iterrows():
        track_audio_features = spot.audio_features(row['trackid'])[0] # take first element (which is a dict) since we are only inputting one song into audio features function
        new_row = [row['username'], row['trackid'], track_audio_features['danceability'], track_audio_features['energy'], track_audio_features['speechiness'], track_audio_features['acousticness'], track_audio_features['instrumentalness'], track_audio_features['valence']]
        df_final.loc[count] = new_row
        count = count + 1

    # Data frame for storing all the recommended songs for each user
    df_final_standardized = pd.DataFrame(columns = ['username', 'trackid', 'danceability', 'energy', 'speechiness', 'acousticness', 'instrumentalness', 'valence'])
    count = 0
    for user in users:
        user_tracks = df_final[df_final.username == user]['trackid'].tolist() # get the user's tracks
        user_5_recs = spot.recommendations(seed_tracks = user_tracks, limit = 5) # get 5 recommendations for the tracks
        user_5_recs_output = [user_5_recs['tracks'][i]['uri'] for i in range (5)] # get the recommendations' track URI's
        user_5_recs_audio_features = spot.audio_features(user_5_recs_output)
        for i in range (5):
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

    # randomly select 5 tracks as seeds from the dataframe
    seeds = df_final_standardized['trackid'].sample(5).tolist()

    # get the recommendations
    num_recs = 100
    recommendations_model_2 = spot.recommendations(seed_tracks = seeds, target_danceability = avg_danceability, target_energy = avg_energy, target_speechines = avg_speechiness, target_acousticness = avg_acousticness, target_instrumentalness = avg_instrumentalness, target_valence = avg_valence,  limit = num_recs)
    recommendations_model_2_output = [recommendations_model_2['tracks'][i]['uri'] for i in range (num_recs)]

    return recommendations_model_2_output