# Cloud Recommendations

The code here was hosted on Google Cloud Platform and deployed as a Cloud Function to respond to HTTP requests from the Jashan mobile application with song recommendations for the group.

## Recommendation Algorithm

Jashan uses the upvotes and downvotes of users in a party to generate song recommendations that appeal to the entire group. This is a way for people to discover songs at the intersection of their music tastes. Here is a brief outline of the algorithm:

For each user in the party:

- Get the user's  5 most recently upvoted/added songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save danceability, energy, speechiness, acousticness, instrumentalness, and valence of each of these new songs in a dataframe (df_final_standardized). Each of these 6 features are in the interval [0,1].
 
 - Get the user's  5 most recently downvoted songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save 1-danceability, 1-energy, 1-speechiness, 1-acousticness, 1-instrumentalness, and 1-valence of each of these new songs in df_final_standardized. This way, we essentially record the inverses of the songs. ***
 
Then, calculate the average danceability, energy, speechiness, acousticness, instrumentalness, and valence of all songs in the dataframe. In this README, we will refer to these features as d, e, s, a, i, and v for the sake of brevity.

Next, using the [Nelder–Mead method](https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method), iteratively change the values of d, e, s, a, i, and v to minimize the error. The error is defined as the sum of squared differences between the current values of the six features and each of the entries in df_final_standardized. In other words,

<img src="https://render.githubusercontent.com/render/math?math=\text{Error} = \sum_{\text{entry} \in \text{df_final_standardized}}((d_{\text{current}}-d_{\text{entry}})^2)">


*** The motivation behind treating inverses of downvoted songs as upvoted songs instead of simply subtracting
