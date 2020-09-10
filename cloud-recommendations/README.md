# Cloud Recommendations

The code here was hosted on Google Cloud Platform and deployed as a Cloud Function to respond to HTTP requests from the Jashan mobile application with song recommendations for the group.

## Recommendation Algorithm

Jashan uses the upvotes and downvotes of users in a party to generate song recommendations that appeal to the entire group. This is a way for people to discover songs at the intersection of their music tastes. Here is a brief outline of the algorithm:

For each user in the party:

- Get the user's  5 most recently upvoted/added songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save danceability, energy, speechiness, acousticness, instrumentalness, and valence of each of these new songs in a dataframe (df_final_standardized). Each of these 6 features are in the interval [0,1], and for the sake of brevity, we will refer to them as d, e, s, a, i, and v for the rest of this section.
 
 - Get the user's  5 most recently downvoted songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save 1-d, 1-e, 1-s, 1-a, 1-i, and 1-v of each of these new songs in df_final_standardized. This way, we essentially record the inverses of the songs. ***
 
Then, calculate the average d, e, s, a, i, and v of all songs in the dataframe.

Next, using the [Nelder–Mead method](https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method), iteratively change the values of d, e, s, a, i, and v to minimize the error. The error is defined as the sum of squared differences between the current values of the six features and each of the entries in df_final_standardized. 

<img src="https://render.githubusercontent.com/render/math?math=\text{Error} = \displaystyle \sum_{\text{entry} \in \text{df_final_standardized}}((d_{\text{current}}-d_{\text{entry}})^2 + (e_{\text{current}}-e_{\text{entry}})^2 + (s_{\text{current}}-s_{\text{entry}})^2">

Feed the final optimized values of d, e, s, a, i, and v (along with 5 randomly chosen songs from df_final_standardized as seeds) into the Spotify recommendation engine to generate 100 new songs for the entire group. This is the final output of the algorithm.


*** The motivation behind treating inverses of downvoted songs as upvoted songs instead of simply subtracting their squared differences when calculating the error is that all points (d, e, s, a, i, v) describing the features of a song come from a 6-dimensional unit _hypercube_. As a result, if we incentivize the algorithm to get as far away from downvoted songs as possible, it will always just end up at one of the corners of the hypercube, which is not good.
