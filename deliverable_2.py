################################################
############## RESEARCH QUESTION ###############
################################################
"""
Are some player’s valuation overexaggerated? (We can maybe look for outliers which do not correspond to the found correlations)
Does valuation always hinge on players’ performance proportionally?
Try coming up with some performance metrics and see the relationship between valuation and performance. 


Hypothesis:
- Players with higher goal-scoring rates have higher valuations (just an example, and easy to change)

Performance metrics:
-Goals scored per game
-Assists per game
-Minutes played
-Matches starting eleven
-Number of matches team captain
-Clean sheets (for goalkeepers) (!!We can leave goalkeepers out, since their value evaluation metrics do not correspond to those of other player positions)
-Age 
-Position (except goalkeeper since those have no goal and little to no assists)
-Foot
-Height

Datasets needed:
-players.csv (to combine player-ids to actual names, birthcountry(?), age, position, foot, height, market value, highest market value)
-game_lineups.csv (to get whether the player was starting and if he was team captain (maybe redundant))
-appearances.csv (for each player appearance we get goals, assists, minutes_played)
-clubs.csv (to combine club-id to actual club names) (needed?)
"""

#################################################
############## PREPROCESSING CODE ###############
#################################################
import pandas as pd

# Load datasets
players = pd.read_csv('archive/players.csv')
lineups = pd.read_csv('archive/game_lineups.csv')
appearances = pd.read_csv('archive/appearances.csv')
clubs = pd.read_csv('archive/clubs.csv')

"""
We can combine lineups with appearances, since those are match based and we add a number of appearances column to the players dataset
First we clean and preprocess the separate datasets:

Look for contradictions in the datasets lineups and appearances

We join datasets on game_id and player_id, but first we inspect the datafra
"""
print(appearances.isna().sum())
print(lineups.isna().sum())

print(lineups.shape, appearances.shape) #(2191911, 10) (1578761, 13)
game_stats_na = lineups.merge(appearances, how='inner', on=['player_id', 'game_id'])
print(game_stats_na.info())

game_stats_na['player_name_y'] = game_stats_na['player_name_y'].fillna(game_stats_na['player_name_x'])
game_stats = game_stats_na
print(game_stats.info())

"""Since date and player name should also be the same for both datasets we can look for contradictions now we have resolved all null values"""

contradicting_dates_count = (game_stats['date_x'] != game_stats['date_y']).sum()

print(f"Number of rows with non-matching dates: {contradicting_dates_count}")

contradicting_names_count = (game_stats['player_name_x'] != game_stats['player_name_y']).sum()

print(f"Number of rows with non-matching names: {contradicting_names_count}")


"""The data contains no contradictions for the dates, however it does contain 31986 contradictions for the names"""

contradicting_names = game_stats[game_stats['player_name_x'] != game_stats['player_name_y']]
print(f"Unique contradicting names: {contradicting_names[['player_name_x', 'player_name_y']].nunique()}")

# We have 640 unique names that are contradicting

char_replacement = {
    '-': ' ',
    'ö': 'o',
    'ó': 'o',
    'ò': 'o',
    'í': 'i',
    'é': 'e',
    'ä': 'a',
    'ü': 'u',
    'ß': 'ss',
    'å': 'a',
    'ø': 'o',
    'ñ': 'n',
    'ç': 'c',
    'œ': 'oe',
    'æ': 'ae',
    'ė': 'e',
    'ż': 'z',
    'ł': 'l',
    'č': 'c',
    'ś': 's',
    'ź': 'z',
    'ñ': 'n',
    'ã': 'a',
    'į': 'i',
    'š': 's',
    'ž': 'z',
    'đ': 'd',
    'ć': 'c',
    'ț': 't',
    'ğ': 'g',
    'ş': 's',
    'î': 'i',
    'ă': 'a',
    'Ș': 'S',
    'Ț': 'T',
    'İ': 'I',
    'ı': 'i',
    'ё': 'e',
    'й': 'i',
    'ю': 'u',
    'я': 'ya',
    'ë': 'e',
    'ș': 's',
    'ţ': 't',
    'ï': 'i',

}

def replace_special_chars(text, replacements):
    for special_char, normal_char in replacements.items():
        text = text.lower().replace(special_char, normal_char)
    return text

game_stats['player_name_x'] = game_stats['player_name_x'].apply(replace_special_chars, args=(char_replacement,))
game_stats['player_name_y'] = game_stats['player_name_y'].apply(replace_special_chars, args=(char_replacement,))

contradicting_names_count = (game_stats['player_name_x'] != game_stats['player_name_y']).sum()
contradicting_names = game_stats[game_stats['player_name_x'] != game_stats['player_name_y']]
print(f"Number of rows with non-matching names: {contradicting_names_count}")
print(contradicting_names[['player_name_x', 'player_name_y']].nunique())

"""
After cleaning capitals and special characters we still have 166 contradictions left. After 
inspection we can conclude these contradictions are regarding the inclusion of middle names,
no first name or no second name, since these do not directly affect our results we have chosen 
to make player_name_x the leading column since it is the most inclusive
"""

game_stats_cleaned = game_stats.drop(['player_name_y', 'date_y'], axis=1).rename(columns={'player_name_x':'player_name', 'date_x':'date'})
# print(game_stats_cleaned)

"""We now can look for conflicts, like duplicate entries"""

duplicates = appearances.duplicated(subset=['player_id', 'game_id'], keep=False)
duplicate_entries = appearances[duplicates]

"""No duplicate entries found"""

appearance_counts = game_stats_cleaned.groupby('player_id')['player_id'].count().reset_index(name='count')
result_players = pd.merge(players, appearance_counts, on='player_id', how='left')

"""
Since we are interested in the market value we can remove all players for which we do not have an appearance count,
since those players are not included in the metrics dataset
"""

result_players_clean = result_players.dropna(axis=0, how='any')
# print(result_players_clean.head(50))


game_stats_cleaned.to_csv('clean/game_stats_cleaned.csv')
result_players_clean.to_csv('clean/result_players_clean.csv')

