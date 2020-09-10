# Cloud Recommendations

The code here was hosted on Google Cloud Platform and deployed as a Cloud Function to respond to HTTP requests from the Jashan mobile application with song recommendations for the group.

## Recommendation Algorithm

Jashan uses the upvotes and downvotes of users in a party to generate song recommendations that appeal to the entire group. This is a way for people to discover songs at the intersection of their music tastes. Here is a brief outline of the algorithm:

1) For each user in the party:
  a) Get the user's  5 most recently upvoted/added songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save danceability, energy, speechiness, acousticness, instrumentalness, and valence of each of these new songs in a dataframe.
  b) Get the user's  5 most recently downvoted songs (or less if there aren't 5 yet) and feed them into Spotify's recommendation engine to generate 5 new songs. Save 1-danceability, 1-energy, 1-speechiness, 1-acousticness, 1-instrumentalness, and 1-valence of each of these new songs in a dataframe. This way, we essentially record the inverses of the songs.

