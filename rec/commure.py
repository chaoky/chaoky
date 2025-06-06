import asyncio
from itertools import batched
import json
from typing import TypedDict, cast
from urllib.request import urlopen


async def mkRequest(url: str):
    def blocking_fetch() -> object:
        with urlopen(url) as response:
            return json.load(response)

    response = await asyncio.to_thread(blocking_fetch)
    return response


class LeaderboardUser(TypedDict):
    username: str


class Leaderboard(TypedDict):
    users: list[LeaderboardUser]


async def getOneLeaderboard(nb: int, perfType: str):
    url = f"https://lichess.org/api/player/top/{nb}/{perfType}"
    response = await mkRequest(url)
    return cast(Leaderboard, response)


class RatingHistory(TypedDict):
    name: str
    points: list[tuple[int, int, int, int]]  # [year, month, day, rating]


async def getRatingHistory(username: str):
    url = f"https://lichess.org/api/user/{username}/rating-history"
    response = await mkRequest(url)
    return cast(list[RatingHistory], response)


async def mkBunchRequests():
    leaderboard = await getOneLeaderboard(50, "classical")
    eachRating = (getRatingHistory(user["username"]) for user in leaderboard["users"])
    chunks = (asyncio.gather(*chunk) for chunk in batched(eachRating, 10))

    async def printPlayer(c: asyncio.Future[list[list[RatingHistory]]]):
        for things in await c:
            print(", ".join([t["name"] for t in things]))

    [await printPlayer(chunk) for chunk in chunks]


# Example usage
if __name__ == "__main__":
    asyncio.run(mkBunchRequests())

# An example of how to use requests
# resp = requests.get('https://httpbin.org/uuid')
# data = resp.json()
# print(data)


# You can use the Lichess API: https://lichess.org/api
# Do NOT use a wrapper library. Only use requests.


# Warmup: List the top 50 classical chess players. Just print their usernames.
def print_top_50_classical_players() -> None:
    pass


# Part 2: Print the rating history for the top chess player in classical chess for the las t 30 calendar days.
# This can be in the format: username, {today-29: 990, today-28: 991, etc}
def print_last_30_day_rating_for_top_player() -> None:
    pass


# Part 3: Create a CSV that shows the rating history for each of these 50 players, for the last 30 days.
# The CSV should have 51 rows (1 header, 50 players).
# The CSV should be in the same order of the leaderboard.
# The first column in the csv should be the username of the player.
# Columns afterward should be the player's rating on the specified date.
# A CSV could look like this:
# username,2022-01-01,2022-01-02,2022-01-03,.....,2022-01-31
# bob,1231,1158,1250,...,1290
# notagm,900,900,900,...,900


def generate_rating_csv_for_top_50_classical_players() -> None:
    pass
